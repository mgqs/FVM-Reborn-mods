#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
FVM-Reborn 授权码发放机器人 —— QQ 官方机器人（QQ 开放平台）版

和 NapCat 版的区别
------------------
官方机器人拿到的是 **openid**，不是 QQ 号（平台设计如此，改不了）。
所以账本的主键从「QQ 号」换成了「openid」——效果一样：一个 QQ 账号一个
openid，腾讯侧给的、伪造不了、只发一次。

接入方式是 WebSocket 长连接（主动出站连腾讯），**不需要公网 IP、不需要域名、
不需要备案**，符合"不用服务器"的前提。

启动
----
    set QQ_APP_ID=你的AppID
    set QQ_APP_SECRET=你的AppSecret
    python bot.py

    python bot.py --check     # 只校验 AppID/AppSecret 和网关，不连 WS

    QQ_SANDBOX=1              # 走沙箱域名（未上架时用）

玩家怎么用
----------
    私聊机器人发  #授权      → 直接私聊回码（推荐，码不外泄）
    群里 @机器人 发 #授权    → 机器人回"请私聊我"，不发码

为什么群里不发码：码是自证票据，谁拿到谁都能激活，群里发等于送给全群。
详见 docs/QQ号校验与授权方案.md 第 12 章。
"""

import asyncio
import json
import os
import sys
import time
import urllib.error
import urllib.request

# ── 让脚本能 import 到 tools/qq_auth.py（复用同一个账本，不重复实现密码学）──
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
sys.path.insert(0, os.path.join(ROOT, "tools"))
import qq_auth  # noqa: E402

# ────────────────────────────── 配置 ──────────────────────────────
# 优先级：环境变量 > bots/qq_auth_bot/config.json > 默认值
# config.json 已在 .gitignore 里（含 AppSecret，不能进公开仓库）
# 模板见同目录 config.example.json

CONFIG_PATH = os.path.join(HERE, "config.json")


def _load_config():
    if not os.path.exists(CONFIG_PATH):
        return {}
    try:
        with open(CONFIG_PATH, "r", encoding="utf-8") as fh:
            data = json.load(fh)
        return data if isinstance(data, dict) else {}
    except Exception as exc:
        print("⚠️  读 config.json 失败（%s），改用环境变量" % exc)
        return {}


_CFG = _load_config()


def _conf(env_key, cfg_key, default=""):
    v = os.environ.get(env_key)
    if v is None or str(v).strip() == "":
        v = _CFG.get(cfg_key, default)
    return str(v if v is not None else default).strip()


def _flag(env_key, cfg_key, default="0"):
    v = _conf(env_key, cfg_key, default).lower()
    return v in ("1", "true", "yes", "on")


def _int(env_key, cfg_key, default):
    """读整数配置。写错了就用默认值，别让整个机器人起不来。"""
    raw = _conf(env_key, cfg_key, str(default))
    try:
        return int(str(raw).strip())
    except (TypeError, ValueError):
        print("⚠️  配置 %s=%r 不是整数，改用默认值 %s" % (cfg_key, raw, default))
        return int(default)


APP_ID = _conf("QQ_APP_ID", "app_id")
APP_SECRET = _conf("QQ_APP_SECRET", "app_secret")
SANDBOX = _flag("QQ_SANDBOX", "sandbox")

AUTH_COMMAND = _conf("AUTH_COMMAND", "auth_command", "#授权")
LOOKUP_COMMAND = _conf("LOOKUP_COMMAND", "lookup_command", "查码")


def _cmd_variants(configured, word):
    """同一个命令同时接受 # 和 / 两种前缀。

    官方 QQ 里两种都能用，玩家记混了不该没反应；
    配置里写的那个排在最前，用于提示文案。
    """
    out = []
    for c in (configured, "#" + word, "/" + word):
        if c and c not in out:
            out.append(c)
    return out


AUTH_CMDS = _cmd_variants(AUTH_COMMAND, "授权")
LOOKUP_CMDS = _cmd_variants(LOOKUP_COMMAND, "查码")


# ────────────────────────── 管理员解绑 ──────────────────────────
# 官方 QQ 机器人**只给 openid，拿不到真实 QQ 号**（平台设计，无接口可换），
# 所以「必须是 QQ 1017443780 本人」这件事没法直接校验 —— 事件里根本没有 QQ 号。
#
# 落地方式：一次性口令认领
#   1. 你把 AUTH_ADMIN_TOKEN 私下发给管理员本人（别发群里）
#   2. 他私聊机器人发一次：  /管理绑定 <口令>
#   3. 机器人把他的 openid 写进账本白名单，口令当场作废
#   4. 白名单一旦非空，任何人的再次认领都会被静默拒绝 → 永久锁死在这一个人
#   5. 之后只有这个 openid 能 /解绑，其他人发同样的命令**得不到任何回复**
#
# ADMIN_QQ 只用于文案提示和人工核对，**不参与鉴权**。
ADMIN_TOKEN = _conf("AUTH_ADMIN_TOKEN", "admin_token", "")
ADMIN_QQ = _conf("ADMIN_QQ", "admin_qq", "1017443780")

ADMIN_CLAIM_CMDS = _cmd_variants("管理绑定", "管理绑定")
UNBIND_UID_CMDS = _cmd_variants("解绑账号", "解绑账号")   # 必须排在 UNBIND_CMDS 前面解析
UNBIND_CMDS = _cmd_variants("解绑", "解绑")
# 2026-11 起 /绑定列表 改名为 /绑定数量，只回数量不回明细。
# 旧命令保留成别名（同样只回数量），免得管理员按老习惯发过来时以为命令失效。
LIST_CMDS = _cmd_variants("绑定数量", "绑定数量")
LIST_ALIAS_CMDS = _cmd_variants("绑定列表", "绑定列表")
WHOAMI_CMDS = _cmd_variants("我是谁", "我是谁")
EXEMPT_CMDS = _cmd_variants("豁免", "豁免")           # 手动把某成员加入免踢名单
UNBLACK_CMDS = _cmd_variants("解黑", "解黑")          # 从群黑名单里放出来
PENDING_CMDS = _cmd_variants("待清理", "待清理")       # 看下一轮会被踢谁
QUERY_CMDS = _cmd_variants("查询", "查询")             # 看 N 小时内会被清理的人（默认 24 小时）

# 群里是否直接发码。码已经和机器码绑定，群发也拿不走，
# 所以默认允许（1）；想只走私聊就设 0。
ALLOW_GROUP_ISSUE = _flag("ALLOW_GROUP_ISSUE", "allow_group_issue", "1")

# 打印每个收到的事件（排查"机器人没反应"时开）
TRACE = _flag("QQ_TRACE", "trace", "0")

# 正式 / 沙箱两套域名
API_BASE = "https://sandbox.api.sgroup.qq.com" if SANDBOX else "https://api.sgroup.qq.com"
TOKEN_URL = "https://bots.qq.com/app/getAppAccessToken"

# Intents：
#   1 << 25  GROUP_AND_C2C_EVENT   群里 @ 机器人 + 单聊消息
#   1 << 24  GROUP_MEMBER_EVENT    群成员加入/退出（新功能要登记新人，必须订阅）
# 只加 1<<24 不影响原有 @ 消息链路；群消息全量模式（GROUP_MESSAGE_CREATE）
# 也在这个 intent 里推，但要到群设置里开「接收所有消息」才真的有数据。
INTENTS = (1 << 25) | (1 << 24)

RECONNECT_MAX = 5           # 连续失败几次就停，别无限重试（会被风控盯上）
MSG_SEQ = {}                # msg_id -> 已用过的 msg_seq

# ────────────────────── 群成员清理（3 天未绑定 / 7 天未发言）──────────────────────
# 规则
#   1. 新人入群 3 天还没绑定授权码 → 踢出 + 拉黑
#   2. 7 天没发过言 → 踢出 + 拉黑（已绑定的也照样处理，这是用户明确要求）
#   3. 踢出前 1 小时 @ 他提示一次
#   4. 群昵称里含「留」字的人永不踢（用户指定的豁免标记）
#
# 豁免为什么看群昵称
# ------------------
# 平台没有「这个成员有没有设群昵称」这样的字段，只有一个 username。
# 但它返回的就是群里显示的那个名字 —— 所以让想留名额的人把群昵称改成
# 带「留」字（例：小明-留），机器人看到 username 里有「留」就跳过。
# 这样不需要申请任何新接口，也不依赖未验证的接口行为。
EXEMPT_MARKS = [m.strip() for m in
                _conf("EXEMPT_MARKS", "exempt_marks", "留").split(",") if m.strip()]
EXEMPT_OPENIDS = [m.strip().upper() for m in
                  _conf("EXEMPT_OPENIDS", "exempt_openids", "").split(",") if m.strip()]

KICK_NO_AUTH_DAYS = _int("KICK_NO_AUTH_DAYS", "kick_no_auth_days", 3)
KICK_IDLE_DAYS = _int("KICK_IDLE_DAYS", "kick_idle_days", 7)
WARN_BEFORE_SEC = _int("WARN_BEFORE_SEC", "warn_before_sec", 3600)
# dry_run：只算名单、只发警告，不真踢（权限没下来 / 想先看误判率时用）
# mute   ：踢不动时退而求其次，给 30 天禁言
# remove ：真踢 + 拉黑
KICK_MODE = (_conf("KICK_MODE", "kick_mode", "dry_run") or "dry_run").strip().lower()
KICK_WITHOUT_WARN = _flag("KICK_WITHOUT_WARN", "kick_without_warn", "1")
BLACKLIST_EXPIRE_DAYS = _int("BLACKLIST_EXPIRE_DAYS", "blacklist_expire_days", 0)
# 已绑定的人要不要也按 7 天未发言清理（用户要求：要）
KICK_BOUND_IDLE = _flag("KICK_BOUND_IDLE", "kick_bound_idle", "1")
GROUP_OPENID = _conf("GROUP_OPENID", "group_openid", "")
# 踢人成功后要不要顺带调官方的群黑名单接口（POST /member_blacklist）。
# 那个接口还在内邀（11253），默认关；开了也不会致命 —— 失败只记日志。
# 我们自己的 members.json 黑名单始终生效，/解黑 只改自己那份。
PUSH_QQ_BLACKLIST = _flag("PUSH_QQ_BLACKLIST", "push_qq_blacklist", "0")

# ────────────────────────────── 文案 ──────────────────────────────
# 注意：这些字会显示在 QQ 里，走 QQ 自带字体，不用担心游戏字体缺字

MSG_CODE = (
    "授权码（已绑定你这台机器，别人拿去也用不了）：\n"
    "{code}\n"
    "\n"
    "游戏 → 右上角授权 → 粘贴上面这串。\n"
    "换电脑或重装系统后，识别码会变，需要重新领一次。"
)

MSG_NEED_HWID = (
    "领码需要你的「本机识别码」，这样码只在你机器上有效。\n"
    "\n"
    "获取方式：打开游戏，启动时弹出的授权窗口里会显示识别码，点一下即可复制\n"
    "然后这样发给我：\n"
    "{cmd} XXXX-XXXX"
)

MSG_BAD_HWID = (
    "识别码不对，应该是 8 位字母数字（像 1A2B-3C4D）。\n"
    "在游戏授权窗口里点一下识别码就能复制，直接粘过来。"
)

MSG_GREETING = (
    "发送 {cmd} 加你的本机识别码即可领取授权码。\n"
    "例：{cmd} 1A2B-3C4D\n"
    "（识别码在游戏启动时弹出的授权窗口里，点一下就能复制）\n"
    "\n"
    "想知道自己会不会被清理、怎么拿豁免，发：/豁免"
)

MSG_GROUP_HINT = (
    "领码请带上本机识别码：{cmd} XXXX-XXXX\n"
    "（识别码在游戏启动时弹出的授权窗口里点一下就能复制）\n"
    "查自己的豁免状态：/豁免"
)

MSG_POOL_EMPTY = "授权码暂时发完了，请联系管理加码后再领。"
# 到上限就是硬拒绝：不提任何解绑/重领的办法，避免玩家觉得"磨一磨就能换"
MSG_TOO_MANY = (
    "这个 QQ 已经绑满 {n} 台机器，不能再领新码了。\n"
    "授权码一发出就和机器绑定，不能转移也不能重领。"
)
MSG_ERROR = "发码出错了，请联系管理。"

# ── 管理员文案（只有管理员本人会看到）──
MSG_WHOAMI = "你的 openid：\n{uid}\n（只发给你自己，别人看不到）"

MSG_ADMIN_NO_TOKEN = "管理员口令还没配置，先让维护者设 AUTH_ADMIN_TOKEN。"

MSG_ADMIN_BAD_TOKEN = "口令不对。"

MSG_ADMIN_CLAIMED = (
    "已把当前账号设为唯一管理员（对应 QQ {qq}）。\n"
    "口令已作废，之后只有这个账号能解绑。\n"
    "\n"
    "可用命令：\n"
    "/解绑 <识别码或码ID>   解绑单台机器\n"
    "/解绑账号 <openid前缀> 解绑某人名下全部机器\n"
    "/绑定数量              看当前绑定了多少台\n"
    "/待清理                看下一轮会被清退谁\n"
    "/查询 [小时]           看 N 小时内会被清理的人（默认 24）\n"
    "/豁免 <openid前缀>     加入免踢名单\n"
    "/解黑 <openid前缀>     从黑名单放出来"
)

MSG_ADMIN_UNBIND_USAGE = (
    "用法：/解绑 CF8A-EFFE   或   /解绑 ACEF3YL5\n"
    "（识别码 8 位十六进制，码 ID 在授权码第一段）"
)

MSG_ADMIN_NOT_FOUND = "账本里没有 {x}，检查一下有没有抄错。"

MSG_ADMIN_UNBOUND = (
    "已解绑。\n"
    "识别码：{hwid}\n"
    "码 ID：{code_id}\n"
    "原账号：{owner}…\n"
    "\n"
    "对方现在可以重新领码（占一个名额）。\n"
    "注意：他旧机器上的游戏仍然是已授权状态，除非删掉那边的 auth.dat。"
)

MSG_ADMIN_UID_USAGE = "用法：/解绑账号 5D253F99（openid 前 8 位就够）"

MSG_ADMIN_UID_AMBIGUOUS = "匹配到 {n} 个账号，多发几位 openid。"

MSG_ADMIN_UID_EMPTY = "没有这个账号：{x}"

MSG_ADMIN_UID_DONE = (
    "已解绑该账号名下 {n} 台机器。\n"
    "{hwids}\n"
    "对方现在可以重新领码。"
)

MSG_ADMIN_LIST_HEAD = "绑定记录：共 {n} 台"

# ── 新的 /绑定数量：只回一个数，绝不贴 openid 和明细 ──
MSG_ADMIN_COUNT = "绑定数量：{n} 台"

MSG_ADMIN_PENDING_EMPTY = "当前没有被清退的对象。"

MSG_ADMIN_PENDING = (
    "下一轮待清理：{n} 人\n"
    "{lines}"
)

# ── /查询：按「还剩多久」筛人，默认看 1 天内会消失的 ──
MSG_ADMIN_QUERY_EMPTY = "{hours} 小时内没有被清理的人。"
MSG_ADMIN_QUERY = (
    "{hours} 小时内会被清理：{n} 人\n"
    "{lines}"
)
MSG_ADMIN_QUERY_USAGE = (
    "用法：/查询 或 /查询 48\n"
    "（不带参数看 24 小时内，也可以报小时数）"
)

MSG_ADMIN_EXEMPT_USAGE = "用法：/豁免 5D253F99（openid 前 8 位就够，也可以直接报群昵称）"

# ── /豁免 不带参数：谁都能查自己有没有豁免（群里也能用）──
# 普通玩家最常问的两句是「我会不会被踢」和「怎么才不被踢」，
# 与其让他们等 1 小时前的警告，不如让他们随时能自己查。
MSG_EXEMPT_SELF_YES = (
    "你有豁免，不会被自动清理。\n"
    "原因：{reason}"
)

MSG_EXEMPT_SELF_NO = (
    "你目前没有豁免。\n"
    "{deadline_line}\n"
    "\n"
    "三种拿到豁免的办法，任选一种：\n"
    "1）把群昵称改成带「{mark}」字的，改完下一轮巡检就生效\n"
    "2）在群里说一句话（每次发言都会重置「{idle} 天未发言」的倒计时）\n"
    "3）找管理员，让他私聊发：/豁免 {short}"
)

MSG_EXEMPT_SELF_UNKNOWN = (
    "成员表里还没有你的记录。\n"
    "（机器人上线前就在群的人，第一次说话才会被登记）\n"
    "\n"
    "想要豁免，把群昵称改成带「{mark}」字的就行，或者找管理员。"
)

MSG_ADMIN_EXEMPT_DONE = "已加入免踢名单：{mid}…"
MSG_ADMIN_EXEMPT_NONE = "成员表里没找到：{x}"

MSG_ADMIN_EXEMPT_LIST = (
    "免踢名单：{n} 人\n"
    "{lines}"
)

MSG_ADMIN_UNBLACK_DONE = "已从黑名单放出：{n} 个"
MSG_ADMIN_UNBLACK_NONE = "黑名单里没有：{x}"

# ── 清理相关（发给被清理的人 / 群）──
MSG_WARN_NO_AUTH = (
    "{who}\n"
    "你加入本群 {days} 天还没绑定授权码，{hours} 小时后会被移出本群并拉黑。\n"
    "\n"
    "现在发这一句就能保住名额：\n"
    "    {cmd} XXXX-XXXX\n"
    "（识别码在游戏启动时弹出的授权窗口里，点一下即可复制）\n"
    "\n"
    "暂时不方便授权的，把群昵称改一下、带上「{mark}」字即可保留。"
)

MSG_WARN_IDLE = (
    "{who}\n"
    "你已经 {days} 天没在群里说过话，{hours} 小时后会被移出本群并拉黑。\n"
    "\n"
    "在群里随便说一句话就能保住名额。\n"
    "不方便发言的，把群昵称改一下、带上「{mark}」字即可保留。"
)

MSG_KICKED_NO_AUTH = "未在 {days} 天内绑定授权码，已移出并加入黑名单。"
MSG_KICKED_IDLE = "连续 {days} 天未发言，已移出并加入黑名单。"
MSG_MUTED_NO_AUTH = "未在 {days} 天内绑定授权码，已禁言。"
MSG_MUTED_IDLE = "连续 {days} 天未发言，已禁言。"

# 新成员入群提示（被动回复，借用 GROUP_ADD_ROBOT 之类事件的配额不足，
# 所以只在能拿到 msg_id 时发；拿不到就靠群公告）
MSG_WELCOME = (
    "欢迎新成员。\n"
    "本群需要绑定游戏授权码才能留下：{days} 天内发\n"
    "    {cmd} XXXX-XXXX\n"
    "（识别码在游戏授权窗口里点一下就能复制）\n"
    "\n"
    "暂时没法授权的，把群昵称改一下、带上「{mark}」字可保留名额。\n"
    "超过 {days} 天未绑定会被移出本群。"
)

MSG_C2C_REDIRECT = (
    "授权统一在群里办理。\n"
    "回群里 @我 发：{cmd} XXXX-XXXX\n"
    "查自己的豁免状态也是回群里发：/豁免"
)


# ────────────────────────────── 发码 ──────────────────────────────

def issue_for(uid, hwid, ledger=None):
    """返回 (code, is_new)。同一台机器永远只对应一个码。

    uid 归属修正
    ------------
    机器人早期的 uid_of() 优先取 union_openid，所以老记录里的 uid 可能是
    union 值；而群成员事件只有 member_openid。不修正的话，这些人永远被判定
    成「未绑定」，3 天一到就被误踢。

    命中已有机器时把 uid 改成现在这个（群内就是 member_openid）。改动只涉及
    「归属显示」，码本身已经和 hwid 绑死，不影响实际授权。
    """
    own = ledger is None
    if own:
        ledger = qq_auth.Ledger(qq_auth.DB_PATH)
    try:
        row = ledger.get_by_hwid(hwid)
        if row:
            if str(row[1]) != str(uid):
                ledger.put(uid, hwid, row[2], row[3])
                if hasattr(ledger, "audit_append"):
                    ledger.audit_append("uid_fix", "system", str(uid),
                                        "hwid=%s old=%s" % (hwid, str(row[1])[:12]))
            return row[3], False
        return qq_auth.issue_for(uid, hwid, ledger)
    finally:
        if own:
            ledger.close()


# ────────────────────────────── HTTP ──────────────────────────────

def _api(method, path, token, payload=None, timeout=15):
    """调 OpenAPI。返回 (status, dict)。"""
    data = None
    if payload is not None:
        data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        API_BASE + path,
        data=data,
        method=method,
        headers={
            "Authorization": "QQBot " + token,
            "Content-Type": "application/json",
            "X-Union-Appid": APP_ID,
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            body = resp.read().decode("utf-8", "replace")
            return resp.status, (json.loads(body) if body.strip() else {})
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", "replace")
        try:
            return exc.code, json.loads(body)
        except Exception:
            return exc.code, {"raw": body}


def get_access_token():
    """AppID + AppSecret 换 access_token（有效期约 7200 秒）。"""
    payload = json.dumps({"appId": APP_ID, "clientSecret": APP_SECRET}).encode("utf-8")
    req = urllib.request.Request(
        TOKEN_URL, data=payload, method="POST",
        headers={"Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req, timeout=15) as resp:
        body = json.loads(resp.read().decode("utf-8", "replace"))
    token = body.get("access_token")
    if not token:
        raise RuntimeError("取 access_token 失败：%s" % body)
    return token, int(str(body.get("expires_in", "7200")).strip() or 7200)


def get_gateway(token):
    status, body = _api("GET", "/gateway", token)
    if status >= 400 or "url" not in body:
        raise RuntimeError("取网关失败 %s：%s" % (status, body))
    return body["url"]


# ────────────────────────────── 发消息 ──────────────────────────────

def _next_seq(msg_id):
    """同一条消息多次回复要递增 msg_seq，否则会被去重丢掉。"""
    n = MSG_SEQ.get(msg_id, 0) + 1
    MSG_SEQ[msg_id] = n
    if len(MSG_SEQ) > 500:
        for k in list(MSG_SEQ)[:250]:
            MSG_SEQ.pop(k, None)
    return n


def send_c2c(token, openid, content, msg_id):
    return _api("POST", "/v2/users/%s/messages" % openid, token, {
        "content": content,
        "msg_type": 0,
        "msg_id": msg_id,
        "msg_seq": _next_seq(msg_id),
    })


def send_group(token, group_openid, content, msg_id):
    return _api("POST", "/v2/groups/%s/messages" % group_openid, token, {
        "content": content,
        "msg_type": 0,
        "msg_id": msg_id,
        "msg_seq": _next_seq(msg_id),
    })


def send_group_active(token, group_openid, content):
    """主动消息：没有 msg_id 可带（定时巡检不来自任何一条消息）。

    被动回复要求 msg_id 是某条真实消息的 id，巡检手里没有，只能发主动消息。
    主动消息有自己的频控（单群 20 条/分钟、每群每天 1000 条），
    所以 sweep 里每轮最多发 20 条，正好卡在上限内。
    """
    return _api("POST", "/v2/groups/%s/messages" % group_openid, token, {
        "content": content,
        "msg_type": 0,
    })


def _log_reply(kind, status, body, msg_id):
    """发消息的结果一定打出来。

    之前只在失败时打印，导致「发出去了但玩家没看到」和「压根没发」
    在日志里长得一样。成功也记一条，才能分清是哪一种。
    """
    ok = status < 400
    print("  [%s] %s status=%s msg_id=%s %s"
          % (kind, "✅" if ok else "❌", status, str(msg_id)[:16],
             "" if ok else json.dumps(body, ensure_ascii=False)[:200]))


# ────────────────────────────── 消息处理 ──────────────────────────────

def strip_mention(text):
    """去掉 <@!123> / <@123> / @机器人 这类前缀，再取命令词。

    2026-11 修：原来只吃掉 `<@!...>`（带感叹号）这一种。
    群消息里 @ 更常见的是 `<@openid>`（不带感叹号），旧实现会把 openid
    整串留在命令词前面，于是 `/授权` 变成 `<openid> /授权` 永远匹配不上，
    玩家看到的现象就是「@ 了机器人却毫无反应」。
    """
    t = text or ""
    while True:
        s = t.find("<@")
        if s < 0:
            break
        e = t.find(">", s)
        if e < 0:
            break
        t = t[:s] + t[e + 1:]
    t = t.replace("<@", "").replace(">", "")
    return t.strip()


# 全角标点归一：手机输入法很容易把 / # 打成 ／ ＃，
# 玩家看不出区别，代码里却匹配不上，表现就是「发了没反应」。
_FULLWIDTH_MAP = {
    ord("／"): "/", ord("＃"): "#", ord("＠"): "@",
    ord("　"): " ",
}


def _norm_cmd(plain):
    return (plain or "").translate(_FULLWIDTH_MAP)


def parse_command(text):
    """返回 (命令类别, 参数)。严格匹配，'#授权码给我' 不算。

    '#授权 1A2B-3C4D'  -> ('auth',   '1A2B3C4D')
    '/授权 1A2B-3C4D'  -> ('auth',   '1A2B3C4D')   # 前缀两种都认
    '#查码 1A2B-3C4D'  -> ('lookup', '1A2B3C4D')
    """
    plain = _norm_cmd(strip_mention(text))
    for cmds, kind in ((AUTH_CMDS, "auth"), (LOOKUP_CMDS, "lookup")):
        for cmd in cmds:
            if plain == cmd:
                return (kind, "")
            # 命令后面必须跟空白，否则 '#授权码' 会被误判成 '#授权'
            if plain.startswith(cmd) and len(plain) > len(cmd) and plain[len(cmd)] in (" ", "\u3000"):
                return (kind, plain[len(cmd):].strip())
    # 兜底：@ 了机器人但只发了一串识别码（'1145-CCBB'），也算 /授权。
    # 玩家从游戏里复制识别码直接粘到群里是常态，不会附带命令词。
    guess = plain.replace("-", "").replace(" ", "").upper()
    if _hwid_like(guess):
        return ("auth", plain)
    return None


def parse_admin_command(text):
    """解析管理员命令。返回 (kind, arg) 或 None。

    和 parse_command 一样，命令后面必须跟空白，避免 '/解绑账号' 被当成 '/解绑'。
    长的先试（解绑账号 在 解绑 之前）。
    """
    plain = _norm_cmd(strip_mention(text))
    table = (
        (ADMIN_CLAIM_CMDS, "claim"),
        (UNBIND_UID_CMDS, "unbind_uid"),
        (UNBLACK_CMDS, "unblack"),
        (UNBIND_CMDS, "unbind"),
        (LIST_CMDS, "list"),
        (LIST_ALIAS_CMDS, "list"),      # 旧命令 /绑定列表 保留成别名，同样只回数量
        (EXEMPT_CMDS, "exempt"),
        (PENDING_CMDS, "pending"),
        (QUERY_CMDS, "query"),
        (WHOAMI_CMDS, "whoami"),
    )
    for cmds, kind in table:
        for cmd in cmds:
            if plain == cmd:
                return (kind, "")
            if plain.startswith(cmd) and len(plain) > len(cmd) and plain[len(cmd)] in (" ", "\u3000"):
                return (kind, plain[len(cmd):].strip())
    return None


def _hwid_like(s):
    return (len(s) == qq_auth.HWID_LEN
            and all(c in qq_auth.HWID_CHARS for c in s))


def handle_admin(uid, kind, arg, ledger, members=None):
    """管理员命令。返回要回的内容，None = 不回。

    ledger 必须是带 admins/is_admin/admin_add/drop_hwid/drop_uid/audit_append
    的那套（scf/store.py）。本地 SQLite 版没有这些，会被 handle_message 挡在前面。

    members：可选的成员表（scf/members.py 的 Members）。/待清理、/豁免、/解黑
    需要它；不传时这几个命令回一句提示，其余命令照常。
    """
    uid = str(uid or "").strip()

    # 谁都可以问自己的 openid：只说给他自己，用来确认认领的是哪个身份
    if kind == "whoami":
        return MSG_WHOAMI.format(uid=uid)

    if kind == "claim":
        if not ADMIN_TOKEN:
            return MSG_ADMIN_NO_TOKEN
        if ledger.admins():
            # 已经有管理员 = 认领通道永久关闭，防止后来者顶掉
            print("  [管理] 拒绝重复认领 uid=%s（已有 %d 名管理员）"
                  % (uid[:12], len(ledger.admins())))
            return None
        if str(arg or "").strip().upper() != ADMIN_TOKEN.upper():
            print("  [管理] 口令错误 uid=%s" % uid[:12])
            return MSG_ADMIN_BAD_TOKEN
        ledger.admin_add(uid, ADMIN_QQ)
        ledger.audit_append("admin_claim", uid, uid, "首批管理员 QQ=%s" % ADMIN_QQ)
        print("  [管理] 已设为管理员 uid=%s" % uid[:12])
        return MSG_ADMIN_CLAIMED.format(qq=ADMIN_QQ)

    # /豁免 不带参数 = 任何人查自己的豁免状态。放在管理员闸门之前，
    # 所以普通群友也能用；它只读成员表，不改任何东西。
    if kind == "exempt" and not str(arg or "").strip():
        return exempt_self_text(uid, members)

    # ── 以下只给管理员；非管理员静默丢弃，不暴露这些命令存在 ──
    if not ledger.is_admin(uid):
        print("  [管理] 非管理员尝试 %s uid=%s（已忽略）" % (kind, uid[:12]))
        return None

    if kind == "list":
        # 2026-11 改版：只回数量。原来会列出每台的识别码 + openid 前缀，
        # 30 条消息刷满屏幕，管理员实际只想知道「一共绑了多少台」。
        return MSG_ADMIN_COUNT.format(n=ledger.count())

    if kind == "unbind":
        raw = str(arg or "").replace("-", "").replace(" ", "").upper()
        if not raw:
            return MSG_ADMIN_UNBIND_USAGE
        row = None
        if _hwid_like(raw):
            row = ledger.get_by_hwid(raw)
        if row is None:
            # 也可能报的是码 ID（授权码第一段），一起认
            row = ledger.get_by_code_id(raw)
        if row is None:
            return MSG_ADMIN_NOT_FOUND.format(x=raw)
        hwid, owner, code_id = row[0], row[1], row[2]
        ledger.drop_hwid(hwid)
        ledger.audit_append("unbind", uid, hwid, "code=%s owner=%s" % (code_id, str(owner)[:12]))
        print("  [解绑] %s -> hwid=%s owner=%s code=%s"
              % (uid[:12], hwid, str(owner)[:12], code_id))
        return MSG_ADMIN_UNBOUND.format(hwid=hwid, code_id=code_id,
                                        owner=str(owner)[:8])

    if kind == "unbind_uid":
        pref = str(arg or "").strip()
        if not pref:
            return MSG_ADMIN_UID_USAGE
        owners = {}
        for r in ledger.all():
            owners.setdefault(r[1], []).append(r[0])
        hits = [o for o in owners if o == pref or o.startswith(pref)]
        if not hits:
            return MSG_ADMIN_UID_EMPTY.format(x=pref)
        if len(hits) > 1:
            return MSG_ADMIN_UID_AMBIGUOUS.format(n=len(hits))
        victim = hits[0]
        hwids = owners[victim]
        n = ledger.drop_uid(victim)
        ledger.audit_append("unbind_uid", uid, victim, "count=%d" % n)
        print("  [解绑] %s -> uid=%s 共 %d 台" % (uid[:12], victim[:12], n))
        return MSG_ADMIN_UID_DONE.format(n=n, hwids="、".join(hwids))

    # ── 成员清理相关 ──
    if kind in ("pending", "exempt", "unblack", "query"):
        if members is None:
            return "成员表没接上，这个命令要云端 Webhook 版才可用。"

    if kind == "pending":
        rows = pending_report(members)
        if not rows:
            return MSG_ADMIN_PENDING_EMPTY
        lines = ["%d. %s  %s  %s" % (i, r["mid"][:8], r["name"] or "-", r["why"])
                 for i, r in enumerate(rows[:30], 1)]
        if len(rows) > 30:
            lines.append("（只显示前 30 个）")
        return MSG_ADMIN_PENDING.format(n=len(rows), lines="\n".join(lines))

    if kind == "query":
        raw = str(arg or "").strip()
        if raw:
            try:
                hours = int(raw)
            except ValueError:
                return MSG_ADMIN_QUERY_USAGE
            if hours <= 0:
                return MSG_ADMIN_QUERY_USAGE
        else:
            hours = 24
        rows = due_report(members, hours)
        if not rows:
            return MSG_ADMIN_QUERY_EMPTY.format(hours=hours)
        lines = ["%d. %s  %s  %s" % (i, r["mid"][:8], r["name"] or "-", r["why"])
                 for i, r in enumerate(rows[:30], 1)]
        if len(rows) > 30:
            lines.append("（只显示前 30 个）")
        return MSG_ADMIN_QUERY.format(hours=hours, n=len(rows), lines="\n".join(lines))

    if kind == "exempt":
        pref = str(arg or "").strip()
        if not pref:
            return MSG_ADMIN_EXEMPT_USAGE
        mid = _find_member(members, pref)
        if not mid:
            return MSG_ADMIN_EXEMPT_NONE.format(x=pref)
        members.set_exempt(mid, True, "admin:%s" % uid[:8])
        members.flush()
        ledger.audit_append("exempt", uid, mid, "manual")
        return MSG_ADMIN_EXEMPT_DONE.format(mid=mid[:8])

    if kind == "unblack":
        pref = str(arg or "").strip()
        if not pref:
            return "用法：/解黑 5D253F99（openid 前 8 位）"
        hits = members.blacklist_find(pref)
        if not hits:
            return MSG_ADMIN_UNBLACK_NONE.format(x=pref)
        for mid in hits:
            members.blacklist_del(mid)
            rec = members.get(mid)
            if rec is not None and rec.get("state") == "kicked":
                rec["state"] = "left"
        members.flush()
        ledger.audit_append("unblack", uid, ",".join(m[:8] for m in hits),
                            "n=%d" % len(hits))
        return MSG_ADMIN_UNBLACK_DONE.format(n=len(hits))

    return None


# ────────────────────── 清理判定（sweep 和 /待清理 共用一份逻辑）──────────────────────

def _has_exempt_mark(name):
    """群昵称里含约定字样即豁免。用户指定：含「留」就不踢。"""
    text = str(name or "")
    if not text:
        return ""
    for mark in EXEMPT_MARKS:
        if mark and mark in text:
            return mark
    return ""


def is_exempt(mid, rec):
    """返回豁免原因（空串 = 不豁免）。"""
    if not rec:
        return ""
    if rec.get("exempt"):
        return rec.get("exempt_by") or "manual"
    if str(mid).upper() in EXEMPT_OPENIDS:
        return "config"
    if str(rec.get("role") or "") in ("owner", "admin"):
        return "role:%s" % rec.get("role")
    mark = _has_exempt_mark(rec.get("name"))
    if mark:
        return "name:%s" % mark
    return ""


def deadline_of(rec, now=None):
    """返回 (截止时间戳, 规则名)。永不清理返回 (0, "")。

    未绑定：入群 3 天，或 7 天没发言，取早的那个
    已绑定：只看 7 天没发言（KICK_BOUND_IDLE 关掉则永不清理）
    """
    now = int(now or time.time())
    join_ts = int(rec.get("join_ts") or 0) or now
    last = int(rec.get("last_speak_ts") or 0) or join_ts
    idle_dl = last + KICK_IDLE_DAYS * 86400
    if rec.get("bound"):
        return (idle_dl, "idle") if KICK_BOUND_IDLE else (0, "")
    noauth_dl = join_ts + KICK_NO_AUTH_DAYS * 86400
    return (min(noauth_dl, idle_dl), "no_auth" if noauth_dl <= idle_dl else "idle")


def _first_mark():
    return EXEMPT_MARKS[0] if EXEMPT_MARKS else "留"


def _human_left(sec):
    """把剩余秒数说成人话：3 天 4 小时 / 2 天 / 5 小时 / 12 分钟。"""
    sec = int(sec)
    if sec <= 0:
        return "已经到点了"
    d, rem = divmod(sec, 86400)
    h = rem // 3600
    if d:
        return "%d 天 %d 小时" % (d, h) if h else "%d 天" % d
    if h:
        return "%d 小时" % h
    return "%d 分钟" % max(1, rem // 60)


def _exempt_reason_text(why):
    """把 is_exempt() 返回的内部原因翻译成玩家能看懂的话。"""
    why = str(why or "")
    if why == "config":
        return "管理员在名单里指定了你"
    if why.startswith("role:"):
        role = why.split(":", 1)[1]
        return "你是群主" if role == "owner" else "你是群管理员"
    if why.startswith("name:"):
        return "你的群昵称里带了「%s」字" % why.split(":", 1)[1]
    if why.startswith("admin:"):
        return "管理员手动给你开的（%s）" % why.split(":", 1)[1]
    if why == "manual":
        return "管理员手动给你开的"
    return why


def exempt_self_text(uid, members=None):
    """任何人 @ 机器人发 /豁免（不带参数），只回他自己的豁免状态。

    这是个只读查询，不碰账本、不改成员表，所以群里也能放心开放 ——
    否则玩家想知道自己会不会被踢，只能等到清理前 1 小时的警告。
    """
    uid = str(uid or "").strip()
    mark = _first_mark()
    if members is None:
        return "豁免查询暂时不可用（成员表没接上），请联系管理。"
    rec = members.get(uid)
    if rec is None:
        return MSG_EXEMPT_SELF_UNKNOWN.format(mark=mark)

    why = is_exempt(uid, rec)
    if why:
        return MSG_EXEMPT_SELF_YES.format(reason=_exempt_reason_text(why))

    now = int(time.time())
    dl, rule = deadline_of(rec, now)
    if not dl:
        line = "按现在的规则，你不会被自动清理。"
    elif dl <= now:
        line = ("按现在的规则，你已经到清理点了"
                "（%s），下一轮巡检就会处理。"
                % ("还没绑定授权码" if rule == "no_auth" else "很久没发言"))
    else:
        line = ("按现在的规则，你%s，%s后会被清理。"
                % ("还没绑定授权码" if rule == "no_auth" else "很久没发言",
                   _human_left(dl - now)))
    return MSG_EXEMPT_SELF_NO.format(
        deadline_line=line,
        mark=mark,
        idle=KICK_IDLE_DAYS,
        short=uid[:8],
    )


def sweep_plan(members, now=None):
    """算出这一轮要警告谁、要踢谁。纯函数，不动任何数据。

    返回 {"warn": [...], "kick": [...], "skip": [...]}
    """
    now = int(now or time.time())
    warn, kick, skip = [], [], []
    for mid, rec in members.members().items():
        state = str(rec.get("state") or "active")
        if state in ("left", "kicked"):
            skip.append({"mid": mid, "why": "state:%s" % state})
            continue
        why_ex = is_exempt(mid, rec)
        if why_ex:
            skip.append({"mid": mid, "why": "exempt:%s" % why_ex})
            continue
        dl, rule = deadline_of(rec, now)
        if not dl:
            skip.append({"mid": mid, "why": "no-deadline"})
            continue
        item = {
            "mid": mid,
            "name": rec.get("name") or "",
            "why": rule,
            "deadline": dl,
            "hours": max(1, int(round((dl - now) / 3600.0))),
        }
        if now >= dl:
            kick.append(item)
        elif now >= dl - WARN_BEFORE_SEC:
            if not rec.get("warned_at") or rec.get("warn_kind") != rule:
                warn.append(item)
            else:
                skip.append({"mid": mid, "why": "already-warned"})
        else:
            skip.append({"mid": mid, "why": "not-yet"})
    return {"warn": warn, "kick": kick, "skip": skip}


def pending_report(members, now=None):
    """/待清理 用：列出已经进入警告窗口和准备踢的人。"""
    plan = sweep_plan(members, now)
    rows = []
    for it in plan["warn"]:
        rows.append({"mid": it["mid"], "name": it["name"],
                     "why": "%s · 警告中 · 剩 %d 小时" % (it["why"], it["hours"])})
    for it in plan["kick"]:
        rows.append({"mid": it["mid"], "name": it["name"],
                     "why": "%s · 到点待踢" % it["why"]})
    return rows


def due_report(members, hours=24, now=None):
    """/查询 用：列出「还剩 hours 小时内会被清理」的人，按剩余时间从少到多排。

    和 /待清理 的区别：
      /待清理  只看「已经在警告窗口里（默认剩 1 小时）+ 已到点」的
      /查询 N  看「从现在起 N 小时内任何一个时刻会到点」的，窗口由你定

    所以 /查询 24 往往比 /待清理 多出一批人——那批人还没开始被告警，
    但你今天之内就会失去他们，提前知道才好决定要不要 /豁免。
    """
    now = int(now or time.time())
    limit = now + int(hours) * 3600
    rows = []
    for mid, rec in members.members().items():
        state = str(rec.get("state") or "active")
        if state in ("left", "kicked"):
            continue
        if is_exempt(mid, rec):
            continue
        dl, rule = deadline_of(rec, now)
        if not dl or dl > limit:
            continue
        left = dl - now
        if left <= 0:
            when = "已到点"
            hrs = 0
        elif left < 3600:
            when = "剩 %d 分钟" % max(1, int(round(left / 60.0)))
            hrs = 1
        else:
            hrs = max(1, int(round(left / 3600.0)))
            when = "剩 %d 小时" % hrs
        label = "未绑定" if rule == "no_auth" else "未发言"
        rows.append({
            "mid": mid,
            "name": rec.get("name") or "",
            "why": "%s · %s · %s" % (label, when, rule),
            "hours": hrs,
            "deadline": dl,
            "rule": rule,
        })
    rows.sort(key=lambda r: (r["deadline"], r["mid"]))
    return rows


def _find_member(members, key):
    """按 openid 前缀或群昵称找成员。管理员手里通常只有名字。"""
    key = str(key or "").strip()
    if not key:
        return ""
    for mid in members.members():
        if mid.upper().startswith(key.upper()):
            return mid
    hits = [mid for mid, rec in members.members().items()
            if str(rec.get("name") or "") == key]
    if len(hits) == 1:
        return hits[0]
    return ""


def mention_of(mid, name=""):
    """群内 @ 某人的写法。

    发送侧用 `<@openid>`：接收事件里 @ 就是被替换成这个形式的，
    发回去平台同样认识。拿不到 openid 才退回纯文本 @名字（不会真提醒，
    但至少文案读得通）。
    """
    mid = str(mid or "").strip()
    if mid:
        return "<@%s>" % mid
    return "@%s" % (name or "群成员")


def warn_text(item, cmd=None):
    """生成警告文案。不放 URL（平台会以 40054010 直接拒收）。"""
    mark = EXEMPT_MARKS[0] if EXEMPT_MARKS else "留"
    who = mention_of(item.get("mid"), item.get("name"))
    if item["why"] == "no_auth":
        return MSG_WARN_NO_AUTH.format(
            who=who,
            days=KICK_NO_AUTH_DAYS,
            hours=item["hours"],
            cmd=cmd or AUTH_COMMAND,
            mark=mark)
    return MSG_WARN_IDLE.format(
        who=who,
        days=KICK_IDLE_DAYS,
        hours=item["hours"],
        mark=mark)


def handle_message(uid, text, ledger=None):
    """返回要回的内容（None 表示不理）。

    ledger 传进来的话就用它（云端 COS 账本），不传就开本地 SQLite。
    管理员命令只有带 admins/is_admin 的账本才支持。
    """
    adm = parse_admin_command(text)
    if adm is not None:
        if ledger is not None:
            return handle_admin(uid, adm[0], adm[1], ledger)
        if hasattr(qq_auth.Ledger, "is_admin"):
            own = qq_auth.Ledger(qq_auth.DB_PATH)
            try:
                return handle_admin(uid, adm[0], adm[1], own)
            finally:
                own.close()
        # 本地 SQLite 账本没有管理员功能（云端才是生产环境）
        print("  [管理] 本地账本不支持管理员命令，请用云端 Webhook")
        return None

    parsed = parse_command(text)
    if parsed is None:
        return MSG_GREETING.format(cmd=AUTH_COMMAND) if strip_mention(text) == "" else None

    _cmd, arg = parsed
    hwid = qq_auth.norm_hwid(arg)
    if not arg:
        return MSG_NEED_HWID.format(cmd=AUTH_COMMAND)
    if not qq_auth.hwid_valid(hwid):
        return MSG_BAD_HWID

    try:
        code, is_new = issue_for(uid, hwid)
        print("  [发码] uid=%s hwid=%s new=%s code=%s"
              % (uid.replace(chr(10), "")[:12], hwid, is_new, code))
        return MSG_CODE.format(code=code)
    except qq_auth.PoolExhausted:
        return MSG_POOL_EMPTY
    except qq_auth.TooManyDevices as exc:
        print("  [上限] %s（玩家只会看到「绑满了」）" % exc)   # 仅日志可见
        return MSG_TOO_MANY.format(n=qq_auth.MAX_DEVICES_PER_UID)
    except Exception as exc:
        print("  [发码失败] uid=%s: %s" % (uid, exc))
        return MSG_ERROR


def uid_of(data, prefer="member"):
    """取稳定的用户标识。

    **群内一律用 member_openid。** 这是 2026-11 改过的地方，之前的顺序是
    union_openid 优先，结果是：群消息里 union_openid 有值就存了 union，
    而入群事件（GROUP_MEMBER_ADD）只给 member_openid，两边永远对不上，
    已经绑定的老玩家会被判定成「未绑定」然后被清理掉。

    单聊场景才用 user_openid（私聊里没有 member_openid）。
    现在授权只在群里做，私聊只回一句指引，所以不会产生新的 user_openid 记录。
    """
    author = data.get("author") or {}
    if prefer == "member":
        return (author.get("member_openid")
                or author.get("union_openid")
                or author.get("user_openid")
                or author.get("id")
                or "")
    return (author.get("user_openid")
            or author.get("union_openid")
            or author.get("member_openid")
            or author.get("id")
            or "")


# ────────────────────────────── 群管理接口 ──────────────────────────────

def group_api(path, token, payload=None, method="POST"):
    """群管理接口的统一入口。返回 (status, dict)。

    这几个接口都要机器人是**群管理员**；权限没下来时平台回 11253
    （应用无接口访问权限），调用方据此降级到禁言或只记日志。
    """
    return _api(method, path, token, payload)


def kick_members(group_openid, tokens, token=None):
    """批量移除群成员。单次最多 20 个。

    返回 (ok, status, body)。11253 = 接口还在内邀，调用方要退化处理。
    """
    tokens = [str(t).strip() for t in (tokens or []) if str(t).strip()][:20]
    if not tokens:
        return False, 0, {"error": "empty"}
    status, body = group_api(
        "/v2/groups/%s/batch_remove_members" % group_openid,
        token, {"members": tokens})
    return status < 400, status, body


def mute_members(group_openid, tokens, days=30, token=None, op="add"):
    """设置禁言。踢不动时的退路（需要机器人是群管理员）。单次最多 20 个。"""
    tokens = [str(t).strip() for t in (tokens or []) if str(t).strip()][:20]
    if not tokens:
        return False, 0, {"error": "empty"}
    payload = {"members": tokens, "op": op}
    if op in ("add", "update"):
        payload["mute_expire_at"] = time.strftime(
            "%Y-%m-%dT%H:%M:%S+08:00", time.localtime(time.time() + days * 86400))
    status, body = group_api(
        "/v2/groups/%s/restrict_chat_setting" % group_openid, token, payload)
    return status < 400, status, body


def blacklist_members(group_openid, tokens, token=None, op="add"):
    """群黑名单操作（QQ 官方接口）POST /v2/groups/{gid}/member_blacklist

    **两条硬前提**（官方文档明确写了）：
      1. 只能对「不在群里」的人操作 —— 所以顺序必须是先踢人、再拉黑。
         人还在群里时调 add，这个人会被放进 fail_openids。
      2. 这个接口同样在内邀（11253），和 batch_remove_members 一个待遇。

    op="add" 拉黑，op="del" 放出来（等价于我们的 /解黑，但作用于 QQ 侧）。
    返回 (ok, status, body)，body 里 fail_openids 是没处理成功的。
    """
    tokens = [str(t).strip() for t in (tokens or []) if str(t).strip()][:20]
    if not tokens:
        return False, 0, {"error": "empty"}
    status, body = group_api(
        "/v2/groups/%s/member_blacklist" % group_openid,
        token, {"op": str(op or "add").lower(), "member_openids": tokens})
    return status < 400, status, body


def approve_join_request(group_openid, member_openid, token=None,
                         op="decline", join_request_id="", reason="",
                         add_to_blacklist=False):
    """审批入群申请（机器人需群管理员）。

    op="approve" 放进来，op="decline" 拒绝。
    **这是唯一一条能把人塞进 QQ 侧黑名单的开放途径**：
    decline 时带 add_to_member_blacklist=true，平台会顺手拉黑
    （member_blacklist 接口还在内邀，这条不用等）。

    返回 (ok, status, body)。
    """
    if not member_openid:
        return False, 0, {"error": "empty"}
    payload = {"op": str(op or "decline").lower()}
    if join_request_id:
        payload["join_request_id"] = str(join_request_id)
    if payload["op"] == "decline":
        if reason:
            payload["reject_reason"] = str(reason)[:50]
        if add_to_blacklist:
            payload["add_to_member_blacklist"] = True
    status, body = group_api(
        "/v2/groups/%s/approval_join_request/%s" % (group_openid, member_openid),
        token, payload)
    return status < 400, status, body


def list_group_members(group_openid, token=None, limit=200):
    """拉群成员列表。**这个接口目前还在内邀**（11253），拿不到就算了。

    拿得到的话有两个用处：①补登记机器人上线前就在群的老成员；
    ②刷新群昵称（判断「留」字豁免）。
    """
    out, cursor = [], ""
    while len(out) < limit:
        path = "/v2/groups/%s/members?limit=30" % group_openid
        if cursor:
            path += "&after=" + str(cursor)
        status, body = group_api(path, token, None, method="GET")
        if status >= 400:
            return out, status, body
        chunk = body.get("data") or []
        out.extend(chunk)
        cursor = body.get("next_cursor") or ""
        if not cursor or not chunk:
            break
    return out[:limit], 0, {}


# ────────────────────────────── WS 客户端 ──────────────────────────────

class Bot(object):
    def __init__(self):
        self.token = None
        self.expire_at = 0
        self.seq = None
        self.session_id = None
        self.ws = None

    async def refresh_token_if_needed(self):
        # 提前 60 秒换，避免发消息时刚好过期
        if self.token and time.time() < self.expire_at - 60:
            return
        self.token, ttl = get_access_token()
        self.expire_at = time.time() + ttl
        print("  [token] 已刷新，%d 秒后过期" % ttl)

    async def heartbeat(self, interval):
        while True:
            await asyncio.sleep(interval)
            if self.ws is None:
                return
            try:
                await self.ws.send(json.dumps({"op": 1, "d": self.seq}))
            except Exception:
                return

    async def on_event(self, name, data):
        if TRACE:
            print("[事件] %-22s %s" % (name, json.dumps(data, ensure_ascii=False)[:180]))

        if name == "C2C_MESSAGE_CREATE":
            uid = uid_of(data)
            if not uid:
                return
            text = data.get("content", "")
            msg_id = data.get("id", "")
            print("[私聊] %s  %r" % (uid[:12], text[:30]))

            async def reply(content):
                await self.refresh_token_if_needed()
                status, body = send_c2c(self.token, uid, content, msg_id)
                _log_reply("私聊回复", status, body, msg_id)

            out = handle_message(uid, text)
            if out:
                await reply(out)
            return

        if name == "GROUP_AT_MESSAGE_CREATE":
            group_openid = data.get("group_openid", "")
            uid = uid_of(data)
            text = data.get("content", "")
            msg_id = data.get("id", "")
            print("[群@] %s group=%s  %r"
                  % (uid[:10], str(group_openid)[:10], text[:40]))
            if not group_openid or not msg_id:
                print("  [跳过] 缺 group_openid / msg_id，没法被动回复")
                return

            async def reply(content):
                await self.refresh_token_if_needed()
                status, body = send_group(self.token, group_openid, content, msg_id)
                _log_reply("群回复", status, body, msg_id)

            if ALLOW_GROUP_ISSUE:
                out = handle_message(uid, text)
                if out:
                    await reply(out)
                else:
                    print("  [忽略] 内容没命中命令（需要 %s 加识别码）"
                          % " / ".join(AUTH_CMDS))
            elif parse_command(text):
                await reply(MSG_GROUP_HINT.format(cmd=AUTH_COMMAND))

    async def run_once(self):
        """连一次，跑到断开为止。返回 True 表示应该重连。"""
        import websockets

        await self.refresh_token_if_needed()
        url = get_gateway(self.token)
        print("  [ws] 连接 %s" % url)

        async with websockets.connect(url, max_size=2 ** 22) as ws:
            self.ws = ws
            hello = json.loads(await ws.recv())
            if hello.get("op") != 10:
                raise RuntimeError("握手异常：%s" % hello)
            interval = hello["d"]["heartbeat_interval"] / 1000.0

            await ws.send(json.dumps({
                "op": 2,
                "d": {
                    "token": "QQBot " + self.token,
                    "intents": INTENTS,
                    "shard": [0, 1],
                    "properties": {},
                },
            }))
            hb = asyncio.ensure_future(self.heartbeat(interval))
            try:
                while True:
                    raw = await ws.recv()
                    msg = json.loads(raw)
                    op = msg.get("op")
                    if msg.get("s") is not None:
                        self.seq = msg["s"]

                    if op == 0:
                        name = msg.get("t", "")
                        data = msg.get("d") or {}
                        if name == "READY":
                            self.session_id = data.get("session_id")
                            print("  [ws] 就绪 session=%s" % str(self.session_id)[:10])
                            print("  [ws] 机器人已在线，等待消息…")
                        elif name == "RESUMED":
                            print("  [ws] 会话已恢复")
                        else:
                            try:
                                await self.on_event(name, data)
                            except Exception as exc:
                                print("  [事件处理异常] %s: %s" % (name, exc))
                    elif op == 1:
                        await ws.send(json.dumps({"op": 1, "d": self.seq}))
                    elif op == 7:
                        print("  [ws] 服务端要求重连")
                        return True
                    elif op == 9:
                        print("  [ws] 会话失效，重新鉴权")
                        self.session_id = None
                        return True
                    elif op == 11:
                        pass
            finally:
                hb.cancel()
                self.ws = None

    async def run(self):
        fails = 0
        while fails < RECONNECT_MAX:
            try:
                need = await self.run_once()
                if need:
                    fails = 0
                    await asyncio.sleep(2)
                    continue
                fails = 0
            except KeyboardInterrupt:
                return
            except Exception as exc:
                fails += 1
                wait = min(30, 5 * fails)
                print("  [断线 %d/%d] %s —— %d 秒后重试" % (fails, RECONNECT_MAX, exc, wait))
                if fails >= RECONNECT_MAX:
                    print("  连续失败太多次，停止。检查 AppID/AppSecret 和网络。")
                    return
                await asyncio.sleep(wait)


# ────────────────────────────── 入口 ──────────────────────────────

def _missing_conf_hint():
    """缺配置时打印具体缺什么，别让人猜。"""
    if APP_ID and not APP_SECRET:
        print("已读到 app_id = %s，只差 app_secret。" % APP_ID)
    elif not APP_ID:
        print("app_id 和 app_secret 都没读到。")
    print("编辑这个文件填进去：%s" % CONFIG_PATH)
    print('  {"app_id": "%s", "app_secret": "在开放平台生成"}' % (APP_ID or "你的AppID"))
    print("\nAppSecret 在开放平台 → 你的机器人 → 开发管理 → 开发设置 生成（只显示一次）。")


def check():
    """只验配置，不连 WS。"""
    if not APP_ID or not APP_SECRET:
        _missing_conf_hint()
        return 1
    print("AppID: %s  %s" % (APP_ID, "（沙箱）" if SANDBOX else "（正式）"))
    # 先查依赖：缺 websockets 时脚本会在连网关那一刻抛 ModuleNotFoundError，
    # 表现成"机器人启动了但完全没反应"，很容易被误判成封号或权限问题。
    try:
        import websockets
        print("websockets: %s" % getattr(websockets, "__version__", "ok"))
    except ImportError:
        print("websockets: ❌ 未安装 —— 机器人启动后会立刻失败")
        print("   修复：python -m pip install -r bots/qq_auth_bot/requirements.txt")
        return 1
    token, ttl = get_access_token()
    print("access_token: ok，%d 秒有效" % ttl)
    url = get_gateway(token)
    print("网关: %s" % url)
    print("账本: %s" % qq_auth.DB_PATH)
    print("池子: %s" % qq_auth.POOL_PATH)
    ok, remaining = True, 0
    pool = qq_auth.load_pool()
    if pool:
        led = qq_auth.Ledger(qq_auth.DB_PATH)
        try:
            used = led.used_ids()
        finally:
            led.close()
        remaining = len([i for i in pool if i not in used])
    else:
        ok = False
    print("池子剩余可发: %d" % remaining)
    if not ok or remaining == 0:
        print("⚠️  池子为空或未生成：python tools/qq_auth.py poolgen 500")
    print("\n配置没问题，直接 python bot.py 启动。")
    return 0


async def listen(seconds):
    """诊断模式：连上后把收到的每个事件原样打印，N 秒后退出。

    用来分清两种"没反应"：
      - 一条事件都没有 → 事件没推过来（机器人没上线 / 未 @ / 不是体验号码 / 环境选错）
      - 有事件但没回码 → 命令或发消息环节的问题
    """
    import websockets

    bot = Bot()
    await bot.refresh_token_if_needed()
    url = get_gateway(bot.token)
    print("  [listen] 网关 %s" % url)

    async with websockets.connect(url, max_size=2 ** 22) as ws:
        hello = json.loads(await ws.recv())
        interval = hello["d"]["heartbeat_interval"] / 1000.0
        await ws.send(json.dumps({
            "op": 2,
            "d": {
                "token": "QQBot " + bot.token,
                "intents": INTENTS,
                "shard": [0, 1],
                "properties": {},
            },
        }))
        bot.ws = ws
        hb = asyncio.ensure_future(bot.heartbeat(interval))
        print("  [listen] 已鉴权，接下来 %d 秒内收到的所有事件都会打印" % seconds)
        print("  [listen] 现在去 QQ 里发消息（群里要 @ 机器人）…\n")

        got_message = False
        deadline = time.time() + seconds
        try:
            while time.time() < deadline:
                timeout = max(0.5, deadline - time.time())
                try:
                    raw = await asyncio.wait_for(ws.recv(), timeout=timeout)
                except asyncio.TimeoutError:
                    continue
                msg = json.loads(raw)
                op = msg.get("op")
                if msg.get("s") is not None:
                    bot.seq = msg["s"]
                if op == 0:
                    name = msg.get("t", "")
                    data = msg.get("d") or {}
                    brief = json.dumps(data, ensure_ascii=False)
                    print("[事件] %-22s %s" % (name, brief[:220]))
                    if name in ("C2C_MESSAGE_CREATE", "GROUP_AT_MESSAGE_CREATE"):
                        got_message = True
                        print("       ↑ 消息事件已到达，普通模式会处理它")
                elif op == 11:
                    pass
                else:
                    print("[op %s] %s" % (op, json.dumps(msg, ensure_ascii=False)[:180]))
        finally:
            hb.cancel()
            bot.ws = None

    print("\n  [listen] 结束")
    if got_message:
        print("  ✅ 事件能到 → 直接跑 python bot.py 就行")
    else:
        print("  ❌ 一条消息事件都没收到。按顺序排查：")
        print("     1. 机器人是否已上线？未上线要用沙箱：config.json 设 \"sandbox\": true")
        print("     2. 群聊必须 @ 机器人，普通发言不会推事件")
        print("     3. 私聊要求你在「开发设置 → 内部体验号码」里（未上线时）")
        print("     4. 开放平台「服务范围」里 QQ 群 / 单聊是否已开启")
    return 0


def main():
    if len(sys.argv) > 1 and sys.argv[1] in ("--check", "check"):
        return check()

    if len(sys.argv) > 1 and sys.argv[1] in ("--listen", "listen"):
        if not APP_ID or not APP_SECRET:
            _missing_conf_hint()
            return 1
        secs = 90
        if len(sys.argv) > 2 and sys.argv[2].isdigit():
            secs = int(sys.argv[2])
        print("=" * 56)
        print(" 诊断模式：%s 环境" % ("沙箱" if SANDBOX else "正式"))
        print("=" * 56)
        try:
            return asyncio.run(listen(secs))
        except KeyboardInterrupt:
            return 0

    if not APP_ID or not APP_SECRET:
        _missing_conf_hint()
        return 1

    print("=" * 56)
    print(" FVM-Reborn 授权机器人（QQ 官方机器人 · WebSocket）")
    print(" AppID: %s" % APP_ID)
    print(" 环境: %s" % ("沙箱" if SANDBOX else "正式"))
    print(" 领码: %s <识别码>   （也接受 %s）" % (AUTH_COMMAND, " / ".join(AUTH_CMDS[1:]) or "无"))
    print(" 查码: %s <识别码>   （也接受 %s）" % (LOOKUP_COMMAND, " / ".join(LOOKUP_CMDS[1:]) or "无"))
    print(" 群内发码: %s" % ("开" if ALLOW_GROUP_ISSUE else "关（推荐）"))
    print(" 每号上限: %d 台机器（第 %d 台起直接拒绝，无自助解绑）"
          % (qq_auth.MAX_DEVICES_PER_UID, qq_auth.MAX_DEVICES_PER_UID + 1))
    print(" 账本: %s" % qq_auth.DB_PATH)
    print("=" * 56)
    print(" Ctrl+C 退出")

    try:
        asyncio.run(Bot().run())
    except KeyboardInterrupt:
        print("\n已停止")
    return 0


if __name__ == "__main__":
    sys.exit(main())

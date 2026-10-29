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

# 群里是否直接发码。码已经和机器码绑定，群发也拿不走，
# 所以默认允许（1）；想只走私聊就设 0。
ALLOW_GROUP_ISSUE = _flag("ALLOW_GROUP_ISSUE", "allow_group_issue", "1")

# 打印每个收到的事件（排查"机器人没反应"时开）
TRACE = _flag("QQ_TRACE", "trace", "0")

# 正式 / 沙箱两套域名
API_BASE = "https://sandbox.api.sgroup.qq.com" if SANDBOX else "https://api.sgroup.qq.com"
TOKEN_URL = "https://bots.qq.com/app/getAppAccessToken"

# Intents：GROUP_AND_C2C_EVENT = 1 << 25（QQ 群 @ 与单聊消息）
INTENTS = 1 << 25

RECONNECT_MAX = 5           # 连续失败几次就停，别无限重试（会被风控盯上）
MSG_SEQ = {}                # msg_id -> 已用过的 msg_seq

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
    "获取方式：打开游戏 → 右上角授权按钮 → 点窗口里的识别码即可复制\n"
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
    "（识别码在游戏右上角授权窗口里，点一下就能复制）"
)

MSG_GROUP_HINT = (
    "领码请带上本机识别码：{cmd} XXXX-XXXX\n"
    "（识别码在游戏右上角授权窗口里点一下就能复制）"
)

MSG_POOL_EMPTY = "授权码暂时发完了，请联系管理加码后再领。"
# 到上限就是硬拒绝：不提任何解绑/重领的办法，避免玩家觉得"磨一磨就能换"
MSG_TOO_MANY = (
    "这个 QQ 已经绑满 {n} 台机器，不能再领新码了。\n"
    "授权码一发出就和机器绑定，不能转移也不能重领。"
)
MSG_ERROR = "发码出错了，请联系管理。"


# ────────────────────────────── 发码 ──────────────────────────────

def issue_for(uid, hwid):
    """返回 (code, is_new)。同一台机器永远只对应一个码。"""
    ledger = qq_auth.Ledger(qq_auth.DB_PATH)
    try:
        row = ledger.get_by_hwid(hwid)
        if row:
            return row[3], False
        return qq_auth.issue_for(uid, hwid, ledger)
    finally:
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
    """去掉 <@!123> / @机器人 这类前缀，再取命令词。"""
    t = text or ""
    while "<@!" in t:
        s = t.find("<@!")
        e = t.find(">", s)
        if e < 0:
            break
        t = t[:s] + t[e + 1:]
    t = t.replace("<@", "").replace(">", "")
    return t.strip()


def parse_command(text):
    """返回 (命令类别, 参数)。严格匹配，'#授权码给我' 不算。

    '#授权 1A2B-3C4D'  -> ('auth',   '1A2B3C4D')
    '/授权 1A2B-3C4D'  -> ('auth',   '1A2B3C4D')   # 前缀两种都认
    '#查码 1A2B-3C4D'  -> ('lookup', '1A2B3C4D')
    """
    plain = strip_mention(text)
    for cmds, kind in ((AUTH_CMDS, "auth"), (LOOKUP_CMDS, "lookup")):
        for cmd in cmds:
            if plain == cmd:
                return (kind, "")
            # 命令后面必须跟空白，否则 '#授权码' 会被误判成 '#授权'
            if plain.startswith(cmd) and len(plain) > len(cmd) and plain[len(cmd)] in (" ", "\u3000"):
                return (kind, plain[len(cmd):].strip())
    return None


def handle_message(uid, text):
    """返回要回的内容（None 表示不理）。"""
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


def uid_of(data):
    """取稳定的用户标识。

    union_openid 存在时优先用它（同一主体下跨场景一致），
    否则 C2C 用 user_openid、群消息用 member_openid。
    """
    author = data.get("author") or {}
    return (author.get("union_openid")
            or author.get("user_openid")
            or author.get("member_openid")
            or author.get("id")
            or "")


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

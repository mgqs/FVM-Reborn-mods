#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Webhook 版端到端自检（不联网、不碰真账本）。

模拟腾讯真实推过来的请求，覆盖四件事：
  1. op=13 回调地址校验握手 → 返回的签名必须能被平台验过
  2. 签名错误的请求必须被拒（401），不能白送码
  3. 群 @ 消息能走完整链路，产出可被游戏端验过的码
  4. 同一台机器重复领，返回原码、不消耗新码池 ID
  5. 超上限（第 3 台）必须硬拒绝

跑：python selftest.py
"""

import json
import os
import sys
import time

_HERE = os.path.dirname(os.path.abspath(__file__))
for _cand in (os.path.join(_HERE, "..", "..", "..", "tools"),
              os.path.join(_HERE, ".."),
              _HERE):
    _cand = os.path.abspath(_cand)
    if _cand not in sys.path:
        sys.path.insert(0, _cand)

# 用假的 AppSecret 跑，别拿真密钥做测试
os.environ["QQ_APP_ID"] = "100000000"
os.environ["QQ_APP_SECRET"] = "TestSecretForSelftest0123456789ab"
# 管理员认领口令也要在 import bot 之前设好（bot 在 import 期读环境变量）
os.environ["AUTH_ADMIN_TOKEN"] = "TESTADMINTOKEN0123456789"

import ed25519_ref as ed25519  # noqa: E402
import members as members_mod  # noqa: E402
import qq_auth  # noqa: E402
import store  # noqa: E402
import sweep as sweep_mod  # noqa: E402
import webhook  # noqa: E402

import bot  # noqa: E402

FAILS = []


def check(cond, good, bad):
    if cond:
        print("  ✓ %s" % good)
    else:
        print("  ✗ %s" % bad)
        FAILS.append(bad)
    return cond


def make_handler(ledger_store):
    # 成员表也用内存的：否则每跑一次自检就往当前目录写一份 _members_debug.json，
    # 第二次跑就被上一轮的数据污染了。
    mem_table = store.MemoryStore()
    handler = webhook.WebhookHandler(
        app_id="100000000",
        app_secret=os.environ["QQ_APP_SECRET"],
        bot_module=bot,
        ledger_factory=lambda: store.Ledger(ledger_store),
        verbose=False,
        members_factory=lambda: members_mod.Members(mem_table, group="GRP1"),
    )
    # 挂到 handler 上，测试里想直接看成员表时有据可查
    handler._test_members_store = mem_table
    return handler


def signed_request(handler, payload, secret=None, tamper=False):
    """按官方规则造一个带签名的请求。"""
    seed = ed25519.seed_from_secret(secret or os.environ["QQ_APP_SECRET"])
    body = json.dumps(payload, ensure_ascii=False).encode("utf-8")
    ts = str(int(time.time()))
    sig = ed25519.sign(seed, ts.encode("utf-8") + body).hex()
    if tamper:
        sig = ("0" if sig[0] != "0" else "1") + sig[1:]
    return {"X-Signature-Ed25519": sig, "X-Signature-Timestamp": ts}, body


def main():
    # ── 底层组件 ──
    print("① Ed25519")
    if not ed25519.selftest(verbose=False):
        check(False, "", "Ed25519 向量未通过")
    else:
        check(True, "RFC 8032 向量通过（%s）" % ed25519.backend(), "")

    print("\n② 账本")
    if not store.selftest():
        check(False, "", "账本自检未通过")
    else:
        check(True, "账本读写/持久化正常", "")

    # ── 抓发送 ──
    sent = []
    bot.get_access_token = lambda: ("FAKE_TOKEN", 7200)

    def fake_send_group(token, group_openid, content, msg_id):
        sent.append(("group", group_openid, content, msg_id))
        return 200, {"id": "fake"}

    def fake_send_c2c(token, openid, content, msg_id):
        sent.append(("c2c", openid, content, msg_id))
        return 200, {"id": "fake"}

    bot.send_group = fake_send_group
    bot.send_c2c = fake_send_c2c

    mem = store.MemoryStore()
    handler = make_handler(mem)

    print("\n③ 回调地址校验握手（op=13）")
    payload = {"op": 13, "d": {"plain_token": "Arq0D5A61EgUu4OxUvOp", "event_ts": "1725442341"}}
    headers, body = signed_request(handler, payload)
    status, resp = handler.handle(headers, body)
    check(status == 200, "握手返回 200", "握手状态码 %s" % status)
    check(resp.get("plain_token") == "Arq0D5A61EgUu4OxUvOp", "plain_token 原样回传",
          "plain_token 没回传对")
    try:
        sig = bytes.fromhex(resp.get("signature", ""))
    except ValueError:
        sig = b""
    check(len(sig) == 64, "返回 64 字节签名", "签名长度不对：%d" % len(sig))
    # 用平台的方式反过来验一遍
    ok = ed25519.verify(
        ed25519.public_key(ed25519.seed_from_secret(os.environ["QQ_APP_SECRET"])),
        ("1725442341" + "Arq0D5A61EgUu4OxUvOp").encode("utf-8"),
        sig,
    )
    check(ok, "握手签名可被平台验过（保存回调地址会成功）", "握手签名平台验不过")

    print("\n④ 错误签名必须被拒")
    payload = {"op": 0, "t": "GROUP_AT_MESSAGE_CREATE",
               "d": {"id": "MSG1", "content": "/授权 CF8A-EFFE",
                     "group_openid": "GRP1", "author": {"member_openid": "UID1"}}}
    headers, body = signed_request(handler, payload, tamper=True)
    status, _ = handler.handle(headers, body)
    check(status == 401, "篡改签名 → 401", "篡改签名竟然通过了（%s）" % status)

    headers, body = signed_request(handler, payload, secret="WrongSecretWrongSecretWrongSecr")
    status, _ = handler.handle(headers, body)
    check(status == 401, "错密钥 → 401", "错密钥竟然通过了（%s）" % status)

    status, _ = handler.handle({}, body)
    check(status == 401, "缺签名头 → 401", "没签名也放行了")

    check(not sent, "被拒的请求没有触发任何发送", "被拒的请求居然发了消息")

    print("\n⑤ 群 @ 消息 → 发码")
    headers, body = signed_request(handler, payload)
    status, _ = handler.handle(headers, body)
    check(status == 200, "正常事件返回 200", "事件状态码 %s" % status)
    check(len(sent) == 1, "触发了一次群回复", "回复次数 %d" % len(sent))
    content = sent[0][2] if sent else ""
    check("FVM4-" in content, "回复里带授权码", "回复里没有码：%r" % content[:60])

    code = ""
    if "FVM4-" in content:
        code = "FVM4-" + content.split("FVM4-")[1].split()[0].strip()
    valid, code_id, hwid = qq_auth.verify(code)
    check(valid, "码的签名有效（游戏端能验过）", "码签名无效：%s" % code)
    check(hwid == "CF8AEFFE", "码绑定了正确的机器码", "机器码错：%s" % hwid)

    print("\n⑥ 同一台机器重复领")
    before = len(store.Ledger(mem).used_ids())
    headers, body = signed_request(handler, payload)
    handler.handle(headers, body)
    after = len(store.Ledger(mem).used_ids())
    again = sent[-1][2] if sent else ""
    check(code in again, "返回同一个码", "又发了新码")
    check(before == after, "没有消耗新的码池 ID", "码池 ID 被多消耗了")

    print("\n⑦ 一个 QQ 最多 2 台（第 3 台必须拒）")
    for i, hwid_extra in enumerate(["11112222", "33334444", "55556666"]):
        msg = {"op": 0, "t": "GROUP_AT_MESSAGE_CREATE",
               "d": {"id": "MSG%d" % (i + 2), "content": "/授权 " + hwid_extra,
                     "group_openid": "GRP1", "author": {"member_openid": "UID_NEW"}}}
        headers, body = signed_request(handler, msg)
        handler.handle(headers, body)
    nth = [s[2] for s in sent[-3:]]
    check("FVM4-" in nth[0] and "FVM4-" in nth[1], "前两台正常发码",
          "前两台就不正常")
    check("FVM4-" not in nth[2], "第 3 台被拒（没发码）", "第 3 台居然发了码")
    check("绑满" in nth[2], "第 3 台收到「已绑满」的提示", "第 3 台的提示不对：%r" % nth[2][:40])
    check("解绑" not in nth[2] and "联系" not in nth[2],
          "拒绝文案不含任何解绑线索", "拒绝文案泄露了解绑途径")

    print("\n⑧ 无关消息不打扰")
    sent.clear()
    msg = {"op": 0, "t": "GROUP_AT_MESSAGE_CREATE",
           "d": {"id": "MSG9", "content": "今天天气不错",
                 "group_openid": "GRP1", "author": {"member_openid": "UID1"}}}
    headers, body = signed_request(handler, msg)
    handler.handle(headers, body)
    check(not sent, "普通聊天不回复", "普通聊天被回复了")

    print("\n⑨ 私聊通道（授权统一在群里办，私聊只回指引）")
    sent.clear()
    msg = {"op": 0, "t": "C2C_MESSAGE_CREATE",
           "d": {"id": "MSG10", "content": "/授权 CF8A-EFFE",
                 "author": {"user_openid": "UID_PRIVATE"}}}
    headers, body = signed_request(handler, msg)
    handler.handle(headers, body)
    check(len(sent) == 1 and sent[0][0] == "c2c", "私聊有回复（不是沉默）",
          "私聊没回或走错通道")
    check("FVM4-" not in (sent[0][2] if sent else ""), "私聊不再发码",
          "私聊还在发码 —— 会写进 user_openid 记录，群成员对不上，老玩家会被误踢")
    check("群" in (sent[0][2] if sent else ""), "私聊回复指明去群里办",
          "私聊回复没说去哪办")

    print("\n⑩ 私聊缺识别码也给同一句指引")
    sent.clear()
    msg = {"op": 0, "t": "C2C_MESSAGE_CREATE",
           "d": {"id": "MSG11", "content": "/授权",
                 "author": {"user_openid": "UID_PRIVATE"}}}
    headers, body = signed_request(handler, msg)
    handler.handle(headers, body)
    check(len(sent) == 1 and "群" in (sent[0][2] if sent else ""),
          "提示去群里办理", "没给指引：%r" % (sent[0][2][:40] if sent else ""))

    print("\n⑪ 函数 URL 层（响应格式 / body 编码）")
    # 这一节专门盯住两个只在云上才发作的坑：
    #   · 手写 Content-Type 会和网关补的那个重复 → Chrome ERR_INVALID_RESPONSE
    #   · 函数 URL 交给事件函数的 body 是「解码过的字符串」，中文一旦串码就验签失败
    import main as scf_main

    resp = scf_main.main_handler({"httpMethod": "GET", "headers": {}, "body": None})
    check(resp["statusCode"] == 200, "浏览器 GET 健康检查返回 200",
          "健康检查状态码 %s（浏览器打开会报错）" % resp["statusCode"])
    check(isinstance(resp.get("body"), str), "响应 body 是字符串",
          "body 不是字符串，网关拼不出响应")
    check("headers" not in resp,
          "响应不手写 Content-Type（不会和网关重复）",
          "响应里带了 headers，Chrome 会报 ERR_INVALID_RESPONSE")
    check("ledger" in resp.get("body", "") and "secret" in resp.get("body", ""),
          "健康检查会报出账本/密钥配置状态（打开浏览器就能自查）",
          "健康检查没报配置状态，只能翻日志判断环境变量生效没有")

    mem_scf = store.MemoryStore()
    scf_handler = scf_main.get_handler()
    scf_handler.ledger_factory = lambda: store.Ledger(mem_scf)
    # 成员表也要换成内存的。这一节会真的走 _on_group_message → handler.members_factory，
    # 不换的话它会用 members_from_env 建一个 FileStore，把 _members_debug.json
    # 写到当前目录（仓库根），每次跑自检留一个垃圾文件。
    scf_mem_tab = members_mod.Members(store.MemoryStore(), group="GRP1")
    scf_handler._members_factory = lambda: scf_mem_tab

    def scf_event(payload, body_text=None):
        """按函数 URL 的真实形态造 event：body 是字符串，没有 isBase64Encoded。"""
        hdrs, body = signed_request(None, payload)
        return {"httpMethod": "POST", "headers": hdrs, "path": "/",
                "queryString": {},
                "body": body_text if body_text is not None else body.decode("utf-8")}, body

    # 昵称带中文，逼出「字符串 ↔ 字节」这一层
    msg_cn = {"op": 0, "t": "GROUP_AT_MESSAGE_CREATE",
              "d": {"id": "MSG_CN", "content": "/授权 CF8A-EFFE",
                    "group_openid": "GRP1",
                    "author": {"member_openid": "UID_CN", "nick": "北故人丿"}}}

    sent.clear()
    ev, _ = scf_event(msg_cn)
    resp = scf_main.main_handler(ev)
    check(resp["statusCode"] == 200, "带中文的事件验签通过", "带中文的事件被拒了")
    check(len(sent) == 1 and "FVM4-" in sent[0][2], "中文昵称不影响发码",
          "中文昵称导致发码失败：%r" % (sent[0][2][:40] if sent else ""))

    # 中间层用 latin-1 解了 utf-8 字节（最常见的串码方式）
    sent.clear()
    _, raw = signed_request(None, msg_cn)
    ev, _ = scf_event(msg_cn, body_text=raw.decode("latin-1"))
    resp = scf_main.main_handler(ev)
    check(resp["statusCode"] == 200, "body 被 latin-1 串码后仍能验签",
          "body 串码后验签失败（玩家会看到「授权出错了」）")

    print("\n⑫ 管理员解绑（仅白名单 + 仅私聊）")
    # 这一节盯住四件事：
    #   · 非管理员发 /解绑 必须一句都不回（回了就等于告诉全群有这条路）
    #   · 认领口令错必须拒绝，对了一次之后白名单永久锁死（不能被顶号）
    #   · 管理员解绑后，玩家能重新领码
    #   · 管理命令只能在私聊用，群里发一律忽略（/绑定列表 会泄露别人 openid）
    admin_mem = store.MemoryStore()
    ah = make_handler(admin_mem)

    def c2c(uid, text, mid):
        sent.clear()
        msg = {"op": 0, "t": "C2C_MESSAGE_CREATE",
               "d": {"id": mid, "content": text,
                     "author": {"user_openid": uid}}}
        headers, body = signed_request(ah, msg)
        ah.handle(headers, body)
        return sent[0][2] if sent else ""

    def grp(uid, text, mid):
        sent.clear()
        msg = {"op": 0, "t": "GROUP_AT_MESSAGE_CREATE",
               "d": {"id": mid, "content": text, "group_openid": "GRP1",
                     "author": {"member_openid": uid}}}
        headers, body = signed_request(ah, msg)
        ah.handle(headers, body)
        return sent[0][2] if sent else ""

    # 先让一个普通玩家占满两台
    for i, h in enumerate(("AAAAAAAA", "BBBBBBBB", "CCCCCCCC")):
        grp("UID_PLAYER", "/授权 " + h, "AD%d" % i)
    check(store.Ledger(admin_mem).count_by_uid("UID_PLAYER") == 2,
          "前置：普通玩家已绑 2 台", "前置条件不成立")

    check(c2c("UID_RANDOM", "/解绑 AAAAAAAA", "AE1") == "",
          "非管理员发 /解绑 一句话都不回", "非管理员发 /解绑 居然收到回复（暴露了命令）")

    out = c2c("UID_RANDOM", "/管理绑定 WRONGTOKEN", "AE2")
    check("口令不对" in out, "认领口令错误被拒", "错口令也放行了：%r" % out[:40])
    check(not store.Ledger(admin_mem).admins(), "口令错时白名单没有变化",
          "错口令竟然写进了白名单")

    out = c2c("UID_ADMIN", "/管理绑定 " + os.environ["AUTH_ADMIN_TOKEN"], "AE3")
    check("唯一管理员" in out, "口令正确 → 成为管理员", "认领失败：%r" % out[:60])
    check(store.Ledger(admin_mem).is_admin("UID_ADMIN"), "管理员已落盘",
          "管理员没落盘（重启就丢）")

    check(c2c("UID_OTHER", "/管理绑定 " + os.environ["AUTH_ADMIN_TOKEN"], "AE4") == "",
          "白名单已满后再次认领被静默拒绝", "第二个人也能认领（管理员可被顶号）")

    check(grp("UID_ADMIN", "/绑定数量", "AE5") == "",
          "群里发 /绑定数量 被忽略（管理命令只在私聊）", "群里居然回了绑定数量")

    out = c2c("UID_ADMIN", "/绑定数量", "AE5b")
    check(out.strip() != "" and "2" in out, "/绑定数量 只回数量",
          "绑定数量回复不对：%r" % out[:60])
    check("AAAA" not in out and "BBBB" not in out,
          "绑定数量不含任何 openid/机器码明细", "还在贴明细：%r" % out[:60])

    out = c2c("UID_ADMIN", "/绑定列表", "AE5c")
    check(out.strip() != "" and "AAAA" not in out,
          "旧命令 /绑定列表 保留为别名、同样只回数量", "旧命令行为没改：%r" % out[:60])

    out = c2c("UID_ADMIN", "/解绑 AAAAAAAA", "AE6")
    check("已解绑" in out and "AAAAAAAA" in out, "管理员解绑指定机器",
          "解绑失败：%r" % out[:60])
    check(store.Ledger(admin_mem).count_by_uid("UID_PLAYER") == 1,
          "账本里该账号只剩 1 台", "解绑没有真的删掉记录")

    out = grp("UID_PLAYER", "/授权 CCCCCCCC", "AE7")
    check("FVM4-" in out, "解绑后玩家能重新领码", "解绑后仍领不到：%r" % out[:40])

    rows = store.Ledger(admin_mem).all()
    cid = rows[0][2] if rows else ""
    out = c2c("UID_ADMIN", "/解绑 " + cid, "AE8")
    check("已解绑" in out, "用码 ID 也能解绑", "按码 ID 解绑失败：%r" % out[:50])

    out = c2c("UID_ADMIN", "/解绑 FFFFFFFF", "AE9")
    check("没有" in out, "解绑不存在的机器会明确说找不到",
          "不存在的机器没有提示：%r" % out[:40])

    audits = store.Ledger(admin_mem).audit_tail(10)
    check(len(audits) >= 3 and all(a["actor"] == "UID_ADMIN" for a in audits[1:]),
          "解绑操作全部留痕（审计记录）", "审计记录缺失或 actor 不对")

    check(c2c("UID_ADMIN", "/我是谁", "AEA").strip() != "", "管理员能查自己的 openid",
          "/我是谁 没回")

    print("\n⑬ 群成员登记（入群 / 发言 / 退群）")
    mh = make_handler(store.MemoryStore())
    t0 = int(time.time())

    def event(name, d):
        out_sent = len(sent)
        msg = {"op": 0, "t": name, "d": d}
        headers, body = signed_request(mh, msg)
        mh.handle(headers, body)
        return len(sent) - out_sent

    def table():
        h = mh.members_factory()
        try:
            return h
        except Exception:
            return None

    event("GROUP_MEMBER_ADD", {"timestamp": t0, "group_openid": "GRP1",
                               "member_openid": "M_NEW"})
    memtab = mh.members_factory()
    rec = memtab.get("M_NEW")
    check(rec is not None, "入群事件写进成员表", "入群没登记")
    check(rec and int(rec["join_ts"]) == t0, "join_ts 取事件 timestamp",
          "join_ts 不对：%r" % (rec or {}).get("join_ts"))
    check(memtab.group == "GRP1", "group_openid 记住了", "group 没存下来")

    event("GROUP_MEMBER_ADD", {"timestamp": t0 + 999, "group_openid": "GRP1",
                               "member_openid": "M_NEW"})
    check(int(memtab.get("M_NEW")["join_ts"]) == t0,
          "重复入群事件不重置 join_ts（不会把 3 天倒计时顶回去）",
          "重复事件把 join_ts 改了：%r" % memtab.get("M_NEW")["join_ts"])

    # 全量模式：不 @ 也要记发言
    n = event("GROUP_MESSAGE_CREATE",
              {"id": "GM1", "content": "随便聊聊", "group_openid": "GRP1",
               "author": {"member_openid": "M_NEW", "username": "小王"}})
    check(n == 0, "全量群消息不回复（只记账）", "全量消息被回复了，会刷屏")
    memtab = mh.members_factory()
    check(memtab.get("M_NEW")["name"] == "小王", "昵称记下来了",
          "昵称没记：%r" % memtab.get("M_NEW")["name"])
    check(int(memtab.get("M_NEW")["last_speak_day"]) > 0, "发言日期记下来了",
          "last_speak_day 还是 0")

    # 机器人上线前就在群的人，第一次说话时补登记
    event("GROUP_MESSAGE_CREATE",
          {"id": "GM2", "content": "我是老成员", "group_openid": "GRP1",
           "author": {"member_openid": "M_OLD", "username": "老李"}})
    memtab = mh.members_factory()
    check(memtab.get("M_OLD") is not None
          and memtab.get("M_OLD")["state"] == "joined_late",
          "老成员首次发言补登记为 joined_late", "老成员没补登记")

    event("GROUP_MEMBER_REMOVE", {"timestamp": t0, "group_openid": "GRP1",
                                  "member_openid": "M_OLD"})
    memtab = mh.members_factory()
    check(memtab.get("M_OLD")["state"] == "left", "退群标成 left（不删记录）",
          "退群没标记")

    print("\n⑭ 领码即算已绑定 + uid 归属修正")
    mh2 = make_handler(mem_store_ := store.MemoryStore())

    def gm(uid, text, mid):
        sent.clear()
        msg = {"op": 0, "t": "GROUP_AT_MESSAGE_CREATE",
               "d": {"id": mid, "content": text, "group_openid": "GRP1",
                     "author": {"member_openid": uid, "username": "玩家"}}}
        headers, body = signed_request(mh2, msg)
        mh2.handle(headers, body)
        return sent[0][2] if sent else ""

    gm("M_BIND", "/授权 11223344", "B1")
    mt = mh2.members_factory()
    check(mt.get("M_BIND") is not None and mt.get("M_BIND")["bound"],
          "群里领码 → 成员表标记已绑定", "领了码却没标已绑定（3 天后会被误踢）")

    # uid_of：群消息里 union_openid 有值，也必须用 member_openid
    author = {"member_openid": "M_MEMBER", "union_openid": "U_UNION",
              "user_openid": "U_C2C", "id": "RAW_ID"}
    check(bot.uid_of({"author": author}) == "M_MEMBER",
          "群消息 uid 优先 member_openid（否则团成员事件永远对不上）",
          "uid 还是取了 union：%s" % bot.uid_of({"author": author}))
    check(bot.uid_of({"author": author}, prefer="user") == "U_C2C",
          "私聊 uid 优先 user_openid", "私聊 uid 取错了")

    print("\n⑮ 清理判定（3 天未绑 / 7 天未言 / 含「留」豁免）")
    now = int(time.time())
    memtab = members_mod.Members(store.MemoryStore(), group="GRP1")
    memtab.add_member("C_FRESH", now - 3600)                     # 刚进来
    memtab.add_member("C_NOAUTH", now - 4 * 86400)               # 进来 4 天没绑
    memtab.add_member("C_WARN", now - 2 * 86400 - 23 * 3600)     # 差 1 小时到点
    memtab.add_member("C_IDLE", now - 40 * 86400)                # 老玩家，8 天没说话
    memtab.get("C_IDLE")["bound"] = True
    memtab.get("C_IDLE")["last_speak_ts"] = now - 8 * 86400
    memtab.add_member("C_MARK", now - 20 * 86400, name="老板（留）")
    memtab.add_member("C_MANUAL", now - 20 * 86400)
    memtab.set_exempt("C_MANUAL", True, by="admin")
    memtab.add_member("C_ADMIN", now - 20 * 86400, role="admin")
    memtab.add_member("C_GONE", now - 20 * 86400)
    memtab.set_state("C_GONE", "left")

    plan = bot.sweep_plan(memtab, now)
    kicks = {i["mid"] for i in plan["kick"]}
    warns = {i["mid"] for i in plan["warn"]}
    skips = {i["mid"] for i in plan["skip"]}
    check("C_NOAUTH" in kicks, "4 天未绑定 → 到点清理", "未绑定的没被排进清理名单")
    check("C_IDLE" in kicks, "已绑定但 8 天没说话 → 到点清理", "长期不说话的漏了")
    check("C_WARN" in warns, "差 1 小时到点 → 进警告名单", "没进警告窗口")
    check("C_FRESH" in skips, "刚进来 1 小时 → 不打扰", "新人也警告了")
    check("C_MARK" not in kicks | warns, "昵称含「留」→ 永不清理",
          "带「留」的人还是被清算了")
    check("C_MANUAL" not in kicks | warns, "/豁免 过的人 → 永不清理",
          "手动豁免无效")
    check("C_ADMIN" not in kicks | warns, "群主/管理员 → 永不清理",
          "把管理员算进去了（会踢不动还报错）")
    check("C_GONE" in skips, "已退群的人不再处理", "对已退群的人还在算")

    # 7 天清了、但一说话就自救
    memtab.touch_speak("C_IDLE", ts=now)
    plan2 = bot.sweep_plan(memtab, now)
    check("C_IDLE" not in {i["mid"] for i in plan2["kick"]},
          "发言即自救（说过话就不清了）", "说话了还是被清")

    print("\n⑯ 巡检执行（dry_run 不动手 / remove 失败退禁言 / 拉黑）")
    sent.clear()
    real = {"kick": [], "mute": [], "send": []}
    orig_kick, orig_mute = bot.kick_members, bot.mute_members
    orig_send = bot.send_group_active

    def fake_kick(gid, tokens, token=None):
        real["kick"].extend(tokens)
        return True, 200, {}

    def fake_kick_fail(gid, tokens, token=None):
        # 模拟 11253：接口没内邀权限
        return False, 404, {"code": 11253, "message": "app no permission"}

    def fake_mute(gid, tokens, days=30, token=None, op="add"):
        real["mute"].extend(tokens)
        return True, 200, {}

    def fake_send_active(token, gid, content):
        real["send"].append(content)
        return 200, {}

    bot.kick_members = fake_kick
    bot.mute_members = fake_mute
    bot.send_group_active = fake_send_active
    try:
        sweep_mem = store.MemoryStore()
        sh = make_handler(store.MemoryStore())
        sh._members_factory = lambda: members_mod.Members(sweep_mem, group="GRP1")
        bot.GROUP_OPENID = "GRP1"

        # 先塞一批人：一个到点该清的、一个正在警告窗口的
        pre = members_mod.Members(sweep_mem, group="GRP1")
        pre.add_member("K_ZERO", now - 5 * 86400)
        pre.add_member("W_ZERO", now - 2 * 86400 - 23 * 3600)
        pre.flush()

        st = sweep_mod.sweep(sh, now=now, mode="dry_run")
        check(st["kicked"] == 0 and not real["kick"],
              "dry_run 一个都不踢", "dry_run 居然真踢了")
        check(st["warned"] >= 1 and real["send"],
              "dry_run 仍然发警告（让人有机会自救）", "dry_run 连警告都不发")
        check(all("http" not in c.lower() for c in real["send"]),
              "警告文案不含 URL（否则 40054010 直接被拒）", "文案里有 URL")

        # 空表跑一次不该炸
        st0 = sweep_mod.sweep(sh, now=now, mode="dry_run")
        check(st0["kicked"] == 0, "空成员表跑巡检不炸", "空表把巡检搞崩了")

        # 真正动手：塞一个到点的人进去
        m2 = members_mod.Members(sweep_mem, group="GRP1")
        m2.add_member("K_ONE", now - 5 * 86400)
        m2.flush()
        real["kick"].clear()
        st1 = sweep_mod.sweep(sh, now=now, mode="remove")
        check(st1["kicked"] >= 1 and "K_ONE" in real["kick"],
              "remove 模式真的移出", "remove 没调踢人接口：%s" % st1)
        m3 = members_mod.Members(sweep_mem, group="GRP1")
        check(m3.is_blacklisted("K_ONE"), "踢出后进黑名单", "没拉黑")
        check(m3.get("K_ONE")["state"] == "kicked", "状态标成 kicked",
              "状态没记：%r" % m3.get("K_ONE")["state"])

        # 11253：踢不动必须退成禁言，不能静默失败
        m3.add_member("K_TWO", now - 5 * 86400)
        m3.flush()
        bot.kick_members = fake_kick_fail
        real["mute"].clear()
        st2 = sweep_mod.sweep(sh, now=now, mode="remove")
        check(st2["muted"] == 1 and "K_TWO" in real["mute"],
              "踢人被 11253 拒绝 → 自动退化禁言",
              "11253 时既没踢也没禁言，静默失败：%s" % st2)
        m4 = members_mod.Members(sweep_mem, group="GRP1")
        check(m4.get("K_TWO")["state"] == "muted", "退化后状态标成 muted",
              "退化后状态不对：%r" % m4.get("K_TWO")["state"])
        check(not m4.is_blacklisted("K_TWO"),
              "禁言不算踢出，不进黑名单（人还在群里，还能自救）",
              "禁言也拉黑了 —— 人还在群里，拉黑等于判死刑")

        # 管理员命令：要先把 UID_ADMIN 写进白名单，否则非管理员一律静默
        adm_led = store.Ledger(store.MemoryStore())
        adm_led.admin_add("UID_ADMIN", label="selftest")
        out = bot.handle_admin("UID_ADMIN", "unblack", "K_ONE", adm_led, members=m4)
        check(out and "1" in out, "/解黑 能把人放出来", "解黑失败：%r" % (out or ""))
        m5 = members_mod.Members(sweep_mem, group="GRP1")
        check(not m5.is_blacklisted("K_ONE"), "解黑真的生效", "黑名单没删掉")
    finally:
        bot.kick_members = orig_kick
        bot.mute_members = orig_mute
        bot.send_group_active = orig_send
        bot.GROUP_OPENID = ""

    print("\n⑰ 豁免与黑名单的边界")
    mtab = members_mod.Members(store.MemoryStore(), group="GRP1")
    mtab.add_member("E1", now, name="老玩家求留一下")
    check(bot.is_exempt("E1", mtab.get("E1")).startswith("name:留"),
          "「留」是包含匹配，不是前缀（叫「老玩家求留一下」也算）",
          "包含匹配没生效：%r" % bot.is_exempt("E1", mtab.get("E1")))
    mtab.add_member("E2", now, name="路人甲")
    check(bot.is_exempt("E2", mtab.get("E2")) == "", "名字没标记的不豁免",
          "没标记的人被豁免了")
    mtab.blacklist_add("E3", why="test", expire_days=0)
    check(mtab.is_blacklisted("E3"), "永久黑名单生效", "永久黑名单不生效")
    mtab.blacklist_add("E4", why="test", expire_days=1, now=now - 2 * 86400)
    check(not mtab.is_blacklisted("E4", now=now), "过期黑名单自动失效",
          "过期了还黑着（人被踢出去就再也回不来）")

    print("\n⑱ /查询：按剩余时间筛人")
    qtab = members_mod.Members(store.MemoryStore(), group="GRP1")
    qled = store.Ledger(store.MemoryStore())
    qled.admin_add("UID_ADMIN", label="selftest")

    # 剩 14 小时的未绑定 / 剩 4 小时的未绑定 / 已到点 / 刚进群 / 含「留」豁免
    qtab.add_member("Q_38H", now - (3 * 86400 - 38 * 3600), name="阿三十八")
    qtab.add_member("Q_4H", now - (3 * 86400 - 4 * 3600), name="阿四")
    qtab.add_member("Q_DUE", now - 4 * 86400, name="阿到点")
    qtab.add_member("Q_NEW", now - 3600, name="阿新")
    qtab.add_member("Q_KEEP", now - 5 * 86400, name="老刘（留）")
    qtab.set_exempt("Q_KEEP", True, "admin:selftest")
    # 已绑定但 8 天没说话 → 已到点；已绑定 1 天没说话 → 还剩 6 天
    qtab.add_member("Q_IDLE", now - 30 * 86400, name="长期潜水")
    qtab.mark_bound("Q_IDLE")
    qtab.touch_speak("Q_IDLE", name="长期潜水", ts=now - 8 * 86400)
    qtab.add_member("Q_OK", now - 30 * 86400, name="活跃")
    qtab.mark_bound("Q_OK")
    qtab.touch_speak("Q_OK", name="活跃", ts=now - 86400)
    # 已退群的人不该出现在任何名单里
    qtab.add_member("Q_LEFT", now - 10 * 86400, name="走掉的")
    qtab.remove_member("Q_LEFT")

    out = bot.handle_admin("UID_ADMIN", "query", "", qled, members=qtab)
    check(out and "24 小时内会被清理" in out, "/查询 默认窗口是 24 小时",
          "默认窗口不对：%r" % out)
    check(out and "Q_DUE" in out, "已到点的人出现在 /查询 里", "已到点的人没出现")
    check(out and "Q_4H" in out, "4 小时后到点的人出现在 24 小时窗口里",
          "4 小时的人没出现")
    check(out and "Q_38H" not in out, "38 小时后到点的人不在 24 小时窗口里",
          "38 小时的人不该出现")
    check(out and "Q_NEW" not in out, "刚进群的人不在窗口里", "新人被算进去了")
    check(out and "Q_KEEP" not in out, "含「留」豁免的人不在窗口里",
          "豁免的人被算进去了（这条最重要，豁免形同虚设）")
    check(out and "Q_LEFT" not in out, "已退群的人不在窗口里", "退群的人被算进去了")

    out6 = bot.handle_admin("UID_ADMIN", "query", "6", qled, members=qtab)
    check(out6 and "6 小时内会被清理" in out6, "/查询 6 认小时数参数",
          "小时数参数没生效：%r" % out6)
    check(out6 and "Q_4H" in out6 and "Q_38H" not in out6,
          "窗口收敛到 6 小时后只剩 Q_4H",
          "6 小时窗口筛得不对：%r" % out6)

    out168 = bot.handle_admin("UID_ADMIN", "query", "168", qled, members=qtab)
    check(out168 and "Q_38H" in out168, "/查询 168 能看见 38 小时后到点的人",
          "大窗口没包含 38 小时后的人")
    check(out168 and "Q_OK" in out168, "/查询 168 能看见 6 天后到点的活跃用户",
          "大窗口没包含 6 天后的人")
    check(out168 and "Q_KEEP" not in out168,
          "再大的窗口也不该出现豁免的人", "豁免在长窗口里失效了")

    # 排序：剩余时间少的排前面
    rows = bot.due_report(qtab, 168, now=now)
    deadlines = [r["deadline"] for r in rows]
    check(deadlines == sorted(deadlines), "/查询 结果按剩余时间从少到多排",
          "排序不对：%r" % deadlines)

    out2 = bot.handle_admin("UID_ADMIN", "query", "2", qled, members=qtab)
    check(out2 and "Q_4H" not in out2 and "Q_DUE" in out2,
          "/查询 2 只剩已到点的人（4 小时的被 2 小时窗口排除）",
          "2 小时窗口筛得不对：%r" % out2)

    bad = bot.handle_admin("UID_ADMIN", "query", "abc", qled, members=qtab)
    check(bad and "用法" in bad, "/查询 报错时回用法而不是崩",
          "参数错误没兜住：%r" % bad)
    zero = bot.handle_admin("UID_ADMIN", "query", "0", qled, members=qtab)
    check(zero and "用法" in zero, "/查询 0 被当成非法参数", "0 没被拦住")

    # 普通玩家发 /查询 必须完全静默
    nobody = bot.handle_admin("NOBODY", "query", "", qled, members=qtab)
    check(nobody is None, "非管理员发 /查询 完全静默",
          "非管理员竟然拿到回复：%r" % nobody)

    # 群里发（members=None 之外的情况）—— 这里直接验 bot 层
    nochamp = bot.handle_admin("UID_ADMIN", "query", "", qled, members=None)
    check(nochamp and "成员表没接上" in nochamp, "成员表没接上时给明确提示",
          "缺成员表时没提示：%r" % nochamp)

    print("\n⑲ /豁免 不带参数：谁都能查自己")
    stab = members_mod.Members(store.MemoryStore(), group="GRP1")
    sled = store.Ledger(store.MemoryStore())
    sled.admin_add("S_ADMIN", label="selftest")
    # 五种人：名字带「留」、管理员、被手动豁免、普通人、成员表里没有的
    stab.add_member("S_MARK", now - 5 * 86400, name="老王（留）")
    stab.add_member("S_OWNER", now - 5 * 86400, name="群主", role="owner")
    stab.add_member("S_MANUAL", now - 5 * 86400, name="手动豁免的")
    stab.set_exempt("S_MANUAL", True, "admin:abcd1234")
    stab.add_member("S_PLAIN", now - 86400, name="普通人")
    stab.add_member("S_DUE", now - 4 * 86400, name="到点的")

    # ① 带「留」的人查自己 → 有豁免 + 原因说得清
    out = bot.exempt_self_text("S_MARK", stab)
    check("有豁免" in out and "「留」" in out, "名字带「留」的人查到自己有豁免",
          "带「留」的人没查到豁免：%r" % out[:60])
    check("不会被自动清理" in out, "豁免回复明确说不会清理", "豁免回复不够明确")

    # ② 管理员也能查到，且原因写的是身份而不是名字
    out = bot.exempt_self_text("S_OWNER", stab)
    check("群主" in out, "群主查到豁免原因是身份", "群主豁免原因不对：%r" % out[:60])

    # ③ 手动豁免的人
    out = bot.exempt_self_text("S_MANUAL", stab)
    check("管理员" in out, "手动豁免的人查到原因", "手动豁免原因不对：%r" % out[:60])

    # ④ 普通人查自己 → 没有豁免 + 说清还剩多久 + 三条拿豁免的办法
    out = bot.exempt_self_text("S_PLAIN", stab)
    check("没有豁免" in out, "普通人查到没有豁免", "普通人竟然显示有豁免")
    check("2 天" in out, "普通人能看到自己还剩几天（1 天前入群 → 还剩 2 天）",
          "剩余时间算错了：%r" % out[:120])
    check("/豁免" in out and "群昵称" in out, "回复里告诉了他怎么拿到豁免",
          "没给出获取豁免的办法")
    check("http" not in out, "群内自查文案里没有 URL（会被 40054010 拒收）",
          "文案里带了 URL")

    # ⑤ 已到点的人
    out = bot.exempt_self_text("S_DUE", stab)
    check("到点" in out or "已经" in out, "已到点的人查到的是「已经到清理点」",
          "到点状态没写清：%r" % out[:80])

    # ⑥ 成员表里没有的人 → 明确说清怎么才能进表
    out = bot.exempt_self_text("S_STRANGER", stab)
    check("还没有你的记录" in out, "陌生 id 得到的是「还没有记录」",
          "陌生 id 的回复不对：%r" % out[:60])

    # ⑦ 成员表没接上时不能崩，要给一句人话
    out = bot.exempt_self_text("S_PLAIN", None)
    check(out and "不可用" in out, "成员表缺失时不崩、给提示", "成员表缺失时炸了：%r" % out)

    # ⑧ /豁免 不带参数走 handle_admin，非管理员也要能拿到回复
    out = bot.handle_admin("S_PLAIN", "exempt", "", sled, members=stab)
    check(out and "没有豁免" in out and out is not None,
          "非管理员发 /豁免 无参数能查自己（不被静默）",
          "非管理员自查被静默了：%r" % out)

    # ⑨ 但 /豁免 带参数仍然是管理员命令
    out = bot.handle_admin("S_PLAIN", "exempt", "S_MARK", sled, members=stab)
    check(out is None, "非管理员发 /豁免 <别人> 仍然静默",
          "非管理员竟然能给别人开豁免：%r" % out)
    out = bot.handle_admin("S_ADMIN", "exempt", "S_PLAIN", sled, members=stab)
    check(out and "已加入" in out, "管理员发 /豁免 <别人> 生效", "管理员豁免不生效：%r" % out)

    # ⑩ 群聊路径：@ 机器人发 /豁免 必须回；@ 发 /豁免 别人必须不回
    gh = make_handler(store.MemoryStore())

    def gsent(uid, text, mid="MG1"):
        sent.clear()
        msg = {"op": 0, "t": "GROUP_AT_MESSAGE_CREATE",
               "d": {"id": mid, "content": text, "group_openid": "GRP1",
                     "author": {"member_openid": uid, "username": "路人"}}}
        headers, body = signed_request(gh, msg)
        gh.handle(headers, body)
        return sent[0][2] if sent else ""

    gsent("G_PLAIN", "/授权 AAAAAAAA", "MG0")   # 先让这个人进成员表
    outg = gsent("G_PLAIN", "/豁免", "MG2")
    check("豁免" in outg, "群里 @ 发 /豁免 能查到自己的状态",
          "群内自查没回复：%r" % outg[:60])
    outg = gsent("G_PLAIN", "/豁免 G_OTHER", "MG3")
    check(outg == "", "群里 @ 发 /豁免 <别人> 被忽略",
          "群里居然能查别人：%r" % outg[:60])
    outg = gsent("G_PLAIN", "/绑定数量", "MG4")
    check(outg == "", "群里 @ 发 /绑定数量 仍然被忽略（没被顺手放开）",
          "别的管理命令也被放开了：%r" % outg[:60])
    outg = gsent("G_PLAIN", "/解绑 AAAAAAAA", "MG5")
    check(outg == "", "群里 @ 发 /解绑 仍然被忽略", "解绑在群里被放开了")

    # ⑳ @ 兼容：<@!id>、<@id>、全角标点、裸识别码 —— 一条都不能漏
    print("\n⑳ @ 兼容与命令解析")
    check(bot.strip_mention("<@!123456> /授权") == "/授权",
          "<@!id> 被剥干净（带感叹号的老格式）", "带感叹号没剥干净")
    check(bot.strip_mention("<@ABC123> /授权") == "/授权",
          "<@id> 被剥干净（群消息真实格式）",
          "不带感叹号没剥干净 → 这就是「@ 了没反应」的根因")
    check(bot.strip_mention("  <@A> <@B> /授权  ") == "/授权",
          "连着两个 @ 也能剥干净", "多个 @ 残留")
    check(bot.strip_mention("") == "", "空串不炸", "空串炸了")

    cases = [
        ("<@!123456> /授权 1145-CCBB", ("auth", "1145-CCBB"), "带感叹号 @ + /授权"),
        ("<@ABC123> /授权 1145-CCBB", ("auth", "1145-CCBB"), "不带感叹号 @ + /授权"),
        ("<@ABC123> /授权", ("auth", ""), "@ 了但没给识别码（应回提示）"),
        ("<@ABC123>  1145-CCBB", ("auth", "1145-CCBB"), "只 @ + 裸识别码"),
        ("1145-CCBB", ("auth", "1145-CCBB"), "连 @ 都没带、只发识别码"),
        ("／授权 1145-CCBB", ("auth", "1145-CCBB"), "全角 ／ 也被认"),
        ("＃授权 1145-CCBB", ("auth", "1145-CCBB"), "全角 ＃ 也被认"),
        ("／授权　1145-CCBB", ("auth", "1145-CCBB"), "全角空格分隔也认"),
        ("/授权码 1145-CCBB", None, "/授权码 不误判成 /授权"),
        ("/授权表", None, "/授权表 不误判"),
        ("1A2B-3C4", None, "7 位识别码不当成领码"),
    ]
    for text, want, desc in cases:
        got = bot.parse_command(text)
        check(got == want, desc, "%r 解析成 %r，期望 %r" % (text, got, want))

    for text, want, desc in [
        ("<@ABC123> /豁免", ("exempt", ""), "@ 着发 /豁免"),
        ("<@ABC123> /查询 48", ("query", "48"), "@ 着发 /查询 48"),
        ("／解绑 AAAAAAAA", ("unbind", "AAAAAAAA"), "全角斜杠的管理命令"),
    ]:
        got = bot.parse_admin_command(text)
        check(got == want, desc, "%r 解析成 %r，期望 %r" % (text, got, want))

    # 端到端：三种 @ 形态都要真的把码发出来
    eh = make_handler(store.MemoryStore())
    for idx, content in enumerate(["<@!BOTID> /授权 1145-CCBB",
                                   "<@BOTID> /授权 1145-CCBB",
                                   "<@BOTID>  1145-CCBB"]):
        sent.clear()
        msg = {"op": 0, "t": "GROUP_AT_MESSAGE_CREATE",
               "d": {"id": "ME%d" % idx, "content": content,
                     "group_openid": "GRP1",
                     "author": {"member_openid": "E2E_%d" % idx,
                                "username": "端到端", "member_role": "member"}}}
        headers, body = signed_request(eh, msg)
        eh.handle(headers, body)
        got = sent[0][2] if sent else ""
        check("FVM4-" in got, "端到端：%r 真的回了码" % content[:26],
              "端到端没回码：%r" % got[:60])

    # ㉑ QQ 侧黑名单 / 入群审批封装：参数必须照官方形状拼
    print("\n㉑ QQ 侧黑名单与入群审批封装")
    calls = []
    real_api = bot.group_api

    def fake_api(path, token, payload=None, method="POST"):
        calls.append((path, token, payload, method))
        return 200, {"fail_openids": []}

    bot.group_api = fake_api
    try:
        ok, _, _ = bot.blacklist_members("GRP1", ["A" * 32, "B" * 32], token="T")
        check(ok and calls and calls[-1][0] == "/v2/groups/GRP1/member_blacklist",
              "拉黑打到 member_blacklist",
              "拉黑路径不对：%r" % (calls[-1][0] if calls else None))
        check(calls[-1][2] == {"op": "add", "member_openids": ["A" * 32, "B" * 32]},
              "拉黑请求体是 {op, member_openids}",
              "拉黑请求体不对：%r" % (calls[-1][2],))

        calls.clear()
        bot.blacklist_members("GRP1", ["C" * 32], token="T", op="del")
        check(calls[-1][2]["op"] == "del", "解黑传 op=del", "op 没传对")

        calls.clear()
        bot.blacklist_members("GRP1", ["D" * 32] * 25, token="T")
        check(len(calls[-1][2]["member_openids"]) == 20,
              "单次最多 20 个（多的截掉，不然平台报错）", "没截到 20")

        calls.clear()
        ok, _, _ = bot.approve_join_request("GRP1", "M" * 32, token="T",
                                            op="decline", join_request_id="JR1",
                                            reason="不收了", add_to_blacklist=True)
        body0 = calls[-1][2]
        check(ok and calls[-1][0] == "/v2/groups/GRP1/approval_join_request/" + "M" * 32,
              "审批打到 approval_join_request", "审批路径不对")
        check(body0.get("op") == "decline" and body0.get("add_to_member_blacklist") is True,
              "拒绝入群时带 add_to_member_blacklist（唯一不内邀的拉黑途径）",
              "审批请求体不对：%r" % (body0,))
        check(body0.get("join_request_id") == "JR1" and body0.get("reject_reason") == "不收了",
              "审批带上 join_request_id 与理由", "缺字段：%r" % (body0,))

        calls.clear()
        bot.approve_join_request("GRP1", "N" * 32, token="T", op="approve")
        check("add_to_member_blacklist" not in calls[-1][2],
              "同意入群时不带拉黑字段", "approve 里混进了拉黑字段")

        check(bot.blacklist_members("GRP1", [], token="T")[0] is False,
              "空名单直接返回失败，不打接口", "空名单居然打了接口")
    finally:
        bot.group_api = real_api

    # 记发言失败不许影响回话（云函数里 FileStore 写盘会抛）
    print("\n㉒ 记发言失败不能吞掉回复")

    class _Boom(object):
        def __getattr__(self, k):
            raise IOError("disk is read-only")

    bh = make_handler(store.MemoryStore())
    bh._members_factory = lambda: _Boom()
    sent.clear()
    msg = {"op": 0, "t": "GROUP_AT_MESSAGE_CREATE",
           "d": {"id": "MB1", "content": "<@BOTID> /授权 1145-CCBB",
                 "group_openid": "GRP1",
                 "author": {"member_openid": "BOOM1", "username": "炸了"}}}
    headers, body = signed_request(bh, msg)
    bh.handle(headers, body)
    got = sent[0][2] if sent else ""
    check("FVM4-" in got, "成员表整个炸了，发码回复照常",
          "成员表一炸就整条链路沉默（这就是「@ 了没反应」）")

    print("\n" + ("=" * 50))
    if FAILS:
        print("✗ %d 项未通过：" % len(FAILS))
        for f in FAILS:
            print("   · %s" % f)
        return 1
    print("✓ 全部通过")
    return 0


if __name__ == "__main__":
    sys.exit(main())

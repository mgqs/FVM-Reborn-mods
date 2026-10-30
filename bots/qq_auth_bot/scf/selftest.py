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
import qq_auth  # noqa: E402
import store  # noqa: E402
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
    handler = webhook.WebhookHandler(
        app_id="100000000",
        app_secret=os.environ["QQ_APP_SECRET"],
        bot_module=bot,
        ledger_factory=lambda: store.Ledger(ledger_store),
        verbose=False,
    )
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

    print("\n⑨ 私聊通道")
    sent.clear()
    msg = {"op": 0, "t": "C2C_MESSAGE_CREATE",
           "d": {"id": "MSG10", "content": "/授权 CF8A-EFFE",
                 "author": {"user_openid": "UID_PRIVATE"}}}
    headers, body = signed_request(handler, msg)
    handler.handle(headers, body)
    check(len(sent) == 1 and sent[0][0] == "c2c", "私聊能正常回码",
          "私聊没回或走错通道")

    print("\n⑩ 缺识别码时给指引")
    sent.clear()
    msg = {"op": 0, "t": "C2C_MESSAGE_CREATE",
           "d": {"id": "MSG11", "content": "/授权",
                 "author": {"user_openid": "UID_PRIVATE"}}}
    headers, body = signed_request(handler, msg)
    handler.handle(headers, body)
    check(len(sent) == 1 and "识别码" in sent[0][2], "提示怎么获取识别码",
          "没给指引：%r" % (sent[0][2][:40] if sent else ""))

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

    check(grp("UID_ADMIN", "/绑定列表", "AE5") == "",
          "群里发 /绑定列表 被忽略（不泄露 openid）", "群里居然回了绑定列表")

    out = c2c("UID_ADMIN", "/解绑 AAAAAAAA", "AE6")
    check("已解绑" in out and "AAAAAAAA" in out, "管理员解绑指定机器",
          "解绑失败：%r" % out[:60])
    check(store.Ledger(admin_mem).count_by_uid("UID_PLAYER") == 1,
          "账本里该账号只剩 1 台", "解绑没有真的删掉记录")

    out = c2c("UID_PLAYER", "/授权 CCCCCCCC", "AE7")
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

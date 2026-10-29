#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""腾讯云函数（SCF）入口 —— QQ 授权机器人 Webhook 版。

部署形态
--------
    腾讯 QQ 开放平台  --HTTPS POST-->  云函数 URL  -->  这个文件
                                                      ├─ 验签（Ed25519）
                                                      ├─ 发码（复用 qq_auth）
                                                      └─ 账本（COS 上的 JSON）

没有常驻进程，没有长连接。没人领码的时候它不存在，所以关掉电脑也不影响
任何人领码——这就是「不需要服务器」的实际含义。

环境变量（在函数配置里填）
--------------------------
    QQ_APP_ID         机器人 AppID（必填）
    QQ_APP_SECRET     机器人 AppSecret（必填，同时用来派生验签密钥）
    AUTH_SECRET       授权码签名密钥，必须与游戏端 kAuthSecretA/B/C 一致
    COS_SECRET_ID     对象存储 SecretId（账本，必填）
    COS_SECRET_KEY    对象存储 SecretKey
    COS_REGION        如 ap-guangzhou
    COS_BUCKET        如 fvm-auth-1250000000
    COS_KEY           账本对象路径，默认 qqauth/ledger.json
    MAX_DEVICES       每个 QQ 最多绑几台机器，默认 2

本地自检
--------
    python main.py --check     检查配置 + 跑 Ed25519 向量 + 连一次 COS
    python main.py --simulate  不联网，模拟一次群 @ 消息，走完整发码链路
"""

import base64
import hashlib
import json
import os
import sys

_HERE = os.path.dirname(os.path.abspath(__file__))
# 本地开发时 bot.py / qq_auth.py 不在这里；云上打包后都在这里。
# 顺序很重要：qq_auth 只能被加载成**同一个模块对象**，否则
# `bot.qq_auth.PoolExhausted` 和函数里 catch 的那个不是同一个类，
# 异常会漏出去变成「发码出错了，请联系管理」。
for _cand in (os.path.join(_HERE, "..", "..", "..", "tools"),
              os.path.join(_HERE, ".."),
              _HERE):
    _cand = os.path.abspath(_cand)
    if _cand not in sys.path:
        sys.path.insert(0, _cand)

import ed25519_ref as ed25519  # noqa: E402
import qq_auth  # noqa: E402
import store  # noqa: E402
import webhook  # noqa: E402

# 必须先于任何签名动作生效：密钥以环境变量为准，
# 免得包里带的 auth_secret.txt 和环境变量不一致却没人发现。
if os.environ.get("AUTH_SECRET", "").strip():
    qq_auth.SECRET = os.environ["AUTH_SECRET"].strip()

import bot  # noqa: E402  （要等 AUTH_SECRET 覆盖完再导入，确保用的是同一份密钥）

_HANDLER = None


def _flag(name, default="0"):
    return os.environ.get(name, default).strip().lower() in ("1", "true", "yes", "on")


def _secret_fingerprint(text):
    return hashlib.md5((text or "").encode("utf-8")).hexdigest().upper()[:8]


def build_handler():
    global _HANDLER
    app_id = os.environ.get("QQ_APP_ID", "").strip() or bot.APP_ID
    app_secret = os.environ.get("QQ_APP_SECRET", "").strip() or bot.APP_SECRET

    if not app_id or not app_secret:
        raise RuntimeError(
            "缺 QQ_APP_ID / QQ_APP_SECRET。到「函数管理 → 函数配置 → 环境变量」里填。"
        )

    _HANDLER = webhook.WebhookHandler(
        app_id=app_id,
        app_secret=app_secret,
        bot_module=bot,
        ledger_factory=store.ledger_from_env,
        verbose=_flag("SCF_VERBOSE", "1"),
        secret_ok=not qq_auth.SECRET.startswith("CHANGE_ME"),
    )

    print("=" * 60)
    print(" FVM 授权机器人 · Webhook")
    print(" AppID: %s" % app_id)
    print(" 验签公钥: %s…（由 AppSecret 派生）" % _HANDLER.pubkey.hex()[:16])
    print(" 授权密钥指纹: %s（要和游戏端 auth_client.gml 里的宏对得上）"
          % _secret_fingerprint(qq_auth.SECRET))
    print(" Ed25519 后端: %s" % ed25519.backend())
    if os.environ.get("COS_BUCKET"):
        print(" 账本: cos://%s/%s"
              % (os.environ["COS_BUCKET"],
                 os.environ.get("COS_KEY", "qqauth/ledger.json")))
    else:
        print(" ⚠️  账本走本地文件（没配 COS_*），云上这样会丢数据，仅限本地调试")
    print(" 每号上限: %d 台机器" % qq_auth.MAX_DEVICES_PER_UID)
    if qq_auth.SECRET.startswith("CHANGE_ME"):
        print(" ⚠️  授权签名密钥是占位符！发出去的码游戏端 100% 验不过。")
        print("    到「函数配置 → 环境变量」加 AUTH_SECRET，值是 tools/auth_secret.txt 的内容。")
        print("    （回调地址仍然能保存成功，但领码会被拒绝，别以为是机器人坏了）")
    print("=" * 60)
    return _HANDLER


def get_handler():
    return _HANDLER or build_handler()


# ---------------------------------------------------------------- SCF 入口

def _resp_text(status, text):
    """纯文本响应。同样不写 Content-Type，理由见 _resp()。"""
    return {"isBase64Encoded": False, "statusCode": int(status), "body": text}


def _resp(status, payload):
    """构造事件函数的 HTTP 响应。

    **不要手写 Content-Type。** 函数 URL 的「参数兼容模式」网关会自己补一个
    Content-Type，函数里再设一个，响应里就会出现重复的 Content-Type。
    curl 容忍这种不合规响应，Chrome 直接报 ERR_INVALID_RESPONSE —— 这个症状
    看起来像网络不通，实际是响应头不合规，排查极费时间。
    交给网关推断即可，QQ 平台那边也不看这个头。
    """
    return {
        "isBase64Encoded": False,
        "statusCode": int(status),
        "body": json.dumps(payload, ensure_ascii=False),
    }


def _raw_candidates(event):
    """还原「腾讯发来的原始字节」的若干候选。

    验签针对原始字节，一个字节都不能变。但函数 URL 交给事件函数的 body
    **已经是解码过的字符串**（官方文档里 event 示例没有 isBase64Encoded 字段），
    所以这里只能再编码回去。问题在于：中间层若用错了字符集解码，再编码就
    对不上原始字节，签名必然失败——而且只在 body 里出现中文时才发作
    （玩家的群昵称、消息内容都可能带中文），非常像「随机验签失败」。

    因此把所有常见的错解方式都试一遍。每个候选都要真的过一遍 Ed25519 验签，
    验不过就换下一个，**不存在绕过校验的可能**，安全性不受影响。
    """
    body = event.get("body")
    if body is None:
        return [b""]
    if isinstance(body, bytes):
        return [body]
    if not isinstance(body, str):
        body = str(body)

    out = []

    def add(b):
        if b and b not in out:
            out.append(b)

    if event.get("isBase64Encoded"):
        try:
            add(base64.b64decode(body))
        except Exception:
            pass

    add(body.encode("utf-8"))

    # 中间层把 utf-8 字节当成 latin-1 解码过（最常见的串码方式）
    try:
        add(body.encode("latin-1"))
    except Exception:
        pass

    # 万一中间层把 base64 文本当普通字符串塞进来
    if len(body) % 4 == 0 and body.isascii():
        try:
            add(base64.b64decode(body, validate=True))
        except Exception:
            pass

    return out or [b""]


def _headers(event):
    headers = event.get("headers")
    if isinstance(headers, dict):
        return headers
    return {}


def main_handler(event, context=None):
    """SCF 调用入口。"""
    try:
        handler = get_handler()
    except Exception as exc:
        print("[scf] 初始化失败：%s" % exc)
        return _resp(500, {"error": "not configured"})

    headers = _headers(event)
    candidates = _raw_candidates(event)

    # 用浏览器直接打开只是健康检查，没有签名也没有 body。
    # 直接把「配置到哪一步了」报出来——否则打开永远是同一句话，
    # 你根本没法判断环境变量有没有生效，只能翻日志。
    # 只报状态、不报桶名和任何密钥，且全是 ASCII，不怕没 charset。
    method = str(event.get("httpMethod") or "").upper()
    if method in ("GET", "HEAD") and not candidates[0]:
        cos_ok = all(os.environ.get(k, "").strip() for k in
                     ("COS_SECRET_ID", "COS_SECRET_KEY", "COS_REGION", "COS_BUCKET"))
        secret_ok = not qq_auth.SECRET.startswith("CHANGE_ME")
        print("[scf] 健康检查（GET）COS=%s 密钥=%s" % (cos_ok, secret_ok))
        lines = [
            "FVM auth bot is running.",
            "ledger : %s" % ("cos (configured)" if cos_ok
                             else "LOCAL FILE -- COS_* not set, data will be lost"),
            "secret : %s" % ("ok" if secret_ok
                             else "PLACEHOLDER -- issued codes will never verify"),
        ]
        return _resp_text(200, "\n".join(lines))

    status, payload = 401, {"error": "invalid signature"}
    for raw in candidates:
        status, payload = handler.handle(headers, raw)
        if status != 401:
            break

    if status == 401:
        # 验签失败时把「平台实际送来的东西」打出来。部署期最容易卡在这一步，
        # 而 SCF 不会告诉你 body 有没有被改编码、头有没有被改大小写、
        # 函数 URL 上的「参数兼容」有没有动过 body。
        # 这里不带任何密钥，body 是 QQ 的事件明文，可以放心打到日志里。
        try:
            sample = candidates[0][:300].decode("utf-8", "replace")
        except Exception:
            sample = repr(candidates[0][:300])
        print("[scf] 验签失败诊断：httpMethod=%r isBase64Encoded=%r 头=%s 候选=%d body[:300]=%r"
              % (method, event.get("isBase64Encoded"), sorted(headers.keys()),
                 len(candidates), sample))

    return _resp(status, payload)


# ---------------------------------------------------------------- 本地自检

def check():
    """不接腾讯，先把能查的都查一遍。"""
    ok = True
    print("① Ed25519 实现")
    if not ed25519.selftest():
        ok = False

    print("\n② 配置")
    app_id = os.environ.get("QQ_APP_ID", "").strip() or bot.APP_ID
    app_secret = os.environ.get("QQ_APP_SECRET", "").strip() or bot.APP_SECRET
    if app_id and app_secret:
        print("  ✓ AppID %s，AppSecret 已填（%d 位）" % (app_id, len(app_secret)))
    else:
        ok = False
        print("  ✗ 缺 AppID / AppSecret")

    secret = qq_auth.SECRET
    if secret.startswith("CHANGE_ME"):
        ok = False
        print("  ✗ 授权签名密钥还是占位符！发出的码游戏端一律验不过")
        print("    修：环境变量 AUTH_SECRET 填 tools/auth_secret.txt 里的那串")
    else:
        print("  ✓ 授权签名密钥 %d 位，指纹 %s"
              % (len(secret), _secret_fingerprint(secret)))

    pool = qq_auth.load_pool()
    print("  %s 码池 %d 个（文件 %s）"
          % ("✓" if pool else "✗", len(pool), qq_auth.POOL_PATH))
    if not pool:
        ok = False

    print("\n③ 验签种子")
    if app_secret:
        seed = ed25519.seed_from_secret(app_secret)
        print("  ✓ seed %d 字节，公钥 %s…" % (len(seed), ed25519.public_key(seed).hex()[:16]))

    print("\n④ 账本")
    sid = os.environ.get("COS_SECRET_ID", "").strip()
    if sid and os.environ.get("COS_SECRET_KEY", "").strip() \
            and os.environ.get("COS_REGION", "").strip() \
            and os.environ.get("COS_BUCKET", "").strip():
        client = store.CosClient(
            sid,
            os.environ["COS_SECRET_KEY"].strip(),
            os.environ["COS_REGION"].strip(),
            os.environ["COS_BUCKET"].strip(),
        )
        key = os.environ.get("COS_KEY", "qqauth/ledger.json").strip() or "qqauth/ledger.json"
        try:
            data, exists = client.get_json(key)
            if exists:
                entries = (data or {}).get("entries", {})
                print("  ✓ COS 连通，账本已有 %d 条记录（cos://%s/%s）"
                      % (len(entries), os.environ["COS_BUCKET"], key))
            else:
                print("  ✓ COS 连通，账本还不存在（第一次发码会自动创建）")
                # 顺手验证写权限，别等玩家来领码才发现只能读不能写
                client.put_json(key, {"entries": {}})
                print("  ✓ 写权限正常")
        except Exception as exc:
            ok = False
            print("  ✗ COS 读写失败：%s" % exc)
            print("    常见原因：SecretId/Key 错、bucket 名少了 -APPID 后缀、region 填成 ap-guangzhou-1")
    else:
        print("  ⚠️  没配 COS_*，走本地文件（只适合本地调试）")

    print("\n" + ("全部正常。" if ok else "有项目没通过，见上面的 ✗。"))
    return 0 if ok else 1


def simulate():
    """不联网，模拟腾讯推来一条群 @ 消息，把发码链路整条跑一遍。

    用内存账本，绝不碰真实账本——否则你在本地点一下，云端就少一个码。
    """
    mem = store.MemoryStore()
    bot_handle = build_handler()
    bot_handle.ledger_factory = lambda: store.Ledger(mem)

    text = "/授权 CF8A-EFFE"
    uid = "SIMULATED_OPENID"

    print("\n模拟消息：%r" % text)
    out = bot_handle._handle_text(uid, text)
    print("回复内容：\n%s\n" % (out or "(无回复)"))

    if not out or "FVM4-" not in out:
        print("✗ 没有产出授权码")
        return 1

    code = "FVM4-" + out.split("FVM4-")[1].split()[0].strip()
    valid, code_id, hwid = qq_auth.verify(code)
    print("回验签名：%s  码ID=%s  绑定机器=%s"
          % ("✓ 有效" if valid else "✗ 无效", code_id, hwid))

    # 同一台机器再领一次，必须拿回同一个码（不消耗新码池 ID）
    again = bot_handle._handle_text(uid, text)
    same = again and code in again
    print("同机重领：%s" % ("✓ 返回原码，未消耗新码" if same else "✗ 又发了一个新码"))

    if valid and hwid == "CF8AEFFE" and same:
        print("\n✓ 链路正确：这条码在你这台机器（CF8A-EFFE）上可以激活")
        return 0
    print("\n✗ 链路有问题，看上面哪一步不对")
    return 1


def main():
    if "--check" in sys.argv:
        return check()
    if "--simulate" in sys.argv:
        return simulate()
    print(__doc__)
    return 0


if __name__ == "__main__":
    sys.exit(main())

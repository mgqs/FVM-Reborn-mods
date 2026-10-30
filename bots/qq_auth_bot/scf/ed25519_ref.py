#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Ed25519 —— 纯标准库实现（RFC 8032）+ 可选加速。

为什么要自带一份
----------------
腾讯云函数按理说能装第三方包，但 `cryptography` 是 C 扩展，必须打
manylinux 的 wheel 才能在函数的 Linux 环境里跑。一旦版本对不上，表现是
「回调地址保存不了，平台只提示签名校验不通过」——这个错很难自己查出来。

所以这里的策略是：
  1. 先尝试 `cryptography`（快，几十倍）
  2. 没有就用下面的纯 Python 实现（零依赖，功能完全一致）

QQ 开放平台的验签规则（官方文档《安全和授权》）：
    seed = botSecret，不足 32 字节就不断重复自身，然后截断到 32 字节
    签名 = Ed25519(seed, X-Signature-Timestamp + body)
    握手 = Ed25519(seed, event_ts + plain_token)

实现要点：用**扩展扭曲爱德华兹坐标** (X:Y:Z:T)。
朴素写法每做一次点加就要算一次模逆（pow(x, p-2, p)），252 次标量乘会
累积成几百毫秒，直接顶爆函数的 3 秒响应上限。扩展坐标把除法推迟到最后
一次，实测快 40 倍以上。
"""

import hashlib

_P = 2 ** 255 - 19
_L = 2 ** 252 + 27742317777372353535851937790883648493
_D = -121665 * pow(121666, _P - 2, _P) % _P
_D2 = 2 * _D % _P
_I = pow(2, (_P - 1) // 4, _P)

try:  # pragma: no cover - 取决于运行环境
    from cryptography.hazmat.primitives.asymmetric.ed25519 import (
        Ed25519PrivateKey,
        Ed25519PublicKey,
    )

    _HAVE_CRYPTOGRAPHY = True
except Exception:  # pragma: no cover
    _HAVE_CRYPTOGRAPHY = False


def backend():
    return "cryptography" if _HAVE_CRYPTOGRAPHY else "pure-python"


# ---------------------------------------------------------------- 曲线运算

def _inv(x):
    return pow(x, _P - 2, _P)


def _xrecover(y):
    xx = (y * y - 1) * _inv(_D * y * y + 1) % _P
    x = pow(xx, (_P + 3) // 8, _P)
    if (x * x - xx) % _P != 0:
        x = x * _I % _P
    if x % 2 != 0:
        x = _P - x
    return x


_BY = 4 * _inv(5) % _P
_BX = _xrecover(_BY)
# 基点用扩展坐标表示：(X, Y, Z, T)，where x = X/Z, y = Y/Z, T = XY/Z
_B_EXT = (_BX % _P, _BY % _P, 1, _BX * _BY % _P)
_ONE_EXT = (0, 1, 1, 0)


def _on_curve(x, y):
    return (-x * x + y * y - 1 - _D * x * x * y * y) % _P == 0


def _add_ext(p, q):
    """扩展坐标下的点加（a = -1 的扭曲爱德华兹曲线）。"""
    x1, y1, z1, t1 = p
    x2, y2, z2, t2 = q
    a = (y1 - x1) * (y2 - x2) % _P
    b = (y1 + x1) * (y2 + x2) % _P
    c = t1 * _D2 * t2 % _P
    d = z1 * 2 * z2 % _P
    e = b - a
    f = d - c
    g = d + c
    h = b + a
    return (e * f % _P, g * h % _P, f * g % _P, e * h % _P)


def _double_ext(p):
    x1, y1, z1, _t1 = p
    a = x1 * x1 % _P
    b = y1 * y1 % _P
    c = 2 * z1 * z1 % _P
    h = a + b
    e = h - (x1 + y1) * (x1 + y1)
    g = a - b
    f = c + g
    return (e * f % _P, g * h % _P, f * g % _P, e * h % _P)


def _mul_ext(point, scalar):
    """标量乘：二进制展开，从左到右 double-and-add。"""
    if scalar == 0:
        return _ONE_EXT
    acc = _ONE_EXT
    for ch in bin(scalar)[2:]:
        acc = _double_ext(acc)
        if ch == "1":
            acc = _add_ext(acc, point)
    return acc


def _to_affine(point):
    x, y, z, _t = point
    if z == 0:
        return (0, 1)
    zinv = _inv(z)
    return (x * zinv % _P, y * zinv % _P)


def _encode_ext(point):
    x, y = _to_affine(point)
    return (y | ((x & 1) << 255)).to_bytes(32, "little")


def _encode_point_affine(x, y):
    return (y | ((x & 1) << 255)).to_bytes(32, "little")


def _decode_point(data):
    """32 字节 → 扩展坐标。格式不合法抛 ValueError。"""
    if len(data) != 32:
        raise ValueError("点必须是 32 字节")
    y = int.from_bytes(data, "little") & ((1 << 255) - 1)
    sign = data[31] >> 7
    if y >= _P:
        raise ValueError("y 越界")
    x = _xrecover(y)
    if (x & 1) != sign:
        x = _P - x
    if not _on_curve(x, y):
        raise ValueError("点不在曲线上")
    return (x, y, 1, x * y % _P)


def _expand_seed(seed):
    if len(seed) != 32:
        raise ValueError("seed 必须是 32 字节，实际 %d" % len(seed))
    h = hashlib.sha512(seed).digest()
    a = int.from_bytes(h[:32], "little")
    a &= (1 << 254) - 8
    a |= 1 << 254
    return a, h[32:], _encode_ext(_mul_ext(_B_EXT, a))


# ---------------------------------------------------------------- 公开 API

def seed_from_secret(secret):
    """把 Bot Secret 按官方规则拉成 32 字节 seed。

    官方 Go 示例：
        seed := botSecret
        for len(seed) < 32 { seed = strings.Repeat(seed, 2) }   // 整体重复
        seed = seed[:32]
    注意是「整体重复两遍」而不是「单字符重复」。
    """
    raw = (secret or "").encode("utf-8")
    if not raw:
        raise ValueError("Bot Secret 不能为空")
    buf = raw
    while len(buf) < 32:
        buf = buf + buf
    return buf[:32]


def public_key(seed):
    if _HAVE_CRYPTOGRAPHY:
        return Ed25519PrivateKey.from_private_bytes(seed).public_key().public_bytes_raw()
    return _expand_seed(seed)[2]


def sign(seed, message):
    """返回 64 字节签名。"""
    if _HAVE_CRYPTOGRAPHY:
        return Ed25519PrivateKey.from_private_bytes(seed).sign(message)
    a, prefix, pub = _expand_seed(seed)
    r = int.from_bytes(hashlib.sha512(prefix + message).digest(), "little") % _L
    big_r = _encode_ext(_mul_ext(_B_EXT, r))
    k = int.from_bytes(hashlib.sha512(big_r + pub + message).digest(), "little") % _L
    s = (r + k * a) % _L
    return big_r + s.to_bytes(32, "little")


def verify(public, message, signature):
    """校验签名。任何异常都当作 False —— 调用方只需要一个是/否。"""
    try:
        if len(signature) != 64 or len(public) != 32:
            return False
        if _HAVE_CRYPTOGRAPHY:
            Ed25519PublicKey.from_public_bytes(public).verify(signature, message)
            return True
        a_point = _decode_point(public)
        r_point = _decode_point(signature[:32])
        s = int.from_bytes(signature[32:], "little")
        if s >= _L:
            return False
        k = int.from_bytes(
            hashlib.sha512(signature[:32] + public + message).digest(), "little"
        ) % _L
        left = _encode_ext(_mul_ext(_B_EXT, s))
        right = _encode_ext(_add_ext(r_point, _mul_ext(a_point, k)))
        return left == right
    except Exception:
        return False


# ---------------------------------------------------------------- 自检

# RFC 8032 §7.1 TEST 1（空消息）
_VEC_SEED = bytes.fromhex(
    "9d61b19deffd5a60ba844af492ec2cc44449c5697b326919703bac031cae7f60"
)
_VEC_PUB = bytes.fromhex(
    "d75a980182b10ab7d54bfed3c964073a0ee172f3daa62325af021a68f707511a"
)
_VEC_SIG = bytes.fromhex(
    "e5564300c360ac729086e2cc806e828a84877f1eb8e5d974d873e06522490155"
    "5fb8821590a33bacc61e39701cf9b46bd25bf5f0595bbe24655141438e7a100b"
)

# RFC 8032 §7.1 TEST 2（1 字节消息 0x72）
_VEC2_SEED = bytes.fromhex(
    "4ccd089b28ff96da9db6c346ec114e0f5b8a319f35aba624da8cf6ed4fb8a6fb"
)
_VEC2_PUB = bytes.fromhex(
    "3d4017c3e843895a92b70aa74d1b7ebc9c982ccf2ec4968cc0cd55f12af4660c"
)
_VEC2_MSG = bytes.fromhex("72")
_VEC2_SIG = bytes.fromhex(
    "92a009a9f0d4cab8720e820b5f642540a2b27b5416503f8fb3762223ebdb69da"
    "085ac1e43e15996e458f3613d0f11d8c387b2eaeb4302aeeb00d291612bb0c00"
)


def selftest(verbose=True):
    """用 RFC 官方向量验证，防止自己手写时算错。"""
    import time

    ok = True

    def check(cond, good, bad):
        nonlocal ok
        if cond:
            if verbose:
                print("  ✓ %s" % good)
        else:
            ok = False
            print("  ✗ %s" % bad)

    t0 = time.time()
    pub = public_key(_VEC_SEED)
    t1 = time.time()
    check(pub == _VEC_PUB, "公钥派生（RFC 8032 TEST 1）",
          "公钥派生错误：期望 %s 实际 %s" % (_VEC_PUB.hex(), pub.hex()))

    sig = sign(_VEC_SEED, b"")
    t2 = time.time()
    check(sig == _VEC_SIG, "空消息签名（RFC 8032 TEST 1）",
          "签名错误：期望 %s 实际 %s" % (_VEC_SIG.hex(), sig.hex()))

    check(verify(_VEC_PUB, b"", _VEC_SIG), "验签通过", "正确签名被判为无效")
    t3 = time.time()

    # 第二组向量（非空消息，覆盖不同分支）
    check(public_key(_VEC2_SEED) == _VEC2_PUB, "公钥派生（RFC 8032 TEST 2）",
          "TEST 2 公钥错误")
    check(sign(_VEC2_SEED, _VEC2_MSG) == _VEC2_SIG, "签名（RFC 8032 TEST 2）",
          "TEST 2 签名错误")
    check(verify(_VEC2_PUB, _VEC2_MSG, _VEC2_SIG), "验签（RFC 8032 TEST 2）",
          "TEST 2 验签失败")

    # 篡改必须失败
    bad = bytearray(_VEC_SIG)
    bad[0] ^= 0x01
    check(not verify(_VEC_PUB, b"", bytes(bad)), "篡改签名被拒",
          "篡改后的签名竟然通过了")
    check(not verify(_VEC_PUB, b"x", _VEC_SIG), "换消息被拒",
          "换了消息竟然还能通过")

    # 垃圾输入不能抛异常
    crashed = None
    for junk in (b"", b"\x00" * 32, b"\xff" * 64):
        try:
            verify(junk, b"", _VEC_SIG)
            verify(_VEC_PUB, b"", junk)
        except Exception as exc:
            crashed = exc
    check(crashed is None, "垃圾输入不抛异常", "垃圾输入抛异常：%s" % crashed)

    # seed_from_secret 规则
    check(ed25519_seed_ok(), "seed 派生规则（整体重复 + 截断）", "seed 派生规则错误")

    if verbose:
        print("  · 后端 %s｜公钥 %.1f ms｜签名 %.1f ms｜验签 %.1f ms"
              % (backend(), (t1 - t0) * 1000, (t2 - t1) * 1000, (t3 - t2) * 1000))
    return ok


def ed25519_seed_ok():
    """验证「不足 32 字节就整体重复」这条规则。"""
    # 32 字节正好：原样
    a = seed_from_secret("A" * 32)
    if a != b"A" * 32:
        return False
    # 16 字节：重复两遍 → 32
    b = seed_from_secret("0123456789abcdef")
    if b != b"0123456789abcdef" * 2:
        return False
    # 20 字节：20 → 40 → 截断成 32 个 x
    c = seed_from_secret("x" * 20)
    if len(c) != 32 or c != b"x" * 32:
        return False
    # 24 字节：24 → 48 → 截断 32（前 32 个 x）
    d = seed_from_secret("y" * 24)
    if len(d) != 32 or d[:24] != b"y" * 24 or d[24:] != b"y" * 8:
        return False
    return True


if __name__ == "__main__":
    import sys

    print("Ed25519 后端：%s" % backend())
    sys.exit(0 if selftest() else 1)

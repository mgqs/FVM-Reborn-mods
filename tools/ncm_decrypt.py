# -*- coding: utf-8 -*-
"""网易云 .ncm 解密（纯 Python 实现，不依赖任何第三方库）

为什么要自己写 AES：
本机的 python 装不上 pycryptodome（pip 超时），而 ncm 的密钥段必须用
AES-128-ECB 解。这里用 ~90 行纯 Python 实现，只解 128 字节的 key，
速度完全够用；音频本体走 RC4（自写流式实现）。

用法:
    python tools/ncm_decrypt.py "D:\\CloudMusic"            # 只看会解什么
    python tools/ncm_decrypt.py "D:\\CloudMusic" --apply    # 真解密
    python tools/ncm_decrypt.py "D:\\CloudMusic" --apply --out "D:\\CloudMusic\\_dec"
"""

import base64
import json
import os
import struct
import sys

# ---------------------------------------------------------------- AES-128 解密

def _gen_sbox():
    p = q = 1
    sbox = [0] * 256
    while True:
        # p 在 GF(2^8) 里乘 3
        p = (p ^ ((p << 1) & 0xFF) ^ (0x1B if p & 0x80 else 0)) & 0xFF
        # q 是 p 的乘法逆
        q ^= (q << 1) & 0xFF
        q ^= (q << 2) & 0xFF
        q ^= (q << 4) & 0xFF
        q &= 0xFF
        if q & 0x80:
            q ^= 0x09
        x = q ^ ((q << 1) | (q >> 7)) & 0xFF
        x ^= ((q << 2) | (q >> 6)) & 0xFF
        x ^= ((q << 3) | (q >> 5)) & 0xFF
        x ^= ((q << 4) | (q >> 4)) & 0xFF
        sbox[p] = (x ^ 0x63) & 0xFF
        if p == 1:
            break
    sbox[0] = 0x63
    return sbox


_SBOX = _gen_sbox()
_INV_SBOX = [0] * 256
for _i, _v in enumerate(_SBOX):
    _INV_SBOX[_v] = _i
_RCON = [0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1B, 0x36]


def _xtime(a):
    a <<= 1
    if a & 0x100:
        a = (a ^ 0x1B) & 0xFF
    return a


def _gmul(a, b):
    r = 0
    for _ in range(8):
        if b & 1:
            r ^= a
        b >>= 1
        a = _xtime(a)
    return r


_MUL9 = [_gmul(x, 9) for x in range(256)]
_MUL11 = [_gmul(x, 11) for x in range(256)]
_MUL13 = [_gmul(x, 13) for x in range(256)]
_MUL14 = [_gmul(x, 14) for x in range(256)]


def _expand_key(key):
    """返回 11 组 round key，每组 16 字节。"""
    w = [list(key[i * 4:i * 4 + 4]) for i in range(4)]
    for i in range(4, 44):
        t = list(w[i - 1])
        if i % 4 == 0:
            t = t[1:] + t[:1]
            t = [_SBOX[b] for b in t]
            t[0] ^= _RCON[i // 4 - 1]
        w.append([w[i - 4][j] ^ t[j] for j in range(4)])
    return [sum(w[i * 4:i * 4 + 4], []) for i in range(11)]


def _inv_shift_rows(s):
    # 行 r 循环右移 r 位（state 索引 = r + 4*c）
    for r in range(1, 4):
        row = [s[r + 4 * c] for c in range(4)]
        row = row[-r:] + row[:-r]
        for c in range(4):
            s[r + 4 * c] = row[c]


def _inv_mix_columns(s):
    for c in range(4):
        a = [s[4 * c + r] for r in range(4)]
        s[4 * c + 0] = _MUL14[a[0]] ^ _MUL11[a[1]] ^ _MUL13[a[2]] ^ _MUL9[a[3]]
        s[4 * c + 1] = _MUL9[a[0]] ^ _MUL14[a[1]] ^ _MUL11[a[2]] ^ _MUL13[a[3]]
        s[4 * c + 2] = _MUL13[a[0]] ^ _MUL9[a[1]] ^ _MUL14[a[2]] ^ _MUL11[a[3]]
        s[4 * c + 3] = _MUL11[a[0]] ^ _MUL13[a[1]] ^ _MUL9[a[2]] ^ _MUL14[a[3]]


def _decrypt_block(block, rk):
    s = [block[i] ^ rk[10][i] for i in range(16)]
    for rnd in range(9, 0, -1):
        _inv_shift_rows(s)
        s = [_INV_SBOX[b] for b in s]
        s = [s[i] ^ rk[rnd][i] for i in range(16)]
        _inv_mix_columns(s)
    _inv_shift_rows(s)
    s = [_INV_SBOX[b] for b in s]
    return bytes(s[i] ^ rk[0][i] for i in range(16))


def aes_ecb_decrypt(data, key):
    rk = _expand_key(key)
    out = bytearray()
    for i in range(0, len(data) - len(data) % 16, 16):
        out += _decrypt_block(data[i:i + 16], rk)
    return bytes(out)


def _unpad(b):
    if not b:
        return b
    n = b[-1]
    if 1 <= n <= 16 and len(b) >= n:
        return b[:-n]
    return b


# ------------------------------------------------------------------- RC4 流式

def rc4_crypt(data, key):
    box = list(range(256))
    j = 0
    klen = len(key)
    for i in range(256):
        j = (j + box[i] + key[i % klen]) & 0xFF
        box[i], box[j] = box[j], box[i]

    out = bytearray(len(data))
    i = j = 0
    CHUNK = 8192
    pos = 0
    total = len(data)
    while pos < total:
        end = min(pos + CHUNK, total)
        buf = bytearray(end - pos)
        for k in range(end - pos):
            i = (i + 1) & 0xFF
            j = (j + box[i]) & 0xFF
            box[i], box[j] = box[j], box[i]
            buf[k] = box[(box[i] + box[j]) & 0xFF]
        seg = data[pos:end]
        out[pos:end] = bytes(a ^ b for a, b in zip(seg, buf))
        pos = end
    return bytes(out)


# ------------------------------------------------------------------ ncm 解析

CORE_KEY = bytes.fromhex("687A4852416D736F356B496E62617857")   # hzHRAmso5kInbaxW
META_KEY = bytes.fromhex("2331346C6A6B5F215C5D2630553C2728")   # #14ljk_!\]&0U<'(


def decrypt_ncm(path):
    """返回 (audio_bytes, fmt, meta_dict)。失败抛异常。"""
    with open(path, "rb") as f:
        if f.read(8) != b"CTENFDAM":
            raise ValueError("不是 ncm 文件（magic 不符）")
        f.read(2)  # gap

        key_len = struct.unpack("<I", f.read(4))[0]
        key_raw = bytes(b ^ 0x64 for b in f.read(key_len))
        rc4_key = _unpad(aes_ecb_decrypt(key_raw, CORE_KEY))[17:]

        meta_len = struct.unpack("<I", f.read(4))[0]
        meta_raw = bytes(b ^ 0x63 for b in f.read(meta_len))
        meta = {}
        if meta_len > 22:
            try:
                m = base64.b64decode(meta_raw[22:])
                m = _unpad(aes_ecb_decrypt(m, META_KEY))
                txt = m.decode("utf-8", "ignore")
                if txt.startswith("music:"):
                    txt = txt[6:]
                meta = json.loads(txt)
            except Exception:
                meta = {}

        f.read(4)  # crc32
        f.read(5)  # gap
        img_len = struct.unpack("<I", f.read(4))[0]
        f.read(img_len)
        audio = f.read()

    fmt = (meta.get("format") or "mp3").lower()
    return rc4_crypt(audio, rc4_key), fmt, meta


def _safe(name):
    bad = '<>:"/\\|?*'
    for c in bad:
        name = name.replace(c, "_")
    return name.strip() or "untitled"


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    apply = "--apply" in sys.argv
    src = args[0] if args else r"D:\CloudMusic"
    out = args[1] if len(args) > 1 else os.path.join(src, "_dec")

    files = []
    for root, _dirs, names in os.walk(src):
        for n in names:
            if n.lower().endswith(".ncm"):
                files.append(os.path.join(root, n))

    print("找到 %d 个 ncm" % len(files))
    if not files:
        return

    if not apply:
        for p in files:
            print("  待解:", os.path.basename(p))
        print("\n加 --apply 才会真正解密")
        return

    os.makedirs(out, exist_ok=True)
    ok = fail = 0
    for p in files:
        base = os.path.splitext(os.path.basename(p))[0]
        try:
            audio, fmt, meta = decrypt_ncm(p)
            name = _safe(meta.get("musicName") or base)
            artist = meta.get("artist")
            if isinstance(artist, list) and artist:
                name = "%s - %s" % (name, artist[0][0] if isinstance(artist[0], list) else artist[0])
            dst = os.path.join(out, name + "." + fmt)
            n = 2
            while os.path.exists(dst):
                dst = os.path.join(out, "%s_%d.%s" % (name, n, fmt))
                n += 1
            with open(dst, "wb") as f:
                f.write(audio)
            print("  OK  %-40s -> %s (%.1f MB)" % (os.path.basename(p)[:40], fmt, len(audio) / 1048576.0))
            ok += 1
        except Exception as e:
            print("  ERR %-40s : %s" % (os.path.basename(p)[:40], e))
            fail += 1

    print("\n成功 %d / 失败 %d，输出目录: %s" % (ok, fail, out))


if __name__ == "__main__":
    main()

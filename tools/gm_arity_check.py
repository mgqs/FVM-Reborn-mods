# -*- coding: utf-8 -*-
"""
GML 内置函数参数个数检查（对应编译错误 GM1020 / GM1010）

只检查 arity 固定、且历史上有过误用记录的少量内建函数，避免误报。
用法：
    python tools/gm_arity_check.py                # 扫全工程
    python tools/gm_arity_check.py scripts/hex_batch3/hex_batch3.gml
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# 函数名 -> (最少参数, 最多参数)。最多为 None 表示不限。
ARITY = {
    "ds_exists": (2, 2),
    "ds_map_exists": (2, 2),
    "ds_map_find_value": (2, 2),
    "ds_map_set": (3, 3),
    "ds_map_delete": (2, 2),
    "ds_map_size": (1, 1),
    "ds_map_clear": (1, 1),
    # 1 参数（2022.5+ 返回新数组）/ 2 参数（旧签名，写入已存在的数组）都合法
    "ds_map_keys_to_array": (1, 2),
    "ds_map_destroy": (1, 1),
    "ds_list_size": (1, 1),
    "ds_list_destroy": (1, 1),
    "ds_list_empty": (1, 1),
    "array_length": (1, 1),
    "array_index_of": (2, 2),
    "array_delete": (3, 3),
    "string_length": (1, 1),
    "variable_global_exists": (1, 1),
    "variable_instance_exists": (2, 2),
    "variable_struct_exists": (2, 2),
    "instance_exists": (1, 1),
    "instance_destroy": (0, None),
    "is_struct": (1, 1),
    "is_undefined": (1, 1),
    "is_array": (1, 1),
    "instance_number": (1, 1),
    "instance_find": (2, 2),
    "point_distance": (4, 4),
    "irandom": (1, 1),
    "irandom_range": (2, 2),
    "random_range": (2, 2),
}


def strip_noise(src):
    """把注释和字符串内容替换成空格，保持长度不变，便于按偏移定位。"""
    out = list(src)
    n = len(src)
    i = 0
    in_str = None
    in_line_comment = False
    in_block = False
    while i < n:
        c = src[i]
        nxt = src[i + 1] if i + 1 < n else ""
        if in_line_comment:
            if c == "\n":
                in_line_comment = False
            else:
                out[i] = " "
            i += 1
            continue
        if in_block:
            if c == "*" and nxt == "/":
                out[i] = out[i + 1] = " "
                i += 2
                in_block = False
                continue
            if c != "\n":
                out[i] = " "
            i += 1
            continue
        if in_str:
            if c == "\\":
                out[i] = " "
                if i + 1 < n:
                    out[i + 1] = " "
                i += 2
                continue
            if c == in_str:
                in_str = None
            else:
                out[i] = " "
            i += 1
            continue
        if c == "/" and nxt == "/":
            out[i] = out[i + 1] = " "
            i += 2
            in_line_comment = True
            continue
        if c == "/" and nxt == "*":
            out[i] = out[i + 1] = " "
            i += 2
            in_block = True
            continue
        if c in "\"'":
            in_str = c
            out[i] = " "
            i += 1
            continue
        i += 1
    return "".join(out)


def count_args(text, open_idx):
    """open_idx 指向 '('，返回 (参数个数, 匹配的 ')' 位置)。"""
    depth = 0
    n = len(text)
    i = open_idx
    args = 1
    while i < n:
        c = text[i]
        if c in "([{":
            depth += 1
        elif c in ")]}":
            depth -= 1
            if depth == 0:
                inner = text[open_idx + 1:i].strip()
                if inner == "":
                    return 0, i
                return args, i
        elif c == "," and depth == 1:
            args += 1
        i += 1
    return -1, n


def check(path):
    try:
        src = open(path, encoding="utf-8", errors="replace").read()
    except OSError:
        return []
    clean = strip_noise(src)
    bad = []
    for name, (lo, hi) in ARITY.items():
        for m in re.finditer(r"(?<![\w.])" + re.escape(name) + r"\s*\(", clean):
            # 跳过函数定义
            before = clean[max(0, m.start() - 20):m.start()]
            if re.search(r"function\s+$", before):
                continue
            open_idx = clean.index("(", m.end() - 1)
            cnt, _ = count_args(clean, open_idx)
            if cnt < 0:
                continue
            if cnt < lo or (hi is not None and cnt > hi):
                line = src[:m.start()].count("\n") + 1
                snippet = src.split("\n")[line - 1].strip()[:90]
                bad.append((line, name, cnt, lo, hi, snippet))
    return bad


def main():
    if len(sys.argv) > 1:
        files = [p if os.path.isabs(p) else os.path.join(ROOT, p) for p in sys.argv[1:]]
    else:
        files = []
        for dp, dn, fn in os.walk(ROOT):
            if ".git" in dp or "\\tools" in dp:
                continue
            for f in fn:
                if f.endswith(".gml"):
                    files.append(os.path.join(dp, f))

    total = 0
    for p in files:
        for line, name, cnt, lo, hi, snip in check(p):
            rel = os.path.relpath(p, ROOT).replace("\\", "/")
            want = "至少 %d" % lo if hi is None else ("%d" % lo if lo == hi else "%d~%d" % (lo, hi))
            print("[X] %s:%d  函数 '%s' 需要 %s 个参数，实际 %d" % (rel, line, name, want, cnt))
            print("      %s" % snip)
            total += 1
    print("\n扫描 %d 个文件，参数个数异常 %d 处" % (len(files), total))
    return 1 if total else 0


if __name__ == "__main__":
    sys.exit(main())

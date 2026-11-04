# -*- coding: utf-8 -*-
"""海克斯二期静态自检：括号/引号配平、函数定义与调用、字段读写对齐。"""
import re, os, sys, json

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
B3 = os.path.join(ROOT, "scripts", "hex_batch3", "hex_batch3.gml")

def read(p):
    with open(p, "r", encoding="utf-8") as f:
        return f.read()

def strip_code(src):
    """去掉注释与字符串，只留语法骨架"""
    out = []
    i, n = 0, len(src)
    while i < n:
        c = src[i]
        if c == "/" and i + 1 < n and src[i+1] == "/":
            while i < n and src[i] != "\n":
                i += 1
        elif c == "/" and i + 1 < n and src[i+1] == "*":
            i += 2
            while i + 1 < n and not (src[i] == "*" and src[i+1] == "/"):
                i += 1
            i += 2
        elif c == '"':
            i += 1
            while i < n:
                if src[i] == "\\":
                    i += 2; continue
                if src[i] == '"':
                    i += 1; break
                i += 1
            out.append('""')
        elif c == "'":
            i += 1
            while i < n:
                if src[i] == "\\":
                    i += 2; continue
                if src[i] == "'":
                    i += 1; break
                i += 1
            out.append("''")
        else:
            out.append(c); i += 1
    return "".join(out)

def balance(path):
    src = read(path)
    code = strip_code(src)
    depth_br = depth_sq = depth_par = 0
    minvals = [0, 0, 0]
    for ch in code:
        if ch == "{": depth_br += 1
        elif ch == "}": depth_br -= 1
        elif ch == "[": depth_sq += 1
        elif ch == "]": depth_sq -= 1
        elif ch == "(": depth_par += 1
        elif ch == ")": depth_par -= 1
        minvals[0] = min(minvals[0], depth_br)
        minvals[1] = min(minvals[1], depth_sq)
        minvals[2] = min(minvals[2], depth_par)
    return depth_br, depth_sq, depth_par, minvals

files = []
for dp, dn, fn in os.walk(ROOT):
    if ".git" in dp or ".workbuddy" in dp: continue
    for f in fn:
        if f.endswith(".gml"):
            files.append(os.path.join(dp, f))

print("=== 1. 括号配平（全部 .gml） ===")
bad = 0
for p in sorted(files):
    b, s, pa, mins = balance(p)
    if b or s or pa or min(mins) < 0:
        bad += 1
        rel = os.path.relpath(p, ROOT)
        print("  [X] %-70s  {}:%-4d []:%-4d ():%-4d  min=%s" % (rel, b, s, pa, mins))
print("  扫描 %d 个文件，异常 %d 个" % (len(files), bad))

print()
print("=== 2. hex_b3_* 函数定义 / 调用对齐 ===")
b3src = read(B3)
defined = set(re.findall(r"^function\s+(hex_b3_\w+)\s*\(", b3src, re.M))
called_all, called_ext = set(), set()
for p in files:
    src = read(p)
    hits = set(re.findall(r"\b(hex_b3_\w+)\s*\(", src))
    if os.path.abspath(p) == os.path.abspath(B3):
        # 本文件内的调用次数要减掉「定义处那一处」
        for h in hits:
            if len(re.findall(r"\b" + h + r"\s*\(", src)) > 1:
                called_all.add(h)
    else:
        called_all |= hits
        called_ext |= hits
missing = sorted(c for c in called_all if c not in defined)
print("  定义 %d 个函数" % len(defined))
if missing:
    for m in missing:
        where = [os.path.relpath(p, ROOT) for p in files if re.search(r"\b" + m + r"\s*\(", read(p))]
        print("  [X] 未定义：%s  (调用点: %s)" % (m, ", ".join(where[:3])))
else:
    print("  [OK] 所有 hex_b3_* 调用都有定义")

unwired = sorted(d for d in defined if d not in called_ext and d not in called_all)
if unwired:
    print("  [X] 定义了但全工程无人调用（接线遗漏）：")
    for u in unwired:
        print("      - %s" % u)
else:
    print("  [OK] 无孤立函数")

print()
print("=== 3. b3_* 状态字段：ensure 声明 vs 实际读取 ===")
ensure_block = ""
m = re.search(r"function\s+hex_b3_ensure\s*\(\)\s*\{", b3src)
if m:
    # 取到函数结束（粗略：下一个 \nfunction ）
    nxt = b3src.find("\nfunction ", m.end())
    ensure_block = b3src[m.end(): nxt if nxt > 0 else len(b3src)]
declared = set(re.findall(r"\b_s\.(b3_\w+)\s*=", ensure_block))
declared |= set(re.findall(r"\b_s\.(b3_\w+)\s*=", b3src))
read_fields = set()
for p in files:
    src = read(p)
    read_fields |= set(re.findall(r"\bhex_state\.(b3_\w+)", src))
read_fields |= set(re.findall(r"\b_s\.(b3_\w+)", b3src))
undeclared = sorted(f for f in read_fields if f not in declared)
print("  ensure/apply 声明 %d 个字段，代码引用 %d 个" % (len(declared), len(read_fields)))
if undeclared:
    for f in undeclared:
        print("  [X] 引用但未声明：%s" % f)
else:
    print("  [OK] 无未声明字段")

print()
print("=== 4. 词条注册数量 ===")
reg_ids = re.findall(r'hex_register\(\s*"(hex_\w+)"', b3src)
print("  hex_batch3 注册 %d 条: %s" % (len(reg_ids), ", ".join(reg_ids)))
allids = []
for dp, dn, fn in os.walk(os.path.join(ROOT, "scripts")):
    for f in fn:
        if f.endswith(".gml"):
            s = read(os.path.join(dp, f))
            allids += re.findall(r'hex_register\(\s*"(hex_\w+)"', s)
print("  全库注册 %d 条（含 Hana 伪词条）" % len(set(allids)))

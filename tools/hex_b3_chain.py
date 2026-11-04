# -*- coding: utf-8 -*-
"""二期词条表 -> hex_b3_apply 解析 -> 读取点 的三段式连通性检查"""
import re, os, io

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
B3 = os.path.join(ROOT, "scripts", "hex_batch3", "hex_batch3.gml")
src = io.open(B3, encoding="utf-8").read()

# ── 1. 取词条表（从 hex_register_batch3 之后的全部 hex_register 块）──
reg_start = src.find("function hex_register_batch3")
table = src[reg_start:]
entries = re.findall(r'hex_register\("(hex_\w+)",\s*\{(.*?)\n    \}\);', table, re.S)
print("词条数:", len(entries))

# core（hex_apply_core / batch2）已经会解析的公共键，不用 hex_b3_apply 管
CORE_KEYS = set("""
atk hp cycle flame_start flame_growth flame_cap cost dmg e_hp e_atk e_spd e_count
prod_bonus deck_cap range_cut heal_tick_pct burn_sec burn_pct pi_value elite_atk
deck_theme_atk atk_floor taken_mult enemy_taken_add ...
""".split())

b3_ex, b3_en = {}, {}
for eid, body in entries:
    for side, bag in (("ex", b3_ex), ("en", b3_en)):
        m = re.search(r"\b" + side + r":\s*\{(.*?)\}", body, re.S)
        if not m:
            continue
        body2 = m.group(1)
        for k in re.findall(r"(\w+)\s*:", body2):
            bag.setdefault(k, []).append(eid)

# ── 2. hex_b3_apply 里有没有解析分支 ──
def func_span(name):
    m = re.search(r"^function\s+" + name + r"\s*\(", src, re.M)
    if not m:
        return (0, 0)
    nxt = re.search(r"^function\s+\w+\s*\(", src[m.end():], re.M)
    end = m.end() + nxt.start() if nxt else len(src)
    return (m.end(), end)

ap_start, ap_end = func_span("hex_b3_apply")
apply_src = src[ap_start:ap_end]
parsed_ex = set(re.findall(r'variable_struct_exists\(_ex,\s*"(\w+)"\)', apply_src))
parsed_en = set(re.findall(r'variable_struct_exists\(_en,\s*"(\w+)"\)', apply_src))

missing_parse = []
for k, ids in list(b3_ex.items()) + list(b3_en.items()):
    if k in CORE_KEYS:
        continue
    if not (k.startswith("b3_") or k.startswith("b2_")):
        continue
    if k in parsed_ex or k in parsed_en:
        continue
    missing_parse.append((k, ids))
print()
print("=== 词条键没有解析分支 ===")
if missing_parse:
    for k, ids in missing_parse:
        print("  [X] %-26s %s" % (k, ",".join(ids)))
else:
    print("  [OK]")

# ── 3. 解析出来的状态字段有没有人读 ──
ens_start, ens_end = func_span("hex_b3_ensure")
# 去掉 ensure（只写默认值）与 apply（只解析）两个函数，看剩下的代码有没有读这些字段
body = src[:ens_start] + src[ens_end:ap_start] + src[ap_end:]
body = re.sub(r"^\s*///.*$", "", body, flags=re.M)

declared = set(re.findall(r"_s\.(b3_\w+)\s*=", src))
unread = []
for f in sorted(declared):
    hits = len(re.findall(r"\b" + f + r"\b", body))
    if hits == 0:
        unread.append(f)
print()
print("=== 声明了但没人读的字段（%d / %d） ===" % (len(unread), len(declared)))
for f in unread:
    print("  [X]", f)
if not unread:
    print("  [OK]")

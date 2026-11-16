# -*- coding: utf-8 -*-
"""解析原版 god_card.xml 的 <evolution> 配置，导出「卡片进化 / 神器进化 / 宝石进化」三张表。

数据源（原版解包，只读）：
  D:/FVM开发/game/FVM开发/res/extracted_card_resources/god_card.xml   evolution 配置
  D:/FVM开发/game/FVM开发/res/extracted_card_resources/card_desc.xml  道具 id -> 名称/类型
  D:/FVM开发/game/FVM开发/res/extracted_card_resources/card_desc.xml  道具 desc（进化前后说明）

输出：
  output/god_evolution.json   三张表（含 id / 名称 / 类型 / 图标提示）
  output/god_evolution.md     人读摘要

用法:
  python tools/god_evolution_extract.py
"""
import json
import os
import re
import sys
import xml.etree.ElementTree as ET

RES = r"D:/FVM开发/game/FVM开发/res/extracted_card_resources"
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT_DIR = os.path.join(ROOT, "output")


def load_item_names():
    """card_desc.xml: <item ... id="0x..." name="..." type="主武器" desc="..."/>"""
    names = {}
    path = os.path.join(RES, "card_desc.xml")
    txt = open(path, "r", encoding="utf-8", errors="replace").read()
    for m in re.finditer(r"<item\b([^>]*)/>", txt):
        attrs = dict(re.findall(r'(\w+)="([^"]*)"', m.group(1)))
        iid = attrs.get("id")
        if not iid:
            continue
        names[iid.lower()] = {
            "name": attrs.get("name", ""),
            "type": attrs.get("type", ""),
            "desc": attrs.get("desc", ""),
            "strengthen": attrs.get("strengthen_desc", ""),
        }
    return names


def parse_evolution(names):
    path = os.path.join(RES, "god_card.xml")
    tree = ET.parse(path)
    root = tree.getroot()
    evo = root.find("evolution")
    result = {}

    def name_of(iid):
        d = names.get(iid.lower())
        return d["name"] if d else iid

    def type_of(iid):
        d = names.get(iid.lower())
        return d["type"] if d else ""

    def desc_of(iid):
        d = names.get(iid.lower())
        return d["desc"] if d else ""

    for tab in evo.findall("compose_tab"):
        tid = int(tab.get("id"))
        rows = []
        for el in tab.findall("element"):
            obtain = el.get("obtain_id", "")
            reel = el.get("reel", "")
            cost_nodes = el.findall("cost/item")
            ext_nodes = el.findall("obtain_ext/item")
            costs = [it.get("item_id", "") for it in cost_nodes]
            extras = [it.get("item_id", "") for it in ext_nodes]
            cost_nums = [int(it.get("num", "1") or 1) for it in cost_nodes]
            ext_counts = [int(it.get("count", "0") or 0) for it in ext_nodes]
            rows.append({
                "obtain_id": obtain,
                "obtain_name": name_of(obtain),
                "obtain_type": type_of(obtain),
                "cost_gem_level": int(el.get("cost_gem_level", "0") or 0),
                "reel_id": reel,
                "reel_name": name_of(reel),
                "cost_ids": costs,
                "cost_names": [name_of(c) for c in costs],
                "cost_nums": cost_nums,
                "ext_ids": extras,
                "ext_names": [name_of(e) for e in extras],
                "ext_counts": ext_counts,
                "note": desc_of(obtain),
            })
        result[tid] = rows
    return result


def main():
    if not os.path.isdir(OUT_DIR):
        os.makedirs(OUT_DIR)
    names = load_item_names()
    evo = parse_evolution(names)

    meta = {
        1: ("卡片进化", "金卡进化：普通卡 + 星座卡 + 进化凭证 -> 金卡"),
        2: ("神器进化", "旧三神 + 进化凭证 -> 新三神 -> 超三神"),
        3: ("宝石进化", "专属宝石 + 宝石进化凭证 -> 补强宝石（按等级分档，含返还）"),
    }

    payload = {"source": "res/extracted_card_resources/god_card.xml", "tabs": {}}
    for tid, rows in sorted(evo.items()):
        payload["tabs"][str(tid)] = {
            "tab": tid,
            "name": meta.get(tid, ("", ""))[0],
            "summary": meta.get(tid, ("", ""))[1],
            "count": len(rows),
            "rows": rows,
        }

    jp = os.path.join(OUT_DIR, "god_evolution.json")
    with open(jp, "w", encoding="utf-8") as f:
        json.dump(payload, f, ensure_ascii=False, indent=1)

    lines = ["# 原版合成屋进化配置（god_card.xml -> evolution）", ""]
    for tid in sorted(evo):
        tname, tsum = meta.get(tid, ("", ""))
        rows = evo[tid]
        lines.append("## %d. %s（%d 条）" % (tid, tname, len(rows)))
        lines.append("")
        lines.append("> %s" % tsum)
        lines.append("")
        lines.append("| # | 产出 obtain_id | 名称 | 消耗 | 凭证 reel | 返还 |")
        lines.append("|---|---|---|---|---|---|")
        for i, r in enumerate(rows):
            cost = " + ".join(r["cost_names"])
            lines.append("| %d | `%s` | %s | %s | %s | %s |" % (
                i + 1, r["obtain_id"], r["obtain_name"], cost,
                r["reel_name"], " + ".join(r["ext_names"]) or "-"))
        lines.append("")
    mp = os.path.join(OUT_DIR, "god_evolution.md")
    with open(mp, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))

    for tid in sorted(evo):
        print("tab %d %s: %d 条" % (tid, meta.get(tid, ("", ""))[0], len(evo[tid])))
    print("已写出:", jp)
    print("已写出:", mp)


if __name__ == "__main__":
    main()

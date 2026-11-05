# -*- coding: utf-8 -*-
"""灼热地域 BOSS 自检：精灵完整性 / 对象一致性 / 资源注册 / 技能改动。

    python tools/zhuore_boss_selfcheck.py
"""
import glob
import io
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
import zhuore_boss_spec as S        # noqa: E402
import zhuore_boss_build as B       # noqa: E402

KEEP = re.compile(r",(\s*[}\]])")


def load(p):
    s = io.open(p, encoding="utf-8-sig").read()
    return json.loads(KEEP.sub(r"\1", s), strict=False)


def main():
    issues = []
    spr_names, obj_names = set(), set()

    for boss in S.MICE:
        key = boss["key"]
        for item in boss["sprites"]:
            spr_names.add(B.sprite_name(key, item[0]))
        obj_names.add(B.obj_name(key))
        for ex in boss.get("extras", ()):
            obj_names.add(B.obj_name(key, ex["key"]))

    # ---------- 1. 精灵 ----------
    for boss in S.MICE:
        key = boss["key"]
        for item in boss["sprites"]:
            suffix, old_spr, total = item[0], item[1], item[2]
            name = B.sprite_name(key, suffix)
            d = os.path.join(ROOT, "sprites", name)
            yy = os.path.join(d, name + ".yy")
            if not os.path.isfile(yy):
                issues.append("缺精灵 .yy: " + name)
                continue
            j = load(yy)
            layers = j.get("layers") or []
            if len(layers) != 1:
                issues.append("%s: layers=%d（必须 1 条）" % (name, len(layers)))
            lid = layers[0]["name"] if layers else ""
            frames = [f["name"] for f in j.get("frames", [])]
            if len(frames) != total:
                issues.append("%s: 帧数 %d != 规格 %d" % (name, len(frames), total))
            # 原版帧数必须一致（对象代码 mod N 是硬编码）。
            # 例外：飞镖对象只用了 mod 4，原版 32 帧里后 28 帧是命中特效，不参与循环。
            ometa = B.sprite_meta(old_spr)
            shrunk = {"spr_mermaid_mary_bullet"}
            if old_spr not in shrunk and len(ometa["frames"]) != total:
                issues.append("%s: 目标 %d != 原版 %s 的 %d"
                              % (name, total, old_spr, len(ometa["frames"])))
            for fid in frames:
                if not os.path.isfile(os.path.join(d, fid + ".png")):
                    issues.append("%s: 缺帧图 %s.png" % (name, fid))
                if not os.path.isfile(os.path.join(d, "layers", fid, lid + ".png")):
                    issues.append("%s: 缺图层图 %s/%s.png" % (name, fid, lid))
            # 不允许整段空白（除了原版本来就空的帧）
            empty_new = [i for i in range(total)
                         if B.alpha_bbox(B.frame_image(name, i)) is None]
            empty_old = [i for i in range(min(total, len(ometa["frames"])))
                         if B.alpha_bbox(B.frame_image(old_spr, i)) is None]
            if len(empty_new) > len(empty_old):
                issues.append("%s: 空白帧 %d 个，原版只有 %d 个"
                              % (name, len(empty_new), len(empty_old)))

    # ---------- 2. 对象 ----------
    for boss in S.MICE:
        key = boss["key"]
        for suffix in [None] + [e["key"] for e in boss.get("extras", ())]:
            o = B.obj_name(key, suffix)
            d = os.path.join(ROOT, "objects", o)
            yy = os.path.join(d, o + ".yy")
            if not os.path.isfile(yy):
                issues.append("缺对象 .yy: " + o)
                continue
            t = io.open(yy, encoding="utf-8-sig").read()
            if '"name":"%s"' % o not in t:
                issues.append("%s: .yy 内 name 不是自己" % o)
            sp = re.search(r'"spriteId":\{\s*"name":"([^"]*)"', t)
            # 允许沿用原版精灵（水波、毒气等没有新素材的物件），但必须真实存在
            if sp and not os.path.isfile(
                    os.path.join(ROOT, "sprites", sp.group(1), sp.group(1) + ".yy")):
                issues.append("%s: spriteId=%s 资源不存在" % (o, sp.group(1)))
            # parent 指向的必须是自己那只 BOSS 的分组，不能指回原版目录
            pm = re.search(r'"parent":\{\s*"name":"([^"]*)",\s*"path":"([^"]*)"', t)
            want_p = "folders/物体/Enemy/kuafu/zhuorediyu/boss/%s.yy" % key
            if not pm:
                issues.append("%s: .yy 没有 parent 分组" % o)
            elif pm.group(2) != want_p:
                issues.append("%s: parent 分组是 %s，应为 %s"
                              % (o, pm.group(2), want_p))
            for g in glob.glob(os.path.join(d, "*.gml")):
                gtxt = io.open(g, encoding="utf-8-sig").read()
                for a, b in (("{", "}"), ("(", ")"), ("[", "]")):
                    if gtxt.count(a) != gtxt.count(b):
                        issues.append("%s/%s: %s 括号不平衡"
                                      % (o, os.path.basename(g), a))
                # 不允许残留原版精灵/对象名
                for old in [i[1] for i in boss["sprites"]]:
                    if re.search(r"\b%s\b" % re.escape(old), gtxt):
                        issues.append("%s/%s: 残留原版精灵 %s"
                                      % (o, os.path.basename(g), old))
                if re.search(r"\b%s\b" % re.escape(boss["old"]), gtxt):
                    issues.append("%s/%s: 残留原版对象 %s"
                                  % (o, os.path.basename(g), boss["old"]))

    # ---------- 3. 注册 ----------
    init = os.path.join(ROOT, "scripts", "zhuore_boss_init", "zhuore_boss_init.gml")
    if not os.path.isfile(init):
        issues.append("缺 scripts/zhuore_boss_init")
    else:
        t = io.open(init, encoding="utf-8-sig").read()
        eids = re.findall(r'register_enemy\("([^"]+)"', t)
        bids = re.findall(r'register_boss\("([^"]+)"', t)
        want = {B.obj_name(m["key"]) .replace("obj_", "") for m in S.MICE}
        if len(S.MICE) != 5:
            issues.append("规格里的 BOSS 数不是 5")
        if len(eids) != len(S.MICE):
            issues.append("register_enemy 条数 %d != %d" % (len(eids), len(S.MICE)))
        if len(bids) != len(S.MICE):
            issues.append("register_boss 条数 %d != %d" % (len(bids), len(S.MICE)))
        for o in re.findall(r"_obj:\s*(obj_\w+)", t):
            if o not in obj_names:
                issues.append("注册引用了不存在的对象: " + o)
        for s in re.findall(r"spr:\s*(spr_kf_zrb_\w+)", t):
            if s not in spr_names:
                issues.append("注册引用了不存在的精灵: " + s)
        mb = os.path.join(ROOT, "scripts", "mod_boss_init", "mod_boss_init.gml")
        if "zhuore_boss_init()" not in io.open(mb, encoding="utf-8-sig").read():
            issues.append("mod_boss_init 未挂接 zhuore_boss_init()")

    # ---------- 4. yyp / folder ----------
    y = load(os.path.join(ROOT, "FVM_Reborn_makk.yyp"))
    rnames = [r["id"]["name"] for r in y["resources"]]
    dup = {n for n in rnames if rnames.count(n) > 1}
    if dup:
        issues.append("yyp 重复资源: %s" % sorted(dup))
    rset = set(rnames)
    for s in sorted(spr_names):
        if s not in rset:
            issues.append("yyp 未注册精灵: " + s)
    for o in sorted(obj_names):
        if o not in rset:
            issues.append("yyp 未注册对象: " + o)
    if "zhuore_boss_init" not in rset:
        issues.append("yyp 未注册 zhuore_boss_init")
    # 脚本光是进 yyp 还不够，得挂进「脚本/mod」分组，否则资源树里会孤零零挂在根目录
    sm = os.path.join(ROOT, "folders", "脚本", "mod.yy")
    if os.path.isfile(sm):
        if "zhuore_boss_init" not in io.open(sm, encoding="utf-8-sig").read():
            issues.append("folders/脚本/mod.yy 未收录 zhuore_boss_init")

    bad = []
    for f in glob.glob(os.path.join(ROOT, "folders", "**", "*.yy"), recursive=True):
        try:
            j = load(f)
        except Exception:
            continue
        for it in j.get("listItems") or []:
            p = it.get("path", "")
            if p and not os.path.exists(os.path.join(ROOT, p)):
                bad.append((os.path.relpath(f, ROOT), p))
    # 只报与本次 BOSS 相关的失效引用
    mine = [b for b in bad if "boss" in b[1] or "kf_zrb" in b[1]]
    if mine:
        issues.append("folders 失效引用 %d 条（本次相关）: %s" % (len(mine), mine[:5]))

    # ---------- 5. 技能改动 ----------
    CHECKS = [
        ("objs_kf_zrb_mary", "objects/obj_kf_zrb_mary/Step_0.gml",
         ["var _row_b = grid_row + 1",
          "grid_row == _row_a || grid_row == _row_b",
          "timer >= 624"]),
        ("objs_kf_zrb_shi", "objects/obj_kf_zrb_shi/Step_0.gml",
         ["i < 10", "jump_times < 8", "timer >= 430"]),
        ("objs_kf_zrb_shi_mace", "objects/obj_kf_zrb_shi_mace/Create_0.gml",
         ["hp = 10000", "maxhp = 10000"]),
        ("objs_kf_zrb_shi_poop", "objects/obj_kf_zrb_shi_poop/Step_0.gml",
         ["_ox <= 1", "abs(grid_row - other.grid_row) <= 1"]),
        ("objs_kf_zrb_jack", "objects/obj_kf_zrb_jack/Step_0.gml",
         ["abs(grid_row - other.grid_row) <= 1", "array_length(selected_coords) < 10",
          # 每 60 帧一颗、共 10 颗，循环上限必须是 600，多 20 帧就会 target_coord[10] 越界
          "skill_timer < 10 * 60{", "skill_timer == 10 * 60 - 2",
          "_i < 6"]),
        ("objs_kf_zrb_jack_rock_4", "objects/obj_kf_zrb_jack_rock_skill_4/Create_0.gml",
         ["hp = 5400", "rock_speed = 2"]),
        ("objs_kf_zrb_vajra", "objects/obj_kf_zrb_vajra/Step_0.gml",
         ["obj_kuafu_boss_ice_area", "ice_radius = 1", "ice_life   = 5 * 60",
          "i < 10", "obj_kuafu_boss_pete", "obj_kuafu_boss_julie",
          # 棘刺 4 秒缩回，放电判定必须同步压到 4 秒，否则判定时棘刺已消失 → 没有闪电
          "timer == 60 + 60* 4 - 1"]),
        ("objs_kf_zrb_vajra_spike", "objects/obj_kf_zrb_vajra_spike/Create_0.gml",
         ["immune_to_ash = true"]),
        ("objs_kf_zrb_vajra_spike", "objects/obj_kf_zrb_vajra_spike/Step_0.gml",
         ["timer >= 4 * 60"]),
        ("objs_kf_zrb_cap", "objects/obj_kf_zrb_cap/Step_0.gml",
         ["global.grid_rows", "_elbow_row_b",
          "grid_row == other.grid_row || grid_row == _elbow_row_b",
          "obj_aircraft_carrier"]),
        ("objs_kf_zrb_cap_rainbow", "objects/obj_kf_zrb_cap_rainbow/Create_0.gml",
         ["hp = 10000"]),
        ("objs_kf_zrb_cap_rainbow", "objects/obj_kf_zrb_cap_rainbow/Step_0.gml",
         ["obj_kuafu_armour"]),
    ]
    for tag, rel, needles in CHECKS:
        p = os.path.join(ROOT, rel)
        if not os.path.isfile(p):
            issues.append("技能校验找不到文件: " + rel)
            continue
        t = io.open(p, encoding="utf-8-sig").read()
        for n in needles:
            if n not in t:
                issues.append("%s 技能改动缺失: %s（%s）" % (tag, n, rel))

    print("精灵 %d 个 / 对象 %d 个" % (len(spr_names), len(obj_names)))
    if issues:
        print("\n发现 %d 个问题：" % len(issues))
        for i in issues:
            print("  -", i)
        return 1
    print("\n自检通过：无问题")
    return 0


if __name__ == "__main__":
    sys.exit(main())

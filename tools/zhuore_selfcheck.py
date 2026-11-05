# -*- coding: utf-8 -*-
"""灼热地域小怪（kf_zr_*）自检。

检查项：
  1. 精灵：目录/.yy 存在、layers 必须只有 1 条、每帧顶层图与 layers 图层图齐全、
     .yy 帧数 == 规格帧数、空帧分布与原版精灵一致
  2. 对象：.yy name 正确、spriteId 指向本批新精灵、父类是 obj_enemy_parent、.gml 括号平衡
  3. 注册脚本：13 条 register_enemy、id 不重复、引用对象/精灵都存在、已被 mod_enemy_init 挂接
  4. yyp：resources 无重复、41 精灵 + 15 对象 + zhuore_enemy_init 全部登记
  5. folders：listItems 无失效路径

用法： python tools/zhuore_selfcheck.py
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

import zhuore_spec as S  # noqa: E402

SPR = os.path.join(ROOT, "sprites")
OBJ = os.path.join(ROOT, "objects")
YPP = os.path.join(ROOT, "FVM_Reborn_makk.yyp")
TRAILING = re.compile(r",(\s*[}\]])")


def load(p):
    s = io.open(p, encoding="utf-8-sig", errors="replace").read()
    return json.loads(TRAILING.sub(r"\1", s), strict=False)


def sprite_name(mouse, suffix):
    base = "spr_" + S.PREFIX + mouse["key"]
    return base if suffix == "main" else base + "_" + suffix


def visible(im):
    return im.convert("RGBA").split()[3].getbbox() is not None


def main():
    issues = []
    pairs = []          # (新精灵名, 原版精灵名, 总帧数)
    for m in S.MICE:
        for suffix, old, total, _ in m["sprites"]:
            pairs.append((sprite_name(m, suffix), old, total))
    spr_names = {p[0] for p in pairs}
    obj_names = {"obj_" + S.PREFIX + m["key"] for m in S.MICE}

    # ---------- 1. 精灵 ----------
    import zhuore_build as B
    for name, old, total in sorted(pairs):
        d = os.path.join(SPR, name)
        yy = os.path.join(d, name + ".yy")
        if not os.path.isdir(d):
            issues.append("缺少精灵目录: " + name)
            continue
        if not os.path.isfile(yy):
            issues.append("缺少精灵 .yy: " + name)
            continue
        j = load(yy)
        layers = j.get("layers") or []
        if len(layers) != 1:
            issues.append("%s: layers 条数=%d（GMSprite 所有帧共用一套图层，必须为 1）"
                          % (name, len(layers)))
        lid = layers[0]["name"] if layers else None
        frames = [f["name"] for f in j.get("frames", [])]
        if len(frames) != total:
            issues.append("%s: .yy 帧数 %d != 规格 %d" % (name, len(frames), total))
        for fid in frames:
            if not os.path.isfile(os.path.join(d, fid + ".png")):
                issues.append("%s: 缺顶层帧图 %s.png" % (name, fid))
            if not os.path.isfile(os.path.join(d, "layers", fid, (lid or "") + ".png")):
                issues.append("%s: 缺图层图 layers/%s/%s.png" % (name, fid, lid))
        # 空帧分布必须与原版一致（原版全透明的帧才允许透明）
        try:
            new_empty = [i for i in range(total) if not visible(B.frame_image(name, i))]
            old_empty = [i for i in range(total) if not visible(B.frame_image(old, i))]
            if new_empty != old_empty:
                issues.append("%s: 空帧 %s 与原版 %s 不一致" % (name, new_empty, old_empty))
        except Exception as e:                                   # noqa: BLE001
            issues.append("%s: 读帧失败 %s" % (name, e))

    # ---------- 2. 对象 ----------
    for ob in sorted(obj_names):
        d = os.path.join(OBJ, ob)
        yy = os.path.join(d, ob + ".yy")
        if not os.path.isdir(d):
            issues.append("缺少对象目录: " + ob)
            continue
        if not os.path.isfile(yy):
            issues.append("缺少对象 .yy: " + ob)
            continue
        txt = io.open(yy, encoding="utf-8-sig").read()
        if '"name":"%s"' % ob not in txt:
            issues.append("%s: .yy 内 name 与目录名不一致" % ob)
        mm = re.search(r'"spriteId":\{\s*"name":"([^"]*)"', txt)
        if not mm or mm.group(1) not in spr_names:
            issues.append("%s: spriteId=%s 不是本批新精灵"
                          % (ob, mm.group(1) if mm else "<无>"))
        if '"name":"obj_enemy_parent"' not in txt:
            issues.append("%s: 父类不是 obj_enemy_parent" % ob)
        for g in glob.glob(os.path.join(d, "*.gml")):
            t = io.open(g, encoding="utf-8-sig").read()
            for a, b in (("{", "}"), ("(", ")"), ("[", "]")):
                if t.count(a) != t.count(b):
                    issues.append("%s/%s: %s%s 括号不平衡"
                                  % (ob, os.path.basename(g), a, b))

    # ---------- 3. 注册脚本 ----------
    init = os.path.join(ROOT, "scripts", "zhuore_enemy_init", "zhuore_enemy_init.gml")
    if not os.path.isfile(init):
        issues.append("缺少 scripts/zhuore_enemy_init/zhuore_enemy_init.gml")
    else:
        t = io.open(init, encoding="utf-8-sig").read()
        ids = re.findall(r'register_enemy\("([^"]+)"', t)
        if len(ids) != 13:
            issues.append("register_enemy 条数 %d != 13" % len(ids))
        if len(set(ids)) != len(ids):
            issues.append("register_enemy 存在重复 id: %s" % ids)
        for o in re.findall(r"_obj:\s*(obj_kf_zr_\w+)", t):
            if o not in obj_names:
                issues.append("注册引用了不存在的对象: " + o)
        for s in re.findall(r"spr:\s*(spr_kf_zr_\w+)", t):
            if s not in spr_names:
                issues.append("注册引用了不存在的精灵: " + s)
        for a, b in (("{", "}"), ("(", ")"), ("[", "]")):
            if t.count(a) != t.count(b):
                issues.append("zhuore_enemy_init.gml: %s%s 括号不平衡" % (a, b))
        mod = os.path.join(ROOT, "scripts", "mod_enemy_init", "mod_enemy_init.gml")
        if os.path.isfile(mod):
            if "zhuore_enemy_init()" not in io.open(mod, encoding="utf-8-sig").read():
                issues.append("mod_enemy_init 未挂接 zhuore_enemy_init()")
        else:
            issues.append("缺少 mod_enemy_init.gml")

    # ---------- 4. yyp ----------
    y = load(YPP)
    res = [r["id"]["name"] + "|" + r["id"]["path"] for r in y["resources"]]
    dup = sorted({x for x in res if res.count(x) > 1})
    if dup:
        issues.append("yyp resources 重复: %s" % dup)
    rnames = {r["id"]["name"] for r in y["resources"]}
    for n in sorted(spr_names | obj_names | {"zhuore_enemy_init"}):
        if n not in rnames:
            issues.append("yyp 未注册: " + n)

    # ---------- 5. 行为一致性（对象代码照抄） ----------
    # 新对象是原版对象的「改名副本」，所以：
    #   a) 不允许残留任何原版精灵名（否则会画回原版美术）
    #   b) 动画常量 move_anim / attack_anim / death_anim / atk_cycle / hurt_rate 必须与原版一致
    #   c) hp / maxhp 必须等于规格血量
    # 注意：move_speed 不在此列 —— 它是《灼热地狱》总表给的数值，个别鼠需要按表改，
    # 由规格的 ms_patch + 注册表 speed 两项单独校验。
    NUM = re.compile(r"\b(move_anim|attack_anim|death_anim|atk_cycle|hurt_rate)\s*=\s*"
                     r"(-?\d+(?:\.\d+)?)")
    HP = re.compile(r"\b(hp|maxhp)\s*=\s*(-?\d+(?:\.\d+)?)")

    def consts(path):
        out = {}
        if not os.path.isfile(path):
            return out
        for k, v in NUM.findall(io.open(path, encoding="utf-8-sig").read()):
            out[k] = v
        return out

    for m in S.MICE:
        new_obj = "obj_" + S.PREFIX + m["key"]
        old_obj = m["old"]
        nd = os.path.join(OBJ, new_obj)
        od = os.path.join(OBJ, old_obj)
        old_sprs = {s[1] for s in m["sprites"]}
        for g in glob.glob(os.path.join(nd, "*.gml")):
            txt = io.open(g, encoding="utf-8-sig").read()
            for os_ in sorted(old_sprs):
                if re.search(r"\b%s\b" % re.escape(os_), txt):
                    issues.append("%s/%s 残留原版精灵名 %s"
                                  % (new_obj, os.path.basename(g), os_))
            for on in (old_obj,):
                if re.search(r"\b%s\b" % on, txt):
                    issues.append("%s/%s 残留原版对象名 %s"
                                  % (new_obj, os.path.basename(g), on))
            # 动画常量对比
            oc = consts(os.path.join(od, os.path.basename(g)))
            nc = consts(g)
            for k in oc:
                if k in nc and nc[k] != oc[k]:
                    issues.append("%s/%s 动画常量 %s=%s 与原版 %s 不一致"
                                  % (new_obj, os.path.basename(g), k, nc[k], oc[k]))
        # 血量 / 护盾
        c = os.path.join(nd, "Create_0.gml")
        if os.path.isfile(c):
            t = io.open(c, encoding="utf-8-sig").read()
            hp = dict(HP.findall(t))
            for k in ("hp", "maxhp"):
                if k in hp and int(float(hp[k])) != m["hp"]:
                    issues.append("%s: %s=%s != 规格 %d" % (new_obj, k, hp[k], m["hp"]))
            sh = m.get("shield") or 0
            for k in ("shield_hp", "shield_max_hp"):
                mm2 = re.search(r"^%s\s*=\s*(-?\d+)" % k, t, re.M)
                if mm2 and int(mm2.group(1)) != sh:
                    issues.append("%s: %s=%s != 规格护盾 %d"
                                  % (new_obj, k, mm2.group(1), sh))
            # 防爆：真正生效的是实例变量 immune_to_ash
            if "ash_proof" in m:
                want = "true" if m["ash_proof"] else "false"
                mm2 = re.search(r"^immune_to_ash\s*=\s*(true|false)", t, re.M)
                if not mm2:
                    issues.append("%s: Create 里没有 immune_to_ash（表格防爆应为 %s）"
                                  % (new_obj, want))
                elif mm2.group(1) != want:
                    issues.append("%s: immune_to_ash=%s != 表格防爆 %s"
                                  % (new_obj, mm2.group(1), want))
            # 移动速度：ms_patch 指定的改点必须已经生效、旧值不许残留
            for pfn, old_v, new_v in m.get("ms_patch", ()):
                pf = os.path.join(nd, pfn)
                if not os.path.isfile(pf):
                    issues.append("%s: 缺 %s" % (new_obj, pfn))
                    continue
                vals = [float(x) for x in re.findall(
                    r"^[ \t]*move_speed[ \t]*=[ \t]*(-?\d+(?:\.\d+)?)",
                    io.open(pf, encoding="utf-8-sig").read(), re.M)]
                if not any(abs(v - new_v) < 1e-9 for v in vals):
                    issues.append("%s/%s: move_speed 未改到 %g（现值 %s）"
                                  % (new_obj, pfn, new_v, vals))
                if any(abs(v - old_v) < 1e-9 for v in vals):
                    issues.append("%s/%s: 仍残留 move_speed = %g" % (new_obj, pfn, old_v))
        else:
            issues.append("%s: 缺 Create_0.gml" % new_obj)

    # 注册表与规格必须一致（zhuore_enemy_init.gml 是手写的，容易被改漏）
    if os.path.isfile(init):
        t = io.open(init, encoding="utf-8-sig").read()
        blocks = re.findall(r'register_enemy\("([^"]+)",\s*\{(.*?)\}\)', t, re.S)
        for eid, body in blocks:
            key = eid[len(S.PREFIX):]
            spec = next((m for m in S.MICE if m["key"] == key), None)
            if not spec:
                issues.append("注册了规格里没有的 id: " + eid)
                continue
            mm2 = re.search(r"\bhp:\s*(\d+)", body)
            if not mm2 or int(mm2.group(1)) != spec["hp"]:
                issues.append("%s: 注册 hp=%s != 规格 %d"
                              % (eid, mm2.group(1) if mm2 else "<无>", spec["hp"]))
            mm2 = re.search(r"\bshield:\s*(\d+)", body)
            if (int(mm2.group(1)) if mm2 else 0) != (spec.get("shield") or 0):
                issues.append("%s: 注册 shield=%s != 规格 %d"
                              % (eid, mm2.group(1) if mm2 else "<无>", spec.get("shield") or 0))
            mm2 = re.search(r"\bspeed:\s*(-?\d+(?:\.\d+)?)", body)
            if not mm2 or abs(float(mm2.group(1)) - spec["speed"]) > 1e-9:
                issues.append("%s: 注册 speed=%s != 规格 %g"
                              % (eid, mm2.group(1) if mm2 else "<无>", spec["speed"]))
            mm2 = re.search(r"\bash_proof:\s*(true|false)", body)
            want = "true" if spec["ash_proof"] else "false"
            if not mm2 or mm2.group(1) != want:
                issues.append("%s: 注册 ash_proof=%s != 规格 %s"
                              % (eid, mm2.group(1) if mm2 else "<无>", want))
        missing = [m["key"] for m in S.MICE
                   if ("kf_zr_" + m["key"]) not in [b[0] for b in blocks]]
        # 小兵由本体召唤生成、不走 register_enemy，和原版一致，不算缺
        missing = [k for k in missing if not k.endswith("_minion")]
        if missing:
            issues.append("规格里有但未注册: %s" % missing)

    # ---------- 6. folders ----------
    # 只把「本次相关」的失效引用算问题；项目里本来就有一批和灼热地域无关的历史失效项
    # （光明神/黑暗神的子弹与特效对象已被删但 folder 还留着），那些单独列出、不阻塞。
    bad, legacy = [], []
    for f in glob.glob(os.path.join(ROOT, "folders", "**", "*.yy"), recursive=True):
        try:
            j = load(f)
        except Exception:                                        # noqa: BLE001
            continue
        for it in j.get("listItems") or []:
            p = it.get("path", "")
            if p and not os.path.exists(os.path.join(ROOT, p)):
                (bad if "kf_zr" in p or "zhuorediyu" in p else legacy).append(
                    (os.path.relpath(f, ROOT), p))
    if bad:
        issues.append("folders 失效引用（本次相关）%d 条: %s" % (len(bad), bad[:5]))

    print("精灵 %d 个 / 对象 %d 个" % (len(spr_names), len(obj_names)))
    if legacy:
        print("提示：项目既有失效 folder 引用 %d 条（与本次无关，未处理）" % len(legacy))
    if issues:
        print("\n发现 %d 个问题：" % len(issues))
        for i in issues:
            print("  -", i)
        return 1
    print("\n自检通过：无问题")
    return 0


if __name__ == "__main__":
    sys.exit(main())

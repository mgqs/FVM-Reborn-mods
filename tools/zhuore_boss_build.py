# -*- coding: utf-8 -*-
"""把「灼热地域」变异僵尸 BOSS 导入项目：精灵 + 对象 + 技能改写 + 资源注册。

用法：
    python tools/zhuore_boss_build.py sprites   # 只生成精灵
    python tools/zhuore_boss_build.py objects   # 只生成对象 + 技能改写
    python tools/zhuore_boss_build.py register  # 只做资源注册
    python tools/zhuore_boss_build.py all
    python tools/zhuore_boss_build.py sprites mary   # 只做单只
"""
import io
import json
import os
import re
import shutil
import sys
import uuid

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
import swf_frame_labels as SWF          # noqa: E402
import zhuore_build as ZB               # noqa: E402  复用 make_sprite / 模板
import zhuore_boss_spec as S            # noqa: E402

SPR_DIR = os.path.join(ROOT, "sprites")
OBJ_DIR = os.path.join(ROOT, "objects")
YYP = os.path.join(ROOT, "FVM_Reborn_makk.yyp")

SPR_FOLDER = "folders/精灵/Enemy/kuafu/zhuorediyu/boss"
OBJ_FOLDER = "folders/物体/Enemy/kuafu/zhuorediyu/boss"


def load_yy(p):
    s = io.open(p, encoding="utf-8-sig").read()
    return json.loads(re.sub(r",(\s*[}\]])", r"\1", s))


def sprite_meta(name):
    d = load_yy(os.path.join(SPR_DIR, name, name + ".yy"))
    return dict(frames=[f["name"] + ".png" for f in d["frames"]],
                w=d["width"], h=d["height"],
                ox=d["sequence"]["xorigin"], oy=d["sequence"]["yorigin"])


def frame_image(sprite, idx):
    m = sprite_meta(sprite)
    return Image.open(os.path.join(SPR_DIR, sprite, m["frames"][idx])).convert("RGBA")


def alpha_bbox(im):
    return im.split()[3].getbbox()


def resample(seq, n):
    if n <= 0:
        return []
    if len(seq) == n:
        return list(seq)
    if len(seq) == 1:
        return [seq[0]] * n
    if n == 1:
        return [seq[0]]
    return [seq[int(round(i * (len(seq) - 1) / (n - 1)))] for i in range(n)]


# ---------------------------------------------------------------- 素材 / SWF
def src_frames(boss, sid=None):
    sid = sid or boss["sid"]
    base = os.path.join(S.SRC_ROOT, boss["src_cn"], "sprites")
    subs = [d for d in os.listdir(base) if "DefineSprite_%d_" % sid in d]
    if not subs:
        raise RuntimeError("%s 找不到 sprite %d" % (boss["cn"], sid))
    d = os.path.join(base, subs[0])
    files = [f for f in os.listdir(d) if f.lower().endswith(".png")]
    files.sort(key=lambda f: int(os.path.splitext(f)[0]))
    return [os.path.join(d, f) for f in files]


def swf_spans(boss, sid=None):
    sid = sid or boss["sid"]
    p = os.path.join(S.SWF_ROOT, boss["swf"])
    sprites = SWF.parse(open(p, "rb").read())
    info = sprites.get(sid)
    if not info:
        raise RuntimeError("%s 里没有 sprite %d" % (boss["swf"], sid))
    labels = sorted(info["labels"])
    spans = {}
    for i, (fr, lb) in enumerate(labels):
        end = labels[i + 1][0] if i + 1 < len(labels) else info["len"]
        spans[lb] = (fr, end)
    return spans, info["len"]


def resolve_span(seg, spans):
    """把段定义解析成 (起, 止)。"""
    if seg[0] is None:
        return seg[2]
    names = seg[0] if isinstance(seg[0], (tuple, list)) else (seg[0],)
    miss = [n for n in names if n not in spans]
    if miss:
        raise RuntimeError("标签不存在: %s（可用: %s）" % (miss, list(spans)))
    return (spans[names[0]][0], spans[names[-1]][1])


def sprite_name(key, suffix):
    base = "spr_" + S.PREFIX + key
    return base if suffix == "main" else "%s_%s" % (base, suffix)


def obj_name(key, suffix=None):
    base = "obj_" + S.PREFIX + key
    return base if suffix in (None, "main") else "%s_%s" % (base, suffix)


# ---------------------------------------------------------------- origin 迁移
def compute_origin(old_spr, new_images, scale):
    """把原版精灵的原点迁移到新素材上。

    dx/dy = 原点相对「可见区域水平中心 / 底边」的偏移，代表角色脚底站位，
    素材缩放后偏移量也要同比放大。
    """
    om = sprite_meta(old_spr)
    omsg = "原版 %s 全透明，无法取参考帧" % old_spr
    obb = None
    for i in range(len(om["frames"])):
        b = alpha_bbox(frame_image(old_spr, i))
        if b:
            obb = b
            break
    if obb is None:
        raise RuntimeError(omsg)

    nbb = None
    for im in new_images:
        b = alpha_bbox(im)
        if b:
            nbb = b
            break
    if nbb is None:
        raise RuntimeError("%s 新精灵全透明" % old_spr)

    dx = (om["ox"] - (obb[0] + obb[2]) / 2.0) * scale
    dy = (om["oy"] - obb[3]) * scale
    ox = int(round((nbb[0] + nbb[2]) / 2.0 + dx))
    oy = int(round(nbb[3] + dy))
    return ox, oy


# ---------------------------------------------------------------- 精灵生成
def build_sprites(only=None):
    report = []
    for boss in S.MICE:
        if only and boss["key"] != only:
            continue
        spans, total = swf_spans(boss)
        span_cache = {}
        scale = boss.get("scale", 1.0)
        cache = {}

        for item in boss["sprites"]:
            suffix, old_spr, total_frames, segs = item[:4]
            sid = item[4] if len(item) > 4 else None
            sspans = spans
            if sid is not None:
                if sid not in span_cache:
                    span_cache[sid] = swf_spans(boss, sid)[0]
                sspans = span_cache[sid]
            srcs = cache.get(sid) if sid else None
            if srcs is None:
                srcs = src_frames(boss, sid)
                cache[sid] = srcs
                if sid is None and len(srcs) != total:
                    print("   ! %s 素材 %d != SWF %d" % (boss["cn"], len(srcs), total))

            picks = []
            for seg in segs:
                st, en = resolve_span(seg, sspans)
                chunk = srcs[st:en]
                # 素材里「闪入/闪出」这类段的头尾常有一两帧全透明，直接取进来
                # 会让角色凭空消失一下。这里只保留有像素的帧（整段都空才回退）。
                keep = [p for p in chunk
                        if alpha_bbox(Image.open(p).convert("RGBA")) is not None]
                if keep and len(keep) < len(chunk):
                    print("   · %s/%s 段 %s 去掉 %d 个空帧"
                          % (boss["cn"], suffix, seg[0] or seg[2], len(chunk) - len(keep)))
                    chunk = keep
                picks += resample(chunk, seg[1])
            if len(picks) != total_frames:
                raise RuntimeError("%s/%s 分段加总 %d != 目标 %d"
                                   % (boss["cn"], suffix, len(picks), total_frames))

            images = []
            for p in picks:
                im = Image.open(p).convert("RGBA")
                if scale != 1.0:
                    im = im.resize((max(1, int(round(im.width * scale))),
                                    max(1, int(round(im.height * scale)))),
                                   Image.LANCZOS)
                images.append(im)

            # 空帧守卫：原版有内容而新帧全透明 = 取到了素材空帧
            oo = [alpha_bbox(frame_image(old_spr, i)) is not None
                  for i in range(total_frames)]
            lost = [i for i, im in enumerate(images) if oo[i] and alpha_bbox(im) is None]
            if lost:
                raise RuntimeError("%s/%s 第 %s 帧空白但原版有内容" % (boss["cn"], suffix, lost))

            ox, oy = compute_origin(old_spr, images, scale)
            name = sprite_name(boss["key"], suffix)
            w, h = ZB.make_sprite(name, images, ox, oy, boss["key"], folder=SPR_FOLDER)
            report.append((name, len(images), w, h, ox, oy))
            print("[sprite] %-30s %3d帧 %4dx%-4d origin(%d,%d)"
                  % (name, len(images), w, h, ox, oy))
    return report


# ---------------------------------------------------------------- 对象生成
def copy_object(old_obj, new_obj, sprite_map, obj_map, mouse_id, hp=None, hp_max=None,
                parent_path=None):
    src = os.path.join(OBJ_DIR, old_obj)
    dst = os.path.join(OBJ_DIR, new_obj)
    if not os.path.isdir(src):
        raise RuntimeError("原版对象不存在: " + old_obj)
    if os.path.isdir(dst):
        shutil.rmtree(dst)
    os.makedirs(dst)

    for fn in os.listdir(src):
        sp = os.path.join(src, fn)
        if fn.endswith(".yy"):
            txt = io.open(sp, encoding="utf-8-sig").read()
            txt = txt.replace('"name":"%s"' % old_obj, '"name":"%s"' % new_obj)
            txt = txt.replace('"%%Name":"%s"' % old_obj, '"%%Name":"%s"' % new_obj)
            # parent = 资源树所在分组。照抄时会指回原版的文件夹，
            # 不改成自己那只 BOSS 的分组，GameMaker 会把对象摆回原版目录。
            if parent_path:
                txt = re.sub(r'"parent":\{\s*"name":"[^"]*",\s*"path":"[^"]*",\s*\}',
                             '"parent":{\n    "name":"%s",\n    "path":"%s",\n  }'
                             % (os.path.splitext(os.path.basename(parent_path))[0],
                                parent_path), txt)
            m = re.search(r'"spriteId":\{\s*"name":"([^"]*)",\s*"path":"[^"]*",\s*\}', txt)
            if m:
                old_sp = m.group(1)
                # 值为 None 表示「没有新素材，沿用原版精灵」
                new_sp = sprite_map.get(old_sp, old_sp) or old_sp
                txt = txt[:m.start()] + ('"spriteId":{\n    "name":"%s",\n'
                                         '    "path":"sprites/%s/%s.yy",\n  }'
                                         % (new_sp, new_sp, new_sp)) + txt[m.end():]
            io.open(os.path.join(dst, new_obj + ".yy"), "w",
                    encoding="utf-8", newline="\n").write(txt)
        elif fn.endswith(".gml"):
            txt = io.open(sp, encoding="utf-8-sig").read()
            for o in sorted(obj_map, key=len, reverse=True):
                txt = re.sub(r"\b%s\b" % re.escape(o), obj_map[o], txt)
            for s in sorted(sprite_map, key=len, reverse=True):
                if sprite_map[s]:
                    txt = re.sub(r"\b%s\b" % re.escape(s), sprite_map[s], txt)
            if mouse_id:
                txt = re.sub(r'mouse_id\s*=\s*"[^"]*"',
                             'mouse_id = "%s"' % mouse_id, txt)
            if hp is not None:
                txt = re.sub(r"^hp\s*=\s*\d+", "hp = %d" % hp, txt, flags=re.M)
            if hp_max is not None:
                txt = re.sub(r"^maxhp\s*=\s*\d+", "maxhp = %d" % hp_max, txt, flags=re.M)
            io.open(os.path.join(dst, fn), "w", encoding="utf-8", newline="\n").write(txt)
        else:
            shutil.copy2(sp, os.path.join(dst, fn))


def build_objects(only=None):
    for boss in S.MICE:
        if only and boss["key"] != only:
            continue
        key = boss["key"]
        # 精灵名映射：原版精灵 -> 新精灵
        smap = {}
        for item in boss["sprites"]:
            smap[item[1]] = sprite_name(key, item[0])
        # 对象名映射：原版对象 -> 新对象
        omap = {boss["old"]: obj_name(key)}
        for ex in boss.get("extras", ()):
            omap[ex["old"]] = obj_name(key, ex["key"])

        # 主对象
        copy_object(boss["old"], obj_name(key), smap, omap,
                    mouse_id=S.PREFIX + key, hp=boss["hp"], hp_max=boss["hp"],
                    parent_path="%s/%s.yy" % (OBJ_FOLDER, key))
        print("[object] %-26s <- %s" % (obj_name(key), boss["old"]))

        # 配套对象
        for ex in boss.get("extras", ()):
            esp = dict(smap)
            for a, b in (ex.get("sprite_map") or {}).items():
                esp[a] = sprite_name(key, b) if b else None
            copy_object(ex["old"], obj_name(key, ex["key"]), esp, omap,
                        mouse_id="%s%s_%s" % (S.PREFIX, key, ex["key"]),
                        hp=ex.get("hp"), hp_max=ex.get("hp"),
                        parent_path="%s/%s.yy" % (OBJ_FOLDER, key))
            print("[object] %-26s <- %s" % (obj_name(key, ex["key"]), ex["old"]))

        apply_skills(boss)


# ---------------------------------------------------------------- 技能改写
def patch(path, old, new, tag=""):
    t = io.open(path, encoding="utf-8-sig").read()
    if old not in t:
        raise RuntimeError("%s: 找不到待替换片段\n%s" % (tag, old[:160]))
    if t.count(old) > 1:
        raise RuntimeError("%s: 片段出现 %d 次，不唯一\n%s" % (tag, t.count(old), old[:160]))
    t = t.replace(old, new)
    io.open(path, "w", encoding="utf-8", newline="\n").write(t)


def apply_skills(boss):
    """每只 BOSS 的技能改动（全部是精确字符串替换，改不到会直接报错）。"""
    key = boss["key"]
    odir = os.path.join(OBJ_DIR, obj_name(key))
    fn = lambda n: os.path.join(odir, n)

    if key == "mary":
        # 技能1：冲撞时同时摧毁 2 行、每行 4 格（原版只砸自己那一行、
        # 靠 target_col = abs(3 - jump_times) 依次砸 4 列）
        patch(fn("Step_0.gml"),
              """		if timer == 20*jump_times + 1 && target_col < 4{
			with obj_card_parent{
				if grid_col == target_col && grid_row == other.grid_row && plant_id != "player" && plant_type != "coffee" && plant_id != "soda_bubble"{
					instance_destroy()
					if hp >= max_hp{
						obj_task_manager.card_loss++
					}
				}
			}
			jump_times++
		}""",
              """		if timer == 20*jump_times + 1 && target_col < 4{
			// 【变异玛丽·技能1】同一次冲撞摧毁 2 行、每行 4 格（原版只砸自己那一行）
			var _row_a = grid_row
			var _row_b = grid_row + 1
			if _row_b >= global.grid_rows{
				_row_b = grid_row - 1
			}
			with obj_card_parent{
				if grid_col == target_col && (grid_row == _row_a || grid_row == _row_b) && plant_id != "player" && plant_type != "coffee" && plant_id != "soda_bubble"{
					instance_destroy()
					if hp >= max_hp{
						obj_task_manager.card_loss++
					}
				}
			}
			jump_times++
		}""", "mary skill1 rows")

        # 技能3（代码里的 SKILL2 = 吹海螺催眠）：睡眠时长 5s -> 10s
        # 原版 timer 24 施放、325 唤醒 = 301 帧；改成 624 就是整整 600 帧
        patch(fn("Step_0.gml"),
              "		if timer >= 325{",
              "		if timer >= 624{          // 【变异玛丽·技能3】催眠 10 秒（原版 325 ≈ 5 秒）",
              "mary sleep 10s")

    elif key == "shi":
        # 技能1：一次召唤 10 只幽灵（原版 5 只鬼火）
        patch(fn("Step_0.gml"),
              """		if timer == 1{
			for(var i = 0;i < 5 ; i++){
				var tg_row = irandom_range(0,global.grid_rows-1)
				var tg_y = get_world_position_from_grid(9,tg_row).y + 33
				var inst = instance_create_depth(x-20+10*i,y,-800,obj_kf_zrb_shi_ignis)
				inst.y_move = (tg_y-y)/120
			}
		}""",
              """		// 【变异屎者·技能1】一次召唤 10 只幽灵（原版 5 只）
		if timer == 1{
			for(var i = 0;i < 10 ; i++){
				var tg_row = irandom_range(0,global.grid_rows-1)
				var tg_y = get_world_position_from_grid(9,tg_row).y + 33
				var inst = instance_create_depth(x-45+10*i, y - (i mod 2) * 20, -800, obj_kf_zrb_shi_ignis)
				inst.y_move = (tg_y-y)/120
			}
		}""", "shi skill1")

        # 技能3：每次吞噬 8 格（原版 4 格）；总时长同步延长
        patch(fn("Step_0.gml"),
              "if timer == 16 * 5 * 3 + 30*jump_times && jump_times < 4{",
              "if timer == 16 * 5 * 3 + 20*jump_times && jump_times < 8{",
              "shi skill3")
        patch(fn("Step_0.gml"),
              "		if timer >= 75*5-1{",
              "		if timer >= 430{          // 240 准备 + 8 次 × 20 + 30 收尾",
              "shi skill3 len")
        # 权杖血量 1w
        patch(os.path.join(OBJ_DIR, obj_name(key, "mace"), "Create_0.gml"),
              "hp = 5000\nmaxhp = 5000",
              "hp = 10000\nmaxhp = 10000", "shi mace hp")
        # 权杖在 Step 里用 sprite_set_offset 动态改锚点，画布变大后要同步换算
        patch(os.path.join(OBJ_DIR, obj_name(key, "mace"), "Step_0.gml"),
              "sprite_set_offset(sprite_index,86,120)",
              "sprite_set_offset(sprite_index,108,107)", "shi mace off1")
        patch(os.path.join(OBJ_DIR, obj_name(key, "mace"), "Step_0.gml"),
              "sprite_set_offset(sprite_index,69,201)",
              "sprite_set_offset(sprite_index,86,197)", "shi mace off2")

        # 技能4：便便爆炸 3×3
        patch(os.path.join(OBJ_DIR, obj_name(key, "poop"), "Step_0.gml"),
              """	if timer == 45{
		var inst = instance_create_depth(x,y-60,-800,obj_engineer_bullet_effect)
		inst.sprite_index = spr_messenger_fog
		var inst2 = instance_create_depth(x-global.grid_cell_size_x,y-60,-800,obj_engineer_bullet_effect)
		inst2.sprite_index = spr_messenger_fog
		var inst3 = instance_create_depth(x+global.grid_cell_size_x,y-60,-800,obj_engineer_bullet_effect)
		inst3.sprite_index = spr_messenger_fog
		var inst4 = instance_create_depth(x,y-60-global.grid_cell_size_y,-800,obj_engineer_bullet_effect)
		inst4.sprite_index = spr_messenger_fog
		var inst5 = instance_create_depth(x,y-60+global.grid_cell_size_y,-800,obj_engineer_bullet_effect)
		inst5.sprite_index = spr_messenger_fog
	}""",
              """	// 【变异屎者·技能4】便便爆炸 3*3（原版十字 5 格）
	if timer == 45{
		for (var _ox = -1; _ox <= 1; _ox++){
			for (var _oy = -1; _oy <= 1; _oy++){
				var inst = instance_create_depth(x + _ox * global.grid_cell_size_x,
				                                 y - 60 + _oy * global.grid_cell_size_y,
				                                 -800, obj_engineer_bullet_effect)
				inst.sprite_index = spr_messenger_fog
			}
		}
	}""", "shi poop effect")
        patch(os.path.join(OBJ_DIR, obj_name(key, "poop"), "Step_0.gml"),
              "if((abs(grid_col - other.grid_col) + abs(grid_row - other.grid_row)) <= 1 && plant_id != \"player\" &&  plant_type != \"coffee\"){",
              "if(abs(grid_col - other.grid_col) <= 1 && abs(grid_row - other.grid_row) <= 1 && plant_id != \"player\" &&  plant_type != \"coffee\"){",
              "shi poop range")

    elif key == "jack":
        # 技能1：锤击 3×3
        patch(fn("Step_0.gml"),
              """		if timer == 26*5-1{
			with obj_card_parent{
				if grid_col >= other.grid_col - 2 && grid_col <= other.grid_col && grid_row == other.grid_row &&""",
              """		// 【变异杰克·技能1】锤击 3*3（原版同行 3 格）
		if timer == 26*5-1{
			with obj_card_parent{
				if grid_col >= other.grid_col - 2 && grid_col <= other.grid_col && abs(grid_row - other.grid_row) <= 1 &&""",
              "jack skill1")

        # 技能3：陨石随机砸 10 格（原版 4 格）；节奏与总时长同比放大
        patch(fn("Step_0.gml"),
              """		if skill_timer < 12 * 5 * 4{
			timer = 0
			skill_timer ++
			if skill_timer == 1{
				y -= 800
				// 创建已选坐标数组
				var selected_coords = [];

				// 循环直到选出4个不同的坐标
				while (array_length(selected_coords) < 4) {""",
              """		// 【变异杰克·技能3】陨石每次随机砸 10 格（原版 4 格）
		if skill_timer < 10 * 60{
			timer = 0
			skill_timer ++
			if skill_timer == 1{
				y -= 800
				// 创建已选坐标数组
				var selected_coords = [];

				// 循环直到选出 10 个不同的坐标
				while (array_length(selected_coords) < 10) {""", "jack skill3 head")
        # 每 60 帧掉一颗：5 / 65 / … / 545 正好 10 颗。
        # 上限必须写死 10*60（=600），写 10*60+20 会多跑到 605，
        # target_coord[10] 越界 → 直接报错。落地时间同理取 598。
        patch(fn("Step_0.gml"),
              "			if skill_timer == 238{",
              "			if skill_timer == 10 * 60 - 2{", "jack skill3 tail")

        # 技能4：一次召唤 6 只火老鼠（原版 240 帧内 4 只）
        patch(fn("Step_0.gml"),
              """		if timer mod 70 == 15{
			var tg_row = irandom_range(0,global.grid_rows-1)
			var tg_y = get_world_position_from_grid(9,tg_row).y + 33
			var inst = instance_create_depth(x-80,y,-800,obj_kf_zrb_jack_fire)
			inst.y_move = (tg_y-y)/120
		}""",
              """		// 【变异杰克·技能4】一次召唤 6 只火老鼠（原版 240 帧内 4 只）
		if timer == 15{
			for (var _i = 0; _i < 6; _i++){
				var tg_row = irandom_range(0, global.grid_rows - 1)
				var tg_y = get_world_position_from_grid(9, tg_row).y + 33
				var inst = instance_create_depth(x - 80, y - _i * 26, -800, obj_kf_zrb_jack_fire)
				inst.y_move = (tg_y - y) / 120
			}
		}""", "jack skill4")

        # 技能2：滚石加速 + 加血
        patch(os.path.join(OBJ_DIR, obj_name(key, "rock_skill_4"), "Create_0.gml"),
              "hp = 1800\nmaxhp = 1800",
              "hp = 5400\nmaxhp = 5400", "jack rock hp")
        patch(os.path.join(OBJ_DIR, obj_name(key, "rock_skill_4"), "Create_0.gml"),
              "move_speed = 1",
              "move_speed = 2\n\n// 【变异杰克·技能2】滚石速度 1 → 2（每帧左移像素数）\nrock_speed = 2",
              "jack rock speed")
        patch(os.path.join(OBJ_DIR, obj_name(key, "rock_skill_4"), "Step_0.gml"),
              "		x -= 1",
              "		x -= rock_speed", "jack rock step")

    elif key == "vajra":
        # 技能1：踩踏后留下 3*3 冰冻区域，持续 5 秒
        patch(fn("Step_0.gml"),
              """		if timer == 6*5{
			with obj_card_parent{
				if grid_col >= other.grid_col - 2 && grid_col <= other.grid_col && abs(grid_row-other.grid_row) <= 1 && plant_id != "player" && plant_type != "coffee" && plant_id != "cotton_candy"{
					instance_destroy()
					if hp >= max_hp{
						obj_task_manager.card_loss++
					}
				}
			}
		}""",
              """		if timer == 6*5{
			with obj_card_parent{
				if grid_col >= other.grid_col - 2 && grid_col <= other.grid_col && abs(grid_row-other.grid_row) <= 1 && plant_id != "player" && plant_type != "coffee" && plant_id != "cotton_candy"{
					instance_destroy()
					if hp >= max_hp{
						obj_task_manager.card_loss++
					}
				}
			}
			// 【变异金刚·技能1】踩踏后留下 3*3 冰冻区，5 秒内补种进去的卡片会被冻住
			var _ic = grid_col - 1
			var _ir = grid_row
			var _ip = get_world_position_from_grid(_ic, _ir)
			var _idge = calculate_plant_depth(_ic, max(_ir - 2, 0), "normal") + 40
			var _ice = instance_create_depth(_ip.x, _ip.y, _idge, obj_kuafu_boss_ice_area)
			_ice.ice_radius = 1
			_ice.ice_life   = 5 * 60
			_ice.ice_col    = _ic
			_ice.ice_row    = _ir
		}""", "vajra skill1 ice")

        # 技能2：一次 10 坨岩浆（原版 5 坨）
        patch(fn("Step_0.gml"),
              """		if timer == 6 * 5 - 1{
			for(var i = 0 ; i < 5 ; i ++){""",
              """		// 【变异金刚·技能2】一次发射 10 坨岩浆（原版 5 坨）
		if timer == 6 * 5 - 1{
			for(var i = 0 ; i < 10 ; i ++){""", "vajra skill2")

        # 技能3：电刺防爆 + 出现 4 秒后放电（原版 9 秒）
        patch(os.path.join(OBJ_DIR, obj_name(key, "spike"), "Create_0.gml"),
              "immune_to_ash = false",
              "immune_to_ash = true", "vajra spike ash")
        patch(os.path.join(OBJ_DIR, obj_name(key, "spike"), "Step_0.gml"),
              "	if timer >= 540{",
              "	if timer >= 4 * 60{          // 【变异金刚·技能3】出现 4 秒后放电（原版 540）",
              "vajra spike timing")

        # 放电判定在 BOSS 这边（timer == 60 + 60*8 - 1），并且会先检查棘刺实例是否还在。
        # 棘刺改成 4 秒缩回后，如果放电时间不动，判定时棘刺全没了 → 一根闪电都不会出现。
        # 所以把整段 60*8 的节奏一起压到 60*4：4 秒放电、随后收尾。
        p3 = fn("Step_0.gml")
        txt = io.open(p3, encoding="utf-8").read()
        counts = (txt.count("60*8"), txt.count("60* 8"), txt.count("60 * 8"))
        if counts != (3, 1, 1):
            raise RuntimeError("vajra skill3 放电节奏：预期 60*8 ×3 / '60* 8' ×1 / '60 * 8' ×1，实际 %s" % (counts,))
        txt = (txt.replace("60*8", "60*4")
                  .replace("60* 8", "60* 4")
                  .replace("60 * 8", "60 * 4"))
        io.open(p3, "w", encoding="utf-8", newline="\n").write(txt)

        # 技能4：分裂成变异皮特 + 变异朱莉
        patch(fn("Step_0.gml"),
              "			band_inst1 = instance_create_depth(x,y,-800,obj_pete)",
              "			band_inst1 = instance_create_depth(x,y,-800,obj_kuafu_boss_pete)   // 【变异金刚·技能4】分裂为变异皮特",
              "vajra split1")
        patch(fn("Step_0.gml"),
              "			band_inst2 = instance_create_depth(x,y,-800,obj_fog_julie)",
              "			band_inst2 = instance_create_depth(x,y,-800,obj_kuafu_boss_julie)  // 【变异金刚·技能4】分裂为变异朱莉",
              "vajra split2")

    elif key == "cap":
        # 技能3：彩虹整列 7 条
        patch(fn("Step_0.gml"),
              """		if timer >= 10 * 5 - 1 && jump_times < 5 && (timer-49) mod 45 == 1{
			var rainbow_pos = get_world_position_from_grid(6,5-jump_times)
			instance_create_depth(rainbow_pos.x,rainbow_pos.y,-800,obj_kf_zrb_cap_rainbow)
			jump_times ++
		}""",
              """		// 【变异美队·技能3】敬礼彩虹铺满整列 7 格（原版 5 格）
		if timer >= 10 * 5 - 1 && jump_times < global.grid_rows && (timer-49) mod 16 == 1{
			var rainbow_pos = get_world_position_from_grid(6, global.grid_rows - 1 - jump_times)
			instance_create_depth(rainbow_pos.x, rainbow_pos.y, -800, obj_kf_zrb_cap_rainbow)
			jump_times ++
		}""", "cap rainbow")

        # 技能3：第 9 列整列 7 个空中航母
        patch(fn("Step_0.gml"),
              """		if timer == 10 * 5 - 1{
			var mouse_pos = get_world_position_from_grid(9,1)
			instance_create_depth(mouse_pos.x,mouse_pos.y,-800,obj_aircraft_carrier)
			var mouse_pos1 = get_world_position_from_grid(9,global.grid_rows-2)
			instance_create_depth(mouse_pos1.x,mouse_pos1.y,-800,obj_aircraft_carrier)
		}""",
              """		// 【变异美队·技能3】第 9 列整列 7 个空中航母（原版 2 个）
		if timer == 10 * 5 - 1{
			for (var _r = 0; _r < global.grid_rows; _r++){
				var mouse_pos = get_world_position_from_grid(9, _r)
				instance_create_depth(mouse_pos.x, mouse_pos.y, -800, obj_aircraft_carrier)
			}
		}""", "cap carrier")

        # 技能2：肘击 2*2（原版同行 2 格）
        patch(fn("Step_0.gml"),
              """		if timer mod 335 == 167{
			with obj_card_parent{
				if grid_col <= other.grid_col-1 && grid_col >= other.grid_col-2 && grid_row == other.grid_row &&""",
              """		// 【变异美队·技能2】肘击摧毁 2*2（原版同行 2 格）
		if timer mod 335 == 167{
			// 2 行：自身行 + 相邻行（贴顶时改成向下取一行）
			var _elbow_row_b = grid_row - 1
			if _elbow_row_b < 0{
				_elbow_row_b = grid_row + 1
			}
			with obj_card_parent{
				if grid_col <= other.grid_col-1 && grid_col >= other.grid_col-2 &&
				(grid_row == other.grid_row || grid_row == _elbow_row_b) &&""",
              "cap elbow")

        # 彩虹：血量 1w + 死后变变异特种鼠
        patch(os.path.join(OBJ_DIR, obj_name(key, "rainbow"), "Step_0.gml"),
              "		instance_create_depth(grid_pos.x+10,grid_pos.y+38,depth,obj_soldier_mouse)",
              "		instance_create_depth(grid_pos.x+10,grid_pos.y+38,depth,obj_kuafu_armour)   // 【变异美队·技能3】彩虹变为变异特种鼠",
              "cap rainbow child")


# ---------------------------------------------------------------- 注册
def ensure_folder(path, name, child_folders=(), items=()):
    full = os.path.join(ROOT, path.replace("/", os.sep))
    os.makedirs(os.path.dirname(full), exist_ok=True)
    folders, listitems = [], []
    if os.path.exists(full):
        try:
            d = load_yy(full)
            folders = [(f["name"], f["path"]) for f in d.get("folders", [])]
            listitems = [(f["name"], f["path"]) for f in d.get("listItems", [])]
        except Exception:
            pass
    for c in child_folders:
        if c not in folders:
            folders.append(c)
    for it in items:
        if it not in listitems:
            listitems.append(it)

    txt = ('{\n  "$GMFolder":"",\n  "%%Name":"%s",\n  "folderPath":"%s",\n'
           '  "isDefaultView":false,\n  "listViewItems":[],\n  "name":"%s",\n'
           '  "resourceType":"GMFolder",\n  "resourceVersion":"2.0",\n'
           '  "viewLocked":false,\n  "visible":true,\n  "folders":[\n%s  ],\n'
           '  "listItems":[\n%s  ],\n}\n') % (
        name, path, name,
        "".join('    {"name":"%s","path":"%s",},\n' % f for f in folders),
        "".join('    {"name":"%s","path":"%s",},\n' % i for i in listitems))
    io.open(full, "w", encoding="utf-8", newline="\n").write(txt)


def yyp_add(entries):
    txt = io.open(YYP, encoding="utf-8-sig").read()
    res_add, fold_add = [], []
    for kind, path in entries:
        if kind == "res":
            name = path.split("/")[1]
            if '"path":"%s"' % path in txt:
                continue
            res_add.append('    {"id":{"name":"%s","path":"%s",},},\n' % (name, path))
        else:
            name = os.path.splitext(os.path.basename(path))[0]
            if '"folderPath":"%s"' % path in txt:
                continue
            fold_add.append('    {"$GMFolder":"","%%Name":"%s","folderPath":"%s","name":"%s",'
                            '"resourceType":"GMFolder","resourceVersion":"2.0",},\n'
                            % (name, path, name))
    if res_add:
        m = re.search(r'"resources":\[\n', txt)
        txt = txt[:m.end()] + "".join(res_add) + txt[m.end():]
    if fold_add:
        m = re.search(r'"Folders":\[\n', txt)
        txt = txt[:m.end()] + "".join(fold_add) + txt[m.end():]
    io.open(YYP, "w", encoding="utf-8", newline="\n").write(txt)


def register(only=None):
    spr_folders, obj_folders, entries = [], [], []
    for boss in S.MICE:
        if only and boss["key"] != only:
            continue
        key = boss["key"]

        sp_items = []
        for item in boss["sprites"]:
            name = sprite_name(key, item[0])
            p = "sprites/%s/%s.yy" % (name, name)
            sp_items.append((name, p))
            entries.append(("res", p))
        sp_path = "%s/%s.yy" % (SPR_FOLDER, key)
        ensure_folder(sp_path, key, items=sp_items)
        spr_folders.append((key, sp_path))
        entries.append(("folder", sp_path))

        ob_items = []
        oname = obj_name(key)
        p = "objects/%s/%s.yy" % (oname, oname)
        ob_items.append((oname, p))
        entries.append(("res", p))
        for ex in boss.get("extras", ()):
            n2 = obj_name(key, ex["key"])
            p2 = "objects/%s/%s.yy" % (n2, n2)
            ob_items.append((n2, p2))
            entries.append(("res", p2))
        ob_path = "%s/%s.yy" % (OBJ_FOLDER, key)
        ensure_folder(ob_path, key, items=ob_items)
        obj_folders.append((key, ob_path))
        entries.append(("folder", ob_path))

    spr_root = "folders/精灵/Enemy/kuafu/zhuorediyu/boss.yy"
    ensure_folder(spr_root, "boss", child_folders=spr_folders)
    obj_root = "folders/物体/Enemy/kuafu/zhuorediyu/boss.yy"
    ensure_folder(obj_root, "boss", child_folders=obj_folders)

    ensure_folder("folders/精灵/Enemy/kuafu/zhuorediyu.yy", "zhuorediyu",
                  child_folders=[("boss", spr_root)])
    ensure_folder("folders/物体/Enemy/kuafu/zhuorediyu.yy", "zhuorediyu",
                  child_folders=[("boss", obj_root)])
    entries += [("folder", spr_root), ("folder", obj_root)]
    yyp_add(entries)
    print("[register] 资源与文件夹已登记")


def main():
    what = sys.argv[1] if len(sys.argv) > 1 else "all"
    only = sys.argv[2] if len(sys.argv) > 2 else None
    if what in ("sprites", "all"):
        build_sprites(only)
    if what in ("objects", "all"):
        build_objects(only)
    if what in ("register", "all"):
        register(only)


if __name__ == "__main__":
    main()

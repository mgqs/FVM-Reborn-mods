# -*- coding: utf-8 -*-
"""「灼热地域」跨服章节 · 变异僵尸 BOSS 规格表。

5 只 BOSS 全部照抄项目里已有的同名鼠代码（行为、技能流程一致），只改技能参数。
精灵按 SWF 的 FrameLabel 分段，重采样到原版精灵的帧数契约
（因为对象代码里的 `mod N` 是硬编码，帧数必须与原版一致）。

段写法（三选一）：
    ("标签", n)              单标签区间重采样到 n 帧
    (("标签A", "标签B"), n)   合并连续标签重采样到 n 帧
    (None, n, (起, 止))      绝对 SWF 帧区间（起含止不含）
"""

PREFIX = "kf_zrb_"
SRC_ROOT = r"C:\Users\18203\Desktop\跨服\灼热地域\BOSS\精灵"
SWF_ROOT = r"C:\Users\18203\Desktop\跨服\灼热地域\BOSS\swf"

# ---------------------------------------------------------------------------
# 1. 变异玛丽 —— obj_blonde_mary（金发玛丽：骑螃蟹的人鱼）
#    技能：①冲撞（同时 2 行、每行 4 格）②回旋镖（不变）③催眠（10s）
#    素材可视尺寸与原版 1:1（待机 160x117 vs 159x119），不需要缩放。
# ---------------------------------------------------------------------------
MARY = dict(
    key="mary", cn="变异玛丽", src_cn="变异玛丽",
    swf="变异玛丽.swf", sid=87, old="obj_blonde_mary",
    hp=30000, icon="spr_blonde_mary_icon", scale=1.0,
    sprites=[
        ("main", "spr_blonde_mary_idle", 12,
         [("正常待机", 6), ("受伤待机", 6)]),
        # 出现 = 钻出地面 17 + 17
        ("appear", "spr_blonde_mary_appear", 34,
         [("正常钻出地面", 17), ("受伤钻出地面", 17)]),
        # 消失 = 钻入地面 18 + 18
        ("disappear", "spr_blonde_mary_disappear", 36,
         [("正常钻入地面", 18), ("受伤钻入地面及死亡", 18)]),
        # 死亡复用「钻入地面」18 帧（原版 death 就是同一条下沉动作）
        ("death", "spr_blonde_mary_death", 18,
         [("正常钻入地面", 18)]),
        ("skill_1_forward", "spr_blonde_mary_skill_1_forward", 16,
         [("正常向左移动", 8), ("受伤向左移动", 8)]),
        ("skill_1_backward", "spr_blonde_mary_skill_1_backward", 16,
         [("正常向右移动", 8), ("受伤向右移动", 8)]),
        ("skill_2_ready", "spr_blonde_mary_skill_2_ready", 10,
         [("正常吹海螺", 5), ("受伤吹海螺", 5)]),
        ("skill_2", "spr_blonde_mary_skill_2", 12,
         [("正常吹海螺循环", 6), ("受伤吹海螺循环", 6)]),
        # 代码分段 7 / 7 / 5（各半 19 帧）：放镖 / 等镖 / 镖回
        ("skill_3", "spr_blonde_mary_skill_3", 38,
         [("正常放飞镖", 7), ("正常等飞镖飞回待机", 7), ("正常飞镖飞回", 5),
          ("受伤放飞镖", 7), ("受伤等飞镖飞回待机", 7), ("受伤飞镖飞回", 5)]),
        # 回旋镖本体 image_speed = 0，只用 1 帧（素材 4 帧是同一条镖的转动）
        ("boomerang", "spr_blonde_mary_boomerang", 1,
         [(None, 1, (0, 1))], 8),
    ],
    extras=[
        dict(key="bullet", old="obj_blonde_mary_bullet", hp=None),
    ],
)

# ---------------------------------------------------------------------------
# 2. 变异屎者 —— obj_hells_messenger
#    技能：①召唤 10 只幽灵 ②权杖（血量 1w）③吞噬 8 格 ④便便 3×3
# ---------------------------------------------------------------------------
SHI = dict(
    key="shi", cn="变异屎者", src_cn="变异屎者",
    swf="变异屎者.swf", sid=194, old="obj_hells_messenger",
    hp=30000, icon="spr_hells_messenger_icon", scale=1.0,
    sprites=[
        ("main", "spr_hells_messenger_idle", 20,
         [("正常透明待机", 10), ("受伤透明待机", 10)]),
        ("appear", "spr_hells_messenger_appear", 12,
         [("正常透明闪入", 6), ("受伤透明闪入", 6)]),
        ("disappear", "spr_hells_messenger_disappear", 10,
         [("正常透明闪出", 5), ("受伤透明闪出", 5)]),
        # 50 = 正常召唤9 + 正常释放16 + 受伤召唤9 + 受伤释放16
        ("skill_1", "spr_hells_messenger_skill_1", 50,
         [("正常透明召唤鬼火", 9), ("正常透明释放幽灵", 16),
          ("受伤透明召唤鬼火", 9), ("受伤透明释放幽灵", 16)]),
        ("skill_2_ready", "spr_hells_messenger_skill_2_ready", 20,
         [("正常扔杖", 10), ("受伤扔杖", 10)]),
        ("skill_2_idle", "spr_hells_messenger_skill_2_idle", 20,
         [("正常实体待机", 10), ("受伤实体待机", 10)]),
        ("skill_3_ready", "spr_hells_messenger_skill_3_ready", 32,
         [(("正常睡觉", "正常睡觉循环"), 16), (("受伤睡觉", "受伤睡觉循环"), 16)]),
        ("skill_3", "spr_hells_messenger_skill_3", 18,
         [("正常吃东西", 9), ("受伤吃东西", 9)]),
        ("skill_4_ready", "spr_hells_messenger_skill_4_ready", 32,
         [(("正常挠头", "正常挠头循环"), 16), (("受伤挠头", "受伤挠头循环"), 16)]),
        ("skill_4", "spr_hells_messenger_skill_4", 14,
         [(("正常拉便便", "正常拉便便循环"), 7),
          (("受伤拉便便", "受伤拉便便循环"), 7)]),
        ("death", "spr_hells_messenger_death", 16,
         [("死亡", 16)]),
        # 配套物件（各自的 sprite id）
        # 权杖 20 帧 = 旋转1 + 落地11 + 待机8
        ("mace", "spr_messenger_mace", 20,
         [(None, 1, (0, 7)), (None, 11, (7, 18)), (None, 8, (18, 26))], 119),
        ("poop", "spr_messenger_poop", 6,
         [(None, 6, (0, 6))], 54),
        # 鬼火 25 帧 = 出现8 / 循环8 / 变成有零鼠9，代码是 7+10+8
        ("ignis", "spr_messenger_ignis_fatuus", 25,
         [(None, 7, (0, 8)), (None, 10, (8, 16)), (None, 8, (16, 25))], 51),
    ],
    extras=[
        dict(key="mace", old="obj_messenger_mace", hp=None),
        dict(key="poop", old="obj_messenger_poop", hp=None),
        dict(key="ignis", old="obj_messenger_ignis_fatuus", hp=None),
    ],
)

# ---------------------------------------------------------------------------
# 3. 变异杰克 —— obj_irritable_jack
#    技能：①锤击 3×3 ②滚石加速加血 ③陨石 10 格 ④一次召唤 6 只火老鼠
# ---------------------------------------------------------------------------
JACK = dict(
    key="jack", cn="变异杰克", src_cn="变异杰克",
    swf="变异杰克.swf", sid=95, old="obj_irritable_jack",
    hp=60000, icon="spr_irritable_jack_icon", scale=1.0,
    sprites=[
        ("main", "spr_irritable_jack_idle", 16,
         [("正常待机", 8), ("受伤待机", 8)]),
        # 出现 = 跳跃预备1+淡出+预备2+淡入+回落（25 帧）→ 11
        ("appear", "spr_irritable_jack_appear", 22,
         [(("正常跳跃预备1", "正常跳跃回落"), 11),
          (("受伤跳跃预备1", "受伤跳跃回落"), 11)]),
        # 技能1 蓄力 = 预备1+淡出+预备2+淡入（0..17）
        ("skill_1_ready", "spr_irritable_jack_skill_1_ready", 32,
         [(None, 16, (0, 17)), (None, 16, (101, 118))]),
        ("skill_1", "spr_irritable_jack_skill_1", 38,
         [("正常砸拳", 19), ("受伤砸拳", 19)]),
        ("skill_2_ready", "spr_irritable_jack_skill_2_ready", 12,
         [("正常召唤火鼠", 6), ("受伤召唤火鼠", 6)]),
        ("skill_2", "spr_irritable_jack_skill_2", 14,
         [("正常召唤火鼠循环", 7), ("受伤召唤火鼠循环", 7)]),
        # 技能3 落地 = 下落 + 砸地（对象代码 SKILL3/SKILL4 的前半段都先播 skill_3 砸地）
        ("skill_3", "spr_irritable_jack_skill_3", 34,
         [(("下落", "砸地"), 17), (("受伤下落", "受伤砸地"), 17)]),
        # 技能4 = 滚动（滚石技能后半段 BOSS 自己滚走）
        ("skill_4", "spr_irritable_jack_skill_4", 20,
         [("滚动", 10), ("受伤滚动", 10)]),
        # 技能4 收尾 = 变身恢复（陨石技能后半段 BOSS 变回本体）
        ("skill_4_return", "spr_irritable_jack_skill_4_return", 30,
         [("正常变身", 15), ("受伤变身", 15)]),
        ("death", "spr_irritable_jack_death", 23,
         [("死亡", 23)]),
        # 落石：0..17 下落+砸地（17 帧）；16..26 滚动（10 帧）
        ("head_skill_3", "spr_irritable_jack_head_skill_3", 17,
         [(None, 17, (0, 17))], 64),
        ("head_skill_4", "spr_irritable_jack_head_skill_4", 10,
         [(None, 10, (16, 26))], 64),
        ("body_skill_3", "spr_irritable_jack_body_skill_3", 17,
         [(None, 17, (0, 17))], 59),
        ("body_skill_4", "spr_irritable_jack_body_skill_4", 10,
         [(None, 10, (16, 26))], 59),
        # 火球 9 帧 = 火球5 + 火球变老鼠4
        ("fire", "spr_irritable_jack_fire_mouse_appear", 9,
         [("火球", 5), ("火球变老鼠", 4)], 39),
        # 火老鼠 9 帧 = 循环6 + 燃烧3
        ("fire_mouse", "spr_irritable_jack_fire_mouse", 9,
         [("火老鼠循环", 6), ("起始燃烧", 3)], 39),
    ],
    extras=[
        dict(key="fire", old="obj_irritable_jack_fire", hp=None),
        dict(key="fire_mouse", old="obj_irritable_jack_fire_mouse", hp=None),
        dict(key="rock_skill_3", old="obj_irritable_jack_rock_skill_3", hp=None),
        dict(key="rock_skill_4", old="obj_irritable_jack_rock_skill_4", hp=None),
    ],
)

# ---------------------------------------------------------------------------
# 4. 变异金刚 —— obj_hot_vajra
#    技能：①踩踏留 3×3 冰冻区（5s）②10 坨岩浆 ③电刺防爆、4s 后放电 ④分裂成变异皮特/朱莉
# ---------------------------------------------------------------------------
VAJRA = dict(
    key="vajra", cn="变异金刚", src_cn="变异金刚",
    swf="变异金刚.swf", sid=217, old="obj_hot_vajra",
    hp=80000, icon="spr_hot_vajra_icon", scale=1.0,
    sprites=[
        ("main", "spr_hot_vajra_idle", 20,
         [("正常待机", 10), ("受伤待机", 10)]),
        # 出现 = 合体预备 + 合体（45 帧）→ 12
        ("appear", "spr_hot_vajra_appear", 24,
         [(("正常合体预备", "正常合体"), 12), (("受伤合体预备", "受伤合体"), 12)]),
        ("disappear", "spr_hot_vajra_disappear", 24,
         [("正常分体", 12), ("受伤分体", 12)]),
        ("skill_1", "spr_hot_vajra_skill_1", 28,
         [("正常践踏", 14), ("受伤践踏", 14)]),
        ("skill_2", "spr_hot_vajra_skill_2", 18,
         [("正常甩岩浆", 9), ("受伤甩岩浆", 9)]),
        ("skill_3_ready", "spr_hot_vajra_skill_3_ready", 24,
         [("正常插入", 12), ("受伤插入", 12)]),
        ("skill_3", "spr_hot_vajra_skill_3", 20,
         [("正常插入待机", 10), ("受伤插入待机", 10)]),
        ("skill_4", "spr_hot_vajra_skill_4", 52,
         [("正常分体", 26), ("受伤分体", 26)]),
        ("skill_4_return", "spr_hot_vajra_skill_4_return", 90,
         [("正常合体", 45), ("受伤合体", 45)]),
        ("death", "spr_hot_vajra_death", 26,
         [("死亡", 26)]),
        ("spike", "spr_vajra_spike", 13,
         [("钻出", 8), ("循环", 5)], 56),
        ("lava", "spr_vajra_lava", 2,
         [("喷射岩浆", 1), ("岩浆掉落", 1)], 69),
        # 6 种闪电：各 2 帧（代码 mod 2）
        ("lightning_horizontal", "spr_vajra_lightning_horizontal", 2,
         [(None, 2, (0, 2))], 12),
        ("lightning_vertical", "spr_vajra_lightning_vertical", 2,
         [(None, 2, (0, 2))], 19),
        ("lightning_incline_1", "spr_vajra_lightning_incline_1", 2,
         [(None, 2, (0, 2))], 22),
        ("lightning_incline_2", "spr_vajra_lightning_incline_2", 2,
         [(None, 2, (0, 2))], 8),
        ("lightning_incline_1_short", "spr_vajra_lightning_incline_1_short", 2,
         [(None, 2, (0, 2))], 4),
        ("lightning_incline_2_short", "spr_vajra_lightning_incline_2_short", 2,
         [(None, 2, (0, 2))], 15),
    ],
    extras=[
        dict(key="spike", old="obj_vajra_spike", hp=None),
        dict(key="lava", old="obj_vajra_lava", hp=None),
        dict(key="lightning", old="obj_vajra_lightning", hp=None),
    ],
)

# ---------------------------------------------------------------------------
# 5. 变异美队 —— obj_captain_america_mouse
#    技能：①飞盾（不变）②肘击 2×2 ③敬礼彩虹整列 + 血 1w + 变变异特种鼠 + 第 9 列整列航母
# ---------------------------------------------------------------------------
CAP = dict(
    key="cap", cn="变异美队", src_cn="变异美队",
    swf="变异美队.swf", sid=103, old="obj_captain_america_mouse",
    hp=90000, icon="spr_captain_america_mouse_icon", scale=1.0,
    sprites=[
        ("main", "spr_captain_america_mouse_idle", 22,
         [("待机", 11), ("受伤待机", 11)]),
        ("appear1", "spr_captain_america_mouse_appear1", 22,
         [("奔跑闪入", 11), ("受伤奔跑闪入", 11)]),
        ("disappear1", "spr_captain_america_mouse_disappear1", 22,
         [("奔跑闪出", 11), ("受伤奔跑闪出", 11)]),
        ("appear2", "spr_captain_america_mouse_appear2", 22,
         [("空手奔跑闪入", 11), ("受伤空手奔跑闪入", 11)]),
        ("disappear2", "spr_captain_america_mouse_disappear2", 22,
         [("空手奔跑闪出", 11), ("受伤空手奔跑闪出", 11)]),
        ("skill_1_ready", "spr_captain_america_mouse_skill_1_ready", 56,
         [("扔盾", 28), ("受伤扔盾", 28)]),
        ("skill_1_idle", "spr_captain_america_mouse_skill_1_idle", 22,
         [("空手待机", 11), ("受伤空手待机", 11)]),
        ("skill_1_return", "spr_captain_america_mouse_skill_1_return", 12,
         [("接盾", 6), ("受伤接盾", 6)]),
        ("skill_2", "spr_captain_america_mouse_skill_2", 108,
         [("敬礼", 54), ("受伤敬礼", 54)]),
        ("skill_3", "spr_captain_america_mouse_skill_3", 42,
         [("撞击", 21), ("受伤撞击", 21)]),
        ("death", "spr_captain_america_mouse_death", 28,
         [("死亡", 28)]),
        # 彩虹 60 帧 = appear 11 / idle 37 / death 12；素材 63 帧无标签，按比例切
        ("rainbow", "spr_captain_america_mouse_rainbow", 60,
         [(None, 11, (0, 12)), (None, 37, (12, 49)), (None, 12, (49, 63))], 51),
        ("shield", "spr_captain_america_mouse_shield", 18,
         [(None, 18, (0, 18))], 18),
        ("effect", "spr_captain_america_mouse_effect", 4,
         [(None, 4, (0, 4))], 37),
    ],
    extras=[
        dict(key="shield", old="obj_captain_shield", hp=None),
        dict(key="rainbow", old="obj_captain_rainbow", hp=10000),
    ],
)

MICE = [MARY, SHI, JACK, VAJRA, CAP]

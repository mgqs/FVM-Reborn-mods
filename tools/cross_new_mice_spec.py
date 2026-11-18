# -*- coding: utf-8 -*-
"""跨服新章节「水火之间 / 巫毒研究所」小怪规格表（2026-11-14）。

行为代码一律照抄本体同名鼠对象，这里只描述：
  - 精灵：素材帧号区间 → 目标精灵帧数（超采样/重采样由 build 脚本处理）
  - 数值：hp / move_speed / 防爆
  - 对象：从哪个原版对象照抄

素材帧号从 0 起，对应 `<中文名>/<帧号+1>.png`。

段格式 (标签, 起帧, 止帧, 目标帧数)：
  起止是素材帧号（左闭右开），目标帧数是该段在 GMS 精灵里占几帧；
  两者长度不同会按首尾保留重采样。
  占位段写 (标签, 起, 起+1, 1) 即复制该帧。
"""

# 段布局必须与照抄对象的 move_anim / attack_anim / death_anim 严格一致：
#   两段式（无盾）精灵总帧数 = move_anim*2 + attack_anim*2 + death_anim

CASES = [
    # ---------------------------------------------------------------- 水火之间
    dict(
        prefix="kf_sh_", key="rowboat", cn="划艇僵尸鼠",
        src=r"水火之间/小怪/精灵/划艇僵尸鼠", total_src=56,
        old="obj_rowboat_mouse", hp=2400, speed=0.45,
        # 本体 Step_0 里后退时 move_speed = -0.36（表格 12×0.03），前进 0.45（15×0.03）
        # 速度比 5:4、时长 8:5 → 路程 2:1，与用户给的口径一致，代码不用改。
        sprites=[
            ("main", "spr_rowboat_mouse", 42, [
                ("正常划水", 16, 29, 13),
                ("受伤划水", 29, 42, 13),
                ("攻击占位", 16, 17, 1),
                ("受伤攻击占位", 29, 30, 1),
                ("死亡下沉", 42, 56, 14),
            ], (16, "spr_rowboat_mouse", 0)),
            ("appear", "spr_rowboat_mouse_appear", 16, [
                ("正常冒出", 0, 16, 16),
            ], (0, "spr_rowboat_mouse_appear", 0)),
        ],
    ),
    dict(
        prefix="kf_sh_", key="dragon_boat", cn="龙舟僵尸鼠",
        src=r"水火之间/小怪/精灵/龙舟僵尸鼠", total_src=56,
        old="obj_dragon_boat_mouse", hp=5400, speed=0.60,
        sprites=[
            ("main", "spr_dragon_boat_mouse", 42, [
                ("正常划水", 16, 29, 13),
                ("受伤划水", 29, 42, 13),
                ("攻击占位", 16, 17, 1),
                ("受伤攻击占位", 29, 30, 1),
                ("死亡下沉", 42, 56, 14),
            ], (16, "spr_dragon_boat_mouse", 0)),
            ("appear", "spr_dragon_boat_mouse_appear", 16, [
                ("正常冒出", 0, 16, 16),
            ], (0, "spr_dragon_boat_mouse_appear", 0)),
        ],
    ),
    dict(
        prefix="kf_sh_", key="flagship", cn="旗舰僵尸鼠",
        src=r"水火之间/小怪/精灵/旗舰僵尸鼠", total_src=56,
        old="obj_flagship_mouse", hp=18000, speed=0.60,
        sprites=[
            ("main", "spr_flagship_mouse", 42, [
                ("正常划水", 16, 29, 13),
                ("受伤划水", 29, 42, 13),
                ("攻击占位", 16, 17, 1),
                ("受伤攻击占位", 29, 30, 1),
                ("死亡下沉", 42, 56, 14),
            ], (16, "spr_flagship_mouse", 0)),
            ("appear", "spr_flagship_mouse_appear", 16, [
                ("正常冒出", 0, 16, 16),
            ], (0, "spr_flagship_mouse_appear", 0)),
        ],
    ),
    # 潜艇三件套：land / water 各 36（move 8*2 + attack 4*2 + death 12），enter 16（入水 8 + 出水 8）。
    # 对象 Step_0 里 ACTING 段是手写 image_index 0..7 / 8..15，所以 enter 必须正好 16 帧。
    dict(
        prefix="kf_sh_", key="kof_submarine", cn="拳皇潜艇僵尸鼠",
        src=r"水火之间/小怪/精灵/拳皇潜艇僵尸鼠", total_src=94,
        old="obj_kof_submarine_mouse", hp=22500, speed=0.60,
        sprites=[
            ("land", "spr_kof_submarine_mouse_land", 36, [
                ("正常行走", 0, 12, 8),
                ("同时受伤行走", 20, 32, 8),
                ("正常打东西", 54, 58, 4),
                ("同时受伤打东西", 78, 82, 4),
                ("死亡", 82, 94, 12),
            ], (0, "spr_kof_submarine_mouse_land", 0)),
            ("water", "spr_kof_submarine_mouse", 36, [
                ("正常潜行", 40, 48, 8),
                ("同时受伤水上行走", 62, 70, 8),
                ("正常打东西", 54, 58, 4),
                ("同时受伤打东西", 78, 82, 4),
                ("死亡", 82, 94, 12),
            ], (40, "spr_kof_submarine_mouse", 0)),
            ("enter", "spr_kof_submarine_mouse_enter", 16, [
                ("正常入水", 12, 20, 8),
                ("同时受伤入水", 32, 40, 8),
            ], (12, "spr_kof_submarine_mouse_enter", 0)),
        ],
    ),
    # ------------------------------------------------- 水火之间·第二批（僵尸鼠四类，2026-11-18）
    # 素材来源：桌面 sprites 下 SWF 导出目录（DefineSprite_XX_...），帧名 1.png 起 = 0 基帧号 +1。
    # 分段一律按 SWF FrameLabel；目标帧数 = 原版同名鼠精灵帧数，
    # 因为对象 Step / 父类按 move_anim / attack_anim / death_anim 的帧距索引，帧数必须与原版一致。
    #
    # 打击潜艇僵尸鼠 ← obj_submarine_mouse（水陆双形态、入水/出水动画）
    #   SWF(44) 正常行走 0..11、受伤行走 20..31、死亡 82..93；入水 12..19 / 32..39
    #   原版 spr_submarine_mouse 36 = 正常 12 + 受伤 12 + 死亡 12；enter 16 = 入水 8 + 受伤入水 8
    #   新素材没有陆地形态，land 精灵复用同一批水上帧（行为照抄，水陆切换照常播动画）
    dict(
        prefix="kf_sh_", key="submarine", cn="打击潜艇僵尸鼠",
        src=r"C:/Users/18203/Desktop/sprites/DefineSprite_44_com.aurora.ui.maogoutd.resource.Intruder.zombie.ZombieWaterSubmarineMouseFirstTransMoveIntruderMovie",
        total_src=94, old="obj_submarine_mouse", hp=4500, speed=0.60,
        sprites=[
            ("main", "spr_submarine_mouse", 36, [
                ("正常行走", 0, 12, 8),
                ("受伤行走", 20, 32, 8),
                ("正常攻击", 54, 58, 4),
                ("受伤攻击", 78, 82, 4),
                ("死亡爆炸", 82, 94, 12),
            ], (0, "spr_submarine_mouse", 0)),
            ("land", "spr_submarine_mouse_land", 36, [
                ("正常行走", 0, 12, 8),
                ("受伤行走", 20, 32, 8),
                ("正常攻击", 54, 58, 4),
                ("受伤攻击", 78, 82, 4),
                ("死亡爆炸", 82, 94, 12),
            ], (0, "spr_submarine_mouse", 0)),
            ("enter", "spr_submarine_mouse_enter", 16, [
                ("正常入水", 12, 20, 8),
                ("受伤入水", 32, 40, 8),
            ], (0, "spr_submarine_mouse", 0)),
        ],
    ),
    # 突袭僵尸鼠 ← obj_assault_mouse（本体 + 头盔两段血，水/陆 × 戴帽/不戴帽 4 套精灵 + 钻出）
    #   SWF(50) 钻出 0..10、头套正常 11..26、头套受伤 27..42、正常水上 59..74、受伤水上 75..90、
    #           陆地戴帽 136..151 / 152..167、陆地 168..183 / 184..199
    #   原版各 32 = 正常 16 + 受伤 16（1:1 不需重采样），appear 7（钻出 11 帧重采样）
    dict(
        prefix="kf_sh_", key="assault", cn="突袭僵尸鼠",
        src=r"C:/Users/18203/Desktop/sprites/DefineSprite_50_com.aurora.ui.maogoutd.resource.Intruder.zombie.ZombieWaterBallFansMouseMoveIntruderMovie",
        total_src=200, old="obj_assault_mouse", hp=720, speed=0.36,
        # 表格体力 720 是总血；原版头盔 180 / 总 460 ≈ 39%，按同比例取 280（先破头盔再打本体）
        text_patch=[("Create_0.gml", "helmet_hp = 180", "helmet_hp = 280"),
                    ("Create_0.gml", "helmet_max_hp = 180", "helmet_max_hp = 280")],
        sprites=[
            ("main", "spr_assault_mouse", 32, [
                ("正常水上行走", 59, 75, 8),
                ("受伤水上行走", 75, 91, 8),
                ("正常攻击吃东西", 112, 119, 4),
                ("受伤攻击吃东西", 119, 126, 4),
                ("死亡下沉", 126, 135, 8),
            ], (59, "spr_assault_mouse", 0)),
            ("helmet", "spr_assault_mouse_helmet", 32, [
                ("头套正常水上", 11, 27, 8),
                ("头套受伤水上", 27, 43, 8),
                ("头套正常吃东西", 91, 98, 4),
                ("头套受伤吃东西", 98, 105, 4),
                ("死亡下沉", 126, 135, 8),
            ], (59, "spr_assault_mouse", 0)),
            ("land", "spr_assault_mouse_land", 32, [
                ("正常陆地行走", 168, 184, 8),
                ("受伤陆地行走", 184, 200, 8),
                ("正常攻击吃东西", 112, 119, 4),
                ("受伤攻击吃东西", 119, 126, 4),
                ("死亡下沉", 126, 135, 8),
            ], (59, "spr_assault_mouse", 0)),
            ("land_helmet", "spr_assault_mouse_land_helmet", 32, [
                ("陆地戴帽正常", 136, 152, 8),
                ("陆地戴帽受伤", 152, 168, 8),
                ("头套正常吃东西", 91, 98, 4),
                ("头套受伤吃东西", 98, 105, 4),
                ("死亡下沉", 126, 135, 8),
            ], (59, "spr_assault_mouse", 0)),
            ("appear", "spr_assault_mouse_appear", 7, [
                ("钻出", 0, 11, 7),
            ], (59, "spr_assault_mouse", 0)),
        ],
    ),
    # 忍者首领僵尸鼠 ← obj_ninja_mouse（dash 冲撞 10 点 + 召唤四向随从）
    #   SWF(69) 出场 0..5、受伤出场 6..11、召唤 12..27、受伤召唤 28..43 → summon 44 帧 1:1
    #           行走 44..59(16→12)、攻击 = 待机1 76..85 + 砍 86..95 + 待机2 96..104（29 帧 1:1）、
    #           受伤行走 60..75(16→12)、受伤攻击 105..133（29 帧）、死亡 134..145(12)
    #   原版 94 = 行走 12×2 + 攻击 29×2 + 死亡 12（move_anim 12 / attack_anim 29 / death_anim 12）
    #   表格速度 40 / 8.57 = dash 1.2 / 行走 0.257，与原版 dash 逻辑一致（1.2 在 Step 里写死，不动）
    dict(
        prefix="kf_sh_", key="ninja", cn="忍者首领僵尸鼠",
        src=r"C:/Users/18203/Desktop/sprites/DefineSprite_69_com.aurora.ui.maogoutd.resource.Intruder.zombie.ZombieNinjaMouseMoveIntruderMovie",
        total_src=146, old="obj_ninja_mouse", hp=860, speed=0.257,
        ms_patch=[("Create_0.gml", 0.26, 0.257), ("Step_0.gml", 0.27, 0.257)],
        obj_map=[("obj_minion_mouse", "obj_kf_sh_minion")],
        sprites=[
            ("main", "spr_ninja_mouse", 94, [
                ("正常行走", 44, 60, 12),
                ("受伤行走", 60, 76, 12),
                ("正常攻击", 76, 105, 29),
                ("受伤攻击", 105, 134, 29),
                ("死亡", 134, 146, 12),
            ], (44, "spr_ninja_mouse", 0)),
            ("summon", "spr_ninja_mouse_summon", 44, [
                ("正常出场", 0, 6, 6),
                ("受伤出场", 6, 12, 6),
                ("正常召唤", 12, 28, 16),
                ("受伤召唤", 28, 44, 16),
            ], (44, "spr_ninja_mouse", 0)),
        ],
    ),
    # 僵尸小喽啰鼠 ← obj_minion_mouse（一出生播召唤出场，之后走路 + 啃卡片，不防爆）
    #   SWF(37) 出场 0..9（summon 10 帧 1:1）、正常行进 10..21(12 1:1)、受伤行进 22..33(12 1:1)、
    #           攻击 = 待机1 34..43 + 砍 44..53 + 待机2 54..62（29 帧）、
    #           受伤攻击 63..92（30→29）、死亡 93..104（12→13）
    #   原版 95 = 行进 12×2 + 攻击 29×2 + 死亡 13
    dict(
        prefix="kf_sh_", key="minion", cn="僵尸小喽啰鼠",
        src=r"C:/Users/18203/Desktop/sprites/DefineSprite_37_com.aurora.ui.maogoutd.resource.Intruder.zombie.ZombieNinjaGuardMouseMoveIntruderMovie",
        total_src=105, old="obj_minion_mouse", hp=100, speed=0.257, ash_proof=False,
        ms_patch=[("Create_0.gml", 0.26, 0.257)],
        sprites=[
            ("main", "spr_minion_mouse", 95, [
                ("正常行进", 10, 22, 12),
                ("受伤行进", 22, 34, 12),
                ("正常攻击", 34, 63, 29),
                ("受伤攻击", 63, 93, 29),
                ("死亡", 93, 105, 13),
            ], (10, "spr_minion_mouse", 0)),
            ("summon", "spr_minion_mouse_summon", 10, [
                ("出场", 0, 10, 10),
            ], (10, "spr_minion_mouse", 0)),
        ],
    ),
    # 蜗牛僵尸鼠 ← obj_snail_mouse（碾压卡片 + 留下润滑黏液）
    #   SWF(72) 41 帧与原版 41 帧同构：前进 8 + 受伤前进 8 + 技能 8 + 受伤技能 9 + 爆炸 8（1:1）
    dict(
        prefix="kf_sh_", key="snail", cn="蜗牛僵尸鼠",
        src=r"C:/Users/18203/Desktop/sprites/DefineSprite_72_com.aurora.ui.maogoutd.resource.Intruder.zombie.ZombieSnailMouseMoveIntruderMovie",
        total_src=41, old="obj_snail_mouse", hp=5400, speed=0.30,
        ms_patch=[("Create_0.gml", 0.5, 0.30)],
        obj_map=[("obj_snail_mouse_mucus", "obj_kf_sh_snail_mucus")],
        sprites=[
            ("main", "spr_snail_mouse", 41, [
                ("正常前进", 0, 8, 8),
                ("受伤前进", 8, 16, 8),
                ("正常技能", 16, 24, 8),
                ("受伤技能", 24, 32, 8),   # 原版 attack_anim 8，SWF 受伤技能 9 帧 → 压 8
                ("爆炸", 33, 40, 9),       # 原版 death_anim 9；SWF 末帧(0基40)全透明，末帧前一帧补
            ], (0, "spr_snail_mouse", 0)),
        ],
    ),
    # 蜗牛润滑黏液（不是敌人，只是特效）：SWF sprite 7 出现 0..7、持续 8..9、消失 10..14。
    #   原版 6 帧循环播（出现+持续），消失靠 image_alpha 渐隐 → 这里取 10 帧并同步 Step 的 mod / 锁帧。
    dict(
        prefix="kf_sh_", key="snail_mucus", cn="蜗牛润滑黏液",
        src=r"C:/Users/18203/Desktop/sprites/DefineSprite_7_com.aurora.ui.maogoutd.resource.effect.SnailLubricationAcceEffectMovie",
        total_src=15, old="obj_snail_mouse_mucus", hp=1, speed=0.0, enemy=False,
        text_patch=[("Step_0.gml", "mod 6", "mod 10"),
                    ("Step_0.gml", "image_index = 5", "image_index = 9"),
                    ("Step_0.gml", "timer <= 6 * 5 - 1", "timer <= 10 * 5 - 1")],
        sprites=[
            ("main", "spr_snail_mouse_mucus", 10, [
                ("出现", 1, 8, 8),   # SWF 第 1 帧(0基0)全透明，从第 2 帧起才是铺开过程
                ("持续", 8, 10, 2),
            ], (5, "spr_snail_mouse_mucus", 3)),   # 参考「完全铺开」帧（原版第 3 帧 = SWF 第 6 帧）
        ],
    ),
    # ---------------------------------------------------------------- 巫毒研究所
    dict(
        prefix="kf_wd_", key="garbage", cn="垃圾车僵尸鼠",
        src=r"巫毒研究所/小怪/精灵/垃圾车僵尸鼠", total_src=30,
        old="obj_garbage_track_mouse", hp=2500, speed=0.60,
        # 本体 move_speed 被原作者写成 0.5（表值 20 → 0.6），用 ms_patch 精确改
        ms_patch=[("Create_0.gml", 0.5, 0.60)],
        sprites=[
            ("main", "spr_garbage_track_mouse", 32, [
                ("正常行进", 0, 8, 8),
                ("受伤行进", 8, 16, 8),
                ("攻击占位", 0, 1, 1),
                ("受伤攻击占位", 8, 9, 1),
                ("爆炸", 16, 30, 14),
            ], (0, "spr_garbage_track_mouse", 0)),
        ],
    ),
]

# register_enemy 附加参数（按 key 索引）。hp / speed / ash_proof 由 CASES 提供。
REG = {
    "rowboat":      dict(name="划艇僵尸鼠", feature="water", atk=2000, cycle=1,   range=120,
                         desc="划艇僵尸鼠：跨服·水火之间小怪，快进慢退，碾压碰到的卡片"),
    "dragon_boat":  dict(name="龙舟僵尸鼠", feature="water", atk=2000, cycle=1,   range=120,
                         desc="龙舟僵尸鼠：跨服·水火之间小怪，快进慢退，碾压碰到的卡片"),
    "flagship":     dict(name="旗舰僵尸鼠", feature="water", atk=2000, cycle=1,   range=120,
                         desc="旗舰僵尸鼠：跨服·水火之间小怪，快进慢退，碾压碰到的卡片"),
    "kof_submarine": dict(name="拳皇潜艇僵尸鼠", feature="water", atk=20, cycle=36, range=120,
                          desc="拳皇潜艇僵尸鼠：跨服·水火之间小怪，装甲完整且不攻击时潜水"),
    "submarine":    dict(name="打击潜艇僵尸鼠", feature="water", atk=20, cycle=36, range=120,
                          desc="打击潜艇僵尸鼠：跨服·水火之间小怪，水陆两栖，入水出水时潜行突进"),
    "assault":      dict(name="突袭僵尸鼠", feature="water", atk=10, cycle=36, range=90,
                          desc="突袭僵尸鼠：跨服·水火之间小怪，从水里突然出现，头盔打掉后暴怒加速"),
    "ninja":        dict(name="忍者首领僵尸鼠", feature="land", atk=10, cycle=36, range=90,
                          desc="忍者首领僵尸鼠：跨服·水火之间小怪，冲撞卡片并不断召唤僵尸小喽啰"),
    "minion":       dict(name="僵尸小喽啰鼠", feature="land", atk=10, cycle=36, range=90,
                          desc="僵尸小喽啰鼠：跨服·水火之间小怪，由忍者首领僵尸鼠召唤"),
    "snail":        dict(name="蜗牛僵尸鼠", feature="land", atk=2000, cycle=1, range=90,
                          desc="蜗牛僵尸鼠：跨服·水火之间小怪，碾压卡片并留下润滑黏液"),
    "garbage":      dict(name="垃圾车僵尸鼠", feature="land", atk=2000, cycle=1,  range=90,
                         desc="垃圾车僵尸鼠：跨服·巫毒研究所小怪，碾压卡片并留下垃圾"),
}

# 每章一个 init 脚本
INIT_SCRIPTS = {
    "sh": dict(file="shuihuo_enemy_init", func="shuihuo_enemy_init", folder_cn="shuihuozhijian",
               keys=["rowboat", "dragon_boat", "flagship", "kof_submarine",
                     "submarine", "assault", "ninja", "minion", "snail"]),
    "wd": dict(file="wudu_enemy_init", func="wudu_enemy_init", folder_cn="wuduyanjiusuo",
               keys=["garbage"]),
}

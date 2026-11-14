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
    "garbage":      dict(name="垃圾车僵尸鼠", feature="land", atk=2000, cycle=1,  range=90,
                         desc="垃圾车僵尸鼠：跨服·巫毒研究所小怪，碾压卡片并留下垃圾"),
}

# 每章一个 init 脚本
INIT_SCRIPTS = {
    "sh": dict(file="shuihuo_enemy_init", func="shuihuo_enemy_init", folder_cn="shuihuozhijian",
               keys=["rowboat", "dragon_boat", "flagship", "kof_submarine"]),
    "wd": dict(file="wudu_enemy_init", func="wudu_enemy_init", folder_cn="wuduyanjiusuo",
               keys=["garbage"]),
}

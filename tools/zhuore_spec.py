# -*- coding: utf-8 -*-
"""灼热地域小怪（变异僵尸鼠）规格表。

条目的 sprites 项为：(精灵后缀, 原版精灵名, 目标总帧数, 段列表)
段列表项为 (SWF 帧标签, 目标帧数)；若各段帧数之和 != 目标总帧数，
会先按标签切段取帧，再整体重采样到目标总帧数。
"""

PREFIX = "kf_zr_"

# SWF 素材根目录
SRC_ROOT = r"C:/Users/18203/Desktop/跨服/灼热地域/小怪/精灵"
SWF_ROOT = r"C:/Users/18203/Desktop/跨服/灼热地域/小怪/SWF"

MICE = [
    dict(key="penguin", cn="企鹅僵尸鼠", swf="企鹅僵尸鼠.swf", sid=17,
         old="obj_water_penguin_mouse", hp=600,
         speed=0.6, ash_proof=True,
         ms_patch=[("Create_0.gml", 0.72, 0.6)], ref=("正常前进", "spr_water_penguin_mouse_land", 0),
         sprites=[
             ("land", "spr_water_penguin_mouse_land", 34,
              [("正常前进", 6), ("受伤前进", 6), ("正常吃东西", 6), ("受伤出场", 6), ("死亡", 10)]),
             ("water", "spr_water_penguin_mouse", 36,
              [("正常前进", 6), ("受伤前进", 6), ("正常吃东西", 6), ("受伤出场", 6), ("死亡", 12)]),
             ("enter", "spr_water_penguin_mouse_enter", 26,
              [("正常进场", 13), ("受伤进场", 13)]),
             ("throw", "spr_water_penguin_mouse_throw", 24,
              [("正常投掷", 12), ("受伤投掷", 12)]),
         ]),

    dict(key="mole", cn="僵尸鼹鼠", swf="僵尸鼹鼠.swf", sid=45,
         old="obj_mole", hp=360,
         speed=0.9, ash_proof=True,
         ms_patch=[("Step_0.gml", -0.15, -0.1386)], ref=("正常走路", "spr_mole", 0),
         sprites=[
             ("main", "spr_mole", 40,
              [("正常走路", 8), ("受伤走路", 8), ("正常吃东西", 7), ("受伤吃东西", 7), ("倒地", 10)]),
             ("dig", "spr_mole_dig", 6, [("挖地", 6)]),
             ("appear", "spr_mole_appear", 24, [("正常出来", 14), ("头盔吸走出来", 10)]),
             ("stun", "spr_mole_stun", 4, [("晃动", 4)]),
         ]),

    dict(key="garbage", cn="垃圾车僵尸鼠", swf="垃圾车僵尸鼠.swf", sid=33,
         old="obj_garbage_track_mouse", hp=2500,
         speed=0.5142, ash_proof=True,
         ms_patch=[("Create_0.gml", 0.5, 0.5142)], ref=("正常行进", "spr_garbage_track_mouse", 0),
         sprites=[
             ("main", "spr_garbage_track_mouse", 32,
              # attack_anim=1 → 攻击槽占 2 帧（正常/受伤各 1），但素材没有独立攻击帧，
              # 因此各取 1 帧行进图占位；必须写满，否则 total 不够会触发全局重采样把后段挤歪。
              [("正常行进", 8), ("受伤行进", 8),
               ("正常行进", 1), ("受伤行进", 1), ("爆炸", 14)]),
         ]),

    dict(key="flower", cn="捧花僵尸僵尸鼠", swf="捧花僵尸僵尸鼠.swf", sid=52,
         old="obj_zombie_with_flower_pot", hp=600, speed=0.36, ash_proof=True, shield=1000,
         ref=("正常带花盆行走", "spr_zombie_with_flower_pot_shield", 0),
         sprites=[
             # 持盾精灵走「四段式」布局（父类 obj_enemy_parent 在 shield_max_hp>0 && shield_hp>0
             # 时用 move*4 + attack*4 + death）：move_anim=12、attack_anim=6、death_anim=14
             # → 12*4 + 6*4 + 14 = 86。四段依次是
             # （盾完好·本体好 / 盾完好·本体伤 / 盾破·本体好 / 盾破·本体伤），
             # 移动与攻击各自的四段顺序一致，不能写两段式。
             # 注意：素材里「正常行走」(64..74) 与「受伤行走」(74..84) 的后两段是空帧，
             # 且原版 sprite 的第 3/4 段本来就和第 1/2 段几乎同图（只差 3px 花盆宽度），
             # 所以后两段直接复用带花盆的帧，避免花盆受损时僵尸隐形。
             ("shield", "spr_zombie_with_flower_pot_shield", 86,
              [(None, 12, (0, 16)),    # 正常带花盆行走
               (None, 12, (16, 32)),   # 本体受伤行走
               (None, 12, (0, 16)),    # 花盆受损·正常（复用，源无对应美术）
               (None, 12, (16, 32)),   # 花盆受损·本体受伤（复用）
               (None, 6, (84, 91)),    # 带花盆正常吃东西
               (None, 6, (91, 98)),    # 本体受伤吃东西
               (None, 6, (84, 91)),    # 花盆受损·正常吃东西（复用）
               (None, 6, (91, 98)),    # 花盆受损·本体受伤吃东西（复用）
               (None, 14, (126, 141))]),  # 带花盆倒地
             # 无花盆形态：素材「正常行走」整段空帧，真正的无盆站立在
             # 花盆掉落 41..48 / 受伤花盆掉落 57..63（各 7 帧），补到 8 帧。
             ("main", "spr_zombie_with_flower_pot", 38,
              [(None, 8, (41, 48)), (None, 8, (57, 64)),
               (None, 4, (98, 105)), (None, 4, (105, 112)),
               (None, 14, (112, 126))]),
             ("drop", "spr_zombie_with_flower_pot_drop", 20,
              [("花盆掉落", 10), ("受伤花盆掉落", 10)]),
         ]),

    dict(key="warrior", cn="武士僵尸鼠", swf="武士僵尸鼠.swf", sid=66,
         old="obj_warrior_mouse", hp=2100,
         speed=1.2, ash_proof=True,
         ms_patch=[("Create_0.gml", 0.26, 0.2571), ("Step_0.gml", 0.27, 0.2571)], ref=("正常行走", "spr_warrior_mouse", 0),
         obj_replace={"obj_warrior_minion_mouse": "obj_kf_zr_warrior_minion"},
         sprites=[
             ("main", "spr_warrior_mouse", 94,
              [("正常行走", 12), ("受伤行走", 12),
               ("正常待机1", 10), ("正常行进砍东西", 10), ("正常行进待机2", 9),
               ("受伤待机1", 10), ("受伤行进砍东西", 10), ("受伤行进待机2", 9),
               ("死亡倒地", 12)]),
             ("summon", "spr_warrior_mouse_summon", 44,
              [("正常出场", 6), ("受伤出场", 6), ("正常召唤", 16), ("受伤召唤", 16)]),
         ]),

    dict(key="warrior_minion", cn="武士僵尸鼠小兵", src_cn="武士僵尸鼠", swf="武士僵尸鼠.swf", sid=32,
         old="obj_warrior_minion_mouse", hp=300,
         speed=0.2571, ash_proof=True,
         ms_patch=[("Create_0.gml", 0.26, 0.2571)], ref=("正常行进", "spr_warrior_minion_mouse", 0),
         sprites=[
             # 小兵主精灵 = 素材 src[10:105] 逐帧 1:1（95 帧）。SWF 第 0..10 帧的「正常召唤出场」
             # 只属于 summon 精灵；逐帧对齐原版 spr_warrior_minion_mouse 已确认尾部偏移恒为 +10，
             # 死亡段实际从 src 92（受伤待机2 末帧）开始，比 FrameLabel 早一帧，故用显式区间。
             ("main", "spr_warrior_minion_mouse", 95,
              [(None, 95, (10, 105))]),
             ("summon", "spr_warrior_minion_mouse_summon", 10, [("正常召唤出场", 10)]),
         ]),

    dict(key="naruto", cn="火影忍者僵尸鼠", swf="火影忍者僵尸鼠.swf", sid=72,
         old="obj_naruto_mouse", hp=3600,
         speed=1.2, ash_proof=True,
         ms_patch=[("Create_0.gml", 0.26, 0.2571), ("Step_0.gml", 0.27, 0.2571)], ref=("正常行走", "spr_naruto_mouse", 0),
         obj_replace={"obj_naruto_minion_mouse": "obj_kf_zr_naruto_minion"},
         sprites=[
             ("main", "spr_naruto_mouse", 94,
              [("正常行走", 12), ("受伤行走", 12),
               ("正常待机1", 10), ("正常行进砍东西", 10), ("正常行进待机2", 9),
               ("受伤待机1", 10), ("受伤行进砍东西", 10), ("受伤行进待机2", 9),
               ("死亡倒地", 12)]),
             ("summon", "spr_naruto_mouse_summon", 44,
              [("正常出场", 6), ("受伤出场", 6), ("正常召唤", 16), ("受伤召唤", 16)]),
         ]),

    dict(key="naruto_minion", cn="火影忍者僵尸鼠小兵", src_cn="火影忍者僵尸鼠", swf="火影忍者僵尸鼠.swf", sid=38,
         old="obj_naruto_minion_mouse", hp=1200,
         speed=0.2571, ash_proof=True,
         ms_patch=[("Create_0.gml", 0.26, 0.2571)], ref=("正常行进", "spr_naruto_minion_mouse", 0),
         sprites=[
             # 同 warrior_minion：src[10:105] 逐帧 1:1
             ("main", "spr_naruto_minion_mouse", 95,
              [(None, 95, (10, 105))]),
             ("summon", "spr_naruto_minion_mouse_summon", 10, [("正常召唤出场", 10)]),
         ]),

    dict(key="dentist", cn="牙医僵尸鼠", swf="牙医僵尸鼠.swf", sid=43,
         old="obj_dentist_mouse", hp=960,
         speed=0.9, ash_proof=True,
         ms_patch=[("Step_0.gml", -0.15, -0.1386)], ref=("正常走路", "spr_dentist_mouse", 0),
         sprites=[
             ("main", "spr_dentist_mouse", 40,
              [("正常走路", 8), ("受伤走路", 8), ("正常吃东西", 7), ("受伤吃东西", 7), ("倒地", 10)]),
             ("dig", "spr_dentist_mouse_dig", 6, [("挖地", 6)]),
             ("appear", "spr_dentist_mouse_appear", 24, [("正常出来", 14), ("头盔吸走出来", 10)]),
             ("stun", "spr_dentist_mouse_stun", 4, [("晃动", 4)]),
         ]),

    dict(key="ghost", cn="神风幽灵鼠", swf="神风幽灵鼠.swf", sid=21,
         old="obj_ghost_mouse", hp=1000,
         speed=0.6, ash_proof=True, ref=("正常显形状态", "spr_ghost_mouse", 0),
         sprites=[
             ("main", "spr_ghost_mouse", 29,
              [("正常显形状态", 9), ("受伤显形状态", 9),
               ("正常显形状态", 1), ("受伤显形状态", 1), ("死亡", 9)]),
         ]),

    dict(key="arson", cn="纵火僵尸鼠", swf="纵火僵尸鼠.swf", sid=41,
         old="obj_arson_mouse", hp=1100,
         speed=0.6, ash_proof=True, ref=("正常前进", "spr_arson_mouse_bomb", 0),
         sprites=[
             ("bomb", "spr_arson_mouse_bomb", 35,
              [("正常前进", 6), ("受伤前进", 6), ("正常吃东西", 4), ("受伤吃东西", 4), ("倒地", 15)]),
             ("main", "spr_arson_mouse", 35,
              [("正常前进", 6), ("受伤前进", 6), ("正常吃东西", 4), ("受伤吃东西", 4), ("倒地", 15)]),
             ("ready", "spr_arson_mouse_ready", 20, [("正常待机", 10), ("受伤待机", 10)]),
             ("throw", "spr_arson_mouse_throw", 18, [("正常投掷", 9), ("受伤投掷", 9)]),
         ]),

    dict(key="can", cn="罐头僵尸鼠", swf="罐头僵尸鼠.swf", sid=33,
         old="obj_can_mouse", hp=1800,
         speed=0.3, ash_proof=True, ref=("正常行走", "spr_can_mouse", 0),
         sprites=[
             ("main", "spr_can_mouse", 46,
              [("正常行走", 12), ("受伤行走", 12), ("正常吃东西", 6), ("受伤吃东西", 6), ("死亡", 10)]),
             ("withcan", "spr_can_mouse_with_can", 46,
              [("带龟壳正常行走", 12), ("带龟壳受伤行走", 12), ("带龟壳正常吃东西", 6),
               ("带龟壳受伤吃东西", 6), ("带龟壳死亡", 10)]),
             ("drop", "spr_can_mouse_drop", 19, [("被炸翻转", 9), ("正常惊吓掉落", 10)]),
         ]),

    dict(key="sawblade", cn="锯刀狂僵尸鼠", swf="锯刀狂僵尸鼠.swf", sid=46,
         old="obj_sawblade_mouse", hp=3600,
         speed=0.9, ash_proof=True,
         ms_patch=[("Step_0.gml", -0.15, -0.1386)], ref=("正常走路", "spr_sawblade_mouse", 0),
         sprites=[
             ("main", "spr_sawblade_mouse", 40,
              [("正常走路", 8), ("受伤走路", 8), ("正常吃东西", 7), ("受伤吃东西", 7), ("倒地", 10)]),
             ("dig", "spr_sawblade_mouse_dig", 6, [("挖地", 6)]),
             ("appear", "spr_sawblade_mouse_appear", 24, [("正常出来", 14), ("头盔吸走出来", 10)]),
             ("stun", "spr_sawblade_mouse_stun", 4, [("晃动", 4)]),
         ]),

    dict(key="nonmain", cn="非主流僵尸鼠", swf="非主流僵尸鼠.swf", sid=68,
         old="obj_non_mainstream_mouse", hp=1200,
         speed=0.3, ash_proof=True,
         ms_patch=[("Create_0.gml", 0.6, 0.3)], ref=("正常行走", "spr_non_mainstream_mouse", 0),
         sprites=[
             ("main", "spr_non_mainstream_mouse", 42,
              [("正常行走", 8), ("受伤行走", 8), ("正常吃东西", 6), ("受伤吃东西", 6), ("死亡", 14)]),
             ("dance1", "spr_non_mainstream_mouse_dance_1", 20, [("正常闪避1", 20)]),
             ("dance2", "spr_non_mainstream_mouse_dance_2", 20, [("正常闪避2", 20)]),
             ("dance3", "spr_non_mainstream_mouse_dance_3", 20, [("正常闪避3", 20)]),
         ]),

    dict(key="magician", cn="魔术师僵尸鼠", swf="魔术师僵尸鼠.swf", sid=56,
         old="obj_magician_mouse", hp=1600,
         speed=0.6, ash_proof=True, ref=("正常待机", "spr_magician_mouse", 0),
         sprites=[
             ("main", "spr_magician_mouse", 72,
              [("正常待机", 6), ("受伤待机", 6),
               ("正常发射", 5), ("正常发射出去", 6), ("正常空膛待机", 6), ("正常装填", 6),
               ("受伤发射", 5), ("受伤发射出去", 6), ("受伤空膛待机", 6), ("受伤装填", 6),
               ("死亡", 14)]),
         ]),
]

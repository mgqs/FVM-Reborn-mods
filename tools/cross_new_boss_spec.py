# -*- coding: utf-8 -*-
"""跨服新章节 BOSS 规格：变异钢铁侠（水火之间） / 变异绿巨人（巫毒研究所）。

分段来源：SWF FrameLabel（tools/swf_frame_labels.py 解析）。
seg 三元组 = (源起始帧0基, 源帧数, 输出帧数)，输出帧数 != 源帧数时重采样，
保证「新精灵总帧数 == 原版精灵总帧数」（对象照抄后 image_index 的 mod N 才能对齐）。

钢铁侠 281 号精灵（426帧）标签：
  0 闪现3 / 3 砸地12 / 15 闪出7 / 22 起飞3 / 25 待机16 / 41 蓄力飞行20 / 61 飞行冲撞6 /
  67 飞行移动8 / 75 蓄力爆甲47 / 122 老鼠待机10 / 132 组合装甲30 / 162 背部伸出炮筒24 /
  186 发射7 / 193 收回炮筒6 / 199 起受伤镜像 / 398 老鼠爆甲死亡14 / 412 老鼠死亡14
绿巨人 190 号精灵（480帧）标签：
  0 走进画面12 / 12 老鼠待机10 / 22 变身62 / 84 绿巨鼠待机10 / 94 变滚球11 / 105 滚球4 /
  109 跳跃预备3 / 112 跳跃6 / 118 下落3 /（二三四段跳跃）/ 160 砸地23 / 183 攻击02 49 /
  232 起受伤镜像 / 443 死亡37
"""

SRC_ROOT = r"C:/Users/18203/Desktop/跨服"
TEX_GROUP = "enemy_volcanic"

SPR_ROOT_FOLDER = "folders/精灵/Enemy/kuafu"
OBJ_ROOT_FOLDER = "folders/物体/Enemy/kuafu"

CHAPTERS = {
    "sh": {"folder_cn": "shuihuozhijian", "title": "水火之间",
           "init_file": "shuihuo_boss_init", "init_func": "shuihuo_boss_init"},
    "wd": {"folder_cn": "wuduyanjiusuo", "title": "巫毒研究所",
           "init_file": "wudu_boss_init", "init_func": "wudu_boss_init"},
}

BOSSES = [
    {
        "key": "iron_man",
        "prefix": "kf_sh_",
        "tag": "sh",
        "cn": "变异钢铁侠",
        "old_obj": "obj_iron_man_mouse",
        "hp": 90000,
        # 主体精灵（一个 SWF 大精灵拆段）与锚点参考帧（新帧0基, 原版精灵, 原版帧）
        "body_src": "水火之间/BOSS/精灵/DefineSprite_281_*IronManBossMoveIntruderMovie",
        "iron_src": "水火之间/BOSS/精灵/DefineSprite_92_*IronManHelmetArmorMoveIntruderMovie",
        "ref": (25, "spr_iron_man_mouse_idle", 0),
        "sprites": [
            # (后缀, 原版精灵, 总帧数校验, segs)
            ("idle",             "spr_iron_man_mouse_idle",         32, [(25, 16, 16), (224, 16, 16)]),
            ("drop",             "spr_iron_man_mouse_drop",         30, [(0, 15, 15), (199, 15, 15)]),
            ("launch",           "spr_iron_man_mouse_launch",       20, [(15, 10, 10), (214, 10, 10)]),
            ("move",             "spr_iron_man_mouse_move",         16, [(67, 8, 8), (266, 8, 8)]),
            ("skill_1_ready",    "spr_iron_man_mouse_skill_1_ready", 40, [(41, 20, 20), (240, 20, 20)]),
            ("skill_1",          "spr_iron_man_mouse_skill_1",      12, [(61, 6, 6), (260, 6, 6)]),
            ("skill_2_ready",    "spr_iron_man_mouse_skill_2_ready", 94, [(75, 47, 47), (274, 47, 47)]),
            ("skill_2_human",    "spr_iron_man_mouse_skill_2_human", 20, [(122, 10, 10), (321, 10, 10)]),
            ("skill_2_return",   "spr_iron_man_mouse_skill_2_return", 60, [(132, 30, 30), (331, 30, 30)]),
            # 装甲（激光）形态：92 号精灵 368 帧与原版逐段同长，直接整搬
            ("skill_2_iron",     "spr_iron_man_mouse_skill_2_iron", 368, [("@92", 368, 368)]),
            # 炮筒段 24/7/6 → 重采样到原版 23/5/9
            ("skill_3_ready",    "spr_iron_man_mouse_skill_3_ready", 46, [(162, 24, 23), (361, 24, 23)]),
            ("skill_3",          "spr_iron_man_mouse_skill_3",      10, [(186, 7, 5), (385, 7, 5)]),
            ("skill_3_return",   "spr_iron_man_mouse_skill_3_return", 18, [(193, 6, 9), (392, 6, 9)]),
            ("death",            "spr_iron_man_mouse_death",        14, [(398, 14, 14)]),
            ("death2",           "spr_iron_man_mouse_death2",       14, [(412, 14, 14)]),
        ],
        # 特效：("后缀", 原版精灵, 源目录glob, segs 或 None(全帧), 锚点模式)
        #   center = 画布中心；ratio = 按原版 origin 占画布比例迁移
        "effects": [
            ("effect",        "spr_iron_man_mouse_effect",        "水火之间/BOSS/精灵/DefineSprite_127_*HitCardBombEffectMovie", None, "center"),
            ("laser",         "spr_iron_man_mouse_laser",         "水火之间/BOSS/精灵/DefineSprite_120_*IronManLaserBombEffectMovie", None, "center"),
            ("bullet",        "spr_iron_man_mouse_bullet",        "水火之间/BOSS/精灵/DefineSprite_158_*IronManMissileShotMovie", [(0, 8, 8)], "center"),
            ("bullet_effect", "spr_iron_man_mouse_bullet_effect", "水火之间/BOSS/精灵/DefineSprite_158_*IronManMissileShotMovie", [(9, 11, 11)], "center"),
        ],
    },
    {
        "key": "hulk",
        "prefix": "kf_wd_",
        "tag": "wd",
        "cn": "变异绿巨人",
        "old_obj": "obj_hulk_mouse",
        "hp": 120000,
        "body_src": "巫毒研究所/BOSS/sprites/DefineSprite_190_*HulkBossMoveIntruderMovie",
        "ref": (84, "spr_hulk_mouse_idle", 0),
        "sprites": [
            # appear：走进12→8（受伤半边无走进受伤版，沿用正常走进），老鼠待机10+变身62 = 72
            ("appear",         "spr_hulk_mouse_appear",     160, [(0, 12, 8), (12, 72, 72), (0, 12, 8), (232, 72, 72)]),
            ("idle",           "spr_hulk_mouse_idle",        18, [(84, 10, 9), (294, 10, 9)]),
            # 技能1（冲拳）：跳跃预备3→8、跳跃6→7 重采样
            ("skill_1_ready",  "spr_hulk_mouse_skill_1_ready", 16, [(109, 3, 8), (319, 3, 8)]),
            ("skill_1",        "spr_hulk_mouse_skill_1",      14, [(112, 6, 7), (322, 6, 7)]),
            ("skill_2",        "spr_hulk_mouse_skill_2",      46, [(160, 23, 23), (371, 23, 23)]),
            ("skill_3",        "spr_hulk_mouse_skill_3",      98, [(183, 49, 49), (394, 49, 49)]),
            ("move_fast",      "spr_hulk_mouse_move_fast",    24, [(105, 4, 12), (315, 4, 12)]),
            ("move_slow",      "spr_hulk_mouse_move_slow",    30, [(94, 11, 15), (304, 11, 15)]),
            ("death",          "spr_hulk_mouse_death",        37, [(443, 37, 37)]),
        ],
        "effects": [
            ("skill_effect_2", "spr_hulk_mouse_skill_effect_2", "巫毒研究所/BOSS/sprites/DefineSprite_26_*HitGroundEffectMovie", None, "ratio"),
            ("skill_effect_3", "spr_hulk_mouse_skill_effect_3", "巫毒研究所/BOSS/sprites/DefineSprite_48_*HulkPunchShotMovie", None, "ratio"),
        ],
    },
]

# 随行对象克隆（激光体 / 导弹 / 摧毁特效），parent 文件夹挂到对应 BOSS 的 boss 子文件夹
COMPANIONS = [
    {
        "boss": "iron_man", "old": "obj_iron_man", "new": "obj_kf_sh_iron_man_laser",
        "sprite_map": {"spr_iron_man_mouse_skill_2_iron": "spr_kf_sh_iron_man_skill_2_iron",
                       "spr_iron_man_mouse_laser": "spr_kf_sh_iron_man_laser"},
        "mouse_old": "iron_man",
        "mouse_id": "kf_sh_iron_man_laser",
    },
    {
        "boss": "iron_man", "old": "obj_iron_man_bullet", "new": "obj_kf_sh_iron_man_bullet",
        "sprite_map": {"spr_iron_man_mouse_bullet": "spr_kf_sh_iron_man_bullet",
                       "spr_iron_man_mouse_bullet_effect": "spr_kf_sh_iron_man_bullet_effect"},
        "mouse_id": None,
    },
    {
        "boss": "hulk", "old": "obj_hulk_destroy_effect", "new": "obj_kf_wd_hulk_destroy_effect",
        "sprite_map": {"spr_hulk_mouse_skill_effect_3": "spr_kf_wd_hulk_skill_effect_3"},
        "mouse_id": None,
    },
]

REG = {
    "kf_sh_iron_man": {
        "name": "变异钢铁侠",
        "desc": "变异钢铁侠：跨服·水火之间BOSS。技能1：摧毁2列。技能2：激光升级为十字范围摧毁。技能3：从第一个技能起就可能发射导弹，每次4枚。",
        "spr": "spr_kf_sh_iron_man_idle",
        "icon": "spr_iron_man_mouse_icon",
    },
    "kf_wd_hulk": {
        "name": "变异绿巨人",
        "desc": "变异绿巨人：跨服·巫毒研究所BOSS。技能全部无法削弱；每次使用技能前蓄力时间缩减为4秒。技能1：冲拳摧毁2*2。技能2：砸地摧毁十字5格。技能3：冲撞摧毁3格纵列。",
        "spr": "spr_kf_wd_hulk_idle",
        "icon": "spr_hulk_mouse_icon",
    },
}

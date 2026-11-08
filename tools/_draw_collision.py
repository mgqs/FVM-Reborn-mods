# -*- coding: utf-8 -*-
import math
from PIL import Image, ImageDraw, ImageFont

W, H = 1760, 1310
img = Image.new("RGB", (W, H), (247, 249, 252))
d = ImageDraw.Draw(img)

def F(sz, bold=False):
    try:
        return ImageFont.truetype(r"C:\Windows\Fonts\msyhbd.ttc" if bold else r"C:\Windows\Fonts\msyh.ttc", sz, index=0)
    except Exception:
        return ImageFont.truetype(r"C:\Windows\Fonts\msyh.ttc", sz, index=0)

f_title = F(34, True); f_h = F(22, True); f_s = F(16); f_xs = F(13)

C_MAIN=(58,122,214);  C_MAIN_BG=(226,238,253)
C_ALT =(206,122,40);  C_ALT_BG =(253,240,226)
C_GATE=(120,74,168);  C_GATE_BG=(238,230,250)
C_DMG =(176,60,60);   C_DMG_BG =(252,231,231)
C_BASE=(60,140,110);  C_BASE_BG=(226,244,236)
C_SIDE=(90,100,115);  C_SIDE_BG=(235,238,242)
C_ARROW=(110,125,145)

def box(x,y,w,h,title,lines,border,bg,f_t=f_h,f_l=f_xs):
    d.rounded_rectangle([x,y,x+w,y+h], radius=10, fill=bg, outline=border, width=2)
    d.rectangle([x,y,x+5,y+h-10], fill=border)
    d.text((x+16,y+9), title, font=f_t, fill=border)
    ty = y + 9 + (30 if f_t is f_h else 26)
    for ln in lines:
        d.text((x+16,ty), ln, font=f_l, fill=(55,62,72))
        ty += 21

def arrow(x1,y1,x2,y2,color=C_ARROW,lw=2):
    d.line([x1,y1,x2,y2], fill=color, width=lw)
    ang = math.atan2(y2-y1, x2-x1); L=11
    for s in (+1,-1):
        d.line([x2,y2, x2-L*math.cos(ang-s*0.42), y2-L*math.sin(ang-s*0.42)], fill=color, width=lw)

d.text((40,26), "FVM Reborn  碰撞 / 命中体系全景", font=f_title, fill=(35,42,55))
d.text((40,74), "核心原则：以「格坐标」为唯一权威空间；引擎碰撞事件基本不用（place_meeting 全项目仅 16 处）", font=f_s, fill=(100,110,125))

# 第 0 层
y0 = 112
d.rounded_rectangle([40,y0,W-40,y0+180], radius=12, fill=C_BASE_BG, outline=C_BASE, width=2)
d.rectangle([40,y0,45,y0+180], fill=C_BASE)
d.text((62,y0+10), "第 0 层   空间地基（两个索引，不是碰撞检测）", font=f_h, fill=C_BASE)
bw = (W-140)/3
box(62, y0+48, bw-18, 118, "grid_plants  (ds_grid)", [
    "每格一个 ds_list，装该格所有卡",
    "plant_layers: normal0 / shield_inner1 / lilypad2",
    "              shield_outer3 / coffee4 / gridless5",
    "scope: col 0..8（地图域）",
], C_BASE, (238,250,244), f_s, f_xs)
box(62+bw, y0+48, bw-18, 118, "grid_terrains  (ds_grid)", [
    "每格地形 {type: water / land / ...}",
    "礼盒刷怪前查它，决定能不能出水属性怪",
    "礼盒水格重抽就走这里",
], C_BASE, (238,250,244), f_s, f_xs)
box(62+bw*2, y0+48, bw-18, 118, "enemy_sx  (SAP 排序表)", [
    "按 bbox_left 插入排序的敌人实例",
    "enemy_sx_l / enemy_sx_pmax(前缀最大右沿)",
    "enemy_sx_gen++ 每帧当版本号",
], C_BASE, (238,250,244), f_s, f_xs)

yA = 334
d.text((40,yA-30), "主流程 A：卡片 → 敌人（300+ 张卡走这条）", font=f_h, fill=C_MAIN)
d.text((600,yA-30), "主流程 B：高精度子弹（79 枚走这条）", font=f_h, fill=C_ALT)
d.text((1150,yA-30), "闸门与伤害", font=f_h, fill=C_GATE)

CX,CW = 60,470
A = [
 ("① 索敌  卡遍历敌人", [
   "for instance_number(obj_enemy_parent) → instance_find",
   "get_grid_position_from_world(e.x,e.y)  世界 → 格",
   "combat_cell_in(col,row)   边界（含第 10 列）",
   "abs(g.col-grid_col) <= range_col",
   "abs(g.row-grid_row) <= range_row",
 ]),
 ("② 开火  生成子弹", [
   "子弹继承 target_type（＝卡的类型）",
   "damage = atk（表值，已含星级/转职倍率）",
   "obj_bullet_parent 只做缩放归一 + 海克斯来源标记",
 ]),
 ("③ 命中  爆炸点几何", [
   "with (obj_enemy_parent)",
   "abs(x-_x) < _range                   水平",
   "point_distance(x,y,_x,_y) < _range   圆形",
   "abs(grid_row-other.row) <= 1         行容差",
   "id != other.hitted_enemy             去重",
 ]),
]
yy = yA
for t,ls in A:
    h = 34+21*len(ls)+10
    box(CX,yy,CW,h,t,ls,C_MAIN,C_MAIN_BG,f_h,f_xs)
    if yy != yA: arrow(CX+CW/2, yy-24, CX+CW/2, yy-6)
    yy += h+24

MX,MW = 610,470
B = [
 ("① 粗筛  bullet_enemy_reachable", [
   "子弹 x 已飞过 enemy_max_right → 直接跳过",
 ]),
 ("② SAP  bullet_sap_type_list", [
   "以 bbox 为键：二分定位 + 反向扫描",
   "enemy_sx_pmax 提前 break",
   "再按 target_type 过滤 → 候选集",
   "按 enemy_sx_gen 缓存，每帧只算一次",
 ]),
 ("③ 精判  precise_bbox_collision", [
   "GM 的 bbox 不跟 image_angle 旋转",
   "用 angle 把四角转过去重算 AABB（带缓存）",
   "再与目标原始 bbox 做矩形相交",
 ]),
]
yy = yA
for t,ls in B:
    h = 34+21*len(ls)+10
    box(MX,yy,MW,h,t,ls,C_ALT,C_ALT_BG,f_h,f_xs)
    if yy != yA: arrow(MX+MW/2, yy-24, MX+MW/2, yy-6)
    yy += h+24

GX,GW = 1150,540
box(GX,yA,GW,96,"④ 类型闸门  can_target_on / can_hit", [
  "A、B 两条流的命中都要先过这里（唯一类型闸门，改一处全局生效）",
  "敌人 7 类：normal / diver / air / dance / obstacle / underground / invisible",
], C_GATE, C_GATE_BG, f_h, f_xs)
box(GX,yA+112,GW,136,"特殊值", [
  "all          → 7 类全吃",
  "pierce_air   → 只吃 normal/air/obstacle（牛油果飞镖）",
  "is_digging_dijing()   → 喷壶类对钻地地精放行",
  "can_hit_segment_bbox()→ Liang-Barsky 线段×矩形（弹道索敌）",
], C_GATE, C_GATE_BG, f_h, f_xs)

arrow(500, 810, 500, 846, C_MAIN)
arrow(845, 682, 845, 842, C_ALT)
arrow(1420, 596, 1420, 842, C_GATE)

yB = 852
d.text((40,yB-32), "第 5 步   唯一的伤害入口：event_user(0)", font=f_h, fill=C_DMG)
box(60,yB,1610,180,"objects/obj_enemy_parent/Other_10.gml   （所有伤害都从这里结算）", [
  "调用方只写两个变量：  damage_amount = 伤害值        damage_type = \"normal\" | \"pierce\" | 其它",
  "",
  "护盾规则：  normal → 只扣 shield_hp（血不掉）    pierce → shield_hp 与 hp 都扣    其它(fire/ice) → 绕过护盾直扣 hp",
  "",
  "入口内再叠三层修正：   hex_batch2_enemy_damage_take  →  hex_b3_enemy_damage_pre  →  hp -=  →  hex_b3_enemy_damage_post",
  "                     （出场无敌/轻装伏击/石护盾）     （固定减伤/抖动/首击倍率）       （齿轮烟气/吸血/重燃火光）",
], C_DMG, C_DMG_BG, f_h, f_xs)


yC = 1084
d.text((40,yC-32), "旁路 / 反向 / 例外", font=f_h, fill=C_SIDE)
side = [
 ("反向：敌人啃卡", [
   "with (obj_card_parent)",
   "dx = x-other.x → 在正面 attack_range 内",
   "zombie_grid.row == grid_row（同行）",
   "按 global.eat_order 优先级挑目标：",
   "  shield → shield_outer → normal → lilypad",
   "特殊：高跷鼠只啃 4 种高大面包",
 ]),
 ("障碍拦截", [
   "obstacle_should_block(bullet,obs)",
   "全工程唯一口径",
   "几何：bbox 相交（障碍掩码已夹到一格）",
   "逻辑：bullet.row == obstacle.row 才挡",
   "row == 0 → 纵/散射弹，退回纯几何",
 ]),
 ("边界（两套列号，最易踩）", [
   "地图域 col 0..8 → 放置/地形/绘制",
   "战斗域 col 0..9 → 索敌/命中/子弹存活",
   "combat_col_in / combat_cell_in",
   "combat_right_x / combat_map_col_in",
 ]),
 ("已知盲区", [
   "parent=null 但注册进 enemy_by_type 的对象",
   "  例：obj_longzhu_green_apple 青苹果",
   "  → with (obj_enemy_parent) 扫不到",
   "attack_range <= 0 分支写反，恒 false",
   "hitted_enemy 单值，多发穿透易漏判",
 ]),
]
sx = 60
sw = (1610-3*16)/4
for t,ls in side:
    h = 34+21*len(ls)+12
    box(sx,yC,sw,h,t,ls,C_SIDE,C_SIDE_BG,f_s,f_xs)
    sx += sw+16

img.save(r"D:\gameProject\FVM-Reborn-mod\docs\碰撞体系全景.png")
print("saved", img.size)

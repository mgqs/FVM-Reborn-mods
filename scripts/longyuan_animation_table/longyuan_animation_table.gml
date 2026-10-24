
function longyuan_animation_table(_kind) {
 switch (_kind) {
  case "pingmin": return {"正常行走": [spr_pingmin, 1, 8], "重伤行走": [spr_pingmin, 9, 16], "正常吃东西循环": [spr_pingmin, 17, 20], "重伤吃东西循环": [spr_pingmin, 21, 24], "倒地": [spr_pingmin, 25, 37]};
  case "dongfeng": return {"持扇前进": [spr_dongfeng, 1, 10], "持扇攻击": [spr_dongfeng, 11, 34], "无扇前进": [spr_dongfeng, 35, 44], "下落": [spr_dongfeng, 45, 52], "正常行走": [spr_dongfeng, 53, 64], "正常啃咬": [spr_dongfeng, 65, 70], "破损行走": [spr_dongfeng, 71, 82], "破损啃咬": [spr_dongfeng, 83, 88], "死亡": [spr_dongfeng, 89, 102]};
  // 高跷鼠：独立精灵文件（正常/破损分别用精灵前半/后半段）
  // 舞步闪避用 3 段精灵（dance1=22帧 / dance2=22帧 / dance3=16帧），碰撞 obj_bullet_parent 时随机选一段播放
  case "gaoqiao": return {
      "正常移动": [spr_gaoqiao_move, 1, 8], "破损移动": [spr_gaoqiao_move, 9, 16],
      "正常啃咬": [spr_gaoqiao_attack, 1, 7], "破损啃咬": [spr_gaoqiao_attack, 8, 14],
      "正常后退": [spr_gaoqiao_move, 1, 8], "破损后退": [spr_gaoqiao_move, 9, 16],
      "死亡": [spr_gaoqiao_dead, 1, 13],
      // 舞步闪避（三个独立精灵，供 Step 碰撞触发时 choose 选；正常=前半段、破损=后半段）
      "闪避A": [spr_gaoqiao_dance1, 1, 11], "破损闪避A": [spr_gaoqiao_dance1, 12, 22],
      "闪避B": [spr_gaoqiao_dance2, 1, 11], "破损闪避B": [spr_gaoqiao_dance2, 12, 22],
      "闪避C": [spr_gaoqiao_dance3, 1, 8],  "破损闪避C": [spr_gaoqiao_dance3, 9, 16]
  };
  case "langyabang": return {"正常行走": [spr_langyabang, 1, 20], "受伤行走": [spr_langyabang, 21, 40], "正常砸东西": [spr_langyabang, 41, 56], "受伤砸东西": [spr_langyabang, 57, 72], "死亡倒地": [spr_langyabang, 73, 94]};
  case "longmu": return {"正常有蛋前进": [spr_longmu, 1, 12], "正常有蛋啃咬": [spr_longmu, 13, 18], "正常原地发火": [spr_longmu, 19, 27], "正常无蛋前进": [spr_longmu, 28, 35], "正常无蛋啃咬": [spr_longmu, 36, 41], "破损有蛋前进": [spr_longmu, 42, 53], "破损有蛋啃咬": [spr_longmu, 54, 59], "破损原地发火": [spr_longmu, 60, 68], "破损无蛋前进": [spr_longmu, 69, 76], "破损无蛋啃咬": [spr_longmu, 77, 82], "死亡": [spr_longmu, 83, 94]};
  // 药罐鼠：独立精灵（正常/破损对半切分）
  case "yaoguan": return {
      "正常前进": [spr_yaoguan_move, 1, 12], "破损前进": [spr_yaoguan_move, 13, 24],
      "正常啃咬": [spr_yaoguan_attack, 1, 8], "破损啃咬": [spr_yaoguan_attack, 9, 16],
      "正常回血": [spr_yaoguan_zhiliao, 1, 16], "破损回血": [spr_yaoguan_zhiliao, 17, 32],
      "死亡": [spr_yaoguan_dead, 1, 10]
  };
  case "zhibuji": return {"全丝线移动": [spr_zhibuji, 1, 8], "全丝线发射子弹": [spr_zhibuji, 9, 14], "剩余2份丝线移动": [spr_zhibuji, 15, 22], "破损剩余2份丝线移动": [spr_zhibuji, 23, 28], "剩余1份丝线移动": [spr_zhibuji, 29, 36], "破损剩余1份丝线移动": [spr_zhibuji, 37, 42], "无丝线移动": [spr_zhibuji, 43, 50], "破损破损剩余1份丝线移动": [spr_zhibuji, 51, 58], "破损破损剩余1份丝线移动": [spr_zhibuji, 59, 64], "破损无丝线移动": [spr_zhibuji, 65, 70], "死亡": [spr_zhibuji, 71, 83]};
  // 开路鼠：独立精灵（本体精灵用户未标注破损变体，仍保持正常/破损共用）
  case "kailu": return {
      "正常前进": [spr_kailu_move, 1, 12], "破损前进": [spr_kailu_move, 1, 12],
      "正常撞击": [spr_kailu_zhuangji, 1, 7], "破损撞击": [spr_kailu_zhuangji, 1, 7],
      "正常冲刺": [spr_kailu_chongci, 1, 8], "破损冲刺": [spr_kailu_chongci, 1, 8],
      "死亡": [spr_kailu_dead, 1, 1]
  };
  // 执念鼠本体：独立精灵（正常/破损对半切分）
  case "zhinian": return {
      "正常前进": [spr_zhinian_move, 1, 8], "破损前进": [spr_zhinian_move, 9, 16],
      "正常啃咬": [spr_zhinian_attack, 1, 5], "破损啃咬": [spr_zhinian_attack, 6, 10],
      "死亡": [spr_zhinian_dead, 1, 14]
  };
  // 符咒鼠本体（正常/破损对半切分）
  case "fuzhou": return {
      "正常前进": [spr_fuzhou_qianjin, 1, 12], "破损前进": [spr_fuzhou_qianjin, 13, 24],
      "正常施法": [spr_fuzhou_shifa, 1, 15], "破损施法": [spr_fuzhou_shifa, 16, 30],
      "正常攻击": [spr_fuzhou_attack, 1, 8], "破损攻击": [spr_fuzhou_attack, 9, 16],
      "死亡": [spr_fuzhou_dead, 1, 11]
  };
  case "zhizhujing": return {"正常待机": [spr_zhizhujing, 1, 8], "缠绕卡片": [spr_zhizhujing, 9, 23], "死亡": [spr_zhizhujing, 24, 32]};
  case "zhizhujing_soul": return {"正常待机": [spr_zhizhujing_1, 1, 8], "正常抱住物品": [spr_zhizhujing_1, 9, 17], "死亡": [spr_zhizhujing_1, 18, 26]};
  case "zhizhujing_apper": return {"出现": [spr_zhizhujing_apper, 1, 13]};
  case "dijing": return {"正常走路": [spr_dijing, 1, 8], "受伤走路": [spr_dijing, 9, 16], "正常吃东西": [spr_dijing, 17, 23], "受伤吃东西": [spr_dijing, 24, 30], "倒地": [spr_dijing, 31, 40]};
  // 开路鼠魂体（夜晚死亡化魂后切换；hunti_move 正常/破损对半切分）
  case "kailu_soul": return {
      "出生": [spr_kailu_hunti_apper, 1, 8],
      "正常前进": [spr_kailu_hunti_move, 1, 10], "破损前进": [spr_kailu_hunti_move, 11, 20],
      "爆炸死亡": [spr_kailu_hunti_baozha_dead, 1, 17],
      "普通死亡": [spr_kailu_hunti_baozha_dead, 1, 17]
  };
  // 执念鼠魂体（夜晚死亡化魂后切换；hunti_move/attack1/attack2 正常/破损对半切分）
  case "zhinian_soul": return {
      "出生": [spr_zhinian_hunti_apper, 1, 9],
      "正常灵魂前进": [spr_zhinian_hunti_move, 1, 12], "破损灵魂前进": [spr_zhinian_hunti_move, 13, 24],
      "正常攻击卡片": [spr_zhinian_hunti_attack1, 1, 10], "破损攻击卡片": [spr_zhinian_hunti_attack1, 11, 20],
      "正常冲刺": [spr_zhinian_hunti_attack2, 1, 22], "破损冲刺": [spr_zhinian_hunti_attack2, 23, 44],
      "死亡": [spr_zhinian_hunti_dead, 1, 12]
  };
  // 符咒子弹符咒（amulet）
  case "amulet": return {
      "飞行": [spr_fuzhou_bullet_fly, 1, 6],
      "变形": [spr_fuzhou_bullet_bianxing, 1, 12],
      "死亡": [spr_fuzhou_bullet_disapper, 1, 7]
  };
  // 符咒魂鼠（符咒子弹落地后召唤的随从；qianjin/gongji 正常/破损对半切分）
  case "fuzhou_minion": return {
      "出生": [spr_fuzhou_zhaohuan_apper, 1, 8],
      "正常前进": [spr_fuzhou_zhaohuan_qianjin, 1, 12], "破损前进": [spr_fuzhou_zhaohuan_qianjin, 13, 24],
      "正常啃咬": [spr_fuzhou_zhaohuan_gongji, 1, 7], "破损啃咬": [spr_fuzhou_zhaohuan_gongji, 8, 14],
      "死亡": [spr_fuzhou_zhaohuan_dead, 1, 11]
  };
  case "web": return {"出生": [spr_zhizhujing_wang, 1, 7], "待机": [spr_zhizhujing_wang, 8, 19], "死亡": [spr_zhizhujing_wang, 20, 30]};
  case "spider_soul": return {"正常待机": [spr_zhizhujing_1, 1, 8], "正常抱住物品": [spr_zhizhujing_1, 9, 17], "死亡": [spr_zhizhujing_1, 18, 26]};
  case "soul_fire": return {"三火出生": [spr_hunhuo, 1, 6], "三火待机": [spr_hunhuo, 7, 12], "二火待机": [spr_hunhuo, 13, 18], "一火待机": [spr_hunhuo, 19, 24], "一火消失": [spr_hunhuo, 25, 29]};
  // ===== 龙渊 BOSS：谛听鼠（独立动作精灵） =====
  case "diting": return {"正常出生": [spr_ly_diting_apper, 1, 40], "破损出生": [spr_ly_diting_apper, 1, 40], "正常待机": [spr_ly_diting_idel, 1, 13], "破损待机": [spr_ly_diting_idel, 14, 26], "正常钻入": [spr_ly_diting_zuanru, 1, 11], "破损钻入": [spr_ly_diting_zuanru, 12, 22], "正常遁地移动": [spr_ly_diting_zuanrumove, 1, 9], "破损遁地移动": [spr_ly_diting_zuanrumove, 10, 17], "正常钻出": [spr_ly_diting_zuanchu, 1, 11], "破损钻出": [spr_ly_diting_zuanchu, 12, 22], "正常技能1钻入": [spr_ly_diting_skill1_zuanru, 1, 11], "破损技能1钻入": [spr_ly_diting_skill1_zuanru, 12, 22], "正常技能1移动": [spr_ly_diting_skill1_move, 1, 10], "破损技能1移动": [spr_ly_diting_skill1_move, 11, 20], "正常技能1钻出": [spr_ly_diting_skill1_zuanchu, 1, 22], "破损技能1钻出": [spr_ly_diting_skill1_zuanchu, 23, 44], "正常技能2": [spr_ly_diting_skill2, 1, 36], "破损技能2": [spr_ly_diting_skill2, 37, 72], "正常技能3": [spr_ly_diting_skill3, 1, 38], "破损技能3": [spr_ly_diting_skill3, 39, 76], "死亡": [spr_ly_diting_dead, 1, 16]};
  case "diting_prison": return {"出生": [spr_ly_diting_prison, 1, 8], "待机": [spr_ly_diting_prison, 9, 13], "激活": [spr_ly_diting_prison, 14, 19], "激活待机": [spr_ly_diting_prison, 20, 29], "死亡": [spr_ly_diting_prison, 30, 39]};
  case "diting_grid_fire": return {"待机": [spr_ly_diting_grid_fire, 1, 15]};
  case "diting_soundwave": return {"待机": [spr_ly_diting_soundwave, 1, 6]};
  // ===== 龙渊 BOSS：哼哈二将 =====
  // 马面/牛头：除出生(apper)与死亡(dead)为单段外，其余精灵前半段=正常、后半段=破损
  case "hengha_horseface": return {"正常出生": [spr_ly_hengha_mamian_apper, 1, 45], "破损出生": [spr_ly_hengha_mamian_apper, 1, 45], "正常有铃铛待机": [spr_ly_hengha_mamian_bell_idel, 1, 12], "破损有铃铛待机": [spr_ly_hengha_mamian_bell_idel, 13, 24], "正常无铃铛待机": [spr_ly_hengha_mamian_nobell_idel, 1, 12], "破损无铃铛待机": [spr_ly_hengha_mamian_nobell_idel, 13, 24], "正常无铃出现": [spr_ly_hengha_mamian_nobell_chuxian, 1, 7], "破损无铃出现": [spr_ly_hengha_mamian_nobell_chuxian, 8, 14], "正常无铃消失": [spr_ly_hengha_mamian_nobell_disapper, 1, 8], "破损无铃消失": [spr_ly_hengha_mamian_nobell_disapper, 9, 16], "正常技能1抛出1": [spr_ly_hengha_mamian_skill1_paochu1, 1, 13], "破损技能1抛出1": [spr_ly_hengha_mamian_skill1_paochu1, 14, 26], "正常技能2循环": [spr_ly_hengha_mamian_skill2_xunhuan, 1, 10], "破损技能2循环": [spr_ly_hengha_mamian_skill2_xunhuan, 11, 20], "正常技能2结束": [spr_ly_hengha_mamian_skill2_jieshu, 1, 7], "破损技能2结束": [spr_ly_hengha_mamian_skill2_jieshu, 8, 14], "死亡": [spr_ly_hengha_mamian_dead, 1, 16]};
  case "hengha_oxhead": return {"正常出生": [spr_ly_hengha_niutou_apper, 1, 9], "破损出生": [spr_ly_hengha_niutou_apper, 1, 9], "正常待机": [spr_ly_hengha_niutou_idel, 1, 12], "破损待机": [spr_ly_hengha_niutou_idel, 13, 24], "正常闪出": [spr_ly_hengha_niutou_shanchu, 1, 7], "破损闪出": [spr_ly_hengha_niutou_shanchu, 8, 14], "正常闪进": [spr_ly_hengha_niutou_shanru, 1, 5], "破损闪进": [spr_ly_hengha_niutou_shanru, 6, 10], "正常跳跃预备": [spr_ly_hengha_niutou_jumpzhunbei, 1, 4], "破损跳跃预备": [spr_ly_hengha_niutou_jumpzhunbei, 5, 8], "正常跳跃": [spr_ly_hengha_niutou_jump, 1, 5], "破损跳跃": [spr_ly_hengha_niutou_jump, 6, 10], "正常下落": [spr_ly_hengha_niutou_xialuo, 1, 3], "破损下落": [spr_ly_hengha_niutou_xialuo, 4, 6], "正常技能1": [spr_ly_hengha_niutou_skill1, 1, 27], "破损技能1": [spr_ly_hengha_niutou_skill1, 28, 54], "正常技能2": [spr_ly_hengha_niutou_skill2, 1, 41], "破损技能2": [spr_ly_hengha_niutou_skill2, 42, 82], "正常技能3": [spr_ly_hengha_niutou_skill3, 1, 30], "破损技能3": [spr_ly_hengha_niutou_skill3, 31, 60], "死亡": [spr_ly_hengha_niutou_dead, 1, 18]};
  case "hengha_food_spirit": return {"出生": [spr_ly_hengha_food_apper, 1, 7], "待机": [spr_ly_hengha_food_idel, 1, 12], "死亡": [spr_ly_hengha_food_dead, 1, 8]};
  case "hengha_bell": return {"飞行": [spr_ly_hengha_bell_fly, 1, 6], "变大": [spr_ly_hengha_bell_big, 1, 10], "待机": [spr_ly_hengha_bell_idel, 1, 6], "待机2": [spr_ly_hengha_bell_idel2, 1, 7], "攻击待机": [spr_ly_hengha_bell_attackidel, 1, 6], "飞走": [spr_ly_hengha_bell_disapper, 1, 9]};
  // ===== 龙渊 BOSS：孟婆鼠 =====
  case "mengpo": return {"出生": [spr_ly_mengpo_boss, 1, 36], "正常待机": [spr_ly_mengpo_boss, 37, 48], "正常闪出": [spr_ly_mengpo_boss, 49, 56], "正常闪进": [spr_ly_mengpo_boss, 57, 63], "正常技能1": [spr_ly_mengpo_boss, 64, 91], "正常技能2": [spr_ly_mengpo_boss, 92, 119], "正常技能3": [spr_ly_mengpo_boss, 120, 127], "正常技能3罐子循环": [spr_ly_mengpo_boss, 128, 139], "正常技能3收茶叶": [spr_ly_mengpo_boss, 140, 156], "正常技能3控制倒水": [spr_ly_mengpo_boss, 157, 164], "正常技能3结束": [spr_ly_mengpo_boss, 165, 173], "死亡": [spr_ly_mengpo_boss, 174, 194]};
  case "mengpo_tea_tree": return {"生长出树枝": [spr_ly_mengpo_tea_tree, 1, 9], "树枝待机": [spr_ly_mengpo_tea_tree, 10, 16], "生出绿叶": [spr_ly_mengpo_tea_tree, 17, 25], "绿叶待机": [spr_ly_mengpo_tea_tree, 26, 32], "boss采茶": [spr_ly_mengpo_tea_tree, 33, 44], "死亡": [spr_ly_mengpo_tea_tree, 45, 55]};
  case "mengpo_rain": return {"下雨": [spr_ly_mengpo_rain, 1, 30]};
  case "mengpo_mushroom": return {"出生": [spr_ly_mengpo_mushroom, 1, 8], "待机": [spr_ly_mengpo_mushroom, 9, 15]};
  case "mengpo_wind_mist": return {"待机": [spr_ly_mengpo_wind_mist, 1, 13]};
  case "mengpo_strong_wind": return {"待机": [spr_ly_mengpo_strong_wind, 1, 6]};
  case "mengpo_wind_hit": return {"待机": [spr_ly_mengpo_wind_hit, 1, 6]};
  case "mengpo_wind_left": return {"待机": [spr_ly_mengpo_wind_left, 1, 4]};
  case "mengpo_wind_right": return {"待机": [spr_ly_mengpo_wind_right, 1, 4]};
  case "mengpo_wind_down": return {"待机": [spr_ly_mengpo_wind_down, 1, 4]};
  case "mengpo_wind_up": return {"待机": [spr_ly_mengpo_wind_up, 1, 4]};
  // ===== 龙渊 BOSS：无常鼠 =====
  case "wuchang": return {"出生": [spr_ly_wuchang_boss, 1, 38], "正常白待机": [spr_ly_wuchang_boss, 39, 50], "正常白闪出": [spr_ly_wuchang_boss, 51, 60], "正常白闪进": [spr_ly_wuchang_boss, 61, 69], "正常黑待机": [spr_ly_wuchang_boss, 70, 81], "正常黑闪出": [spr_ly_wuchang_boss, 82, 88], "正常黑闪进": [spr_ly_wuchang_boss, 89, 93], "正常技能1": [spr_ly_wuchang_boss, 94, 120], "正常技能2": [spr_ly_wuchang_boss, 121, 143], "正常技能3": [spr_ly_wuchang_boss, 144, 170], "正常技能4开始": [spr_ly_wuchang_boss, 171, 196], "正常技能4结束": [spr_ly_wuchang_boss, 197, 207], "破损白待机": [spr_ly_wuchang_boss, 208, 219], "破损白闪出": [spr_ly_wuchang_boss, 220, 229], "破损白闪进": [spr_ly_wuchang_boss, 230, 238], "破损黑待机": [spr_ly_wuchang_boss, 239, 250], "破损黑闪出": [spr_ly_wuchang_boss, 251, 257], "破损黑闪进": [spr_ly_wuchang_boss, 258, 262], "破损技能1": [spr_ly_wuchang_boss, 263, 289], "破损技能2": [spr_ly_wuchang_boss, 290, 312], "破损技能3": [spr_ly_wuchang_boss, 313, 339], "破损技能4开始": [spr_ly_wuchang_boss, 340, 365], "破损技能4结束": [spr_ly_wuchang_boss, 366, 376], "死亡": [spr_ly_wuchang_boss, 377, 399]};
  case "wuchang_fuzhou": return {"出生": [spr_ly_wuchang_fuzhou, 1, 8], "正常前进": [spr_ly_wuchang_fuzhou, 9, 20], "正常啃咬": [spr_ly_wuchang_fuzhou, 21, 27], "破损前进": [spr_ly_wuchang_fuzhou, 28, 39], "破损啃咬": [spr_ly_wuchang_fuzhou, 40, 46], "死亡": [spr_ly_wuchang_fuzhou, 47, 57]};
  case "wuchang_gold_ingot": return {"旋转": [spr_ly_wuchang_gold_ingot, 1, 6], "待机": [spr_ly_wuchang_gold_ingot, 7, 20], "爆炸": [spr_ly_wuchang_gold_ingot, 21, 33], "金币待机": [spr_ly_wuchang_gold_ingot, 34, 41], "消失": [spr_ly_wuchang_gold_ingot, 42, 42]};
  case "wuchang_chain": return {"待机": [spr_ly_wuchang_chain, 1, 11], "死亡": [spr_ly_wuchang_chain, 12, 12]};
  case "wuchang_chain2_blue": return {"开始1": [spr_ly_wuchang_chain2_blue, 1, 3], "循环1": [spr_ly_wuchang_chain2_blue, 4, 8], "结束1": [spr_ly_wuchang_chain2_blue, 9, 11], "开始2": [spr_ly_wuchang_chain2_blue, 12, 14], "循环2": [spr_ly_wuchang_chain2_blue, 15, 19], "结束2": [spr_ly_wuchang_chain2_blue, 20, 22]};
  case "wuchang_chain1_blue": return {"待机": [spr_ly_wuchang_chain1_blue, 1, 2]};
  case "wuchang_chain1_red": return {"动画": [spr_ly_wuchang_chain1_red, 1, 2]};
  case "wuchang_fire_wheel": return {"旋转": [spr_ly_wuchang_fire_wheel, 1, 6]};
  case "wuchang_soul_banner": return {"待机": [spr_ly_wuchang_soul_banner, 1, 6]};
  // ===== 龙渊 BOSS：游神鼠（独立动作精灵） =====
  case "youshen": return {"正常出生": [spr_ly_youshen_apper, 1, 37], "破损出生": [spr_ly_youshen_apper, 1, 37], "正常待机": [spr_ly_youshen_idel, 1, 12], "破损待机": [spr_ly_youshen_idel, 13, 24], "正常移动": [spr_ly_youshen_move, 1, 12], "破损移动": [spr_ly_youshen_move, 13, 24], "正常游入": [spr_ly_youshen_youru, 1, 9], "破损游入": [spr_ly_youshen_youru, 10, 18], "正常游出": [spr_ly_youshen_youchu, 1, 10], "破损游出": [spr_ly_youshen_youchu, 11, 20], "正常技能1": [spr_ly_youshen_skill1, 1, 35], "破损技能1": [spr_ly_youshen_skill1, 36, 70], "正常技能2": [spr_ly_youshen_skill2, 1, 46], "破损技能2": [spr_ly_youshen_skill2, 47, 92], "正常技能3": [spr_ly_youshen_skill3, 1, 17], "破损技能3": [spr_ly_youshen_skill3, 18, 34], "正常技能3冲刺": [spr_ly_youshen_skill3_chongci, 1, 6], "破损技能3冲刺": [spr_ly_youshen_skill3_chongci, 7, 12], "正常技能3结束": [spr_ly_youshen_skill3_jieshu, 1, 12], "破损技能3结束": [spr_ly_youshen_skill3_jieshu, 13, 24], "死亡": [spr_ly_youshen_dead, 1, 16]};
  case "youshen_scroll": return {"飞行": [spr_ly_youshen_scroll, 1, 26]};
  case "youshen_mist": return {"待机": [spr_ly_youshen_mist, 1, 17]};
 }
 return {};
}

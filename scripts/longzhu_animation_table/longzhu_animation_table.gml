/// ============================================================
/// 龙柱（七色龙柱）及附属物的 SWF 标签动画表
/// ------------------------------------------------------------
/// 帧区间均为 1 基闭区间 [首帧, 末帧]，与 swf_manifest.json 的标签逐帧对应。
///
/// 龙柱本体（80 帧，7 色共用同一套标签）：
///   出生1 / 悬浮待机11 / 前摇21 / 悬浮施法25 /
///   插入地面39 / 地面待机48 / 地面施法54 / 飞起68
///   未封印 = 悬浮（悬浮待机，前摇→悬浮施法）
///   被封印 = 插地（插入地面→地面待机，地面施法）
///   解封   = 飞起
///
/// 青苹果（43 帧）：出生1 / 正常待机7 / 破损待机23 / 消失39
/// 红苹果（43 帧）：旋转待机1 / 正常待机6 / 破损待机22 / 消失38
/// ============================================================

/// 龙柱本体精灵：按 kind 取对应颜色
/// cheng=松露大厅(橙) / lv=百味关(绿) / huang=贪婪(黄) / lv2=傲慢(青绿)
function longzhu_pillar_sprite(_kind) {
	switch (_kind) {
		case "cheng": return spr_longzhu_cheng;
		case "lv":    return spr_longzhu_lv;
		case "huang": return spr_longzhu_huang;
		case "lv2":   return spr_longzhu_lv2;
		case "lan":   return spr_longzhu_lan;
		case "hong":  return spr_longzhu_hong;
		case "zi":    return spr_longzhu_zi;
	}
	return spr_longzhu_cheng;
}

/// 龙柱本体动作表（按传入精灵生成，7 色共用同一套帧区间）
function longzhu_pillar_anims(_sprite) {
	return {
		"出生":     [_sprite, 1, 10],
		"悬浮待机": [_sprite, 11, 20],
		"前摇":     [_sprite, 21, 24],
		"悬浮施法": [_sprite, 25, 38],
		"插入地面": [_sprite, 39, 47],
		"地面待机": [_sprite, 48, 53],
		"地面施法": [_sprite, 54, 67],
		"飞起":     [_sprite, 68, 80]
	};
}

/// 青苹果（傲慢龙柱的感染体）：出生1 / 正常待机7 / 破损待机23 / 消失39
function longzhu_green_apple_anims() {
	return {
		"出生":     [spr_longzhu_green_apple, 1, 6],
		"正常待机": [spr_longzhu_green_apple, 7, 22],
		"破损待机": [spr_longzhu_green_apple, 23, 38],
		"消失":     [spr_longzhu_green_apple, 39, 43]
	};
}

/// 红苹果（傲慢龙柱的追踪子弹）：旋转待机1 / 正常待机6 / 破损待机22 / 消失38
function longzhu_red_apple_anims() {
	return {
		"旋转待机": [spr_longzhu_red_apple, 1, 5],
		"正常待机": [spr_longzhu_red_apple, 6, 21],
		"破损待机": [spr_longzhu_red_apple, 22, 37],
		"消失":     [spr_longzhu_red_apple, 38, 43]
	};
}

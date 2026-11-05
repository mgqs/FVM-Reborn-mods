// 面板只在「测试关 + 海克斯模式」里存在，离开就自毁（CleanUp 会把暂停还回去）
if (!instance_exists(obj_battle)) { instance_destroy(); exit; }
if (!hex_test_enabled())          { instance_destroy(); exit; }

t += 1;
if (msg_timer > 0) msg_timer -= 1;

// ── 关闭后的延迟恢复 ──
// 点「关闭面板」的那一下左键和关闭是同一帧，is_paused 必须再撑一帧，
// 否则下方卡槽会把这次按下当成正常的选卡
if (resume_in > 0) {
    resume_in -= 1;
    if (resume_in <= 0 && paused_by_me) {
        global.is_paused = prev_paused;
        paused_by_me     = false;
    }
}

// ── F5：开 / 关 ──
// 用 F5 而不是 Esc：Esc 在 obj_battle_pause_manager 里是「开暂停菜单」的键，
// 两个对象同一帧都收到 Esc 会互相踩（关掉面板的同一帧又把暂停菜单拉起来）
if (keyboard_check_pressed(vk_f5)) {
    if (!collapsed) picker_close();
    else if (picker_can_toggle()) picker_open();
    audio_play_sound(snd_button, 0, 0);
}

var _mx = mouse_x;
var _my = mouse_y;

// ── 收起状态：不画任何东西，也不接点击（只用 F5 展开）──
if (collapsed) exit;

// 展开期间每帧把暂停压回去：卡槽 / 地图放置 / 老鼠 AI 的 Step 首行都是
// `if (global.is_paused) exit`，这就是「点不到下面按钮」的实现方式
picker_freeze();

// 每帧刷新筛选结果对应的滚动上限（筛选条件一变这里就跟着变）
max_scroll = picker_max_scroll();
scroll     = clamp(scroll, 0, max_scroll);

var _side      = picker_side_list();
var _side_rows = picker_side_rows();
side_max       = max(0, array_length(_side) - _side_rows);
side_scroll    = clamp(side_scroll, 0, side_max);

// ── 滚轮：右栏滚自己的，其余滚网格（按整行滚）──
var _wu = mouse_wheel_up();
var _wd = mouse_wheel_down();
if (_wu || _wd) {
    if (_mx >= side_x) {
        if (_wu) side_scroll = max(0, side_scroll - 1);
        if (_wd) side_scroll = min(side_max, side_scroll + 1);
    } else {
        // 全库 248 条 = 60 多行，一次滚一行要点 58 下，这里一次两行
        if (_wu) scroll = max(0, scroll - 2);
        if (_wd) scroll = min(max_scroll, scroll + 2);
    }
}

// ── 悬停 ──
var _ids  = picker_filter_ids();
var _hi   = picker_hit_card(_mx, _my);
hover_id  = "";
if (_hi >= 0 && _hi < array_length(_ids)) hover_id = _ids[_hi];

// ── 点击 ──
var _lmb = mouse_check_button_pressed(mb_left);
var _rmb = mouse_check_button_pressed(mb_right);

if (_lmb || _rmb) {
    // 1) 顶部筛选按钮
    var _btn = picker_buttons();
    for (var i = 0; i < array_length(_btn); i++) {
        var _b = _btn[i];
        if (point_in_rectangle(_mx, _my, _b.x, _b.y, _b.x + _b.w, _b.y + _b.h)) {
            picker_btn_click(_b);
            exit;
        }
    }

    // 2) 卡片：左键加 / 减一层，右键整条清掉
    if (_hi >= 0 && _hi < array_length(_ids)) {
        picker_toggle(_ids[_hi], _rmb);
        exit;
    }

    // 3) 右栏 ✕：整条移除
    if (_mx >= side_x && _my >= grid_y + side_pad && _my <= grid_y + grid_h) {
        var _r = floor((_my - grid_y - side_pad) / side_row_h);
        if (_r >= 0 && _r < _side_rows) {
            var _ai = side_scroll + _r;
            if (_ai >= 0 && _ai < array_length(_side)) {
                if (_mx >= side_x + side_w - 40) {
                    hex_test_remove_all(_side[_ai].id);
                    hex_test_rebuild();
                    audio_play_sound(snd_button, 0, 0);
                    exit;
                }
            }
        }
    }

    // 4) 底部：清空 / 关闭
    if (point_in_rectangle(_mx, _my, 40, 1012, 220, 1066)) {
        hex_test_clear();
        hex_test_rebuild();
        msg_text  = "已清空本局全部词条";
        msg_timer = 60;
        audio_play_sound(snd_button, 0, 0);
        exit;
    }
    if (point_in_rectangle(_mx, _my, 236, 1012, 416, 1066)) {
        picker_close();
        audio_play_sound(snd_button, 0, 0);
        exit;
    }
}

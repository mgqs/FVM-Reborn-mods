// obj_start_reward Draw：面板/按钮走 mod_tg_modal_draw，这里只负责文案
var _row = difficulty_start_reward_of(sr_diff);
if (is_undefined(_row)) exit;

var _lines = [
    { text: "领取「" + _row.name + "」开局奖励？", red: false },
    { text: difficulty_start_reward_gold_text(_row.gold) + " 金币" + (_row.warm_bird ? " + 暖暖鸡 + 自选一张卡" : ""), red: false },
    { text: "领取后无法再领其他难度的开局奖励", red: true }
];

mod_tg_modal_draw(sr_hover, _lines, "", false, ["领取", "以后再说"]);

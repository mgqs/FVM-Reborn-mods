/// place_mutex_class(card_id)
/// @description 放置互斥类：同类卡不能放在同一格（彼此都不能叠），不同类 / 没登记的卡照旧可叠。
///   2026-11-08 用户口径：蜜糖陷阱与仙笛马归为同一类（都是「不占格 · 追踪」的悬浮卡）。
///   2026-11-18 用户口径：结界马二转是 gridless（不占格），但**同一格只允许一张**，
///     参考海洋女神的处理（can_place_at_position:73）。这里给类名只填自己，
///     效果就是「同名卡不能同格叠放」，0/1 转是 normal 本来就叠不了，行为不变。
///   ⚠️ 同名的拦截是「免费」的：自己那格已经有了同名卡 → 类名相同 → 直接判不可放，
///      所以不需要再为每张卡单独写「同格不能重复放自己」。
///   加卡 = 在下面的 switch 里加一行 case，返回同一个类名即可。
/// @param {string} _card_id 卡牌 id（与 plant_id 同一套）
/// @returns {string} 类名；"" = 不参与互斥
function place_mutex_class(_card_id) {
    switch (_card_id) {
        case "honeytrap":
        case "xiandima":
            return "gridless_track";
        case "jiejiema":
            return "jiejiema_self";
    }
    return "";
}

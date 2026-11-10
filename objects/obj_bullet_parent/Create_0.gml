// 子弹父对象创建事件
// can_dandantu_store: 是否可被蛋蛋兔储存伤害
// 默认为 true，直线子弹均可被储存；非直线/特殊子弹在各自 Create 中设为 false
can_dandantu_store = true;

// 当前过火倍率：多座火源取最高的一档（不累乘、不叠加），
// 布丁反弹的附伤按它补乘，保证「先过火还是先反弹」结果都是 (子弹 + 附伤) × 倍率
fire_mult = 1;

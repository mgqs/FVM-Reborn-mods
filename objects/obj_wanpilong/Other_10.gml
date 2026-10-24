/// @description 顽皮龙 - 用户事件0（属性初始化）
// 调用父对象初始化（读取存档、设置星级、应用食谱等）
event_inherited();

// 顽皮龙不支持技能强化，技能等级强制为0
skill = 0;

// 初始化当前血量
current_hp = hp;
max_hp = hp;

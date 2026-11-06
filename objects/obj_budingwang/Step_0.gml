// obj_budingwang Step 事件
// 走樱桃布丁的 Step（内含 obj_card_parent 的动画 / 死亡 / 状态），
//   它自己的补血与反伤被 `is_cookbook_equipped("pineapple_pudding")` 挡着，
//   没装「菠萝布丁」食神谱时等于什么都不做。
if global.is_paused{
    exit
}
event_inherited();

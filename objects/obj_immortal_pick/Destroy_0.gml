// obj_immortal_pick Destroy 事件
// 没点「确定」就被销毁（强关游戏以外的所有情况：ESC 关界面、切房间、外部 instance_destroy）
// → 默认发第一张，奖励不丢。已经点过确定的话 committed = true，这里什么都不做。
if (!committed){
    immortal_pick_claim_default();
}

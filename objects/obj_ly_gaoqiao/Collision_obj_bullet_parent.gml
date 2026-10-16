if (ly_mode != "attack" && ly_mode != "dodge" && ly_mode != "retreat" && ly_dodge_cooldown <= 0 && ly_dance_cooldown <= 0 && hp > 0) {
    ly_mode = "dodge";
    target_type = "dance";
    longyuan_play(irandom(1) == 0 ? longyuan_variant("正常闪避1", "破损闪避1") : longyuan_variant("正常闪避2", "破损闪避2"), true);
}

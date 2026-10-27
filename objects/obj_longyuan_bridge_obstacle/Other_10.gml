if (hp <= 0) exit;
if (zhangaiwu_state == "dead") exit;

// ---------- 奶盖桥岩浆障碍物：不再「完全防爆」 ----------
// 卡片侧的灰烬 / 碾压实现口径不统一：有的写 damage_type = "ash"，
// 春笋这类写 "normal"，面粉袋 / 椰子还会先 hp -= atk 再 event_user(0)。
// 老逻辑按 damage_type 白名单放行，导致写 "normal" 的卡打上来直接被判「完全免疫」
// （玩家看到的「完全防爆」）。现在统一成：只要命中就扣本体 50% 血量，
// 一次灰烬 = 半血，两次打穿。血量以 ly_hp_lock 为准，抵消卡片侧额外的 hp -= atk。
ly_hp_lock = max(0, ly_hp_lock - maxhp * 0.5);
hp = ly_hp_lock;

damage_amount = 0;
damage_type = "";
flash_value = 150;

if (hp <= 0) {
    hp = 0;
    zhangaiwu_state = "dead";
    sprite_index = spr_zhangaiwu_dead;
    image_index = 0;
}

if (global.is_paused)
    exit;

timer++;
image_index = floor(timer / 5);

if (!instance_exists(banding_card_obj) || banding_card_obj.state != CARD_STATE.ATTACK)
    event_user(7);

image_xscale = 1.6;
image_yscale = 1.6;
instance_create_depth(1473, 284, depth - 1, obj_gods_hall_closer);
instance_create_depth(1296, 284, depth - 1, obj_gods_store_enter);
is_submenu_opened = false;
is_wishing = false;
wish_completed = true;
start_wishing = false;
start_wishing5 = false;
reward_id = [];
reward_list = [];
random_begin = false;
var wish = instance_create_depth((x + 2) - 200, 782, depth - 1, obj_gods_hall_wish);
wish.parent_gui = id;
wish.mode = 0;
var wish5 = instance_create_depth(x + 2 + 200, 782, depth - 1, obj_gods_hall_wish);
wish5.parent_gui = id;
wish5.mode = 1;
var bag = instance_create_depth(x + 2, (room_height / 2) - 50, depth - 1, obj_gods_hall_bag);
bag.parent_gui = id;
bag.list_num = 0;

if (!variable_struct_exists(global.save_data.player, "wish_count"))
    global.save_data.player.wish_count = 0;

function gods_hall_get_random_reward()
{
    var r = irandom(99);
    
    if (r < 22)
        return ["金币", 1000];
    else if (r < 31)
        return ["金币", 5000];
    else if (r < 35)
        return ["金币", 10000];
    else if (r < 38)
        return ["神谕之石", 5];
    else if (r < 39)
        return ["神谕之石", 10];
    else if (r < 40)
        return ["神谕之石", 25];
    else if (r < 53)
        return ["天然香料", 25];
    else if (r < 57)
        return ["天然香料", 50];
    else if (r < 58)
        return ["天然香料", 200];
    else if (r < 67)
        return ["秘制香料", 25];
    else if (r < 69)
        return ["秘制香料", 50];
    else if (r < 70)
        return ["秘制香料", 200];
    else if (r < 83)
        return ["初级强化水晶", 25];
    else if (r < 88)
        return ["初级强化水晶", 50];
    else if (r < 97)
        return ["中级强化水晶", 25];
    else
        return ["中级强化水晶", 50];
}

function gods_hall_get_guarantee_reward()
{
    var r = irandom(99);
    
    if (r < 60)
        return ["神谕之石", 5];
    else if (r < 80)
        return ["神谕之石", 10];
    else
        return ["神谕之石", 25];
}

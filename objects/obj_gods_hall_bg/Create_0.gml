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
    
    if (r < 20)
        return ["金币", 1000];
    else if (r < 29)
        return ["金币", 5000];
    else if (r < 33)
        return ["金币", 10000];
    else if (r < 36)
        return ["神谕之石", 5];
    else if (r < 37)
        return ["神谕之石", 10];
    else if (r < 38)
        return ["神谕之石", 25];
    else if (r < 51)
        return ["天然香料", 25];
    else if (r < 55)
        return ["天然香料", 50];
    else if (r < 56)
        return ["天然香料", 200];
    else if (r < 65)
        return ["秘制香料", 25];
    else if (r < 67)
        return ["秘制香料", 50];
    else if (r < 68)
        return ["秘制香料", 200];
    else if (r < 78)
        return ["初级强化水晶", 25];
    else if (r < 82)
        return ["初级强化水晶", 50];
    else if (r < 89)
        return ["中级强化水晶", 25];
    else if (r < 92)
        return ["中级强化水晶", 50];
    else if (r < 95)
        return ["4级四叶草", 20];
    else
        return ["高级强化水晶", 20];
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

var reward_id = parent_gui.reward_list[list_num];
var reward_spr = 0;

switch (reward_id[0])
{
    case "金币":
        reward_spr = 0;
        break;
    
    case "神谕之石":
        reward_spr = 1;
        break;
    
    case "天然香料":
        reward_spr = 2;
        break;
    
    case "秘制香料":
        reward_spr = 3;
        break;
    
    case "初级强化水晶":
        reward_spr = 4;
        break;
    
    case "中级强化水晶":
        reward_spr = 5;
        break;
}

var reward = instance_create_depth(x - 2, y - 20, depth - 1, obj_gods_hall_reward);
reward.parent_gui = id;
reward.list_num = list_num;
reward.reward_id = reward_id;
reward.image_index = reward_spr;

if (reward_id[0] == "神谕之石")
{
    var effect = instance_create_depth(x - 1, y - 20, depth - 1, obj_gods_hall_reward_effect);
    effect.parent_gui = reward;
}

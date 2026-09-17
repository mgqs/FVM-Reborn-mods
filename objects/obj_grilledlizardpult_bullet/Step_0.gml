if (global.is_paused)
    exit;

x += move_speed;
y -= cvspeed;
cvspeed -= cgravity;
image_angle -= 5;

if (x > 2200 || y > 1200 || x < -200 || y < -200)
    instance_destroy();

if (y >= (thrower_y - 30))
{
    var inst = instance_create_depth(x, y, depth, obj_grilledlizardpult_bullet_effect);
    inst.image_angle -= 75;
    instance_destroy();
}

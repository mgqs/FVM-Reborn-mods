launch_tick++;
image_angle += launch_spin;
y += launch_vy;
launch_vy += launch_grav;
if (launch_tick > 16) image_alpha -= 0.06;
if (image_alpha <= 0 || launch_tick >= 90) instance_destroy();

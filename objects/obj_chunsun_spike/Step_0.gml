spike_tick++;
image_index = min(3, spike_tick div 4);
if (spike_tick >= 16) instance_destroy();

if (variable_instance_exists(id, "ready_max_y_offset")) {
	if y_offset_target <= ready_max_y_offset - 40{
	    y_offset_target += 40
	}
	else{
	    y_offset_target = ready_max_y_offset
	}
}
else{
	if y_offset_target <= 96*slot_cols - 40 - 372{
	    y_offset_target += 40
	}
	else{
	    y_offset_target = 96*slot_cols - 372
	}
}

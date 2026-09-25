if (variable_instance_exists(id, "ready_max_y_offset")) {
	if y_offset <= ready_max_y_offset - 40{
	    y_offset += 40
	}
	else{
	    y_offset = ready_max_y_offset
	}
}
else{
	if y_offset <= 96*slot_cols - 40 - 372{
	    y_offset += 40
	}
	else{
	    y_offset = 96*slot_cols - 372
	}
}

if package_button_select == 1{
	if (variable_instance_exists(id, "max_y_offset_1")) {
		if y_offset < max_y_offset_1 - 40{
			y_offset += 40
		}
		else{
			y_offset = max_y_offset_1
		}
	}
	else{
		if y_offset < (package_rows-8)*96 -40{
			y_offset += 40
		}
		else{
			y_offset = (package_rows-8)*96
		}
	}
}
else if package_button_select == 2{
	if (variable_instance_exists(id, "max_y_offset_2")) {
		if y_offset < max_y_offset_2 - 40{
			y_offset += 40
		}
		else{
			y_offset = max_y_offset_2
		}
	}
	else{
		if y_offset < (package_rows-9)*88 -40{
			y_offset += 40
		}
		else{
			y_offset = (package_rows-9)*88
		}
	}
}
else if package_button_select == 3{
	if (variable_instance_exists(id, "max_y_offset_3")) {
		if y_offset < max_y_offset_3 - 40{
			y_offset += 40
		}
		else{
			y_offset = max_y_offset_3
		}
	}
	else{
		if y_offset < (package_rows-9)*88 -40{
			y_offset += 40
		}
		else{
			y_offset = (package_rows-9)*88
		}
	}
}

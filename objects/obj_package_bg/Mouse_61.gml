if package_button_select == 1{
	if y_offset < (package_rows-8)*96 -40{
		y_offset += 40
	}
	else{
		y_offset = (package_rows-8)*96
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

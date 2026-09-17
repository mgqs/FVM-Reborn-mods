/// @function ini_write_bool(section, key, value)
/// @param {string} section INI文件中的节名
/// @param {string} key     键名
/// @param {bool}   value   要写入的布尔值
function ini_write_bool(section, key, value){
	// 将布尔值转换为字符串表示
	var str_value = value ? "true" : "false";
	ini_write_string(section, key, str_value);
}

/// @function ini_read_bool(section, key, default_value)
/// @param {string} section      INI文件中的节名
/// @param {string} key          键名
/// @param {bool}   default_value 默认值（可选）
/// @return {bool} 读取到的布尔值或默认值
function ini_read_bool(section, key, default_value){

	// 读取字符串值
	var str_value = ini_read_string(section, key, "");

	// 如果键不存在，返回默认值
	if (str_value == "") {
	    return default_value;
	}

	// 将字符串转换为布尔值
	if str_value == "true" or str_value == "false"{
		if (str_value == "true") {
		    return true;
		} else if (str_value == "false") {
		    return false;
		} else {
		    // 无效值，返回默认值
		    return default_value;
		}
	}
	else{
		if (real(str_value) > 0) {
		    return true;
		} else if (real(str_value) == 0) {
		    return false;
		} else {
		    // 无效值，返回默认值
		    return default_value;
		}
	}
}
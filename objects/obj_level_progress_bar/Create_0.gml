depth = 0
total_wave = global.level_file.total_waves
if (!is_array(global.level_file.waves)) {
	total_wave = 0
} else if (total_wave > array_length(global.level_file.waves)) {
	total_wave = array_length(global.level_file.waves)
}
elite_wave = global.level_file.elite_wave
level_stage = "pre"
last_wave = false
function pointsPerSecond()
	return points_per_second_start - (global.supply.level-1) * points_per_second_level_subtract
end
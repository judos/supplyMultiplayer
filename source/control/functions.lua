function pointsPerSecond()
	return points_per_second_start - (global.supply.level-1) * points_per_second_level_subtract
end


function addLevel(data)
	if #data < 1 then error("level needs a defined time-span as first table item") end
	if #data % 2 ~= 1 then error("level needs for every item an amount defined") end
	local level={requirements={},time=data[1]}
	for i=2,#data-1,2 do
		table.insert(level.requirements,{name=data[i],count=data[i+1]})
	end
	table.insert(levels,level)
end


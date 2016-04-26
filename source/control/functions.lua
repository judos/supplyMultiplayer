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


function calculateAccumulated()
	local level = levels[global.supply.level]
	local accumulated = {}
	for _,item in pairs(level.requirements) do
		accumulated[item.name] = 0
	end
	for i = #global.supply.chests,1,-1 do
		local chest = global.supply.chests[i]
		if not chest.valid then
			table.remove(global.supply.chests,i)
		else
			accumulated = addContentsTables(accumulated, chest.get_inventory(defines.inventory.chest).get_contents())
		end
	end
	global.supply.accumulated = accumulated
end

function isLevelRequirementFullfilled()
	local level = levels[global.supply.level]
	for _,item in pairs(level.requirements) do
		if global.supply.accumulated[item.name] < item.count then return false end
	end
	return true
end
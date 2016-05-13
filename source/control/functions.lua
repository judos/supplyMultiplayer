function pointsPerSecond()
	return points_per_second_start - (global.supply.level-1) * points_per_second_level_subtract
end


function addLevel(data)
	if #data < 1 then error("level needs a defined time-span as first table item") end
	if #data % 2 ~= 1 then error("level needs for every item an amount defined") end
	local level={requirements={},time=data[1]}
	for i=2,#data-1,2 do
		level.requirements[data[i]]=data[i+1]
	end
	table.insert(levels,level)
end

function checkNextLevelAndWinConditions()
	local time_left = get_time_left()
	if time_left < 0 then
		local fullFilled = isLevelRequirementFullfilled()
		if fullFilled then
			if subtractRequirements() then
				local points_addition = global.supply.level * 10
				PlayerPrint({"level-completed", global.supply.level, points_addition})
				nextLevel()
			else
				fullFilled = false
			end
		end
		if not fullFilled then
			for _,player in pairs(game.players) do
				player.set_ending_screen_data({"points-achieved", global.supply.points})
			end
			game.set_game_state{game_finished=true, player_won=false}
		end
	end
end

function get_time_left()
	local pastTime = global.supply.level_started_at - game.tick
	local level = levels[global.supply.level]
	if not level then return 0 end
	return time_modifier * level.time * 60 + pastTime
end

function nextLevel()
	local points_time = 0
	local points_addition = global.supply.level * 10
	local time_left = get_time_left()
	local seconds_left = math.ceil(time_left / 60)
	if seconds_left > 0 then
		points_time = math.floor(seconds_left * pointsPerSecond())
		PlayerPrint({"time-bonus", points_time, seconds_left})
	end
	global.supply.points = global.supply.points + points_addition + points_time

	global.supply.level = global.supply.level + 1
	global.supply.level_started_at = game.tick
	for _,player in pairs(game.players) do
		updatePlayerGui(player)
	end
	
	if global.supply.level > #levels then
		PlayerPrint({"points-achieved",global.supply.points})
		for _,player in pairs(game.players) do
			player.set_ending_screen_data({"points-achieved", global.supply.points})
		end
		game.set_game_state{game_finished=true, player_won=true, can_continue=true}
	end
end


function calculateAccumulated()
	local level = levels[global.supply.level]
	local accumulated = {}
	if not level then return end
	for itemName,count in pairs(level.requirements) do
		accumulated[itemName] = 0
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
	if not level then return nil end
	for itemName,count in pairs(level.requirements) do
		if global.supply.accumulated[itemName] < count then return false end
	end
	return true
end

-- returns: true when succeeded
function subtractRequirements()
	calculateAccumulated()
	if not isLevelRequirementFullfilled() then return false end
	local toRemove = deepcopy(levels[global.supply.level].requirements)
	for _,chest in pairs(global.supply.chests) do
		local inventory = chest.get_inventory(defines.inventory.chest)
		local contents = inventory.get_contents()
		for itemName, count in pairs(contents) do
			if toRemove[itemName] ~= nil then
				local countToConsume = toRemove[itemName]
				if countToConsume > count then
					countToConsume = count
				end
				if countToConsume ~= 0 then
					inventory.remove{name = itemName, count = countToConsume}
					toRemove[itemName] = toRemove[itemName] - countToConsume
				end
			end
		end
	end
	return true
end
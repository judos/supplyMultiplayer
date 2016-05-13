require "defines"
require "libs.functions"
require "control.functions"
require "control.gui"
require "control.initialize"
require "config"
require "levels"

----------------------------------------------------------------
-- Script
----------------------------------------------------------------

script.on_configuration_changed(function(event)
	if event.mod_changes ~= nil and event.mod_changes["supplyMultiplayer"] ~= nil then
		init()
		for index, _ in pairs(game.players) do
			initPlayerWithIndex(index)
		end
	end
end)

script.on_init(function()
	init()
end)
script.on_load(function()
	init()
end)

script.on_event(defines.events.on_gui_click, function(event)
	local player = game.players[event.player_index]
	local force = player.force
	if event.element == player.gui.top.supply.nextButton then
		if subtractRequirements() then
			nextLevel()
		end
	end
end)

script.on_event(defines.events.on_player_created, function(event)
	initPlayerWithIndex(event.player_index)
end)

script.on_event(defines.events.on_tick, function(event)
	if event.tick % 60 ~= 0 then return end

	--	global.supply.level_started_at = game.tick + 300 - levels[game.supply.level].time
	--	if global.supply.level_started_at < game.tick

	calculateAccumulated()
	update_info()
	local time_left = get_time_left()
	if time_left < 0 then
		local fullFilled = isLevelRequirementFullfilled()
		if fullFilled then
			if subtractRequirements() then
				local points_addition = global.supply.level * 10
				PlayerPrint({"level-completed", global.level, points_addition})
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
end)

script.on_event(defines.events.on_built_entity, function(event)
	entityBuilt(event)
end)
script.on_event(defines.events.on_robot_built_entity, function(event)
	entityBuilt(event)
end)

----------------------------------------------------------------
-- Functions
----------------------------------------------------------------

function entityBuilt(event)
	local entity = event.created_entity
	local name = entity.name
	if name~="supply-chest" then
		return
	end
	table.insert(global.supply.chests,entity)
end

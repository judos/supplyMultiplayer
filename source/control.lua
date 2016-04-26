require "defines"
require "libs.functions"
require "control.functions"
require "control.gui"
require "control.initialize"
require "control.levels"
require "config"

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
	if event.element.name == "supplyMultiplayer.nextLevel" then
	end
end)

script.on_event(defines.events.on_player_created, function(event)
	initPlayerWithIndex(event.player_index)
end)

script.on_event(defines.events.on_tick, function(event)
	if event.tick % 60 ~= 0 then return end
	
	for index,player in pairs(game.players) do
		calculateAccumulated()
		update_info()
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
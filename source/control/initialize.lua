
function init()
	showStartDialog()
	if not global then global={} end
	if not global.supply then
		global.supply={}
		global.supply.points = 0
		global.supply.level=1
		global.supply.level_started_at = 0
		global.supply.chests = {} -- list of entities
	end
end

function initPlayerWithIndex(index)
	local player = game.players[index]
	
	updatePlayerGui(player)
end

function showStartDialog()
	return
	--[[
	game.show_message_dialog{text = {"welcome"}}
	game.show_message_dialog{text = {"rules1"}}
	game.show_message_dialog{text = {"rules2"}}
	game.show_message_dialog{text = {"rules3"}}
	game.show_message_dialog{text = {"rules4"}}
	game.show_message_dialog{text = {"rules5"}}
	]]--
end

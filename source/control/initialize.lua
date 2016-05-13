
function init()
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
	player.insert{name="supply-chest",count=1}
	
	updatePlayerGui(player)
	showNextDialog(player)
end

function showNextDialog(player)
	if player.gui.center.supply then
		player.gui.center.supply.destroy()
		return
	end
	
	local frame = player.gui.center.add{type="frame",name="supply",direction="vertical",caption={"welcome"}}
	frame.add{type="table",colspan="1",name="t"}
	frame.t.add{type="label",caption={"rules1"} }
	frame.t.add{type="label",caption={"rules2"} }
	frame.t.add{type="label",caption={"rules3"} }
	frame.t.add{type="label",caption={"rules4"} }
	frame.t.add{type="label",caption={"rules5"} }
	frame.t.add{type="button",caption="x",name=intro_button,style="close-button"}
end

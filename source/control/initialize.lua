
function init()
	showStartDialog()
	if not global.supply then
		global.supply={}
		global.supply.points = 0
		global.supply.level=1
		global.supply.level_started_at = 0
	end
end

function initPlayerWithIndex(index)
	local level = levels[global.supply.level] 
	
	local frame = player.gui.top.add{type="frame", name="supply", direction="vertical", caption = {"", {"level"}, " ", global.supply.level}}
	local table = frame.add{type="table", name="table", colspan=2}
	frame.add{type="label", name="time_left"}
	frame.add{type="label", caption={"", {"points-per-second"}, ": ", points_per_second_start - global.supply.level * points_per_second_level_subtract}}
	frame.add{type="label", caption={"", {"points"}, ": ", math.floor(global.supply.points)}}
	frame.add{type="label", caption={"", {"required-items"}, ":"}, style="caption_label_style"}
	for index, item in pairs(level.requirements) do
		table.add{type="label", caption=game.item_prototypes[item.name].localised_name}
		table.add{type="label", caption="0/" .. item.count, name=item.name}
	end

	if global.level < #levels then
		local next_level = levels[global.supply.level + 1]
		frame.add{type="label", caption={"", {"next-level"}, ":"}, style="caption_label_style"}
		local table = frame.add{type="table", colspan=2}
		for index, item in pairs(next_level.requirements) do
			table.add{type="label", caption=game.item_prototypes[item.name].localised_name}
			table.add{type="label", caption=item.count}
		end
	end
end

function showStartDialog()
	game.show_message_dialog{text = {"welcome"}}
	game.show_message_dialog{text = {"rules1"}}
	game.show_message_dialog{text = {"rules2"}}
	game.show_message_dialog{text = {"rules3"}}
	game.show_message_dialog{text = {"rules4"}}
	game.show_message_dialog{text = {"rules5"}}
end

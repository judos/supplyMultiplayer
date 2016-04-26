
function init()
	showStartDialog()
	global.supply.points = 0
end

function initPlayerWithIndex(index)
	local frame = player.gui.top.add{type="frame", name="supply", direction="vertical", caption = {"", {"level"}, " ", global.level}}
	local table = frame.add{type="table", name="table", colspan=2}
	frame.add{type="label", name="time_left"}
	frame.add{type="label", caption={"", {"points-per-second"}, ": ", points_per_second_start - global.level * points_per_second_level_subtract}}
	frame.add{type="label", caption={"", {"points"}, ": ", math.floor(global.points)}}
	frame.add{type="label", caption={"", {"required-items"}, ":"}, style="caption_label_style"}
	for index, item in pairs(level.requirements) do
		table.add{type="label", caption=item_prototypes[item.name].localised_name}
		table.add{type="label", caption="0/" .. item.count, name=item.name}
		global.accumulated[item.name] = 0
		global.required[item.name] = item.count
	end

	if global.level < #levels then
		local next_level = levels[global.level + 1]
		frame.add{type="label", caption={"", {"next-level"}, ":"}, style="caption_label_style"}
		local table = frame.add{type="table", colspan=2}
		local item_prototypes = game.item_prototypes
		for index, item in pairs(next_level.requirements) do
			local diff;
			if global.required[item.name] ~= nil then
				diff = item.count - global.required[item.name]
			else
				diff = item.count
			end
			if diff ~= 0 then
				table.add{type="label", caption=item_prototypes[item.name].localised_name}
			end
			if diff > 0 then
				table.add{type="label", caption="+" .. diff}
			elseif diff < 0 then
				table.add{type="label", caption=diff}
			end
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

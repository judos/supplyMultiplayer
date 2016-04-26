require "util"

function update_info()
	for _,player in pairs(game.players) do 
		updatePlayerGui(player)
		local frame = player.gui.top.supply
		local level = levels[global.supply.level]
		local table=frame.table
		for index, item in pairs(level.requirements) do
			local accumulated = global.supply.accumulated[item.name]
			local label = table[item.name]
			label.caption = accumulated .. "/" .. item.count
			if accumulated >= item.count then
				label.style.font_color = {g=0.8}
				table["t"..item.name].style.font_color = {g=0.8}
			end
		end
	end
	update_time_left()
end

function get_time_left()
	return global.supply.level_started_at + time_modifier * levels[global.supply.level].time * 60 - game.tick
end

function update_time_left()
	local time_left = get_time_left()
	if time_left < 0 then
		time_left = 0
	end
	for _,player in pairs(game.players) do 
		if player.gui.top.supply then
			local label = player.gui.top.supply.time_left
			label.caption = {"", {"time-left"}, ": ", util.formattime(time_left)}
			if time_left == 60 * 30 then
				label.style.font_color = {r=1}
			end
		end
	end
end

function updatePlayerGui(player)
	if player.gui.top.supply then
		player.gui.top.supply.destroy()
	end
	local level = levels[global.supply.level] 
	local frame = player.gui.top.add{type="frame", name="supply", direction="vertical", caption = {"", {"level"}, " ", global.supply.level}}
	frame.add{type="label", name="time_left"}
	frame.add{type="label", caption={"", {"points-per-second"}, ": ", pointsPerSecond()}}
	frame.add{type="label", caption={"", {"points"}, ": ", math.floor(global.supply.points)}}
	frame.add{type="label", caption={"", {"required-items"}, ":"}, style="caption_label_style"}
	local table = frame.add{type="table", name="table", colspan=2}
	for index, item in pairs(level.requirements) do
		table.add{type="label", caption=game.item_prototypes[item.name].localised_name,name="t"..item.name}
		table.add{type="label", caption="0/" .. item.count, name=item.name}
	end

	if global.supply.level < #levels then
		local next_level = levels[global.supply.level + 1]
		frame.add{type="label", caption={"", {"next-level"}, ":"}, style="caption_label_style"}
		local table = frame.add{type="table", colspan=2}
		for index, item in pairs(next_level.requirements) do
			table.add{type="label", caption=game.item_prototypes[item.name].localised_name}
			table.add{type="label", caption=item.count}
		end
	end
end
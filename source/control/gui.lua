require "util"

function update_info()
	for _,player in pairs(game.players) do 
		local frame = player.gui.top.supply
		local level = levels[global.supply.level]
		local table=frame.table
		for index, item in pairs(level.requirements) do
			local accumulated = global.supply.accumulated[item.name]
			local label = table[item.name]
			label.caption = accumulated .. "/" .. item.count
			if accumulated == item.count then
				label.style.font_color = {g=0.6}
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
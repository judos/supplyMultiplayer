function update_info()
	for _,player in pairs(game.players) do 
		local frame = player.gui.top.frame
		local level = levels[global.level]
		local table=frame.table
		for index, item in pairs(level.requirements) do
			local accumulated = global.accumulated[item.name]
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
	return global.level_started_at + time_modifier * levels[global.level].time * 60 - game.tick
end

function update_time_left()
	local time_left = get_time_left()
	if time_left < 0 then
		time_left = 0
	end
	for _,player in pairs(game.players) do 
		if player.gui.top.frame then
			local label = player.gui.top.frame.time_left
			label.caption = {"", {"time-left"}, ": ", util.formattime(time_left)}
			if time_left == 60 * 30 then
				label.style.font_color = {r=1}
			end
		end
	end
end
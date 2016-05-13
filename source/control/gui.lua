require "util"

function update_info()
	local fullFilled = isLevelRequirementFullfilled() 
	for _,player in pairs(game.players) do 
		local frame = player.gui.top.supply
		local level = levels[global.supply.level]
		local table=frame.table
		for itemName, count in pairs(level.requirements) do
			local accumulated = global.supply.accumulated[itemName]
			local label = table[itemName]
			label.caption = accumulated .. "/" .. count
			if accumulated >= count then
				label.style.font_color = {g=0.8}
				table["t"..itemName].style.font_color = {g=0.8}
			else
				label.style.font_color = nil
				table["t"..itemName].style.font_color = nil
			end
		end
		if fullFilled and frame.nextButton == nil then
			frame.add{type = "button", name = "nextButton", caption={"next-level"}}
		elseif not fullFilled and frame.nextButton ~= nil then
			frame.nextButton.destroy()
		end
	end
	update_time_left()
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
	for itemName,count in pairs(level.requirements) do
		table.add{type="label", caption=game.item_prototypes[itemName].localised_name,name="t"..itemName}
		table.add{type="label", caption="0/" .. count, name=itemName}
	end

	if global.supply.level < #levels then
		local next_level = levels[global.supply.level + 1]
		frame.add{type="label", caption={"", {"next-level"}, ":"}, style="caption_label_style"}
		local table = frame.add{type="table", colspan=2}
		for itemName,count in pairs(next_level.requirements) do
			table.add{type="label", caption=game.item_prototypes[itemName].localised_name}
			table.add{type="label", caption=count}
		end
	end
	update_time_left()
end
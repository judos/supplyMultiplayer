require "util"

function update_info()
	local fullFilled = isLevelRequirementFullfilled() 
	local level = levels[global.supply.level]
	if not level then return end
	for _,player in pairs(game.players) do 
		local frame = player.gui.top.supply
		local table=frame.content.table
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
		if fullFilled and frame[next_button] == nil then
			frame.add{type = "button", name = next_button, caption={"next-level"}}
		elseif not fullFilled and frame[next_button]~= nil then
			frame[next_button].destroy()
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
			local label = player.gui.top.supply.content.time_left
			label.caption = {"", {"time-left"}, ": ", util.formattime(time_left)}
			if time_left <= 60 * 30 then
				label.style.font_color = {r=1}
			end
		end
	end
end

function updatePlayerGui(player)
	local frame = player.gui.top.supply
	local level = levels[global.supply.level]
	if not frame then
		frame = player.gui.top.add{type="frame", name="supply", direction="vertical", caption = {"", {"level"}, " ", global.supply.level}}
	else
		for _,name in pairs(frame.children_names) do
			frame[name].destroy()
		end
		if level then
			frame.caption = {"", {"level"}, " ", global.supply.level}
		else
			frame.caption = ""
			local table = frame.add{type="table", name="table", colspan=2}
			table.add{type="label", name="done", caption= {"", {"points-achieved",global.supply.points}}}
			table.add{type="button",name=close_button,caption="x"}		
		end
	end
	
	if level then
		local content = frame.add{type="table", name="content", colspan=1}
		content.add{type="label", name="time_left"}
		content.add{type="label", name="pps_value", caption={"", {"points"}, ": ", math.floor(global.supply.points)}}
		content.add{type="label", name="pps", caption={"", {"points-per-second"}, ": ", pointsPerSecond()}}
		content.add{type="label", name="required_items", caption={"", {"required-items"}, ":"}, style="caption_label_style"}
		local table = content.add{type="table", name="table", colspan=2}
		for itemName,count in pairs(level.requirements) do
			table.add{type="label", caption=game.item_prototypes[itemName].localised_name,name="t"..itemName}
			table.add{type="label", caption="0/" .. count, name=itemName}
		end
	
		content.add{type="label", name="next_level_title", caption={"", {"next-level"}, ":"}, style="caption_label_style"}
		if global.supply.level < #levels then
			local next_level = levels[global.supply.level + 1]
			local table2 = content.add{type="table", name="table2", colspan=2}
			for itemName,count in pairs(next_level.requirements) do
				table2.add{type="label", caption={"",game.item_prototypes[itemName].localised_name," "}}
				table2.add{type="label", caption=count}
			end
		else
			content.add{type="label",name="finished",caption="-"}
			content.finished.style.font_color = {g=0.8}
		end
		update_time_left()
	end
end
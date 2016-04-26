require "util"
require "story"
require "defines"
require "levels"

time_modifier = 1.4
points_per_second_start = 5
points_per_second_level_subtract = 0.2


function update_info()
	local frame = game.player.gui.top.frame

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
	local label = game.player.gui.top.frame.time_left
	label.caption = {"", {"time-left"}, ": ", util.formattime(time_left)}
	if time_left == 60 * 30 then
		label.style.font_color = {r=1}
	end
end

story_table =
	{
		{
			{
				action = function()
					game.show_message_dialog{text = {"welcome"}}
					game.show_message_dialog{text = {"rules1"}}
					game.show_message_dialog{text = {"rules2"}}
					game.show_message_dialog{text = {"rules3"}}
					game.show_message_dialog{text = {"rules4"}}
					game.show_message_dialog{text = {"rules5"}}
				end
			},
			{},
			{
				name = "level-start",
				init = function(event)
					local level = levels[global.level]
					local frame = game.player.gui.top.add{type="frame", name="frame", direction="vertical", caption = {"", {"level"}, " ", global.level}}
					frame.add{type="label", name="time_left"}
					frame.add{type="label", caption={"", {"points-per-second"}, ": ", points_per_second_start - global.level * points_per_second_level_subtract}}
					frame.add{type="label", caption={"", {"points"}, ": ", math.floor(global.points)}}
					frame.add{type="label", caption={"", {"required-items"}, ":"}, style="caption_label_style"}
					global.accumulated = {}
					global.required = {}
					global.labels = {}
					local table = frame.add{type="table", name="table", colspan=2}
					local item_prototypes = game.item_prototypes
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
					global.level_started_at = event.tick
					update_info()
				end,
			},
			{
				name = "level-progress",
				update =
				function(event)
					local update_info_needed = false
					local level = levels[global.level]
					for index, chest in pairs(global.chests) do
						local inventory = chest.get_inventory(defines.inventory.chest)
						local contents = inventory.get_contents()
						for itemname, count in pairs(contents) do
							if global.accumulated[itemname] == nil then
							--goto continue
							end
							local counttoconsume = global.required[itemname] - global.accumulated[itemname]
							if counttoconsume > count then
								counttoconsume = count
							end
							if counttoconsume ~= 0 then
								inventory.remove{name = itemname, count = counttoconsume}
								global.accumulated[itemname] = global.accumulated[itemname] + counttoconsume
								update_info_needed = true
							end
							--::continue::
						end
					end
					if update_info_needed then
						update_info()
					end
					update_time_left()
				end,

				condition = function(event)
					local level = levels[global.level]
					local time_left = get_time_left()

					if event.name == defines.events.on_gui_click and
						event.element.name == "next_level" then
						local seconds_left = math.floor(time_left / 60)
						local points_addition = math.floor(seconds_left * (points_per_second_start - global.level * points_per_second_level_subtract))
						game.player.print({"time-bonus", points_addition, seconds_left})
						global.points = global.points + points_addition
						return true
					end

					local result = true
					for index, item in pairs(level.requirements) do
						local accumulated = global.accumulated[item.name]
						if accumulated < item.count then
							result = false
						end
					end

					if result and game.player.gui.top.next_level == nil then
						game.player.gui.top.add{type = "button", name = "next_level", caption={"next-level"}}
					end

					if time_left <= 0 then
						if result == false then
							game.set_game_state{game_finished=true, player_won=false}
							game.player.set_ending_screen_data({"points-achieved", global.points})
							return false
						else
							return true
						end
					end

					return false
				end,
				action = function(event, story)
					if game.player.gui.top.next_level ~= nil then
						game.player.gui.top.next_level.destroy()
					end
					global.level = global.level + 1
					local points_addition = (global.level - 1) * 10
					game.player.print({"level-completed", global.level - 1, points_addition})
					global.points = global.points + points_addition

					if global.level < #levels + 1 then
						game.player.gui.top.frame.destroy()
						story_jump_to(story, "level-start")
					end
				end
			},
			{
				action = function()
					game.player.set_ending_screen_data({"points-achieved", global.points})
				end
			}
		}
	}

story_init_helpers(story_table)

script.on_init(function()
	global.story = story_init(story_table)
	game.map_settings.pollution.enabled = false
	game.evolution_factor = 0
	global.chests = {}
	for i=1,6,1 do
		local chest = game.get_entity_by_tag("chest" .. i)
		chest.minable = false
		chest.destructible = false
		global.chests[i] = chest
	end
	global.level = 1
	game.player.character.insert{name = "iron-plate", count = 8}
	global.points = 0
end)

script.on_event(defines.events, function(event)
	story_update(global.story, event, "")
end)

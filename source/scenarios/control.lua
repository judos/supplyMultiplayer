require "util"
require "story"
require "defines"




story_table = {
	{
		{
			name = "level-progress",
			update = function(event)
				local update_info_needed = false
				local level = levels[global.level]
				for index, chest in pairs(global.chests) do
					local inventory = chest.get_inventory(defines.inventory.chest)
					local contents = inventory.get_contents()
					for itemname, count in pairs(contents) do
						if global.accumulated[itemname] ~= nil then
							local counttoconsume = global.required[itemname] - global.accumulated[itemname]
							if counttoconsume > count then
								counttoconsume = count
							end
							if counttoconsume ~= 0 then
								inventory.remove{name = itemname, count = counttoconsume}
								global.accumulated[itemname] = global.accumulated[itemname] + counttoconsume
								update_info_needed = true
							end
						end
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
					for _,player in pairs(game.players) do
						player.print({"time-bonus", points_addition, seconds_left})
					end
					global.points = global.points + points_addition
					return true
				end


				if time_left <= 0 then
					if result == false then
						game.set_game_state{game_finished=true, player_won=false}
						for _,player in pairs(game.players) do
							player.set_ending_screen_data({"points-achieved", global.points})
						end
						return false
					else
						return true
					end
				end

				return false
			end,
			action = function(event, story)
				global.level = global.level + 1
				local points_addition = (global.level - 1) * 10
				for _,player in pairs(game.players) do
					if player.gui.top.next_level ~= nil then
						player.gui.top.next_level.destroy()
					end
					player.print({"level-completed", global.level - 1, points_addition})
				end
				global.points = global.points + points_addition

				if global.level < #levels + 1 then
					for _,player in pairs(game.players) do
						player.gui.top.frame.destroy()
					end
					story_jump_to(story, "level-start")
				end
			end
		},
		{
			action = function()
				for _,player in pairs(game.players) do
					player.set_ending_screen_data({"points-achieved", global.points})
				end
			end
		}
	}
}


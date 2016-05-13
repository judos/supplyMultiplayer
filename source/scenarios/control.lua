require "util"
require "story"
require "defines"




story_table = {
	{
		{
			
			action = function(event, story)
				

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


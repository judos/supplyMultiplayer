require "libs.functions"
require "libs.basic-lua-extensions"

data:extend({
  {
    type = "item",
    name = "supply-chest",
    icon = "__supplyMultiplayer__/graphics/icons/supply-chest.png",
    flags = {"goes-to-quickbar"},
    subgroup = "storage",
    order = "a[items]-z[supply-chest]",
    place_result = "supply-chest",
    stack_size = 50
  }
})

local supplyChest = deepcopy(data.raw["smart-container"]["smart-chest"])
overwriteContent(supplyChest,{
	name = "supply-chest",
	icon = "__supplyMultiplayer__/graphics/icons/supply-chest.png",
	minable = {
		hardness = 0.2,
		mining_time = 0.5,
		result = "supply-chest"
  },
	collision_box = {{-0.9, -0.9}, {0.9, 0.9}},
  selection_box = {{-0.9, -0.9}, {0.9, 0.9}},
	picture = {
		filename = "__supplyMultiplayer__/graphics/entity/supply-chest.png",
		priority = "extra-high",
		width = 80,
		height = 80,
		shift = {0, 0}
  }
})

data:extend({supplyChest})
minetest.log("action", "[sm_mapnodes] loading...")

local minetest = minetest

local VoxelArea = VoxelArea

local vector = vector

--local s = minetest.get_mod_storage()
local modpath = minetest.get_modpath("sm_mapnodes")

dofile(modpath.."/building_nodes.lua")

minetest.register_abm({
	label = "Coins Spawning",

	nodenames = {"sm_mapnodes:gravel"},

	interval = 3,
	chance = 20,
	min_y = -1,
    max_y = -1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local pos2 = vector.add(pos, vector.new(0, 1, 0))
		minetest.add_entity(pos2, "sm_mapnodes:mese_coin")
	end,
})

minetest.log("action", "[sm_mapnodes] loaded sucessfully")
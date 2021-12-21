minetest.log("action", "[sm_mapnodes] loading...")

local minetest = minetest

--local vector = vector

local modpath = minetest.get_modpath("sm_mapnodes")

dofile(modpath.."/building_nodes.lua")
dofile(modpath.."/entities.lua")

minetest.register_abm({
	label = "Coins Spawning",
	nodenames = {"sm_mapnodes:rail"},
	interval = 3,
	chance = 20,
	min_y = 0,
    max_y = 0,
	action = function(pos, node, active_object_count, active_object_count_wider)
		minetest.add_entity(pos, "sm_mapnodes:mese_coin")
	end,
})

minetest.log("action", "[sm_mapnodes] loaded sucessfully")
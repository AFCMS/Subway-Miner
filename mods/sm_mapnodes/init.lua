minetest.log("action", "[sm_mapnodes] loading...")

local minetest = minetest

--local vector = vector

local modpath = minetest.get_modpath("sm_mapnodes")

dofile(modpath.."/building_nodes.lua")
dofile(modpath.."/entities.lua")

minetest.log("action", "[sm_mapnodes] loaded sucessfully")
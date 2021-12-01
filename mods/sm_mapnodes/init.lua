minetest.log("action", "[sm_mapnodes] loading...")

local minetest = minetest

local VoxelArea = VoxelArea

local vector = vector

--local s = minetest.get_mod_storage()
local modpath = minetest.get_modpath("sm_mapnodes")

dofile(modpath.."/building_nodes.lua")

local content_ids = {
	gravel = minetest.get_content_id("sm_mapnodes:gravel"),
	rail = minetest.get_content_id("sm_mapnodes:rail"),
}

minetest.register_on_generated(function(minp, maxp, seed)
	minetest.chat_send_all(string.format("minp=%s, maxp=%s", minetest.pos_to_string(minp), minetest.pos_to_string(maxp)))
	if minp.y ~= -32 or minp.x ~= -32 then
		return
	end

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	local data = vm:get_data()

	for z = minp.z, maxp.z do
		for x = minp.x, maxp.x do
			for y = minp.y, maxp.y do
				local vi = area:index(x, y, z)
				if y == -1 then
					if x == -1 or x == 0 or x == 1 then
						data[vi] = content_ids.gravel
					end
				elseif y == 0 or y == 1 then
					if x == -2 or x == 2 then
						data[vi] = content_ids.gravel
					end
				end
				if y == 0 then
					if x == -1 or x == 0 or x == 1 then
						data[vi] = content_ids.rail
					end
				end
			end
		end
	end

	vm:set_data(data)
	vm:write_to_map(data)
end)

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
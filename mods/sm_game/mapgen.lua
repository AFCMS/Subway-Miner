local minetest = minetest
--local vector = vector

local content_ids = {
	gravel = minetest.get_content_id("sm_mapnodes:gravel"),
	rail = minetest.get_content_id("sm_mapnodes:rail"),
}

sm_game.map_sectors = {
	{
		border = {
			{
				{x=-1, y=0, id=content_ids.gravel}
			},
		},
	},
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
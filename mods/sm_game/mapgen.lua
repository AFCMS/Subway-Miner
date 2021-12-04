local minetest = minetest
--local vector = vector
local ipairs = ipairs

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
		for e in ipairs(sm_game.map_sectors[1].border) do
			for i in ipairs(e) do
				
			end
		end
	end

	vm:set_data(data)
	vm:write_to_map(data)
end)
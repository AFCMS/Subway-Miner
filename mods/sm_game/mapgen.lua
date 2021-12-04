local minetest = minetest
--local vector = vector
local ipairs = ipairs

local VoxelArea = VoxelArea

local content_ids = {
	gravel = minetest.get_content_id("sm_mapnodes:gravel"),
	rail = minetest.get_content_id("sm_mapnodes:rail"),
}

local content_ids = setmetatable({}, {__index = function(self, nodename)
    local c_id = minetest.get_content_id(nodename)
    self[nodename] = c_id
    return c_id
end})

sm_game.map_sectors = {
	{
		border = {
			{
				{x=-1, y=0, id=content_ids["sm_mapnodes:gravel"]},
				{x=0, y=0, id=content_ids["sm_mapnodes:gravel"]},
				{x=1, y=0, id=content_ids["sm_mapnodes:gravel"]},
				{x=-1, y=1, id=content_ids["sm_mapnodes:rail"]},
				{x=0, y=1, id=content_ids["sm_mapnodes:rail"]},
				{x=1, y=1, id=content_ids["sm_mapnodes:rail"]},
			},
			{
				{x=-1, y=0, id=content_ids["sm_mapnodes:gravel2"]},
				{x=0, y=0, id=content_ids["sm_mapnodes:gravel2"]},
				{x=1, y=0, id=content_ids["sm_mapnodes:gravel2"]},
				{x=-1, y=1, id=content_ids["sm_mapnodes:rail"]},
				{x=0, y=1, id=content_ids["sm_mapnodes:rail"]},
				{x=1, y=1, id=content_ids["sm_mapnodes:rail"]},
			},
		},
	},
	{
		border = {
			{
				{x=-1, y=0, id=content_ids["sm_mapnodes:gravel2"]},
				{x=0, y=0, id=content_ids["sm_mapnodes:gravel"]},
				{x=1, y=0, id=content_ids["sm_mapnodes:gravel2"]},
				{x=-1, y=1, id=content_ids["sm_mapnodes:rail"]},
				{x=0, y=1, id=content_ids["sm_mapnodes:rail"]},
				{x=1, y=1, id=content_ids["sm_mapnodes:rail"]},
			},
			{
				{x=-1, y=0, id=content_ids["sm_mapnodes:gravel"]},
				{x=0, y=0, id=content_ids["sm_mapnodes:gravel2"]},
				{x=1, y=0, id=content_ids["sm_mapnodes:gravel"]},
				{x=-1, y=1, id=content_ids["sm_mapnodes:rail"]},
				{x=0, y=1, id=content_ids["sm_mapnodes:rail"]},
				{x=1, y=1, id=content_ids["sm_mapnodes:rail"]},
			},
		},
	},
}

local pcgrandom = PseudoRandom(minetest.get_mapgen_setting("seed"))

minetest.register_on_generated(function(minp, maxp, seed)
	minetest.chat_send_all(string.format("minp=%s, maxp=%s", minetest.pos_to_string(minp), minetest.pos_to_string(maxp)))
	if minp.y ~= -32 or minp.x ~= -32 then
		return
	end

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	local data = vm:get_data()

	local al = pcgrandom:next(1, #sm_game.map_sectors)
	minetest.chat_send_all(al)
	local border = sm_game.map_sectors[al].border

	for index, nodes in ipairs(border) do
		for z = minp.z + index - 1, maxp.z, #border do
			for _,node in ipairs(nodes) do
				data[area:index(node.x, node.y, z)] = node.id
			end
		end
	end

	--[[
	for z = minp.z, maxp.z do
		for _,e in ipairs(border) do
			for _,i in ipairs(e) do
				data[area:index(i.x, i.y, z)] = i.id
			end
		end
		if z == -30850 then data[area:index(1, 1, -30850)] = content_ids["sm_mapnodes:bumper"] end
	end
	]]

	vm:set_data(data)
	vm:write_to_map(data)
end)
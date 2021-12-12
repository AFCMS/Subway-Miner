local minetest = minetest
--local vector = vector
local ipairs = ipairs

local VoxelArea = VoxelArea
local PseudoRandom = PseudoRandom

local content_ids = setmetatable({}, {__index = function(self, nodename)
    local c_id = minetest.get_content_id(nodename)
    self[nodename] = c_id
    return c_id
end})

sm_game.map_elements = {
	train1 = {
		{y=1, id=content_ids["sm_mapnodes:train_1"]},
	},
	bumper1 = {
		{y=1, id=content_ids["sm_mapnodes:train_1"]},
		{y=1, id=content_ids["sm_mapnodes:train_2"]},
		{y=1, id=content_ids["sm_mapnodes:train_3"]},
		{y=1, id=content_ids["sm_mapnodes:wagon_1"]},
		{y=1, id=content_ids["sm_mapnodes:wagon_2"]},
		{y=1, id=content_ids["sm_mapnodes:wagon_3"]},
		{y=1, id=content_ids["sm_mapnodes:wagon_1"]},
		{y=1, id=content_ids["sm_mapnodes:wagon_2"]},
		{y=1, id=content_ids["sm_mapnodes:wagon_3"]},
		{y=1, id=content_ids["sm_mapnodes:wagon_1"]},
		{y=1, id=content_ids["sm_mapnodes:wagon_2"]},
		{y=1, id=content_ids["sm_mapnodes:wagon_3"]},
		{y=1, id=content_ids["sm_mapnodes:rail"]},
		{y=1, id=content_ids["sm_mapnodes:bumper"]}
	},
}

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
		elements = {
			{line=1, pos=10, element=sm_game.map_elements.train1},
			{line=1, pos=20, element=sm_game.map_elements.train1},
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
		elements = {
			{line=-1, pos=5, element=sm_game.map_elements.bumper1},
			{line=1, pos=20, element=sm_game.map_elements.bumper1},
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

	local elements = sm_game.map_sectors[al].elements

	for _,e in ipairs(elements) do
		for z = minp.z, maxp.z do
			if z == minp.z + e.pos then
				minetest.chat_send_all("("..tostring(minp.z + e.pos)..")")
				local count = 0
				for _,node in ipairs(e.element) do
					data[area:index(e.line, node.y, minp.z + e.pos + count)] = node.id
					count = count + 1
				end
			end
		end
	end

	vm:set_data(data)
	vm:write_to_map(data)
end)
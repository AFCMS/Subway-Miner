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
		{y=1, id=content_ids["sm_mapnodes:train_2"]},
		{y=1, id=content_ids["sm_mapnodes:train_3"]},
	},
	train2 = {
		{y=1, id=content_ids["sm_mapnodes:train_1"]},
		{y=1, id=content_ids["sm_mapnodes:train_2"]},
		{y=1, id=content_ids["sm_mapnodes:train_3"]},
		{y=1, id=content_ids["sm_mapnodes:wagon_1"]},
		{y=1, id=content_ids["sm_mapnodes:wagon_2"]},
		{y=1, id=content_ids["sm_mapnodes:wagon_3"]},
	},
	train3 = {
		{y=1, id=content_ids["sm_mapnodes:train_1"]},
		{y=1, id=content_ids["sm_mapnodes:train_2"]},
		{y=1, id=content_ids["sm_mapnodes:train_3"]},
		{y=1, id=content_ids["sm_mapnodes:wagon_1"]},
		{y=1, id=content_ids["sm_mapnodes:wagon_2"]},
		{y=1, id=content_ids["sm_mapnodes:wagon_3"]},
		{y=1, id=content_ids["sm_mapnodes:wagon_1"]},
		{y=1, id=content_ids["sm_mapnodes:wagon_2"]},
		{y=1, id=content_ids["sm_mapnodes:wagon_3"]},
	},
	train4 = {
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
	},
	bumper1 = {
		{y=1, id=content_ids["sm_mapnodes:bumper"]}
	},
	bumper2 = {
		{y=1, id=content_ids["sm_mapnodes:bumper2"]}
	},
	wagon1 = {
		{y=1, id=content_ids["sm_mapnodes:wagon_1"]},
		{y=1, id=content_ids["sm_mapnodes:wagon_2"]},
		{y=1, id=content_ids["sm_mapnodes:wagon_3"]},
	},
	wagon2 = {
		{y=1, id=content_ids["sm_mapnodes:wagon_1"]},
		{y=1, id=content_ids["sm_mapnodes:wagon_2"]},
		{y=1, id=content_ids["sm_mapnodes:wagon_3"]},
		{y=1, id=content_ids["sm_mapnodes:wagon_1"]},
		{y=1, id=content_ids["sm_mapnodes:wagon_2"]},
		{y=1, id=content_ids["sm_mapnodes:wagon_3"]},
	},
	wagon3 = {
		{y=1, id=content_ids["sm_mapnodes:wagon_1"]},
		{y=1, id=content_ids["sm_mapnodes:wagon_2"]},
		{y=1, id=content_ids["sm_mapnodes:wagon_3"]},
		{y=1, id=content_ids["sm_mapnodes:wagon_1"]},
		{y=1, id=content_ids["sm_mapnodes:wagon_2"]},
		{y=1, id=content_ids["sm_mapnodes:wagon_3"]},
		{y=1, id=content_ids["sm_mapnodes:wagon_1"]},
		{y=1, id=content_ids["sm_mapnodes:wagon_2"]},
		{y=1, id=content_ids["sm_mapnodes:wagon_3"]},
	},
}

sm_game.map_sectors = {
	{
		border = {
			{
				{x=-2, y=0, id=content_ids["sm_mapnodes:sand"]},
				{x=2, y=0, id=content_ids["sm_mapnodes:sand"]},
				{x=-2, y=1, id=content_ids["sm_mapnodes:fence_wood"]},
				{x=2, y=1, id=content_ids["sm_mapnodes:fence_wood"]},
				{x=-1, y=0, id=content_ids["sm_mapnodes:gravel"]},
				{x=0, y=0, id=content_ids["sm_mapnodes:gravel"]},
				{x=1, y=0, id=content_ids["sm_mapnodes:gravel"]},
				{x=-1, y=1, id=content_ids["sm_mapnodes:rail"]},
				{x=0, y=1, id=content_ids["sm_mapnodes:rail"]},
				{x=1, y=1, id=content_ids["sm_mapnodes:rail"]},
			},
			{
				{x=-2, y=0, id=content_ids["sm_mapnodes:sand"]},
				{x=2, y=0, id=content_ids["sm_mapnodes:sand"]},
				{x=-2, y=1, id=content_ids["sm_mapnodes:fence_wood"]},
				{x=2, y=1, id=content_ids["sm_mapnodes:fence_wood"]},
				{x=-1, y=0, id=content_ids["sm_mapnodes:gravel"]},
				{x=0, y=0, id=content_ids["sm_mapnodes:gravel"]},
				{x=1, y=0, id=content_ids["sm_mapnodes:gravel"]},
				{x=-1, y=1, id=content_ids["sm_mapnodes:rail"]},
				{x=0, y=1, id=content_ids["sm_mapnodes:rail"]},
				{x=1, y=1, id=content_ids["sm_mapnodes:rail"]},
			},
			{
				{x=-2, y=0, id=content_ids["sm_mapnodes:sand"]},
				{x=2, y=0, id=content_ids["sm_mapnodes:sand"]},
				{x=-2, y=1, id=content_ids["sm_mapnodes:fence_wood"]},
				{x=2, y=1, id=content_ids["sm_mapnodes:fence_wood"]},
				{x=-1, y=0, id=content_ids["sm_mapnodes:gravel"]},
				{x=0, y=0, id=content_ids["sm_mapnodes:gravel"]},
				{x=1, y=0, id=content_ids["sm_mapnodes:gravel"]},
				{x=-1, y=1, id=content_ids["sm_mapnodes:rail"]},
				{x=0, y=1, id=content_ids["sm_mapnodes:rail"]},
				{x=1, y=1, id=content_ids["sm_mapnodes:rail"]},
			},
			{
				{x=-2, y=0, id=content_ids["sm_mapnodes:sand"]},
				{x=2, y=0, id=content_ids["sm_mapnodes:sand"]},
				{x=-2, y=1, id=content_ids["sm_mapnodes:fence_wood"]},
				{x=2, y=1, id=content_ids["sm_mapnodes:fence_wood"]},
				{x=-1, y=0, id=content_ids["sm_mapnodes:gravel"]},
				{x=0, y=0, id=content_ids["sm_mapnodes:gravel"]},
				{x=1, y=0, id=content_ids["sm_mapnodes:gravel"]},
				{x=-1, y=1, id=content_ids["sm_mapnodes:rail"]},
				{x=0, y=1, id=content_ids["sm_mapnodes:rail"]},
				{x=1, y=1, id=content_ids["sm_mapnodes:rail"]},
			},
			{
				{x=-2, y=0, id=content_ids["sm_mapnodes:sand"]},
				{x=2, y=0, id=content_ids["sm_mapnodes:sand"]},
				{x=-2, y=1, id=content_ids["sm_mapnodes:fence_wood"]},
				{x=2, y=1, id=content_ids["sm_mapnodes:fence_wood"]},
				{x=-1, y=0, id=content_ids["sm_mapnodes:gravel"]},
				{x=0, y=0, id=content_ids["sm_mapnodes:gravel"]},
				{x=1, y=0, id=content_ids["sm_mapnodes:gravel"]},
				{x=-1, y=1, id=content_ids["sm_mapnodes:rail"]},
				{x=0, y=1, id=content_ids["sm_mapnodes:rail"]},
				{x=1, y=1, id=content_ids["sm_mapnodes:rail"]},
			},
			{
				{x=-2, y=0, id=content_ids["sm_mapnodes:sand"]},
				{x=2, y=0, id=content_ids["sm_mapnodes:sand"]},
				{x=-2, y=1, id=content_ids["sm_mapnodes:fence_wood"]},
				{x=2, y=1, id=content_ids["sm_mapnodes:fence_wood"]},
				{x=-1, y=0, id=content_ids["sm_mapnodes:gravel"]},
				{x=0, y=0, id=content_ids["sm_mapnodes:gravel"]},
				{x=1, y=0, id=content_ids["sm_mapnodes:gravel"]},
				{x=-1, y=1, id=content_ids["sm_mapnodes:rail"]},
				{x=0, y=1, id=content_ids["sm_mapnodes:rail"]},
				{x=1, y=1, id=content_ids["sm_mapnodes:rail"]},
			},
			{
				{x=-2, y=0, id=content_ids["sm_mapnodes:sand"]},
				{x=2, y=0, id=content_ids["sm_mapnodes:sand"]},
				{x=-2, y=2, id=content_ids["sm_mapnodes:post_light"]},
				{x=2, y=2, id=content_ids["sm_mapnodes:post_light"]},
				{x=-2, y=1, id=content_ids["sm_mapnodes:fence_wood"]},
				{x=2, y=1, id=content_ids["sm_mapnodes:fence_wood"]},
				{x=-1, y=0, id=content_ids["sm_mapnodes:gravel"]},
				{x=0, y=0, id=content_ids["sm_mapnodes:gravel"]},
				{x=1, y=0, id=content_ids["sm_mapnodes:gravel"]},
				{x=-1, y=1, id=content_ids["sm_mapnodes:rail"]},
				{x=0, y=1, id=content_ids["sm_mapnodes:rail"]},
				{x=1, y=1, id=content_ids["sm_mapnodes:rail"]},
			},
			{
				{x=-2, y=0, id=content_ids["sm_mapnodes:sand"]},
				{x=2, y=0, id=content_ids["sm_mapnodes:sand"]},
				{x=-2, y=1, id=content_ids["sm_mapnodes:fence_wood"]},
				{x=2, y=1, id=content_ids["sm_mapnodes:fence_wood"]},
				{x=-1, y=0, id=content_ids["sm_mapnodes:gravel"]},
				{x=0, y=0, id=content_ids["sm_mapnodes:gravel"]},
				{x=1, y=0, id=content_ids["sm_mapnodes:gravel"]},
				{x=-1, y=1, id=content_ids["sm_mapnodes:rail"]},
				{x=0, y=1, id=content_ids["sm_mapnodes:rail"]},
				{x=1, y=1, id=content_ids["sm_mapnodes:rail"]},
			},
			{
				{x=-2, y=0, id=content_ids["sm_mapnodes:sand"]},
				{x=2, y=0, id=content_ids["sm_mapnodes:sand"]},
				{x=-2, y=1, id=content_ids["sm_mapnodes:fence_wood"]},
				{x=2, y=1, id=content_ids["sm_mapnodes:fence_wood"]},
				{x=-1, y=0, id=content_ids["sm_mapnodes:gravel"]},
				{x=0, y=0, id=content_ids["sm_mapnodes:gravel"]},
				{x=1, y=0, id=content_ids["sm_mapnodes:gravel"]},
				{x=-1, y=1, id=content_ids["sm_mapnodes:rail"]},
				{x=0, y=1, id=content_ids["sm_mapnodes:rail"]},
				{x=1, y=1, id=content_ids["sm_mapnodes:rail"]},
			},
		},
		elements = {
			{line=1, pos=10, element=sm_game.map_elements.train4},
			{line=-1, pos=30, element=sm_game.map_elements.train2},
			{line=0, pos=0, element=sm_game.map_elements.bumper2},
			{line=1, pos=0, element=sm_game.map_elements.wagon2},
			{line=-1, pos=2, element=sm_game.map_elements.wagon3},
			{line=-1, pos=50, element=sm_game.map_elements.wagon2},
		},
	},
	{
		border = {
			{
				{x=-1, y=0, id=content_ids["sm_mapnodes:gravel"]},
				{x=0, y=0, id=content_ids["sm_mapnodes:gravel"]},
				{x=1, y=0, id=content_ids["sm_mapnodes:gravel"]},
				{x=-2, y=0, id=content_ids["sm_mapnodes:cobble"]},
				{x=2, y=0, id=content_ids["sm_mapnodes:cobble"]},
				{x=-1, y=1, id=content_ids["sm_mapnodes:rail"]},
				{x=0, y=1, id=content_ids["sm_mapnodes:rail"]},
				{x=1, y=1, id=content_ids["sm_mapnodes:rail"]},
			},
			{
				{x=-2, y=0, id=content_ids["sm_mapnodes:cobble"]},
				{x=2, y=0, id=content_ids["sm_mapnodes:cobble"]},
				{x=-2, y=1, id=content_ids["sm_mapnodes:cobble_wall"]},
				{x=2, y=1, id=content_ids["sm_mapnodes:cobble_wall"]},
				{x=-1, y=0, id=content_ids["sm_mapnodes:gravel"]},
				{x=0, y=0, id=content_ids["sm_mapnodes:gravel"]},
				{x=1, y=0, id=content_ids["sm_mapnodes:gravel"]},
				{x=-1, y=1, id=content_ids["sm_mapnodes:rail"]},
				{x=0, y=1, id=content_ids["sm_mapnodes:rail"]},
				{x=1, y=1, id=content_ids["sm_mapnodes:rail"]},
			},
		},
		elements = {
			{line=-1, pos=10, element=sm_game.map_elements.train2},
			{line=0, pos=25, element=sm_game.map_elements.wagon2},
			{line=1, pos=20, element=sm_game.map_elements.wagon3},
			{line=0, pos=40, element=sm_game.map_elements.bumper1},
			{line=-1, pos=45, element=sm_game.map_elements.wagon3},
			{line=0, pos=50, element=sm_game.map_elements.wagon3},
			{line=1, pos=65, element=sm_game.map_elements.train3},
		},
	},
}

local pcgrandom = PseudoRandom(os.time())

minetest.register_on_generated(function(minp, maxp, seed)
	--minetest.chat_send_all(string.format("minp=%s, maxp=%s", minetest.pos_to_string(minp), minetest.pos_to_string(maxp)))
	if minp.y ~= -32 or minp.x ~= -32 then
		return
	end

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
	local data = vm:get_data()

	local al = pcgrandom:next(1, #sm_game.map_sectors)
	--minetest.chat_send_all(al)
	--minetest.chat_send_all(dump(dump(minp)..", "..dump(maxp)))
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
				--minetest.chat_send_all("("..tostring(minp.z + e.pos)..")")
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
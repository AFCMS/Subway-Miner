local minetest = minetest
--local vector = vector

minetest.register_node("sm_mapnodes:gravel",{
	description = "Gravel",
	tiles = {"default_gravel.png"},
	groups = {environment_block = 1},
	diggable = false,
	is_ground_content = false,
	drop = "",
})

minetest.register_node("sm_mapnodes:gravel2",{
	description = "Gravel2",
	tiles = {"default_gravel.png^[brighten"},
	groups = {environment_block = 1},
	diggable = false,
	is_ground_content = false,
	drop = "",
})

minetest.register_node("sm_mapnodes:rail", {
	drawtype = "mesh",
	mesh = "sm_mapnodes_rail.obj",
	tiles = {"sm_mapnodes_rail.png"},
	use_texture_alpha = "opaque",
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, -1/2+1/16, 1/2},
	},
})

minetest.register_node("sm_mapnodes:bumper", {
	drawtype = "mesh",
	mesh = "sm_mapnodes_bumper.obj",
	tiles = {"sm_mapnodes_bumper.png"},
	use_texture_alpha = "opaque",
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, -1/2+1/16, 1/2},
	},
})

minetest.register_node("sm_mapnodes:train_1", {
	drawtype = "mesh",
	mesh = "sm_mapnodes_train1.obj",
	tiles = {"sm_mapnodes_train1.png"},
	use_texture_alpha = "opaque",
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, -1/2+1/16, 1/2},
	},
})

minetest.register_node("sm_mapnodes:train_2", {
	drawtype = "mesh",
	mesh = "sm_mapnodes_train2.obj",
	tiles = {"sm_mapnodes_train2.png"},
	use_texture_alpha = "opaque",
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, -1/2+1/16, 1/2},
	},
})

minetest.register_node("sm_mapnodes:train_3", {
	drawtype = "mesh",
	mesh = "sm_mapnodes_train3.obj",
	tiles = {"sm_mapnodes_train3.png"},
	use_texture_alpha = "opaque",
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, -1/2+1/16, 1/2},
	},
})


--this is used to generate a mese entity
minetest.register_craftitem("sm_mapnodes:mese", {
	description = "Mese Crystal",
	inventory_image = "default_mese_crystal.png",
})

minetest.register_entity("sm_mapnodes:mese_coin", {
	initial_properties = {
		visual = "wielditem",
		wield_item = "sm_mapnodes:mese",
		glow = minetest.LIGHT_MAX,
		visual_size = {x = 0.2, y = 0.2},
		automatic_rotate = math.pi * 0.5 * 0.2 / 0.3,
		pointable = false,
		static_save = false,
	},
	capture = function(self, object)
		local pos = self.object:get_pos()
		minetest.add_particlespawner({
			amount = 20,
			time = 0.1,
			minpos = pos,
			maxpos = pos,
			--minpos = vector.new(0,0,0),
			--maxpos = vector.new(0,0,0),
			minvel = {x=-4, y=-4, z=-4},
			maxvel = {x=4, y=4, z=4},
			--minacc = {x=-1, y=-1, z=-1},
			--maxacc = {x=1, y=1, z=1},
			minexptime = 0.1,
			maxexptime = 0.3,
			minsize = 1,
			maxsize = 1.5,
			--attached = object,
			collisiondetection = false,
			collision_removal = false,
			object_collision = false,
			vertical = false,
			texture = "default_mese_crystal.png",
			playername = "singleplayer",
			glow = minetest.LIGHT_MAX,
		})
		self.object:remove()
	end,
})
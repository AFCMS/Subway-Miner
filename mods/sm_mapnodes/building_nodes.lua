local minetest = minetest
--local vector = vector


--obstacle node group:
--0: not an obstacle
--1: hard obstacle
--2: jump avoidable obstacle
--3: sneak avoidable obstacle

minetest.register_node("sm_mapnodes:gravel",{
	description = "Gravel",
	tiles = {"default_gravel.png^[colorize:#1c1c2f:150"},
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
	groups = {obstacle = 2},
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
	groups = {obstacle = 2},
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
	groups = {obstacle = 2},
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
	groups = {obstacle = 2},
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

minetest.register_node("sm_mapnodes:wagon_1", {
	drawtype = "mesh",
	mesh = "sm_mapnodes_wagon1.obj",
	tiles = {"sm_mapnodes_wagon1.png"},
	groups = {obstacle = 2},
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

minetest.register_node("sm_mapnodes:wagon_2", {
	drawtype = "mesh",
	mesh = "sm_mapnodes_wagon2.obj",
	tiles = {"sm_mapnodes_wagon2.png"},
	groups = {obstacle = 2},
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

minetest.register_node("sm_mapnodes:wagon_3", {
	drawtype = "mesh",
	mesh = "sm_mapnodes_wagon3.obj",
	tiles = {"sm_mapnodes_wagon3.png"},
	groups = {obstacle = 2},
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


--this is used to generate a item entities
minetest.register_craftitem("sm_mapnodes:mese", {
	description = "Mese Crystal",
	inventory_image = "default_mese_crystal.png",
})

minetest.register_craftitem("sm_mapnodes:pick", {
	description = "Pick",
	inventory_image = "default_tool_diamondpick.png",
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
})

minetest.register_entity("sm_mapnodes:pick", {
	initial_properties = {
		hp_max           = 1,
		visual           = "wielditem",
		physical         = false,
		--textures         = {""},
		wield_item = "sm_mapnodes:pick",
		automatic_rotate = 1.5,
		is_visible       = true,
		pointable        = false,
		collide_with_objects = false,
		static_save = false,
		collisionbox = {-0.21, -0.21, -0.21, 0.21, 0.21, 0.21},
		selectionbox = {-0.21, -0.21, -0.21, 0.21, 0.21, 0.21},
		visual_size  = {x = 0.25, y = 0.25},
	},
})
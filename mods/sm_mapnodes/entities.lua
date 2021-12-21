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
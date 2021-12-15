minetest.log("action", "[sm_game] loading...")

--make API functions local for better performances
local minetest = minetest
local Settings = Settings

local vector = vector
--local math = math
local os = os
local table = table

--local pairs = pairs
--local tostring = tostring

local modpath = minetest.get_modpath("sm_game")

--the game can't be played in multiplayer
if not minetest.is_singleplayer() then
	error("This game isn't intended to be played in multiplayer!")
end


--switch the mab backend to RAM only
--this is an ugly hack
local worldmt = Settings(minetest.get_worldpath().."/world.mt")
if worldmt:get("backend") ~= "dummy" then
	worldmt:set("backend","dummy")
	worldmt:write()
	minetest.log("action", "[sm_game] Changed map backend to RAM only (Dummy), forcing restart")
	--minetest.request_shutdown("Intial world setup complete, please reconnect", true, 0)
	minetest.register_on_joinplayer(function()
		minetest.kick_player("singleplayer", "\nInitial world setup complete, please reconnect")
	end)
end


--local storage = minetest.get_mod_storage()

local init_pos = vector.new(0,1,-30900)

sm_game = {
	data = {
		state = "loading",
		infos = {},
		hud_ids = {},
	},
	api = {},
}

local default_infos = {
	menu = {
		page = "main",
	},
	game = {
		init_gametime = nil,
		coins_count = 0,
		target_line = 0,
		line = 0,
		direction = nil,
		is_sneaking = false,
		is_moving = false,
		nodes = {
		},
	}
}

function sm_game.set_state(name, infos)
	sm_game.data.state = name
	sm_game.data.infos = infos
end

local data = sm_game.data

local cache_player

--function minetest.chat_send_player() return end
--function minetest.chat_send_all() return end


--local animation_speed = 30
local model_animations = {
	stand     = {x = 0,   y = 79},
	lay       = {x = 162, y = 166},
	walk      = {x = 168, y = 187},
	--mine      = {x = 189, y = 198},
	--walk_mine = {x = 200, y = 219},
	--sit       = {x = 81,  y = 160},
}

minetest.register_on_joinplayer(function(player)
	cache_player = player
	sm_game.player = player
	player:set_pos(init_pos)
	player:set_properties({
		mesh = "character.b3d",
		textures = {"character.png"},
		visual = "mesh",
		visual_size = {x = 0.5, y = 0.5},
		collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3},
		stepheight = 0.6,
		eye_height = 0.4,--1.47,
	})
	player:hud_set_flags({
		hotbar = false,
		crosshair = false,
		healthbar = false,
		breathbar = false,
		wielditem = false,
		minimap = false,
		minimap_radar = false,
	})
	player:set_stars({visible = false})
	player:set_clouds({density = 0})
	player:set_sun({visible = false})
	player:set_moon({visible = false})
	player:override_day_night_ratio(1)
	player:set_formspec_prepend(table.concat({
		"bgcolor[#080808BB;both;#58AFB9]",
		"background9[5,5;1,1;gui_formbg.png;true;10]",
	}))
	player:set_inventory_formspec(table.concat({
		"formspec_version[4]",
		"size[5,5]",
		"position[1,0.5]",
		"anchor[1,0.5]",
		"no_prepend[]",
		"background9[5,5;1,1;gui_formbg.png;true;10]",
		string.format("hypertext[0.5,0.5;4.5,4.5;help;%s]", table.concat({
			"<style color=red size=20>Right / Left - Change line</style>\n",
			"<style color=red size=20>Sneak - Pass under high barriers</style>\n",
			"<style color=red size=20>Jump - Jump</style>\n",
			"<style color=red size=20>Aux1 - Use ability</style>\n",
		})),
	}))
	data.hud_ids.coin_icon = player:hud_add({
		hud_elem_type = "image",
		position = {x=0, y=0},
		name = "coin_icon",
		scale = {x = 4, y = 4},
		text = "default_mese_crystal.png",
		alignment = {x=1, y=1},
		offset = {x=20, y=20},
		size = { x=100, y=100 },
		z_index = 0,
	})
	data.hud_ids.coin_count = player:hud_add({
		hud_elem_type = "text",
		position = {x=0, y=0},
		name = "coin_icon",
		scale = {x = 4, y = 4},
		text = "00000",
		number = 0xFFFFFF,
		alignment = {x=1, y=1},
		offset = {x=80, y=25},
		size = { x=3, y=3 },
		z_index = 0,
	})
	--sm_game_button.png
	minetest.show_formspec("singleplayer", "sm_game:loading", table.concat({
		"formspec_version[4]",
		"size[20,12]",
		"hypertext[0,0;20,10;loading;<global valign=middle halign=center size=50 color=#FFFFFF>Loading...]",
	}))
end)

--close the game if the player try to quit the loading formspec
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "sm_game:loading" and fields.quit then
		minetest.request_shutdown()
	elseif formname == "sm_game:menu" then
		if fields.quit then
			minetest.request_shutdown()
		elseif fields.play then
			minetest.close_formspec("singleplayer", "sm_game:menu")
			sm_game.data.state = "game"
			sm_game.data.infos = default_infos["game"]
			sm_game.data.infos.init_gametime = os.time()
		end
	end
end)

minetest.register_entity("sm_game:player", {
	initial_properties = {
		visual = "sprite",
		textures = {"blank.png"},
		pointable = false,
		static_save = false,
	},

	walk_speed = 6,

	active = false,

	zvel = function(self)
		--TODO: reduce speed using sneak_timeout
		return self.active and (12+(os.time()-sm_game.data.infos.init_gametime)/5) or 0
		--return 5000
	end,
	on_step = function(self)
		if cache_player and sm_game.data.state == "game" and self.active then
			local pos = self.object:get_pos()
			local infos = sm_game.data.infos
			if infos.line ~= infos.target_line then
				sm_game.data.infos.is_moving = true
				if infos.line < infos.target_line then
					if pos.x > infos.target_line then
						self.object:set_velocity(vector.new(0, 0, self:zvel()))
						sm_game.data.infos.is_moving = false
						infos.line = infos.target_line
						self.object:set_pos(vector.new(infos.line, pos.y, pos.z))
					else
						self.object:set_velocity(vector.new(self.walk_speed, 0, self:zvel()))
					end
				else
					if pos.x < infos.target_line then
						self.object:set_velocity(vector.new(0, 0, self:zvel()))
						sm_game.data.infos.is_moving = false
						infos.line = infos.target_line
						self.object:set_pos(vector.new(infos.line, pos.y, pos.z))
					else
						self.object:set_velocity(vector.new(-self.walk_speed, 0, self:zvel()))
					end
				end
			end
		else
			self.object:set_velocity(vector.new(0, 0, 0))
		end
	end,
})

local function is_line_valid(line)
	return (line == -1 or line == 0 or line == 1)
end

local has_started = false

minetest.after(2, function()
	has_started = true
end)

minetest.register_globalstep(function(dtime)
	if cache_player and has_started then
		local gamestate = sm_game.data.state
		local player = minetest.get_player_by_name("singleplayer")
		local attach = player:get_attach()
		local pos = cache_player:get_pos()

		local infos = sm_game.data.infos

		if gamestate == "loading" then
			if attach then
				sm_game.data.state = "menu"
				sm_game.data.infos = default_infos["menu"]
				--sm_game.data.infos.init_gametime = os.time()
				--minetest.close_formspec("singleplayer", "sm_game:loading")
				minetest.after(0, function()
					minetest.show_formspec("singleplayer", "sm_game:menu", table.concat({
						"formspec_version[4]",
						"size[20,12]",
						"style_type[button;border=false;font_size=*2;font=bold;textcolor=#58AFB9;bgimg=sm_game_button.png;bgimg_pressed=sm_game_button_pressed.png;bgimg_middle=2,2]",
						"button[8,10;4,1;play;Play]",
					}))
				end)
			else
				cache_player:set_pos(init_pos)
				--minetest.chat_send_all("called")
				attach = minetest.add_entity(init_pos, "sm_game:player")
				player:set_attach(attach, "", vector.new(0, -5, 0), vector.new(0, 0, 0))
				local lent = attach:get_luaentity()
				lent.active = true
			end
			cache_player:set_animation(model_animations["stand"], 40, 0)
		--elseif gamestate == "menu" then

		elseif gamestate == "game" then

			local lent

			if not attach then

				minetest.log("error","[sm_game] ATTACH NOT FOUND!, creating new attachment!")

				attach = minetest.add_entity(init_pos, "sm_game:player")
				player:set_attach(attach, "", vector.new(0, -5, 0), vector.new(0, 0, 0))
				lent = attach:get_luaentity()
				lent.active = true
			else
				lent = attach:get_luaentity()
			end

			if not sm_game.data.infos.is_moving and not sm_game.data.infos.is_sneaking then
				local ctrl = cache_player:get_player_control()
				if ctrl.right then
					--minetest.chat_send_all("right")
					if is_line_valid(infos.target_line + 1) then
						--minetest.chat_send_all("rightc")
						infos.target_line = infos.target_line + 1
					end
				elseif ctrl.left then
					--minetest.chat_send_all("left")
					if is_line_valid(infos.target_line - 1) then
						--minetest.chat_send_all("leftc")
						infos.target_line = infos.target_line - 1
					end
				elseif ctrl.sneak then
					sm_game.data.infos.is_sneaking = true
					sm_game.data.infos.sneak_timeout = os.clock()
				end
			end

			if sm_game.data.infos.is_sneaking then
				if os.clock() > sm_game.data.infos.sneak_timeout + 0.5 then
					sm_game.data.infos.is_sneaking = false
					sm_game.data.infos.sneak_timeout = nil
				end
			end

			for _,obj in pairs(minetest.get_objects_inside_radius(pos, 0.9)) do
				local ent = obj:get_luaentity()
				if ent and ent.name == "sm_mapnodes:mese_coin" then
					ent:capture()
					infos.coins_count = infos.coins_count + 1
				end
			end

			infos.nodes.inside = minetest.get_node(pos).name
			--minetest.log("error", infos.nodes.inside)

			if infos.nodes.inside ~= "sm_mapnodes:rail" then
				lent.active = false
				if infos.coins_count > sm_game.api.get_highscore() then
					sm_game.api.set_highscore(infos.coins_count)
					minetest.chat_send_all("New High Score!")
				end
			end

			if sm_game.data.infos.is_sneaking then
				cache_player:set_animation(model_animations["lay"], 40, 0)
			else
				cache_player:set_animation(model_animations["walk"], 40, 0)
			end

			cache_player:hud_change(sm_game.data.hud_ids.coin_count, "text", string.format("%5.f", infos.coins_count))
		end
	end
end)

dofile(modpath.."/storage.lua")
dofile(modpath.."/builtin_modifications.lua")
dofile(modpath.."/mapgen.lua")

minetest.log("action", "[sm_game] loaded sucessfully")
minetest.log("action", "[sm_game] loading...")

--make API functions local for better performances
local minetest = minetest
local Settings = Settings

local vector = vector
local math = math
local os = os
local table = table

local pairs = pairs
--local tostring = tostring

local modpath = minetest.get_modpath("sm_game")

local settings = {
	music = minetest.settings:get_bool("subwayminer.music", true)
}

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
	--minetest.request_shutdown("Initial world setup complete, please reconnect", true, 0)
	minetest.register_on_joinplayer(function()
		minetest.kick_player("singleplayer", "\nInitial world setup complete, please reconnect")
	end)
end


--local storage = minetest.get_mod_storage()

local init_pos = vector.new(0, 1, -30900)

sm_game = {
	data = {
		state = "loading",
		infos = {},
		hud_ids = {},
	},
	api = {},
}

local sm_game = sm_game

local default_infos = {
	menu = {
		page = "main",
	},
	game_loading = {
		init_gametime = nil,
		is_sound = false,
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
		music_handler = nil,
	},
	game_end = {
		is_hud_shown = false,
		high_score = false,
		is_emerged = false,
		is_emerging = false,
		is_send = false,
	},
}

function sm_game.set_state(name, infos)
	sm_game.data.state = name
	sm_game.data.infos = table.copy(default_infos[name])
	for k,v in pairs(infos or {}) do
		sm_game.data.infos[k] = v
	end
end

local data = sm_game.data

local cache_player
--local cache_chunk

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

local wait_hud_colors = {
	0xFF0300, --red
	0xFF8000, --orange
	0xFFDB00, --yellow
	0x2AFF00, --green
}

minetest.register_on_joinplayer(function(player)
	cache_player = player
	sm_game.player = player
	cache_player:set_pos(init_pos)
	cache_player:set_properties({
		mesh         = "character.b3d",
		textures     = {"character.png"},
		visual       = "mesh",
		visual_size  = {x = 0.5, y = 0.5},
		collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3},
		stepheight   = 0.6,
		eye_height   = 0.4,--1.47,
	})
	cache_player:hud_set_flags({
		hotbar        = false,
		crosshair     = false,
		healthbar     = false,
		breathbar     = false,
		wielditem     = false,
		minimap       = false,
		minimap_radar = false,
	})
	cache_player:set_stars({visible = false})
	--cache_player:set_clouds({density = 0})
	cache_player:set_sun({visible = false})
	cache_player:set_moon({visible = false})
	cache_player:override_day_night_ratio(1)
	cache_player:set_formspec_prepend(table.concat({
		"bgcolor[#080808BB;both;#58AFB9]",
		"background9[5,5;1,1;gui_formbg.png;true;10]",
	}))
	cache_player:set_inventory_formspec(table.concat({
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
	data.hud_ids.coin_icon = cache_player:hud_add({
		hud_elem_type = "image",
		position      = {x=0, y=0},
		name          = "coin_icon",
		scale         = {x = 4, y = 4},
		text          = "default_mese_crystal.png",
		alignment     = {x=1, y=1},
		offset        = {x=20, y=20},
		size          = { x=100, y=100 },
		z_index       = 0,
	})
	data.hud_ids.coin_count = cache_player:hud_add({
		hud_elem_type = "text",
		position      = {x=0, y=0},
		name          = "coin_icon",
		scale         = {x = 4, y = 4},
		text          = "00000",
		number        = 0xFFFFFF,
		alignment     = {x=1, y=1},
		offset        = {x=90, y=24},
		size          = { x=3, y=3 },
		z_index       = 0,
	})
	data.hud_ids.title = cache_player:hud_add({
		hud_elem_type = "text",
		position      = {x = 0.5, y = 0.5},
		alignment     = {x = 0, y = -1.3},
		text          = "",
		style         = 1,
		size          = {x = 7},
		number        = 0xFFFFFF,
		z_index       = 100,
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
			sm_game.set_state("game_loading", {init_gametime = os.time()})
			cache_player:set_animation(model_animations["stand"], 40, 0)
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

	zvel = function(self)
		--TODO: reduce speed using sneak_timeout
		return (12+(os.time()-sm_game.data.infos.init_gametime)/5) or 0
		--return 5000
	end,
	on_step = function(self)
		if cache_player and sm_game.data.state == "game" then
			local cvel = vector.new(0, 0, self:zvel())
			local pos = self.object:get_pos()
			local infos = sm_game.data.infos
			if infos.line ~= infos.target_line then
				sm_game.data.infos.is_moving = true
				if infos.line < infos.target_line then
					if pos.x > infos.target_line then
						sm_game.data.infos.is_moving = false
						infos.line = infos.target_line
						self.object:set_pos(vector.new(infos.line, pos.y, pos.z))
					else
						cvel = vector.add(cvel, vector.new(self.walk_speed, 0, 0))
					end
				else
					if pos.x < infos.target_line then
						sm_game.data.infos.is_moving = false
						infos.line = infos.target_line
						self.object:set_pos(vector.new(infos.line, pos.y, pos.z))
					else
						cvel = vector.add(cvel, vector.new(-self.walk_speed, 0, 0))
					end
				end
			end
			self.object:set_velocity(cvel)
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

local main_menu = table.concat({
	"formspec_version[4]",
	"size[20,12]",
	"style_type[button;border=false;sound=sm_game_button;font_size=*2;font=bold;textcolor=#58AFB9]",
	"button[8,10;4,1;play;Play]",
	"model[0.75,0.5;7,11;playermodel;character.b3d;character.png;0,200;false;true;0,79]",
})

minetest.register_globalstep(function(dtime)
	if cache_player and has_started then
		local gamestate = sm_game.data.state
		local attach = cache_player:get_attach()
		local pos = cache_player:get_pos()

		--cache_chunk = vector.floor(vector.divide(pos, vector.new(80, 80, 80)))
		--minetest.chat_send_all(dump(cache_chunk))

		local infos = sm_game.data.infos

		if gamestate == "loading" then
			if attach then
				sm_game.set_state("menu")
				--minetest.close_formspec("singleplayer", "sm_game:loading")
				minetest.after(0, function()
					minetest.show_formspec("singleplayer", "sm_game:menu", main_menu)
				end)
			else
				cache_player:set_pos(init_pos)
				attach = minetest.add_entity(init_pos, "sm_game:player")
				cache_player:set_attach(attach, "", vector.new(0, -5, 0), vector.new(0, 0, 0))

				local itementity = minetest.add_entity(init_pos, "sm_mapnodes:pick")
				itementity:set_attach(cache_player, "Arm_Right", vector.new(0, 5.5, 3), vector.new(-90, 225, 90))
			end
			cache_player:set_animation(model_animations["stand"], 40, 0)
		elseif gamestate == "menu" then
			cache_player:set_look_horizontal(math.pi/2)
			cache_player:set_look_vertical(math.pi*3/2)
		elseif gamestate == "game_loading" then
			local time = os.time()
			local gametime = infos.init_gametime
			local ctime = time - gametime

			if not infos.is_sound then
				cache_player:set_look_vertical(math.pi*3/2)
				if settings.music and not infos.music_handler then
					infos.music_handler = minetest.sound_play({
						name = "sm_game_game_music"
					},
					{
						to_player = "singleplayer",
						gain = 0.2,
						loop = true
					}, false)
				end
				minetest.after(1, function()
					minetest.sound_play({name = "sm_game_wait"}, {to_player = "singleplayer"}, true)
				end)
				minetest.after(2, function()
					minetest.sound_play({name = "sm_game_wait"}, {to_player = "singleplayer"}, true)
				end)
				minetest.after(3, function()
					minetest.sound_play({name = "sm_game_wait", pitch = 1.5}, {to_player = "singleplayer"}, true)
				end)
				infos.is_sound = true
			end

			if ctime == 0 then
				cache_player:hud_change(data.hud_ids.coin_count, "text", "00000")
				cache_player:hud_change(data.hud_ids.title, "text", "3..")
				cache_player:hud_change(data.hud_ids.title, "number", wait_hud_colors[1])
			elseif ctime == 1 then
				cache_player:hud_change(data.hud_ids.title, "text", "2..")
				cache_player:hud_change(data.hud_ids.title, "number", wait_hud_colors[2])
			elseif ctime == 2 then
				cache_player:hud_change(data.hud_ids.title, "text", "1..")
				cache_player:hud_change(data.hud_ids.title, "number", wait_hud_colors[3])
			elseif ctime == 3 then
				cache_player:hud_change(data.hud_ids.title, "text", "Go!")
				cache_player:hud_change(data.hud_ids.title, "number", wait_hud_colors[4])
			elseif ctime == 4 then
				cache_player:hud_change(data.hud_ids.title, "text", "")
				--cache_player:set_look_vertical(math.pi*2)
				--cache_player:set_look_horizontal(math.pi)
				--cache_player:set_look_horizontal(math.pi)
				local sh = infos.music_handler
				sm_game.set_state("game", {init_gametime = os.time(), music_handler = sh})
			end
		elseif gamestate == "game" then

			if not attach then

				minetest.log("error","[sm_game] ATTACH NOT FOUND!, creating new attachment!")

				attach = minetest.add_entity(init_pos, "sm_game:player")
				cache_player:set_attach(attach, "", vector.new(0, -5, 0), vector.new(0, 0, 0))
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
					minetest.sound_play({name = "sm_game_coin"}, {to_player = "singleplayer"}, true)
					infos.coins_count = infos.coins_count + 1
				end
			end

			if sm_game.data.infos.is_sneaking then
				cache_player:set_animation(model_animations["lay"], 40, 0)
			else
				cache_player:set_animation(model_animations["walk"], 40, 0)
			end

			infos.nodes.inside = minetest.get_node(pos).name
			--minetest.log("error", infos.nodes.inside)

			if infos.nodes.inside ~= "sm_mapnodes:rail" then
				--lent.active = false
				local is_highscore = infos.coins_count > sm_game.api.get_highscore()
				if is_highscore then
					sm_game.api.set_highscore(infos.coins_count)
					minetest.chat_send_all("New High Score!")
				end
				local sh = infos.music_handler
				sm_game.set_state("game_end", {high_score = is_highscore, init_gametime = os.time(), music_handler = sh})
			end

			cache_player:hud_change(sm_game.data.hud_ids.coin_count, "text", string.format("%05.f", infos.coins_count))
		elseif gamestate == "game_end" then
			if not infos.is_hud_shown then
				cache_player:hud_change(data.hud_ids.title, "text", "Game Over")
				cache_player:hud_change(data.hud_ids.title, "number", wait_hud_colors[1])
				cache_player:set_animation(model_animations["lay"], 40, 0)
				if settings.music and infos.music_handler then
					minetest.sound_fade(infos.music_handler, 4, 0)
					infos.music_handler = nil
				end
				infos.is_hud_shown = true
			end
			if not infos.is_emerging then
				minetest.emerge_area(init_pos, init_pos, function(blockpos, action, calls_remaining, param)
					if sm_game.data.state == "game_end" then
						sm_game.data.infos.is_emerged = true
					end
				end)
				infos.is_emerging = true
			end

			if infos.is_emerged and not infos.is_send then
				infos.is_send = cache_player:send_mapblock(vector.floor(vector.divide(init_pos, vector.new(16, 16, 16))))
			end

			if infos.is_send and os.time() - infos.init_gametime > 3 then
				local obj = cache_player:get_attach()
				if obj then
					obj:set_pos(init_pos)
					cache_player:hud_change(data.hud_ids.title, "text", "")
					sm_game.set_state("menu")
					minetest.show_formspec("singleplayer", "sm_game:menu", main_menu)
				end
			end
		end
	end
end)

dofile(modpath.."/storage.lua")
dofile(modpath.."/builtin_modifications.lua")
dofile(modpath.."/mapgen.lua")

minetest.log("action", "[sm_game] loaded sucessfully")
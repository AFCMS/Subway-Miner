minetest.log("action", "[sm_game] loading...")

--make API functions local for better performances
local minetest = minetest
local Settings = Settings

local C = minetest.colorize
local F = minetest.formspec_escape

local vector = vector
local math = math
local os = os
local table = table

local pairs = pairs
local tonumber = tonumber
local tostring = tostring

local modpath = minetest.get_modpath("sm_game")

local setting_file = Settings(minetest.get_worldpath().."/sm_game.conf")

local settings = {
	music = setting_file:get_bool("subwayminer.music", true),
	speed_clipping = tonumber(setting_file:get("subwayminer.speed_clipping")) or 30
}

local function save_settings()
	setting_file:set_bool("subwayminer.music", settings.music)
	setting_file:set("subwayminer.speed_clipping", settings.speed_clipping)
	if setting_file:write() then
		minetest.log("action", "[sm_game] Config file saved sucesfully")
	else
		minetest.log("action", "[sm_game] Saving config file failed!")
	end
end

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

local init_pos = vector.new(0, 1, -30910)

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
		target_height = 0.5,
		height = 0.5,
		direction = nil,
		is_sneaking = false,
		is_jumping = false,
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

local loading_formspec = table.concat({
	"formspec_version[4]",
	"size[20,12]",
	"bgcolor[#080808BB;both;#58AFB9]",
	"hypertext[0,0;20,10;loading;<global valign=middle halign=center size=50 color=#58AFB9><b>Loading...</b>]",
})

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
		"background9[5,5;1,1;gui_formbg.png;true;10]",
	}))
	cache_player:set_inventory_formspec("")
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
		text          = "000000",
		number        = 0xFFFFFF,
		alignment     = {x=1, y=1},
		offset        = {x=90, y=24},
		size          = { x=3, y=3 },
		z_index       = 0,
	})
	data.hud_ids.coin_bg = cache_player:hud_add({
		hud_elem_type = "image",
		position      = {x=0, y=0},
		name          = "coin_bg",
		scale         = {x = 2, y = 2},
		text          = "sm_game_score_hud.png",
		alignment     = {x=1, y=1},
		offset        = {x=19, y=19},
		size          = { x=100, y=100 },
		z_index       = -1,
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
	data.hud_ids.title_bg = cache_player:hud_add({
		hud_elem_type = "image",
		position      = {x = 0.5, y = 0.5},
		name          = "title_bg",
		scale         = {x = 2, y = 2},
		text          = "blank.png",
		alignment     = {x = 0, y = -1.3},
		size          = { x=100, y=100 },
		z_index       = -1,
	})
	--[[data.hud_ids.subtitle = cache_player:hud_add({
		hud_elem_type = "text",
		position      = {x = 0.5, y = 0.6},
		alignment     = {x = 0, y = -1.3},
		text          = "",
		style         = 1,
		size          = {x = 3},
		number        = 0xFFFFFF,
		z_index       = 100,
	})]]

	minetest.show_formspec("singleplayer", "sm_game:loading", loading_formspec)
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
		return math.min((10+(os.time()-sm_game.data.infos.init_gametime)/5), settings.speed_clipping) or 0
	end,
	on_step = function(self)
		if cache_player and sm_game.data.state == "game" then
			local cvel = vector.new(0, 0, self:zvel())
			local pos = self.object:get_pos()
			local infos = sm_game.data.infos
			if infos.line ~= infos.target_line then
				infos.is_moving = true
				if infos.line < infos.target_line then
					if pos.x > infos.target_line then
						infos.is_moving = false
						infos.line = infos.target_line
						self.object:set_pos(vector.new(infos.line, pos.y, pos.z))
					else
						cvel = vector.add(cvel, vector.new(self.walk_speed, 0, 0))
					end
				else
					if pos.x < infos.target_line then
						infos.is_moving = false
						infos.line = infos.target_line
						self.object:set_pos(vector.new(infos.line, pos.y, pos.z))
					else
						cvel = vector.add(cvel, vector.new(-self.walk_speed, 0, 0))
					end
				end
			elseif infos.is_jumping then
				if not infos.jumping_state then
					infos.jumping_state = "up"
				end
				if infos.jumping_state == "up" then
					if pos.y > 3 then
						infos.jumping_state = "down"
						--self.object:set_pos(vector.new(infos.line, pos.y, pos.z))
					else
						cvel = vector.add(cvel, vector.new(0, self.walk_speed, 0))
					end
				else
					if pos.y < 1 then
						infos.is_jumping = false
						infos.jumping_state = nil
						self.object:set_pos(vector.new(infos.line, 1, pos.z))
					else
						cvel = vector.add(cvel, vector.new(0, -self.walk_speed, 0))
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

local function divmod(a, b) return math.floor(a / b), a % b end

local function format_duration(seconds)
	local display_hours, seconds_left = divmod(seconds, 3600)
	local display_minutes, display_seconds = divmod(seconds_left, 60)
	return ("%02d:%02d:%02d"):format(display_hours, display_minutes, display_seconds)
end

local has_started = false

minetest.after(2, function()
	has_started = true
end)

local main_menu_header = table.concat({
	"formspec_version[4]",
	"size[20,12]",
	"bgcolor[#080808BB;both;#58AFB9]",
	"style_type[button;border=false;sound=sm_game_button;font_size=*2;font=bold;textcolor=#58AFB9]",
})

local function get_main_menu(page)
	if page == "main" then
		local form = main_menu_header
		form = form..table.concat({
			"button[8,6;4,1;play;Play]",
			"button[8,7;4,1;options;Options]",
			"button[8,8;4,1;help;Help]",
			"button[8,9;4,1;infos;Infos]",
			"button[8,10;4,1;quit;Quit]",
			"model[0.75,0.5;7,11;playermodel;character.b3d;character.png;0,200;false;false;0,79]",
			string.format("hypertext[13,1;6,10;info_txt;%s]", table.concat({
				"<style color=#58AFB9 size=50><center><b>Stats</b></center></style>",
				"<global size=25 color=#58AFB9>",
				"<mono>Highscore:    "..string.format("%06.f", sm_game.api.get_highscore()).."</mono>\n",
				"<mono>Playcount:    "..string.format("%06.f", sm_game.api.get_playcount()).."</mono>\n",
				"<mono>Playtime:     "..format_duration(sm_game.api.get_playtime()).."</mono>\n",
			})),
		})
		return form
	elseif page == "options" then
		local form = main_menu_header
		form = form..table.concat({
			string.format("hypertext[1,0.5;18,10;help_txt;%s]", table.concat({
				"<style color=#58AFB9 size=50><center><b>Options</b></center></style>",
			})),
			"checkbox[1,2;option_music;Enable Music;"..tostring(settings.music).."]",
			"tooltip[option_music;"..F("Toggle Music").."]",
			"label[1,2.75;Player Speed Clipping]",
			"tooltip[1,2.75;4,0.25;"..F("At how much the player speed will be clipped (10-40)").."]",
			"scrollbaroptions[min=10;max=40;smallstep=1;largestep=10]",
			"scrollbar[1,3;5,0.5;<orientation>;option_speed_clipping;"..settings.speed_clipping.."]",
			"button[1,4;4.25,1;option_reset;Reset Stats]",
			"button[0,0;2,1;back;Back]",
			"button[0,11;2,1;option_save;Save]",
		})
		return form
	elseif page == "infos" then
		local form = main_menu_header
		form = form..table.concat({
			string.format("hypertext[1,0.5;18,10;help_txt;%s]", table.concat({
				"<style color=#58AFB9 size=50><center><b>Informations</b></center></style>",
				"<global size=25 color=#58AFB9>",
				"This game is inspired by Subway-Surfers and Temple Run.\n",
				"It was made by AFCM for the Minetest Game Jam 2021\n\n\n\n\n\n\n\n\n\n",
				"Licence: GPLv3\n",
				"Source Code: ",
				"<action name=link_github>https://github.com/AFCMS/Subway-Miner</action>",
			})),
			"button[0,0;2,1;back;Back]",
		})
		return form
	elseif page == "help" then
		local form = main_menu_header
		form = form..table.concat({
			string.format("hypertext[1,0.5;18,10;help_txt;%s]", table.concat({
				"<style color=#58AFB9 size=50><center><b>Help</b></center></style>",
				"<global size=25 color=#58AFB9>",
				"You drive the player between obstacles, trying to collect as many mese cristals as possible.\n",
				"Your speed increase with time.\n",
				"Move between lines using the left and right keys.\n",
				"Use the jump key to jump above small barriers.\n",
				"Use the sneak key to go under high barriers.\n\n",
				"You should turn on 3rd person view.\n",
			})),
			"button[0,0;2,1;back;Back]",
		})
		return form
	end
end

local function get_end_formspec(score, is_highscore, playtime)
	return table.concat({
		main_menu_header,
		string.format("hypertext[1,0.5;18,10;help_txt;%s]", table.concat({
			"<style color=#58AFB9 size=50><center><b>Summary</b></center></style>",
			"<global size=25 color=#58AFB9>",
			is_highscore and "<style color=#2AFF00><center><b>New Highscore!</b></center></style>" or "\n",
			"<mono>Score:        "..string.format("%06.f", score).."</mono>\n",
			"<mono>Playtime:     "..format_duration(playtime).."</mono>\n",
		})),
		"button[9,11;2,1;game_ok;Ok]",
	})
end

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
		elseif fields.options then
			minetest.show_formspec("singleplayer", "sm_game:menu", get_main_menu("options"))
		elseif fields.back then
			minetest.show_formspec("singleplayer", "sm_game:menu", get_main_menu("main"))
		elseif fields.infos then
			minetest.show_formspec("singleplayer", "sm_game:menu", get_main_menu("infos"))
		elseif fields.help then
			minetest.show_formspec("singleplayer", "sm_game:menu", get_main_menu("help"))
		elseif fields.game_ok then
			minetest.show_formspec("singleplayer", "sm_game:menu", get_main_menu("main"))
		elseif fields.option_music == "false" then
			settings.music = false
		elseif fields.option_music == "true" then
			settings.music = true
		elseif fields.option_reset then
			sm_game.api.set_highscore(0)
			sm_game.api.set_playtime(0)
			sm_game.api.set_playcount(0)
		elseif fields.option_save then
			save_settings()
		elseif fields.option_speed_clipping then
			local e = minetest.explode_scrollbar_event(fields.option_speed_clipping)
			if e.type == "CHG" then
				settings.speed_clipping = e.value
			end
		elseif fields.help_txt == "action:link_github" then
			minetest.chat_send_all(C("green", "Source Code: https://github.com/AFCMS/Subway-Miner"))
		end
	end
end)

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
					minetest.show_formspec("singleplayer", "sm_game:menu", get_main_menu("main"))
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
			cache_player:set_look_horizontal(0)
			cache_player:set_look_vertical(-math.pi/2)
		elseif gamestate == "game_loading" then
			local time = os.time()
			local gametime = infos.init_gametime
			local ctime = time - gametime

			if not infos.is_sound then
				cache_player:set_look_horizontal(0)
				cache_player:set_look_vertical(0)
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
				cache_player:hud_change(data.hud_ids.coin_count, "text", "000000")
				cache_player:hud_change(data.hud_ids.title, "text", "3..")
				cache_player:hud_change(data.hud_ids.title, "number", wait_hud_colors[1])
				cache_player:hud_change(data.hud_ids.title_bg, "text", "sm_game_title_hud.png")
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
				cache_player:hud_change(data.hud_ids.title_bg, "text", "blank.png")
				local sh = infos.music_handler
				sm_game.set_state("game", {init_gametime = os.time(), music_handler = sh})
			end
		elseif gamestate == "game" then

			if not attach then

				minetest.log("error","[sm_game] ATTACH NOT FOUND!, creating new attachment!")

				attach = minetest.add_entity(init_pos, "sm_game:player")
				cache_player:set_attach(attach, "", vector.new(0, -5, 0), vector.new(0, 0, 0))
			end

			if not infos.is_moving and not infos.is_sneaking and not infos.is_jumping then
				local ctrl = cache_player:get_player_control()
				if ctrl.right then
					if is_line_valid(infos.target_line + 1) then
						infos.target_line = infos.target_line + 1
					end
				elseif ctrl.left then
					if is_line_valid(infos.target_line - 1) then
						infos.target_line = infos.target_line - 1
					end
				elseif ctrl.sneak then
					infos.is_sneaking = true
					infos.sneak_timeout = os.clock()
				elseif ctrl.jump then
					infos.is_jumping = true
					infos.target_height = 2
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
					obj:remove()
					minetest.sound_play({name = "sm_game_coin"}, {to_player = "singleplayer"}, true)
					infos.coins_count = infos.coins_count + 1
				end
			end

			if sm_game.data.infos.is_sneaking then
				cache_player:set_animation(model_animations["lay"], 40, 0)
			else
				cache_player:set_animation(model_animations["walk"], 40, 0)
			end

			infos.nodes.inside = minetest.get_node(vector.new(infos.line, 1, pos.z)).name

			local obstacle_state = minetest.get_item_group(infos.nodes.inside, "obstacle")

			if obstacle_state ~= 0 then
				local is_crash = false
				if obstacle_state == 1 then
					is_crash = true
				elseif obstacle_state == 2 then
					if not infos.is_jumping then
						is_crash = true
					end
				elseif obstacle_state == 3 then
					if not infos.is_sneaking then
						is_crash = true
					end
				end
				if is_crash then
					local is_highscore = infos.coins_count > sm_game.api.get_highscore()
					if is_highscore then
						sm_game.api.set_highscore(infos.coins_count)
					end
					sm_game.api.set_playtime(sm_game.api.get_playtime() + (os.time() - infos.init_gametime))
					sm_game.api.set_playcount(sm_game.api.get_playcount() + 1)
					local sh = infos.music_handler

					--remove all existing coins
					for _,l in pairs(minetest.luaentities) do
						if l.name == "sm_mapnodes:mese_coin" then
							l.object:remove()
						end
					end

					sm_game.set_state("game_end", {
						playtime = os.time() - infos.init_gametime,
						score = infos.coins_count,
						high_score = is_highscore,
						init_gametime = os.time(),
						music_handler = sh,
					})
				end
			end

			cache_player:hud_change(sm_game.data.hud_ids.coin_count, "text", string.format("%06.f", infos.coins_count))
		elseif gamestate == "game_end" then
			if not infos.is_hud_shown then
				cache_player:hud_change(data.hud_ids.title, "text", "Game Over")
				cache_player:hud_change(data.hud_ids.title, "number", wait_hud_colors[1])
				cache_player:hud_change(data.hud_ids.title_bg, "text", "sm_game_title_hud.png")
				cache_player:set_animation(model_animations["lay"], 40, 0)
				if settings.music and infos.music_handler then
					minetest.sound_fade(infos.music_handler, 4, 0)
					infos.music_handler = nil
				end
				--[[if infos.high_score then
					cache_player:hud_change(data.hud_ids.subtitle, "text", "New Highscore!")
					cache_player:hud_change(data.hud_ids.subtitle, "number", wait_hud_colors[4])
				end]]
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
					--cache_player:hud_change(data.hud_ids.subtitle, "text", "")
					cache_player:hud_change(data.hud_ids.title_bg, "text", "blank.png")
					sm_game.set_state("menu")
					minetest.show_formspec("singleplayer", "sm_game:menu",
						get_end_formspec(infos.score, infos.high_score, infos.playtime))
				end
			end
		end
	end
end)

minetest.register_abm({
	label = "Coins Spawning",
	nodenames = {"sm_mapnodes:rail"},
	interval = 3,
	chance = 20,
	min_y = 1,
    max_y = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		if data.state == "game" then
			minetest.add_entity(pos, "sm_mapnodes:mese_coin")
		end
	end,
})

dofile(modpath.."/storage.lua")
dofile(modpath.."/builtin_modifications.lua")
dofile(modpath.."/mapgen.lua")

minetest.log("action", "[sm_game] loaded sucessfully")
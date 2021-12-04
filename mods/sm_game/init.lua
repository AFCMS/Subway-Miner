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
	--minetest.request_shutdown("Intial world setup complete, please reconnect",true,0)
	minetest.register_on_joinplayer(function()
		minetest.kick_player("singleplayer", "\nInitial world setup complete, please reconnect")
	end)
end


--local storage = minetest.get_mod_storage()

sm_game = {
	player_data = {
		object = nil,
		state = "menu",
		infos = {},
		hud_ids = {},
	},
}

function sm_game.set_state(name, infos)
	sm_game.player_data.state = name
	sm_game.player_data.infos = infos
end

local player_data = sm_game.player_data

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
		hotbar = false, --temp
		crosshair = true, --temp
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
	player:set_inventory_formspec(table.concat({
		"formspec_version[4]",
		"size[5,5]",
		"position[1,0.5]",
		"anchor[1,0.5]",
		string.format("hypertext[0.5,0.5;4.5,4.5;help;%s]", table.concat({
			"<style color=red size=20>Right / Left - Change line</style>\n",
			"<style color=red size=20>Sneak - Pass under high barriers</style>\n",
			"<style color=red size=20>Jump - Jump</style>\n",
			"<style color=red size=20>Aux1 - Use ability</style>\n",
		})),
	}))
	player_data.hud_ids.coin_icon = player:hud_add({
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
	player_data.hud_ids.coin_count = player:hud_add({
		hud_elem_type = "text",
		position = {x=0, y=0},
		name = "coin_icon",
		scale = {x = 4, y = 4},
		text = "000000",
		number = 0xFFFFFF,
		alignment = {x=1, y=1},
		offset = {x=80, y=25},
		size = { x=3, y=3 },
		z_index = 0,
	})
end)

minetest.register_entity("sm_game:player", {
	initial_properties = {
		visual = "sprite",
		textures = {"blank.png"},
		pointable = true, --tmp
		static_save = false,
	},

	walk_speed = 6,

	active = false,
	is_moving = false,
	is_sneaking = false,

	sneak_timeout = nil,

	target_line = 0, --x axis
	line = 0,
	direction = nil,

	zvel = function(self)
		--TODO: reduce speed using sneak_timeout
		return self.active and 8 or 0
	end,

	is_line_valid = function(self, line)
		return (line == -1 or line == 0 or line == 1)
	end,

	sneak = function(self)
		self.is_sneaking = true
		self.sneak_timeout = os.clock()
		minetest.chat_send_all("sneak")
	end,

	end_sneak = function(self)
		self.is_sneaking = false
		self.sneak_timeout = nil
		minetest.chat_send_all("end sneak")
	end,

	walk = {
		start = {
			right = function(self)
				if self:is_line_valid(self.target_line + 1) then
					self.target_line = self.target_line + 1
					self.object:set_velocity({x=self.walk_speed, y=0, z=self:zvel()})
					self.direction = "right"
					self.is_moving = true
				end
			end,
			left = function(self)
				if self:is_line_valid(self.target_line - 1) then
					self.target_line = self.target_line - 1
					self.object:set_velocity({x=-self.walk_speed, y=0, z=self:zvel()})
					self.direction = "left"
					self.is_moving = true
				end
			end,
		},
		stop = {
			right = function(self)
				local pos = self.object:get_pos()
				if self.target_line and pos.x >= self.target_line then
					self.object:set_velocity({x=0, y=0, z=self:zvel()})
					self.direction = nil
					self.object:set_pos({x=self.target_line, y=pos.y, z=pos.z})
					self.is_moving = false
				end
			end,
			left = function(self)
				local pos = self.object:get_pos()
				if self.target_line and pos.x <= self.target_line then
					self.object:set_velocity({x=0, y=0, z=self:zvel()})
					self.direction = nil
					self.object:set_pos({x=self.target_line, y=pos.y, z=pos.z})
					self.is_moving = false
				end
			end,
		},
	},

	on_step = function(self)
		local pos = self.object:get_pos()
		--minetest.chat_send_all(pos.x)

		if cache_player then
			--cache_player:set_look_vertical(math.pi/2)
			--cache_player:set_look_horizontal(math.pi)
			if self.active then
				if self.is_sneaking then
					cache_player:set_animation(model_animations["lay"], 30, 0)
				else
					cache_player:set_animation(model_animations["walk"], 40, 0)
				end
			else
				cache_player:set_animation(model_animations["stand"], 30, 0)
			end
			if not self.is_sneaking then
				local ctrl = cache_player:get_player_control()

				if not self.is_moving then
					if ctrl.right then
						self.walk.start.right(self)
					elseif ctrl.left then
						self.walk.start.left(self)
					elseif ctrl.sneak then
						self:sneak()
					end
				end
				if self.direction ~= nil then
					self.walk.stop[self.direction](self)
					return
				end
				--minetest.chat_send_all(self.target_line)
			else
				minetest.chat_send_all(string.format("os.clock=%s, sneak_timeout=%s", os.clock(), self.sneak_timeout))
				if os.clock() > self.sneak_timeout + 0.5 then
					self:end_sneak()
				end
			end
		else
			sm_game.set_state("menu", {})
			self.object:remove()
		end
		for _,obj in pairs(minetest.get_objects_inside_radius(pos, 0.9)) do
			local ent = obj:get_luaentity()
			if ent and ent.name == "sm_mapnodes:mese_coin" then
				ent:capture(self.object)
				player_data.infos.coins_count = player_data.infos.coins_count + 1
				--minetest.chat_send_all("captured! ("..player_data.infos.coins_count..")")
			end
		end
	end,
	on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		if not self.active then self.active = true return end
		self.object:remove()
		sm_game.set_state("menu", {})
		if cache_player then
			cache_player:set_look_horizontal(3/4 * math.pi)
			cache_player:set_animation(model_animations["stand"], 30, 0)
		end
	end,
})

minetest.register_globalstep(function()
	if cache_player then
		if player_data.state == "game" then
			cache_player:hud_change(player_data.hud_ids.coin_count, "text", string.format("%05.f", player_data.infos.coins_count))
		end
	end
end)

minetest.register_chatcommand("a", {
	func = function()
		cache_player:set_pos(vector.new(0,1,-30900))
		local obj = minetest.add_entity(vector.new(0,1,-30900), "sm_game:player")
		--obj:get_luaentity().player = "singleplayer"
		if obj then
			cache_player:set_attach(obj, "", {x = 0, y = -5, z = 0}, {x = 0, y = 0, z = 0})
			sm_game.set_state("game", {
				coins_count = 0,
				score = 0,
				fake_player = obj,
			})
			return true, "Sucess"
		else
			return false, "Spawning object failed!"
		end
	end,
})

dofile(modpath.."/commands.lua")
dofile(modpath.."/mapgen.lua")

minetest.log("action", "[sm_game] loaded sucessfully")
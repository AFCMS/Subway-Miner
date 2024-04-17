local storage = minetest.get_mod_storage()

---@return integer
function sm_game.api.get_highscore()
	return storage:get_int("high_score")
end

---@param val integer
function sm_game.api.set_highscore(val)
	storage:set_int("high_score", val)
end

---@return integer
function sm_game.api.get_playtime()
	return storage:get_int("playtime")
end

---@param val integer
function sm_game.api.set_playtime(val)
	storage:set_int("playtime", val)
end

---@return integer
function sm_game.api.get_playcount()
	return storage:get_int("playcount")
end

---@param val integer
function sm_game.api.set_playcount(val)
	storage:set_int("playcount", val)
end

---@param val integer
function sm_game.api.set_coin_count(val)
	storage:set_int("coins", val)
end

---@return integer
function sm_game.api.get_coin_count()
	return storage:get_int("coins")
end

---@class achievement_definition: table
---@field icon string
---@field rarity integer
---@field description string
---@field long_description string

---@type table<string, true>
---@diagnostic disable-next-line: assign-type-mismatch
sm_game.api.player_achievements = minetest.parse_json(storage:get_string("achievements")) or {}

---@type table<string, achievement_definition>
sm_game.api.achievements = {}

---@param name string
---@param def achievement_definition
function sm_game.api.register_achievement(name, def)
	sm_game.api.achievements[name] = def
end

---@param name string
function sm_game.api.grant_achievement(name)
	sm_game.api.player_achievements[name] = true
end

minetest.register_on_shutdown(function()
	storage:set_string("achievements", assert(minetest.write_json(sm_game.api.player_achievements)))
end)

sm_game.api.register_achievement("first", {
	icon = "default_mese_crystal.png",
	rarity = 0,
	description = "First Run",
	long_description = "Run for the first time ever",
})

sm_game.api.register_achievement("death_bumber", {
	icon = "default_mese_crystal.png",
	rarity = 1,
	description = "Fatal Bumper",
	long_description = "Die by hitting a bumper",
})

sm_game.api.register_achievement("death_train", {
	icon = "default_mese_crystal.png",
	rarity = 1,
	description = "Fatal Train",
	long_description = "Die by hitting a train",
})

sm_game.api.register_achievement("100coins", {
	icon = "default_mese_crystal.png",
	rarity = 2,
	description = "100 Coins",
	long_description = "Collect 100 coins in a single run",
})

sm_game.api.register_achievement("adict", {
	icon = "default_mese_crystal.png",
	rarity = 8,
	description = "Adict.",
	long_description = "Run 100 times",
})

sm_game.api.register_achievement("1000coins", {
	icon = "default_mese_crystal.png",
	rarity = 10,
	description = "1000 Coins",
	long_description = "Collect 1000 coins in a single run",
})

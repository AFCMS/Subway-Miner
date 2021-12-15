local storage = minetest.get_mod_storage()

function sm_game.api.get_highscore()
	return storage:get_int("high_score")
end

function sm_game.api.set_highscore(val)
	storage:set_int("high_score", val)
end
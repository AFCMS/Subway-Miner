local get_connected_players = minetest.get_connected_players
local clock = os.clock

local pairs = pairs

controls = {}
controls.players = {}
local players = controls.players

controls.registered_on_press = {}
local registered_on_press = controls.registered_on_press
function controls.register_on_press(func)
	controls.registered_on_press[#controls.registered_on_press+1] = func
end

controls.registered_on_release = {}
local registered_on_release = controls.registered_on_release
function controls.register_on_release(func)
	controls.registered_on_release[#controls.registered_on_release+1] = func
end

controls.registered_on_hold = {}
local registered_on_hold = controls.registered_on_hold
function controls.register_on_hold(func)
	controls.registered_on_hold[#controls.registered_on_hold+1]=func
end

local known_controls = {
	jump = true,
	right = true,
	left = true,
	LMB = true,
	RMB = true,
	sneak = true,
	aux1 = true,
	down = true,
	up = true,
}

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	players[name] = {}
	for cname,_ in pairs(known_controls) do
		players[name][cname] = { false }
	end
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	players[name] = nil
end)

minetest.register_globalstep(function(dtime)
	for _, player in pairs(get_connected_players()) do
		local player_name = player:get_player_name()
		local player_controls = player:get_player_control()
		if players[player_name] then
			for cname, cbool in pairs(player_controls) do
				if known_controls[cname] == true then
					--Press a key
					if cbool == true and players[player_name][cname][1] == false then
						for _, func in pairs(registered_on_press) do
							func(player, cname)
						end
						players[player_name][cname] = {true, clock()}
					elseif cbool == true and players[player_name][cname][1] == true then
						for _, func in pairs(registered_on_hold) do
							func(player, cname, clock()-players[player_name][cname][2])
						end
					--Release a key
					elseif cbool == false and players[player_name][cname][1] == true then
						for _, func in pairs(registered_on_release) do
							func(player, cname, clock()-players[player_name][cname][2])
						end
						players[player_name][cname] = {false}
					end
				end
			end
		end
	end
end)

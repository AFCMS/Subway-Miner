minetest.register_on_mods_loaded(function()
	for name in pairs(minetest.registered_chatcommands) do
		if name ~= "profiler" and name ~= "status" then
			minetest.unregister_chatcommand(name)
		end
	end
end)

function minetest.handle_node_drops()
end

function minetest.calculate_knockback()
	return 0
end
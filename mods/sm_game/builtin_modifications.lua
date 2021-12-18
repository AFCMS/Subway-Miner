minetest.register_on_mods_loaded(function()
	--unregister all chatcommands except monitoring ones that are used for debugging
	for name in pairs(minetest.registered_chatcommands) do
		if name ~= "profiler" and name ~= "status" then
			minetest.unregister_chatcommand(name)
		end
	end

	--make all nodes not pointable to hide their borders ingame
	for name in pairs(minetest.registered_nodes) do
		minetest.override_item(name, {pointable = false, diggable = false})
	end
end)

function minetest.handle_node_drops()
end

function minetest.calculate_knockback()
	return 0
end
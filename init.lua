-- internationalization boilerplate
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

lib_sfinv_map = {}

-- GET NAMES AND PATHS TO ENSURE CORRECT MAP IS USED
local worldPath = minetest.get_worldpath()
local worldName = string.gsub(worldPath, "(.*worlds.)(.*)", "%2")
local worldsqlName = worldPath.. "/map.sqlite"

if not file_exists(worldsqlName) then
	return 0
end

local curModPath = minetest.get_modpath('lib_sfinv_map')
local texPath = curModPath.. "/textures/"
local dummyFilePName = texPath.. "mapit.png"
local mapFileName = worldName:gsub("%s+", "_").. ".png"
local mapFilePName = texPath.. mapFileName


function updateMap(player)

	local pname = player:get_player_name()
	
	if minetest.check_player_privs(pname, {creative=true}) then
	
		local osx = "map " .. worldPath .. " " .. mapFilePName
		os.execute(osx)
		minetest.chat_send_player(pname, "lib_sfinv_map: Map is updating for ".. worldName)

	else
		minetest.chat_send_player(pname, "You do not have sufficient privileges to use this tool.")
		return false
	end

end

function generateFormSpec()
	-- GENERATE THE FORM AND DISPLAY IT
        mapitFormspecBasic =  "size[12,12]" ..
 			"image[0.5,0.5;13,13;"..worldName:gsub("%s+", "_")..".png]"
	return mapitFormspecBasic
end

function map_handler_maptool (itemstack, user, pointed_thing)
	local mapitPlayerName=user:get_player_name()
	generateFormSpec(mapitPlayerName)
	minetest.show_formspec(mapitPlayerName, "lib_sfinv_map:maptool", mapitFormspecBasic)
end

minetest.register_node('lib_sfinv_map:map_table', {
	description = "Map Table",
	drawtype = "nodebox",
	tiles = {
		string.gsub(string.gsub(minetest.get_worldpath(), "(.*worlds.)(.*)", "%2"),"%s+", "_")..".png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",		
	},
	sunlight_propagates = false,
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	walkable = true,
	groups = { cracky = 3, wall = 1, stone = 2 },
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, 0.375, -0.5, 0.5, 0.5, 0.5}, -- NodeBox1
			{-0.375, -0.5, -0.375, -0.25, 0.375, -0.25}, -- NodeBox3
			{0.25, -0.5, -0.375, 0.375, 0.375, -0.25}, -- NodeBox5
			{-0.375, -0.5, 0.25, -0.25, 0.375, 0.375}, -- NodeBox6
			{0.25, -0.5, 0.25, 0.375, 0.375, 0.375}, -- NodeBox7
		},
	},
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end

		local p0 = pointed_thing.under
		local p1 = pointed_thing.above
		local param2 = 0

		local placer_pos = placer:getpos()
		if placer_pos then
			local dir = {
				x = p1.x - placer_pos.x,
				y = p1.y - placer_pos.y,
				z = p1.z - placer_pos.z
			}
			param2 = minetest.dir_to_facedir(dir)
		end

		if p0.y-1 == p1.y then
			param2 = param2 + 20
			if param2 == 21 then
				param2 = 23
			elseif param2 == 23 then
				param2 = 21
			end
		end

		return minetest.item_place(itemstack, placer, pointed_thing, param2)
	end,
})

minetest.register_node('lib_sfinv_map:wallmap', {
	description = "Wall Map",
	drawtype = "nodebox",
	tiles = {
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",		
		string.gsub(string.gsub(minetest.get_worldpath(), "(.*worlds.)(.*)", "%2"),"%s+", "_")..".png",
	},
	sunlight_propagates = false,
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	walkable = true,
	groups = { cracky = 3, wall = 1, stone = 2 },
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.437, 0.5, 0.5, 0.5}, -- NodeBox1
		},
	},
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end

		local p0 = pointed_thing.under
		local p1 = pointed_thing.above
		local param2 = 0

		local placer_pos = placer:getpos()
		if placer_pos then
			local dir = {
				x = p1.x - placer_pos.x,
				y = p1.y - placer_pos.y,
				z = p1.z - placer_pos.z
			}
			param2 = minetest.dir_to_facedir(dir)
		end

		if p0.y-1 == p1.y then
			param2 = param2 + 20
			if param2 == 21 then
				param2 = 23
			elseif param2 == 23 then
				param2 = 21
			end
		end

		return minetest.item_place(itemstack, placer, pointed_thing, param2)
	end,
})

minetest.register_tool("lib_sfinv_map:maphud", {
	description = "Map HUD",
	inventory_image = "mapsettings.png",
	on_use = function(itemstack, user, pointed_thing)
		map_handler_maptool(itemstack,user,pointed_thing)
	end,
})

--[[
minetest.register_tool("lib_sfinv_map:maptool", {
	description = "Map Tool",
	inventory_image = string.gsub(string.gsub(minetest.get_worldpath(), "(.*worlds.)(.*)", "%2"),"%s+", "_")..".png",
	on_use = function(itemstack, user, pointed_thing)
		map_handler_maptool(itemstack,user,pointed_thing)
	end,
})

minetest.register_tool("lib_sfinv_map:mapper", {
	description = "Map Generator",
	inventory_image = "mapsettings.png",
	on_use = function(itemstack, user, pointed_thing)
		updateMap(user)
	end,
})
--]]

if minetest.get_modpath("sfinv") == nil then

	minetest.log("warning", S("lib_sfinv_map: Mod loaded but unused."))
	return
end

-- GET NAMES AND PATHS TO ENSURE CORRECT MAP IS USED
local worldPath = minetest.get_worldpath()
local worldName = string.gsub(worldPath, "(.*worlds.)(.*)", "%2")

local mapFileName = worldName:gsub("%s+", "_").. ".png"

sfinv.register_page("lib_sfinv_map:map", {
	title = S("World Map"),
	get = function(self, player, context)
		local name = player:get_player_name()
		local formspec = "image[0.0,0.1;9.5,9.5;"..mapFileName.."]"
		return sfinv.make_formspec(player, context, formspec, false)
	end,
})

lib_sfinv_map.register_on_update = (function(player)
	if sfinv.enabled then
		sfinv.set_player_inventory_formspec(player)
	end
end)


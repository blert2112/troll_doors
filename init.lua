
troll_doors = {}

local waiting = {}

local get_random_pos = function()
	local pos = {
		x = math.random(-31000, 31000),
		y = 0,
		z = math.random(-31000, 31000)
	}
	return pos
end

local lock_player = function(pos, player)
	local ent = minetest.add_entity(pos, "troll_doors:lock")
	player:set_attach(ent, "", {x=0, y=0, z=0}, {x=0, y=0, z=0})
	return ent
end


local count = 0
--local lock_ent_track = 0
minetest.register_globalstep(function(dtime)
	-- timer, every second
	count = count + dtime
	if count < 3 then
		return
	end
	count = 0

	local wait_count = #waiting
	if wait_count == 0 then
		return
	end
print("WAITING: "..wait_count)

	local working = waiting[1]
	local minp = {
		x = working.to_pos.x-1,
		y = -300,
		z = working.to_pos.z-1
	}
	local maxp = {
		x = working.to_pos.x+1,
		y = 300,
		z = working.to_pos.z+1
	}
print("MINp: "..minetest.pos_to_string(minp))
print("MAXp: "..minetest.pos_to_string(maxp))
	
--	local c_air = minetest.get_content_id("air")
--	local c_ignore = minetest.get_content_id("ignore")
--	local vm = minetest.get_voxel_manip()
--	local emin, emax = vm:read_from_map(minp, maxp)
--	local area = VoxelArea:new{MinEdge = emin, MaxEdge = emax}
--	local data = vm:get_data()
--	local x = working.to_pos.x
--	local z = working.to_pos.z
--	local positions = {}
--	for y = -300, 297, 1 do
--		local node1 = data[area:index(x, y, z)]
--		local node2 = data[area:index(x, y+1, z)]
--		local node3 = data[area:index(x, y+2, z)]
--		if node3 == c_air and node2 == c_air then
--			if node1 ~= c_air and node ~= c_ignore then
--				table.insert(positions, {x = x, y = y, z = z})
--			end
--		end
--	end

	local positions = minetest.find_nodes_in_area_under_air(minp, maxp, {"group:cracky", "group:crumbly"})
	local pos_count = #positions
print("FOUND "..pos_count.." positions. ")
	
	if pos_count == 0 then
		waiting[1].to_pos = get_random_pos()
		working.lock_ent:moveto(waiting[1].to_pos, {continuous=false})
		return
	end
	local selected_pos = positions[math.random(pos_count)]
	selected_pos = {
		x=selected_pos.x,
		y=selected_pos.y + 1,
		z=selected_pos.z
	}
print("SELECTED POSITION: "..minetest.pos_to_string(selected_pos))
	
	working.lock_ent:setpos(selected_pos)
		
	minetest.after(0.2, function(p, o)
		p:set_detach()
		o:remove()
	end, working.player, working.lock_ent)
		
	-- remove waiting player from table
	table.remove(waiting, 1)

end)

minetest.register_node("troll_doors:temp", {
	description = "TD example",
	tile_images = {"default_diamond_block.png"},
	light_source = light,
	groups = {cracky=3},
	sounds = default.node_sound_glass_defaults()
})

minetest.register_abm({
	nodenames = {"troll_doors:temp"},
	neighbors = {},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local all_objects = minetest.get_objects_inside_radius(pos,1)
		for _,obj in ipairs(all_objects) do
			if obj:is_player() then
				local to_pos = get_random_pos()
				local lock_ent = lock_player(to_pos, obj)
				table.insert(waiting, {
					player = obj,
					lock_ent = lock_ent,
					to_pos = to_pos,
					orig_pos = pos
				})
			end
		end
	end
})

-- borrowed from the world_edge mod
minetest.register_entity("troll_doors:lock", {
	is_visible = false
})

--[[
		if waiting[1].ready then
			print("checking position!!!!!!!!!!!!!!!!!!!!!!!!!!!")
			local node1 = minetest.get_node_or_nil({x=waiting[1].to_pos.x, y=waiting[1].to_pos.y+1.5, z=waiting[1].to_pos.z})
			local node2 = minetest.get_node_or_nil({x=waiting[1].to_pos.x, y=waiting[1].to_pos.y+2.5, z=waiting[1].to_pos.z})
			if node1.name == "air" and node2.name == "air" then
				print("moving player!!!!!!!!!!!!!!!!!!!!!!!!!!!")
				waiting[1].player:set_detach()
				waiting[1].lock_ent:remove()
				waiting[1].player:setpos({x=waiting[1].to_pos.x,y=waiting[1].to_pos.y+0.5,z=waiting[1].to_pos.z})
				table.remove(waiting, 1)
			else
				print("resetting pos to nil!!!!!!!!!!!!!!!!!!!!!!!!!!! TOP")
				waiting[1].to_pos = nil
				waiting[1].ready = false
			end
			return
		end

		if lock_ent_track == 0 then
			print("moving ent!!!!!!!!!!!!!!!!!!!!!!!!!!!")
			waiting[1].lock_ent:moveto(waiting[1].to_pos, {continuous=false})
			lock_ent_track = 1
			return
		end

		
		local pos_count = #positions
		if pos_count > 0 then
			local sele = math.random(pos_count)
			local pos = positions[sele]
			print(minetest.pos_to_string(pos).."  selected pos!!!!!!!!!!!!!!!!!!!!!!!!!!!")
			waiting[1].to_pos = pos
			waiting[1].ready = true
		else
			print("resetting pos to nil!!!!!!!!!!!!!!!!!!!!!!!!!!! BOTTOM")
			waiting[1].to_pos = nil
		end
	end
]]

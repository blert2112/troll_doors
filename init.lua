
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
local lock_ent_track = 0
minetest.register_globalstep(function(dtime)
	-- timer, every second
	count = count + dtime
	if count < 1 then
		return
	end
	count = 0

	if waiting[1] then
		print("waiting!!!!!!!!!!!!!!!!!!!!!!!!!!!")

		if waiting[1].to_pos == nil then
			print("getting pos!!!!!!!!!!!!!!!!!!!!!!!!!!!")
			local to_pos = get_random_pos()
			waiting[1].to_pos = to_pos
			lock_ent_track = 0
		end
		
		if waiting[1].lock_ent == nil then
			print("getting ent!!!!!!!!!!!!!!!!!!!!!!!!!!!")
			local lock_ent = lock_player(waiting[1].to_pos, waiting[1].player)
			waiting[1].lock_ent = lock_ent
			lock_ent_track = 1
			return
		end
		
		if lock_ent_track == 0 then
			print("moving ent!!!!!!!!!!!!!!!!!!!!!!!!!!!")
			waiting[1].lock_ent:moveto(waiting[1].to_pos, {continuous=false})
			lock_ent_track = 1
			return
		end

		print("finding positions!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		local positions = minetest.find_nodes_in_area_under_air(
			{x=waiting[1].to_pos.x-0.5, y=-300, z=waiting[1].to_pos.z-0.5},
			{x=waiting[1].to_pos.x+0.5, y=300, z=waiting[1].to_pos.z+0.5},
			{"group:cracky", "group:crumbly"}
		)
		
		local pos_count = #positions
		if pos_count > 0 then
			local sele = math.random(pos_count)
			local pos = positions[sele]
			print(minetest.pos_to_string(pos).."  selected pos!!!!!!!!!!!!!!!!!!!!!!!!!!!")
			print("checking position!!!!!!!!!!!!!!!!!!!!!!!!!!!"..pos_count)
			local node1 = minetest.get_node_or_nil({x=pos.x, y=pos.y+1.5, z=pos.z})
			local node2 = minetest.get_node_or_nil({x=pos.x, y=pos.y+2.5, z=pos.z})
			if node1.name == "air" and node2.name == "air" then
				print("moving player!!!!!!!!!!!!!!!!!!!!!!!!!!!")
				waiting[1].player:set_detach()
				waiting[1].lock_ent:remove()
				waiting[1].player:setpos({x=pos.x,y=pos.y+0.5,z=pos.z})
				table.remove(waiting, 1)
			end
		else
			print("resetting pos to nil!!!!!!!!!!!!!!!!!!!!!!!!!!!")
			waiting[1].to_pos = nil
		end
	end
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
	interval = 0.25,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local all_objects = minetest.get_objects_inside_radius(pos,1)
		for _,obj in ipairs(all_objects) do
			if obj:is_player() then
				--local pname = obj:get_player_name()
				--waiting[pname] = {player = obj}
				table.insert(waiting, {player = obj})
			end
		end
	end
})

-- borrowed from the world_edge mod
minetest.register_entity("troll_doors:lock", {
	initial_properties = {
		is_visible = false
	},
	on_activate = function(staticdata, dtime_s)
		--self.object:set_armor_groups({immortal = 1})
	end
})


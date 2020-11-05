function initGlobals()
	--[[
	## Table of obstacles
	
	This table contains tables which hold the name of the obstacle, their
	paramaters, and the value ranges for their paramaters. Not all of this info
	is used at the moment, but it is helpful to have a layout for everything.
	
	```lua
	The format is the following:
	{
		"name" = obstaclename                  -- The name of the obstacle
		"params" = {                           -- A table of paramaters
			{param_name, param_type, [param_max, param_min], [param_vals]},
			{param_name, param_type, [param_max, param_min], [param_vals]}
		}
	}
	```
	]]
-- 	obstacles = {
-- 		-- stack of glass cubes
-- 		{
-- 			"name" = "pyramid",
-- 			"params" = {
-- 				{"material", "string", {"metal", "glass"}}, 
-- 				{"levels", "int", 3, 5},
-- 				{"size", "float", 0.10, 0.25}
-- 			}
-- 		}
-- 	}
	
	-- Init the obstacle and crystal tables
	crystals = {"scorediamond", "scoremulti", "scorestar", "scoretop"}
	
	-- List of obstacles used during alpha room versions
	test_obstacles = {"pyramid", "bar", "3dcross", "babytoy", "beatmill", "rotor", "tree"}
	
	-- Room size
	room_size = {12, 10, 0}
	room_size[3] = mgRndInt(50, 250)
	
	-- Room color
	room_color = {0.0, 0.0, 0.0}
	room_color[1] = mgRndFloat(-0.35, 1.35)
	room_color[2] = mgRndFloat(-0.35, 1.35)
	room_color[3] = mgRndFloat(-0.35, 1.35)
	
	-- Room width (controls where walls are)
	-- {[width of walls from player from center], [ceiling height], [floor depth]}
	room_walls = {0.0, 0.0, 0.0}
	room_walls[1] = mgRndInt(4, 10) / 2
	room_walls[2] = mgRndInt(6, 18) / 2
	room_walls[3] = mgRndInt(-8, -2) / 2
	
	-- The clearance width of the room
	clearance_width = mgRndInt(2, 4)
end

--
-- Helper functions
--

function getRndFrom(e)
	-- Return a random value from some table
	return e[math.random(#e)]
end

function getRndNegitise(n, force)
	if mgRndBool() then
		return -n
	else
		return n
	end
end

function getRndBoxPos()
	-- Return a table with a random and safe box position
	local t = {0, 0, 0}
	
	-- x-axis
-- 	while not t[1] or t[1] > -clearance_width or t[1] < clearance_width do
		t[1] = mgRndFloat(-6, 6)
-- 	end
	
	-- y-axis
-- 	while not t[2] or t[2] > -clearance_width or t[2] < clearance_width do
		t[2] = mgRndFloat(-3, 4)
-- 	end
	
	-- z-axis
	t[3] = mgRndFloat(-room_size[3], 0)
	
	return t
end

function getRndSize(mx, my, mz)
	local t = {0, 0, 0}
	t[1] = mgRndFloat(0.5, mx) / 2
	t[2] = mgRndFloat(0.5, my) / 2
	t[3] = mgRndFloat(0.5, mz) / 2
	return t
end

function getRndColor()
	return tostring(mgRndFloat(-0.15, 1.15)) .. " " .. tostring(mgRndFloat(-0.15, 1.15)) .. " " .. tostring(mgRndFloat(-0.15, 1.15))
end

function getRoomColor()
	return tostring(room_color[1]) .. " " .. tostring(room_color[2]) .. " " .. tostring(room_color[3])
end

function buildBox(size, pos)
	-- size  : table {x (width), y (height), z (depth)}
	-- pos   : table {x, y, z}
	mgBox(size[1]/2, size[2]/2, size[3]/2, pos[1], pos[2], pos[3])
	mgObstacle("stone",
	           pos[1], pos[2], pos[3],
	           "sizeX=" .. tostring(size[1]/2),
	           "sizeY=" .. tostring(size[2]/2),
	           "sizeZ=" .. tostring(size[3]/2),
	           "color=" .. getRoomColor())
end

function buildWalls()
	-- Build the walls and possibly the floor and ceiling
	local div_size = room_size[3]/16
	
	for i = 0, room_size[3], div_size do
		-- left wall
		buildBox({1.0, room_size[2]*2, div_size}, {-room_walls[1], 0.0, -div_size-i})
		-- right wall
		buildBox({1.0, room_size[2]*2, div_size}, {room_walls[1], 0.0, -div_size-i})
		-- floor
		if mgRndBool() then
			buildBox({room_size[1]*2, 1.0, div_size}, {0.0, room_walls[3], -div_size-i})
		end
		-- ceiling
		if mgRndBool() then
			buildBox({room_size[1]*2, 1.0, div_size}, {0.0, room_walls[2], -div_size-i})
		end
	end
end

function buildDecor()
	-- Build the decorations on the sides of the room
	for z = 0, room_size[3], mgRndInt(12, 32) do
		local left = mgRndBool()
		local right = mgRndBool()
		
		if left then
			buildBox({1.0, room_size[2]*2, 1.0}, {-(room_walls[1]-1), 0.0, -z})
		end
		
		if right then
			buildBox({1.0, room_size[2]*2, 1.0}, {(room_walls[1]-1), 0.0, -z})
		end
	end
end

function buildCrystalsOnWalls()
	-- Build the crystals and their stands
	for z = 0, room_size[3], mgRndInt(16, 64) do
		local x = getRndNegitise(room_walls[1]-1)
		local y = mgRndFloat(-1.0, 3.0)
		-- crystal needs to be stored as a varible so we know if we need to add
		-- 0.5 to y-axis for non-scoretop or not
		local c = getRndFrom(crystals)
		
		buildBox({1.0, 1.0, 1.0}, {x, y, -z})
		if c ~= "scoretop" then y = y + 0.5 end
		mgObstacle(c, x, y + 0.5, -z, "color=" .. getRndColor())
	end
end

function buildObstacleSimple()
	-- Build random obstacles in the center of the room
	local obs = {"pyramid", "bar", "beatmill", "rotor"}
	for z = 0, room_size[3], 10 do
		mgObstacle(getRndFrom(obs), 0.0, mgRndFloat(0.0, 3.0), -z, "color=" .. getRndColor())
	end
end

-- ----------------------------------------------------------------------------
-- Old room building functions, please do not use these anymore.
-- ----------------------------------------------------------------------------

function buildRndBox(z, obstacle)
	local pos = getRndBoxPos()
	local size = getRndSize(2.0, 2.0, 2.0)
	
	-- Box and stonehack obstacle
	mgBox(size[1], size[2], size[3], pos[1], pos[2], z)
	mgObstacle("stone",
	           pos[1], pos[2], z,
	           "sizeX=" .. tostring(size[1]),
	           "sizeY=" .. tostring(size[2]),
	           "sizeZ=" .. tostring(size[3]),
	           "color=" .. getRoomColor())
	
	-- Obstacle on top of the box
	if obstacle then
		mgObstacle(getRndFrom(test_obstacles), pos[1], size[2]/2 + pos[2], z, "color=" .. getRndColor())
	end
end

function buildRoomOld()
	for i = 0, room_size[3], mgRndInt(4, 8) do
		buildRndBox(-i, nil)
	end
end

-- ----------------------------------------------------------------------------
-- Main Functions
-- ----------------------------------------------------------------------------

function init()
	mgFogColor(mgRndFloat(-0.35, 1.35), mgRndFloat(-0.35, 1.35), mgRndFloat(-0.35, 1.35), 
	           mgRndFloat(-0.35, 1.35), mgRndFloat(-0.35, 1.35), mgRndFloat(-0.35, 1.35))
	-- TODO: Implement random music system like the one from Random Hit
	mgMusic(tostring(mgRndInt(0, 28)))
	
	-- init global variables
	initGlobals()
	
	-- build the room using various builders
	buildWalls()
	buildDecor()
	buildCrystalsOnWalls()
	buildObstacleSimple()
	
	-- set room length
	mgLength(room_size[3])
end

function tick()
end

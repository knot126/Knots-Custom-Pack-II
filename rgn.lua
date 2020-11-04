function initGlobals()
	--[[
	Table of obstacles
	==================
	This table contains tables which hold the name of the obstacle, their
	paramaters, and the value ranges for their paramaters. Not all of this info
	is used at the moment, but it is helpful to have a layout for everything.
	
	The format is the following:
	{
		"name" = obstaclename                  -- The name of the obstacle
		"params" = {                           -- A table of paramaters
			{param_name, param_type, [param_max, param_min], [param_vals]},
			{param_name, param_type, [param_max, param_min], [param_vals]}
		}
	}
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
	test_obstacles = {"pyramid", "bar", "3dcross", "babytoy", "beatmill", "rotor", "tree", "scorediamond", "scoremulti", "scorestar", "scoretop"}
	
	-- Room size
	room_size = {12, 10, 0}
	room_size[3] = mgRndInt(50, 250)
	
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
	           "color=" .. getRndColor())
	
	-- Obstacle on top of the box
	mgObstacle(getRndFrom(test_obstacles), pos[1], size[2]/2 + pos[2], z, "color=" .. getRndColor())
end

function buildRoom()
	for i = 0, room_size[3], mgRndInt(4, 8) do
		buildRndBox(-i, nil)
	end
end

function init()
	mgFogColor(mgRndFloat(-0.35, 1.35), mgRndFloat(-0.35, 1.35), mgRndFloat(-0.35, 1.35), 
	           mgRndFloat(-0.35, 1.35), mgRndFloat(-0.35, 1.35), mgRndFloat(-0.35, 1.35))
	mgMusic(tostring(mgRndInt(0, 28)))
	
	initGlobals()
	buildRoom()
	
	mgLength(room_size[3])
end

function tick()
end

-- Camera Shake Presets
-- Stephen Leitnick
-- February 26, 2018

--[[
	
	CameraShakePresets.Bump
	CameraShakePresets.Explosion
	CameraShakePresets.Earthquake
	CameraShakePresets.BadTrip
	CameraShakePresets.HandheldCamera
	CameraShakePresets.Vibration
	CameraShakePresets.RoughDriving
	
--]]



local CameraShakeInstance = require(script.Parent.CameraShakeInstance)

local CameraShakePresets = {
	
	
	
	Bump = function()
		local c = CameraShakeInstance.new(2.5, 4, 0.1, 0.75)
		c.PositionInfluence = Vector3.new(0.15, 0.15, 0.15)
		c.RotationInfluence = Vector3.new(1, 1, 1)
		return c
	end,
	
	HeavyHit = function()
		local c = CameraShakeInstance.new(8, 14, 0, 1.25)
		c.PositionInfluence = Vector3.new(0.5, 0.5, 0)
		c.RotationInfluence = Vector3.new(0, 0, 0)
		return c
	end,
	
	LightHit = function()
		local c = CameraShakeInstance.new(4, 7, 0.1, 0.75)
		c.PositionInfluence = Vector3.new(0.25, 0.25, 0)
		c.RotationInfluence = Vector3.new(0, 0, 0)
		return c
	end,
	
	BigBump = function()
		local c = CameraShakeInstance.new(2.5, 4, 0.1, 0.75)
		c.PositionInfluence = Vector3.new(0.8, 0.8, 0.8)
		c.RotationInfluence = Vector3.new(1, 1, 1)
		return c
	end;

	SmallBump = function()
		local c = CameraShakeInstance.new(2.5, 4, 0.1, 0.75)
		c.PositionInfluence = Vector3.new(0.01, 0.01, 0.01)
		c.RotationInfluence = Vector3.new(.5, .5, .5)
		return c
	end;

	TinyBump = function()
		local c = CameraShakeInstance.new(1.5, 4, 0.1, 0.75)
		c.PositionInfluence = Vector3.new(0.005, 0.005, 0.005)
		c.RotationInfluence = Vector3.new(.2, .2, .2)
		return c
	end;


	-- An intense and rough shake.
	-- Should happen once.
	Explosion = function()
		local c = CameraShakeInstance.new(5, 10, 0, 1.5)
		c.PositionInfluence = Vector3.new(0.25, 0.25, 0.25)
		c.RotationInfluence = Vector3.new(4, 1, 1)
		return c
	end;

	Explosion1 = function()
		local c = CameraShakeInstance.new(2, 10, 0, 0.2)
		c.PositionInfluence = Vector3.new(0.25, 0.25, 0.25)
		c.RotationInfluence = Vector3.new(4, 1, 1)
		return c
	end;

	Explosion3 = function()
		local c = CameraShakeInstance.new(6, 8, 0, 1.2)
		c.PositionInfluence = Vector3.new(0.18, 0.18, 0.18)
		c.RotationInfluence = Vector3.new(3, .8, .8)
		return c
	end;


	-- An intense and rough shake.
	-- Should happen once.
	Explosion2 = function()
		local c = CameraShakeInstance.new(10, 20, 0, 3)
		c.PositionInfluence = Vector3.new(0.50, 0.50, 0.50)
		c.RotationInfluence = Vector3.new(8, 2, 2)
		return c
	end;


	-- A continuous, rough shake
	-- Sustained.
	Earthquake = function()
		local c = CameraShakeInstance.new(0.6, 3.5, 2, 10)
		c.PositionInfluence = Vector3.new(0.25, 0.25, 0.25)
		c.RotationInfluence = Vector3.new(1, 1, 4)
		return c
	end;

	HoldShake = function()
		local c = CameraShakeInstance.new(0.5, 75, 0, 0.25)
		c.PositionInfluence = Vector3.new(0.50, 0.50, 0.50)
		c.RotationInfluence = Vector3.new(5, 1, 1)
		return c
	end;
	
	
	-- A bizarre shake with a very high magnitude and low roughness.
	-- Sustained.
	BadTrip = function()
		local c = CameraShakeInstance.new(10, 0.15, 5, 10)
		c.PositionInfluence = Vector3.new(0, 0, 0.15)
		c.RotationInfluence = Vector3.new(2, 1, 4)
		return c
	end;
	
	
	-- A subtle, slow shake.
	-- Sustained.
	HandheldCamera = function()
		local c = CameraShakeInstance.new(1, 0.25, 5, 10)
		c.PositionInfluence = Vector3.new(0, 0, 0)
		c.RotationInfluence = Vector3.new(1, 0.5, 0.5)
		return c
	end;
	
	
	-- A very rough, yet low magnitude shake.
	-- Sustained.
	Vibration = function()
		local c = CameraShakeInstance.new(0.4, 20, 2, 2)
		c.PositionInfluence = Vector3.new(0, 0.15, 0)
		c.RotationInfluence = Vector3.new(1.25, 0, 4)
		return c
	end;
	
	RoughVibration = function()
		local c = CameraShakeInstance.new(4, 25, 3, 3)
		c.PositionInfluence = Vector3.new(0, 0.35, 0)
		c.RotationInfluence = Vector3.new(1.40, 0, 5)
		return c
	end;
	
	RoughVibration2 = function()
		local c = CameraShakeInstance.new(3, 23, 6, 6)
		c.PositionInfluence = Vector3.new(1, 0.25, 1)
		c.RotationInfluence = Vector3.new(2.40, 1, 6)
		return c
	end;
	
	
	-- A slightly rough, medium magnitude shake.
	-- Sustained.
	RoughDriving = function()
		local c = CameraShakeInstance.new(1, 2, 1, 1)
		c.PositionInfluence = Vector3.new(0, 0, 0)
		c.RotationInfluence = Vector3.new(1, 1, 1)
		return c
	end;
	
	-- Fear
	Fear = function()
		local c = CameraShakeInstance.new(1, 2, 1, 2)
		c.PositionInfluence = Vector3.new(0.25, 0.25, 0.25)
		c.RotationInfluence = Vector3.new(1.5, 1.5, 4)
		return c
	end;

	
}


return setmetatable({}, {
	__index = function(t, i)
		local f = CameraShakePresets[i]
		if (type(f) == "function") then
			return f()
		end
		error("No preset found with index \"" .. i .. "\"")
	end;
})
local RunService = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")
local Modules = RepStorage:WaitForChild("Modules")
local RepStorage = game:GetService("ReplicatedStorage")
local Modules = RepStorage:WaitForChild("Modules")
local Utils = Modules.Utils
local GameManagers = Modules:WaitForChild("GameManagers")
local GameControllers = Modules:WaitForChild("GameControllers")
local BaseSystems = Modules:WaitForChild("BaseSystems")


local MoverManager = require(Utils:WaitForChild("MoverManager"))
local AnimManager = require(Utils:WaitForChild("AnimManager"))
return {
	Func = function(CharConfig,Options)
		local MoverManager =  MoverManager
		local AnimManager =  AnimManager
		local Mover = CharConfig.Mover
		local Targ:Model
		CharConfig.Controller:SetAttribute("KiSense", not CharConfig.Controller:GetAttribute("KiSense"))
	end,

	--[[CheckIfUsable = function(CharConfig,Options)
		
	end]]
}
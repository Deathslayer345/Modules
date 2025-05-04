local RepStorage = game:GetService("ReplicatedStorage")

local Modules = RepStorage:WaitForChild("Modules")

local BaseSystems = Modules:WaitForChild("BaseSystems")
local GameControllers = Modules:WaitForChild("GameControllers")
local Utils = Modules:WaitForChild("Utils")
local GameManagers = Modules:WaitForChild("GameControllers")


local GeneralLocations = {
	BaseSystems = BaseSystems,
	GameControllers = GameControllers,
	Utils = Utils,
	GameManagers = GameManagers,
	Modules = Modules,
	Models = RepStorage:WaitForChild("Models"),
	Events = RepStorage:WaitForChild("Events"),
	Effects = RepStorage:WaitForChild("Effects")
}

return GeneralLocations
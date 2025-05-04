local Modules = game:GetService("ReplicatedStorage"):WaitForChild("Modules")
local Config = {
	Important = {
		Modules,
		--Modules:WaitForChild("AnimManager")
	},
	Skippable = {
		game:GetService("ReplicatedStorage"):WaitForChild("Modules"),
		game:GetService("Lighting"),
		--workspace
		--workspace
	}
}
if game:GetService("RunService"):IsClient() then
	Config.Skippable.Models = game:GetService("ReplicatedStorage"):WaitForChild("Models")
	Config.Skippable.Effects = game:GetService("ReplicatedStorage"):WaitForChild("Effects")

end
return Config

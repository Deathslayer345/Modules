local rs = game:GetService("ReplicatedStorage")
local function GetData(player)
	return rs:FindFirstChild("Datas"):FindFirstChild(player.UserId)
end
local Modules = game:GetService("ReplicatedStorage"):WaitForChild("Modules")
local StatsManager = require(Modules:WaitForChild("BaseSystems"):WaitForChild("StatsManager"))

local Customization = game.ReplicatedStorage:WaitForChild("Package"):WaitForChild("Customization")
return function(Mod:Model)
	local Char:Model = Mod.Parent
	if Char then
		
		local CustomizationData = StatsManager:GetStats(Char)
			repeat
			CustomizationData = StatsManager:GetStats(Char)
				wait(.04)
			until CustomizationData and CustomizationData:FindFirstChild("Data")
		CustomizationData = CustomizationData.Data.Customization

		local Plr = game.Players:GetPlayerFromCharacter(Char)
		if not Plr then return end
		local Status = Plr:WaitForChild("Status")
		local Skin = Customization["Skin Color"][CustomizationData["Skin Color"].Value].BackgroundColor3
		local HairColor = Customization["Hair Color"][CustomizationData["Hair Color"].Value].BackgroundColor3
		local EyeColor = Customization["Eye Color"][CustomizationData["Eye Color"].Value].BackgroundColor3
		local Face = Customization.Faces[CustomizationData.Face.Value]
		local Outfit = Customization.Outfit:FindFirstChild(CustomizationData.Outfit.Value) or Customization.Outfit:FindFirstChild("Outfit1")


		if Status.Form.Value == "None" or Status.Form.Value == ""  then
			for i,v in Mod:GetDescendants() do
				if v:IsA("BasePart") then
					if v.Name == "Hair" then
						v.Color = HairColor
					end
				end
			end
		end
	end
end
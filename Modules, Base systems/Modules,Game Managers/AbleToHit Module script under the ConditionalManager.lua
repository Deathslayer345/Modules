
return function(CharConfig)
	if not CharConfig then return end
	local Data = CharConfig.Data
	if not Data or not Data.CharStats then return end
	local Char = CharConfig.Controller
	local Hum:Humanoid = Char:FindFirstChildWhichIsA("Humanoid")
	--local Calculations = _G.Modules.Combat.Calculations
	if Hum then
		if Char:GetAttribute("DoingMove") then return end
		--if Char:GetAttribute("Energy") and Char:GetAttribute("Energy") <= 0 then return end
		--if Char:GetAttribute("Stamina") and Char:GetAttribute("Stamina") <= Calculations:CalcStamDrain(Char)  then return end
		local HumRootPart:BasePart = Char:WaitForChild("HumanoidRootPart")
		if Char:GetAttribute("InSkillCreator") then return end
		if CharConfig.Data.CharStats.Charging.Value then return end
	end
	--if game:GetService("RunService"):IsServer() then
	local Plr = game.Players:GetPlayerFromCharacter(CharConfig.Controller)
	return not CharConfig.HitDebounce or os.clock() >= CharConfig.HitDebounce
	--return true
	--return #(Data.CharStats.HitBy) > 0
end

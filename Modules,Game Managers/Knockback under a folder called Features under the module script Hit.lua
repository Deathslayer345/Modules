local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Modules = RepStorage:WaitForChild("Modules")
local RepStorage = game:GetService("ReplicatedStorage")
local Modules = RepStorage:WaitForChild("Modules")
local Utils = Modules.Utils
local GameManagers = Modules:WaitForChild("GameManagers")
local GameControllers = Modules:WaitForChild("GameControllers")
local BaseSystems = Modules:WaitForChild("BaseSystems")


local CombatService = require(BaseSystems:WaitForChild("CombatService"))
local AnimManager = require(Utils:WaitForChild("AnimManager"))
local RenderService = require(BaseSystems:WaitForChild("RenderService"))
local TimeManager = require(Utils:WaitForChild("TimeManager"))
local Knockback = {

}

Knockback.Func = function(HitTab,CharConfig,Options)
	local HitList = {}
	--if game:GetService("RunService"):IsServer() then
	local CXlock = os.clock()
	if RunService:IsServer() then

		if Options.Clock then
			local plr = game.Players:GetPlayerFromCharacter(CharConfig.Controller)
			if TimeManager and TimeManager.getClientSync then
			CXlock =  Options.Clock + TimeManager:getClientSync(plr) 
			Options.Clock = nil
			end
		end
	end
	CharConfig.HitDebounce = CXlock + .5	
	if game:GetService("RunService"):IsServer() then


		CombatService:ResetCombo(CharConfig,{})
	end
	--end
	if CharConfig.PlayerServer then  

	else
	--[[	CharConfig:DoAction("ShiftFlight",{
			Holding = false
		})]]
		local Animator = CharConfig.Animator
		local Mover = CharConfig.Mover
		local AnimManager =  AnimManager
		if CharConfig.LockedTarget then
			HitTab.Lunge(CharConfig,{
				BaseVel = 300,
				VelocityTrack = 1.2,
				TimeTake = .3
			})
		end
		local HitboxTimes,Anim = HitTab.PlayAnim(CharConfig,{
			Type = "M1",
			Speed = 1.2
		})
		HitTab.ResetAnims(CharConfig,"All")
		local Controller=  CharConfig.Controller
		HitTab.HitDetect(CharConfig,{
			Model = Controller["HumanoidRootPart"],
			Extensions = {

			},
			HitFunc = function(Found,List)
				--print(List)

				--print(Found)
				if #Found > 0 then

					HitTab.Hit(CharConfig,{
						List = Found,
						HitType = "Knockback"
					})
					--print("Hit")
					--print(Found)
					return "Destroy"

				end
			end,
			HitboxTimes = HitboxTimes,
			Anim = Anim
		})
	end
end



Knockback.CharHit = function(HitTab,CharConfig,Mod:Model)
	--	if CharConfig.Data.CharStats.KnockCool then return end
	--CharConfig.Data.CharStats.KnockCool = true
	CharConfig.Data.CharStats.Knocker.Value = true
	local Char:Model = CharConfig.Controller

	local EnemyConfig = _G.CreateCharacter(Mod)
	local EnemyHum:Humanoid = Mod:FindFirstChildWhichIsA("Humanoid")
	local EnemyRoot:BasePart = Mod:FindFirstChild("HumanoidRootPart")
if EnemyHum.Health <= 0 then return end

	HitTab.CamShake(CharConfig,.5)
	RenderService:HitEffect(EnemyRoot,{
		Type = "Knockback"
	})
	CombatService:Damage(Char,Mod,2)
	CombatService:Stun(Mod,{
		TimeLast =1.6,
		Killer = Char,
		Knockback = 100,
		StunType = "Light",
		KillerTime = true
	})
	
	
	
	


	task.delay(3.5,function()
		if not CharConfig.Data.CharStats then return end
		CharConfig.Data.CharStats.Knocker.Value = false
	end)
	HitTab.Highlight(Mod)

end

return Knockback

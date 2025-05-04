local RepStorage = game:GetService("ReplicatedStorage")

local Modules = RepStorage:WaitForChild("Modules")

local StatsManager
spawn(function()
	repeat
		wait(.05)
		StatsManager = _G.StatsManager

	until StatsManager
end)

local CalcManager = {}

function CalcManager:GetSuppression(Stats)
	if not Stats then return 1 end
	return Stats.Suppression.Value / 100
end

function CalcManager:LevelToStats(Level)
	return Level^(1.3 * Level^.05)
end


function CalcManager:GetStat(Data, Stat)
	if not Data then return 1 end
	local Stats = Data.Stats
--	local Avg = CalcManager:LevelToStats(Stats.Level.Value)
	local Val = Stats[Stat].Value + 1
	return (Val) *  CalcManager:GetSuppression(Stats)
end

function CalcKiSize(Data)
	if not Data then return end
	return CalcManager:GetStat(Data,"Energy")
end

function CalcManager:CalcSpeed(char:Model)
	local Data = StatsManager:GetStats(char).Data
	local Speed = CalcManager:GetStat(Data,"Speed")
	return 1 + math.log(Speed + 1,10)^.8 * .2
end

function CalcManager:GetAvgStats(Data)
	if not Data then return 1 end
	local Stats = Data.Stats
	local IncludedStats = { "Strength", "Defense", "Energy", "Speed" }
	local Amnt = #IncludedStats
	local Avg = 0
	for _, Stat in ipairs(IncludedStats) do
		Avg = Avg + CalcManager:GetStat(Data, Stat)
	end
	Avg /= (Amnt + 1)
	return Avg
end

function CalcManager:CalcPL(Stats)
	if not Stats or not Stats.Parent then return 1 end
	local Avg = CalcManager:GetAvgStats(Stats.Parent)
	return Avg^(1.8 * (Avg)^.034 - 1 + .9)
end
-- Helper function to calculate the logarithmic base (unchanged)
function CalcManager:CalculateLogBase(Potential)
	return math.log(Potential^0.15 + 2, 60)
end
--TRAINING FEATURES
local Multi = 20
local Exp = 2.1
local OppExp = .2
local OppMult = 4
-- Corrected CalcLevelAmount function
function CalcManager:CalcLevelAmount(Level, EXP, Potential)
	
	local Amnt = CalcManager:CalcLevelReq(Level,Potential)
	
	--print(EXP,Amnt)
	local num = EXP/Amnt
	return math.min(math.floor(num/math.max(math.log(.0000001*num^2,1.7),1)),10e5)
end

local basePrefixes = {
	"K", "M", "B", "T", "Qd", "Qn", "Sx", "Sp", "Oc", "No",
	"Dec", "UnD", "DD", "TD", "QD", "QnD", "SxD", "SpD", "OcD", "NoD",
	"Vgn", "UnVgn", "DuoVgn",
	"TreVgn", "QtrVgn", "QnVgn", "SxVgn", "SpVgn", "OcVgn", "NvVgn",
	"Tgn", "UnTgn", "DuoTgn", "TreTgn", "QtrTgn", "QnTgn", "SxTgn", "SpTgn", "OcTgn", "NvTgn",
	"Qdg", "UnQdg", "DuoQdg", "TreQdg", "QtrQdg", "QnQdg", "SxQdg", "SpQdg", "OcQdg", "NvQdg",
	"Qng", "UnQng", "DuoQng", "TreQng", "QtrQng", "QnQng", "SxQng", "SpQng", "OcQng", "NvQng",
	"Sxg", "UnSxg", "DuoSxg", "TreSxg", "QtrSxg", "QnSxg", "SxSxg", "SpSxg", "OcSxg", "NvSxg",
	"Spg", "UnSpg", "DuoSpg", "TreSpg", "QtrSpg", "QnSpg", "SxSpg", "SpSpg", "OcSpg", "NvSpg",
	"Ocg", "UnOcg", "DuoOcg", "TreOcg", "QtrOcg", "QnOcg", "SxOcg", "SpOcg", "OcOcg", "NvOcg",
	"Ng", "UnNg", "DuoNg", "TreNg", "QtrNg", "QnNg", "SxNg", "SpNg", "OcNg", "NvNg",
	"C", "UnC", "DuoC", "TreC", "QtrC", "QnC", "SxC", "SpC", "OcC", "NvC"
}
function CalcManager:ShortenNumber(Num:number)
	local Log = math.floor(math.log(Num, 1000))
	local Res = Num / 1000^Log
	local Index = Res < 10 and 4 or Res < 100 and 5 or 3
	--print(Res)

	local Str = string.sub(tostring(Res), 1, Index) 
	if Num < 1000 then
		
	
	else
		Str = Str  .. (basePrefixes[Log] or "...")
	end
	return Str
end

_G.ShortenNumber = function(Num:number)
	return CalcManager:ShortenNumber(Num)
end

function CalcManager:CalcKiMax(Data)
	return math.floor(CalcManager:GetStat(Data,"Energy") + 100)
end

function CalcManager:PunchTrain(Data)
	Data = Data or {}
	local Enemy = Data.Enemy

	local Giver = Data.Giver
	if not Giver then return end
	local GiverStatAVG = CalcManager:GetAvgStats(Giver)
	local EnemyStatAVG = CalcManager:GetAvgStats(Enemy)
	local Level = Giver.Stats.Level.Value + 1
	local Potential = Giver.Stats.Potential.Value
	return self:train(Level, (EnemyStatAVG/GiverStatAVG), Potential)
	--return ((EnemyStatAVG/GiverStatAVG) + 1)^0.4 * (1.13^(math.log((0.3 * Level + 1), (1 + 0.07 / (Potential^.2))))) 
	--return (.8 * Level)^(1.35 * Level^.065) * (EnemyStatAVG/GiverStatAVG)^.7

end

function CalcManager:CalcKiAmount(Data)
	Data = Data or {}
	local Giver = Data.Giver
	if not Giver then return end
	local GiverStatAVG = CalcManager:GetStat(Giver,"Energy")
	
	
	return GiverStatAVG^.7 * .02
	--return ((EnemyStatAVG/GiverStatAVG) + 1)^0.4 * (1.13^(math.log((0.3 * Level + 1), (1 + 0.07 / (Potential^.2))))) 
	--return (.8 * Level)^(1.35 * Level^.065) * (EnemyStatAVG/GiverStatAVG)^.7

end



function CalcManager:CalcDamage(Data)
	Data = Data or {}
	local Enemy = Data.Enemy

	local Giver = Data.Giver
	if not Giver then return end
	local GiverStatAVG = CalcManager:GetAvgStats(Giver)
	local EnemyStatAVG = CalcManager:GetAvgStats(Enemy)
	return (GiverStatAVG/EnemyStatAVG)^.6
	--return (.8 * Level)^(1.35 * Level^.065) * (EnemyStatAVG/GiverStatAVG)^.7

end
function CalcManager:CalcKnockback(Data)
	Data = Data or {}
	local Amount = CalcManager:CalcDamage(Data)
	if not Amount then return end
	Amount /= 1
	return Amount 
	--return (.8 * Level)^(1.35 * Level^.065) * (EnemyStatAVG/GiverStatAVG)^.7

end

local IndicatorValues = {
	{
		Type = "Low",
		Val = 0
	},
	{
		Type = "Med",
		Val = 50
	}
}
table.sort(IndicatorValues,function(entry1,entry2)
	return entry1.Val < entry2.Val
end)

function CalcManager:GetDamageIndicator(Data,DMG:number)
	if typeof(DMG) ~= "number" then return end
	if not Data then return end
	if DMG == 0 then return end
	local AVG = CalcManager:GetAvgStats(Data)
	for i,v in IndicatorValues do
		local Val = v.Val
		if DMG >= Val then
			local Valid = false
			if not IndicatorValues[i + 1] then
				Valid = true
			end
			if not Valid then
				local v2 = IndicatorValues[i + 1] 
				if DMG < v2.Val then
					Valid = true
				end
			end
			if Valid then
				return v.Type
			end
		end
	end
	
end

return CalcManager

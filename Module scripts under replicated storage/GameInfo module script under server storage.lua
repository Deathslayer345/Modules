---repeat task.wait(.05) until _G.Suffixes
require(game.ReplicatedStorage.SimpleModules.Suffixes)
local ConvertSuffix = _G.ConvertSuffix

local TimeSuffixes = {
	{"s",1},
	{"m",60},
	{"h",24},
	{"d",7},
	{"w",4},
	{"mo",1}
}
function GetAmount(Suffix)
	local TimeT = Suffix[1]
	for i,v in TimeSuffixes do
		
		TimeT *= v[2]
		if TimeT == v[1] then
			break
		end
	end
	return TimeT
end
_G.GetAmount = GetAmount
function ConvertTime(Tab)
	for i,v in Tab do
		
	end
	return ConvertSuffix(Amnt,SuffixNum)
end

local Infos = {
	

}
local function Added(v:ModuleScript)
	if v:IsA("ModuleScript") then
		for e,x in require(v) do
			Infos[e] = x
		end
	end
end
function CheckWait(num:number)
	if num % 10 == 0 then
		task.wait(.1)
	end
end
for i,v in script:GetDescendants() do
	CheckWait(i)
	Added(v)
end
script.DescendantAdded:Connect(Added)
_G.SkillInfos = Infos
return Infos
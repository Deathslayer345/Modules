local Lib = {}

function Added(v:ModuleScript)
	if not v:IsA("ModuleScript") then return end
	spawn(function()
		pcall(function()
		Lib[v.Name] = require(v)
		end)
	end)
end

for i,Module in script:GetChildren() do
	Added(Module)
end
script.ChildAdded:Connect(Added)

_G.Configs = Lib
return Lib
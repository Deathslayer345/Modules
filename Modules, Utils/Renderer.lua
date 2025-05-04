

return function(Mod:Model)
	local function Added(v:ModuleScript)
		if v:IsA("ModuleScript" ) then
			require(v)(Mod)
		end
	end
	for i,v in script:GetChildren() do
		spawn(function()
			Added(v)
		end)
	end
	script.ChildAdded:Connect(Added)
end
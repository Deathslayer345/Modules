function GetSize(Part:BasePart)
	local Size = Part.Size
	if Part:IsA("Part") then
		for i,v:SpecialMesh in Part:GetChildren() do
			if v:IsA("SpecialMesh") then
				if v.MeshType == Enum.MeshType.Head then
					Size *= v.Scale / 1.25
				elseif v.MeshType == Enum.MeshType.FileMesh then
					Size *= v.Scale / 100
				else
					Size *= v.Scale
				end
			end
		end
	end
	return Size
end

return {
	Init = function(BindInfo,Part:Light,Target:BasePart,Parent:BasePart)
		Parent = Parent or Part.Parent
		local parentOriginSizeAttr = Parent:GetAttribute("OriginSize")
		if not parentOriginSizeAttr then
			warn("BindService Light: Parent missing OriginSize attribute:", Parent:GetFullName())
			Parent:SetAttribute("OriginSize", GetSize(Parent))
			parentOriginSizeAttr = Parent:GetAttribute("OriginSize")
			if not parentOriginSizeAttr or parentOriginSizeAttr == Vector3.zero then
				warn("BindService Light: Failed to get/set valid OriginSize for parent:", Parent:GetFullName())
				return
			end
		end
		if parentOriginSizeAttr == Vector3.zero then
			warn("BindService Light: Parent OriginSize attribute is zero:", Parent:GetFullName())
			return
		end

		local Origins = {}
		local Types = {
			Range = "number",
		}
		local LightInstance = Part

		local function SizePart(Prop:string, ScaleFactor:Vector3)
			if not Origins[Prop] then
				local success, value = pcall(function() return LightInstance[Prop] end)
				if not success then return end
				Origins[Prop] = value
			end

			local originalValue = Origins[Prop]
			local propType = Types[Prop]
			if not originalValue then return end

			pcall(function()
				if propType == "number" then
					local magnitudeScale = ScaleFactor.Magnitude
					if typeof(originalValue) == "number" then
						LightInstance[Prop] = originalValue * magnitudeScale
					end
				end
			end)
		end

		local function Changed()
			local parentOriginSize = Parent:GetAttribute("OriginSize")
			if not parentOriginSize or parentOriginSize == Vector3.zero then return end

			local targetSize = GetSize(Target)
			local scaleVector = Vector3.new(
				parentOriginSize.X ~= 0 and targetSize.X / parentOriginSize.X or 1,
				parentOriginSize.Y ~= 0 and targetSize.Y / parentOriginSize.Y or 1,
				parentOriginSize.Z ~= 0 and targetSize.Z / parentOriginSize.Z or 1
			)

			for propName, propType in pairs(Types) do
				SizePart(propName, scaleVector)
			end
		end

		table.insert(BindInfo.Events, Target:GetPropertyChangedSignal("Size"):Connect(Changed))

		Changed()
	end,
}

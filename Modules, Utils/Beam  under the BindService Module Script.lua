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
	Init = function(BindInfo,Part:Beam,Target:BasePart,Parent)
		Parent = Parent or Part.Parent
		local beamPart = Part:FindFirstAncestorWhichIsA("BasePart")
		local beamPartOriginSize = beamPart and beamPart:GetAttribute("OriginSize")

		if not beamPart or not beamPartOriginSize then
			warn("BindService Beam: Ancestor BasePart or its OriginSize attribute not found for:", Part:GetFullName())
			if beamPart then beamPart:SetAttribute("OriginSize", GetSize(beamPart)) end
			beamPartOriginSize = beamPart and beamPart:GetAttribute("OriginSize")
			if not beamPart or not beamPartOriginSize or beamPartOriginSize == Vector3.zero then
				warn("BindService Beam: Failed to get/set valid OriginSize for ancestor:", beamPart and beamPart:GetFullName())
				return
			end
		end
		if beamPartOriginSize == Vector3.zero then
			warn("BindService Beam: Ancestor OriginSize attribute is zero:", beamPart:GetFullName())
			return
		end


		local Origins = {}
		local Types = {
			Width0 = "number",
			Width1 = "number",
			CurveSize0 = "number",
			CurveSize1 = "number",
			Segments = "number",
		}
		local BeamInstance = Part

		local function SizePart(Prop:string, ScaleFactor:Vector3)
			if not Origins[Prop] then
				local success, value = pcall(function() return BeamInstance[Prop] end)
				if not success then return end
				Origins[Prop] = value
			end

			local originalValue = Origins[Prop]
			local propType = Types[Prop]
			if not originalValue then return end

			pcall(function()
				if propType == "NumberSequence" then
					local magnitudeScale = ScaleFactor.Magnitude
					if typeof(originalValue) == "NumberSequence" then
						local NumSeq = originalValue.Keypoints
						local EmptyEq = {}
						for i,v in ipairs(NumSeq) do
							EmptyEq[i] = NumberSequenceKeypoint.new(v.Time, v.Value * magnitudeScale, v.Envelope * magnitudeScale)
						end
						BeamInstance[Prop] = NumberSequence.new(EmptyEq)
					end
				elseif propType == "number" then
					local magnitudeScale = ScaleFactor.Magnitude
					if typeof(originalValue) == "number" then
						if Prop ~= "Segments" then
							BeamInstance[Prop] = originalValue * magnitudeScale
						end
					end
				end
			end)
		end

		local function Changed()
			local ancestorOriginSize = beamPart:GetAttribute("OriginSize")
			if not ancestorOriginSize or ancestorOriginSize == Vector3.zero then return end

			local targetSize = GetSize(Target)
			local scaleVector = Vector3.new(
				ancestorOriginSize.X ~= 0 and targetSize.X / ancestorOriginSize.X or 1,
				ancestorOriginSize.Y ~= 0 and targetSize.Y / ancestorOriginSize.Y or 1,
				ancestorOriginSize.Z ~= 0 and targetSize.Z / ancestorOriginSize.Z or 1
			)

			for propName, propType in pairs(Types) do
				SizePart(propName, scaleVector)
			end
		end

		table.insert(BindInfo.Events, Target:GetPropertyChangedSignal("Size"):Connect(Changed))

		Changed()
	end,
}
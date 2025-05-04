function GetSize(Part:BasePart)
	local Size = Part.Size
	if Part:IsA("Part") then
		for i,v:SpecialMesh in Part:GetChildren() do
			if v:IsA("SpecialMesh") then
				if v.MeshType == Enum.MeshType.Head then
					Size *= v.Scale
					local Min = math.min(Size.X,Size.Z)
					Size = Vector3.new(Min,Size.Y,Min)
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
	Init = function(BindInfo,Part:BasePart,Target:BasePart,Parent)
		BindInfo.Offset = BindInfo.Offset or CFrame.new()
		Part.Anchored = false
		Part.Massless = true
		local Weld = Instance.new("Weld")
		Parent = Parent or Part.Parent
		local Model = Parent:GetAttribute("BindService")

		if not Model then
			local parentOriginCF = Parent:GetAttribute("OriginCF")
			if not parentOriginCF or not Parent:GetAttribute("OriginSize") then
				warn("BindService BasePart: Parent missing OriginCF or OriginSize attribute:", Parent:GetFullName())
				return
			end

			local CF = parentOriginCF:ToObjectSpace(Part.CFrame)
			BindInfo.Origins[Part] = CF
			local parentOriginSize = Parent:GetAttribute("OriginSize")
			if parentOriginSize == Vector3.zero then return end

			local Pos = (BindInfo.Offset * CF).Position * (GetSize(Target) / parentOriginSize)
			Weld.C0 = CFrame.new(Pos)* BindInfo.Offset.Rotation * CF.Rotation
			Part:SetAttribute("OriginSize",GetSize(Part))
			Part:SetAttribute("OriginCF",Part.CFrame)
			local partOriginSize = Part:GetAttribute("OriginSize")
			-- Ensure safe division
			local sizeX = parentOriginSize.X ~= 0 and GetSize(Target).X * (partOriginSize.X / parentOriginSize.X) or 0
			local sizeY = parentOriginSize.Y ~= 0 and GetSize(Target).Y * (partOriginSize.Y / parentOriginSize.Y) or 0
			local sizeZ = parentOriginSize.Z ~= 0 and GetSize(Target).Z * (partOriginSize.Z / parentOriginSize.Z) or 0
			Part.Size = Vector3.new(sizeX, sizeY, sizeZ)
		else
			Weld.C0 = BindInfo.Offset
			Part:SetAttribute("OriginSize",GetSize(Part))
			Part:SetAttribute("OriginCF",Part.CFrame)
			Part.Transparency = 1
			Part.Size = GetSize(Target)
		end

		local function Changed()
			if not BindInfo or not BindInfo.Origins or not BindInfo.Origins[Part] or not Target or not Target.Parent or not Part or not Part.Parent then return end
			local isTopLevelPart = Parent:GetAttribute("BindService")

			if isTopLevelPart then
				Part.Size = GetSize(Target)
				Weld.C0 = BindInfo.Offset
			else
				local parentOriginSize = Parent:GetAttribute("OriginSize")
				if not parentOriginSize or parentOriginSize == Vector3.zero then return end

				local CF = BindInfo.Origins[Part]
				if not CF then return end -- Ensure CF exists

				local targetSize = GetSize(Target)
				-- Check for division by zero component-wise for scaleVector
				local scaleVector = Vector3.new(
					parentOriginSize.X ~= 0 and targetSize.X / parentOriginSize.X or 1,
					parentOriginSize.Y ~= 0 and targetSize.Y / parentOriginSize.Y or 1,
					parentOriginSize.Z ~= 0 and targetSize.Z / parentOriginSize.Z or 1
				)

				local Pos = (BindInfo.Offset * CF).Position * scaleVector
				Weld.C0 = CFrame.new(Pos) * BindInfo.Offset.Rotation * CF.Rotation

				local partOriginSize = Part:GetAttribute("OriginSize")
				if not partOriginSize then return end

				Part.Size = Vector3.new(
					parentOriginSize.X ~= 0 and targetSize.X * (partOriginSize.X / parentOriginSize.X) or 0,
					parentOriginSize.Y ~= 0 and targetSize.Y * (partOriginSize.Y / parentOriginSize.Y) or 0,
					parentOriginSize.Z ~= 0 and targetSize.Z * (partOriginSize.Z / parentOriginSize.Z) or 0
				)
			end
		end

		local updateCoroutine
		updateCoroutine = spawn(function()
			while task.wait() do
				if not Part or not Part.Parent or not Target or not Target.Parent or not BindInfo or not BindInfo.Origins then
					break
				end
				Changed()
			end
		end)
		table.insert(BindInfo.Events, {Disconnect = function() task.cancel(updateCoroutine) end})


		table.insert(BindInfo.Events, Target:GetPropertyChangedSignal("Size"):Connect(Changed))

		Changed()
		Part.Anchored = false
		Part.CanCollide = false
		Part.CanTouch = false
		Part.Massless = true
		Weld.Part0 = Target
		Weld.Part1 = Part
		Weld.Parent = Part
	end,
}
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
	Init = function(BindInfo,Part:ParticleEmitter,Target:BasePart,Parent:BasePart)
		Parent = Parent or Part.Parent
		local parentOriginSizeAttr = Parent:GetAttribute("OriginSize")
		if not parentOriginSizeAttr then
			warn("BindService ParticleEmitter: Parent missing OriginSize attribute:", Parent:GetFullName())
			Parent:SetAttribute("OriginSize", GetSize(Parent))
			parentOriginSizeAttr = Parent:GetAttribute("OriginSize")
			if not parentOriginSizeAttr or parentOriginSizeAttr == Vector3.zero then
				warn("BindService ParticleEmitter: Failed to get/set valid OriginSize for parent:", Parent:GetFullName())
				return
			end
		end
		if parentOriginSizeAttr == Vector3.zero then
			warn("BindService ParticleEmitter: Parent OriginSize attribute is zero:", Parent:GetFullName())
			return
		end


		local Origins = {}
		local Types = {
			Size = "NumberSequence",
			Speed = "NumberRange",
			Acceleration = "Vector3",
			Drag = "number",
			VelocityInheritance = "number"
		}
		local Particle = Part

		local function SizePart(Prop:string,ScaleFactor:Vector3)
			if not Origins[Prop] then
				local success, value = pcall(function() return Particle[Prop] end)
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
						Particle[Prop] = NumberSequence.new(EmptyEq)
					end
				elseif propType == "NumberRange" then
					local magnitudeScale = ScaleFactor.Magnitude
					if typeof(originalValue) == "NumberRange" then
						Particle[Prop] = NumberRange.new(originalValue.Min * magnitudeScale, originalValue.Max * magnitudeScale)
					end
				elseif propType == "Vector3" then
					if typeof(originalValue) == "Vector3" then
						Particle[Prop] = originalValue * ScaleFactor
					end
				elseif propType == "number" then
					local magnitudeScale = ScaleFactor.Magnitude
					if typeof(originalValue) == "number" then
						Particle[Prop] = originalValue * magnitudeScale
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

		local TimeLife = Part:GetAttribute("EmitDelay") or 0
		if typeof(Part.Lifetime) == "NumberRange" then
			TimeLife += Part.Lifetime.Max / (Part.TimeScale > 0 and Part.TimeScale or 1)
		end

		local SetOnce = false
		local function SetTime()
			local model = Parent.Parent
			if not model then return end

			if Part.Enabled or BindInfo.Emit then
				local currentDelay = Part:GetAttribute("EmitDelay") or 0
				local currentLifetimeMax = 0
				if typeof(Part.Lifetime) == "NumberRange" then
					currentLifetimeMax = Part.Lifetime.Max / (Part.TimeScale > 0 and Part.TimeScale or 1)
				end
				local currentTotalTime = currentDelay + currentLifetimeMax

				local currentMaxDelay = model:GetAttribute("Delay") or 0
				model:SetAttribute("Delay", math.max(currentMaxDelay, currentTotalTime))
				SetOnce = true

			elseif SetOnce then
				local currentMaxDelay = model:GetAttribute("Delay") or 0
				model:SetAttribute("Delay", math.max(currentMaxDelay, TimeLife))
			end
		end

		table.insert(BindInfo.Events, Part:GetPropertyChangedSignal("Enabled"):Connect(function()
			SetTime()
		end))

		SetTime()

		table.insert(BindInfo.Events, Target:GetPropertyChangedSignal("Size"):Connect(Changed))

		Changed()

		if BindInfo.Emit then
			task.delay(Part:GetAttribute("EmitDelay") or 0, function()
				if Part and Part.Parent then
					Part:Emit(Part:GetAttribute("EmitCount") or 10)
				end
			end)

			if not BindInfo.MaxTime or TimeLife > BindInfo.MaxTime then
				BindInfo.MaxTime = TimeLife
			end
		end
	end,
}
local players = game:GetService("Players")
local replicated_storage = game:GetService("ReplicatedStorage")
local lighting = game:GetService("Lighting")
local run_service = game:GetService("RunService")
local tween_service = game:GetService("TweenService")
local debris = game:GetService("Debris")

local cam = workspace.CurrentCamera
local camera_shaker 
local start_tick = tick()
task.delay(0.5,function()
	camera_shaker = require(replicated_storage.CameraShaker)
	
	if not camera_shaker.Shaker then
		camera_shaker.Shaker = camera_shaker.new(Enum.RenderPriority.Camera.Value, function(args)
			cam.CFrame = cam.CFrame * args
		end)
	end
end)

--end)

local vfx = replicated_storage.Vfx
local part_cache = require(replicated_storage.PartCache)
local cache = part_cache:NewCache(100)
local camera_tweens = {}
local color_tween
local player = players.LocalPlayer


local function reset_camera_tweens()
	for i,v in camera_tweens do
		v:Pause()
	end
end

local function new_camera_tween(info,fov)
	reset_camera_tweens()
	
	local tween = tween_service:Create(cam,info,{FieldOfView = fov})
	tween:Play()
	table.insert(camera_tweens,tween)
end
_G.EFMod = _G.EFMod or {}
return { 
	-- will handle 90% of everything
	change_status = function(status, state)
		if typeof(status) == "table" then
			
			for i,v in status do
				local loop_time = os.time()
				local tag_name = typeof(i) == "string" and i or v.tag
				local status
				if typeof(v) ~= "table" then -- need to do it like this otherwise it will evaluate to nil
					status = v
				elseif typeof(v) == "table" and v.state then
					status = v.state
				end
				if status == nil then
					continue
				end
				if typeof(tag_name) ~= "string" then
					continue
				end
				_G.EFMod[tag_name] = status
			end
		elseif typeof(status) == "string" then
			_G.EFMod[status] = state
		else
			warn("not valid")
		end
	end,
	BeamExplosion = function(victim_root)
		local explosion_effect = vfx.Goku_Black.KameExplosion:Clone()
		explosion_effect.CFrame = CFrame.new(victim_root.Position)
		explosion_effect.Parent = workspace.Others.Effects
		
		for i,v in explosion_effect.Attachment:GetChildren() do
			if v:GetAttribute("EmitCount") then
				v:Emit(v:GetAttribute("EmitCount"))
			end
		end
		
		debris:AddItem(explosion_effect,7)
	end,
	SpaceCutterRush = function(state)
		local character = player.Character
		local root_part = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChildWhichIsA("Humanoid")
		
		if state == "Start" then
			warn("slime")
			local body_velocity = root_part:FindFirstChildWhichIsA("BodyVelocity")
			local gyro = root_part:FindFirstChildWhichIsA("BodyGyro")
			
			_G.Flying = true
			humanoid.PlatformStand = true
			local multiplier = Instance.new("NumberValue")
			multiplier.Name = "Multiplier"
			multiplier.Value = 160
			multiplier.Parent = body_velocity
			
			
			local conn
			conn = run_service.Stepped:Connect(function(dt)
				if not body_velocity.Parent then
					conn:Disconnect()
					gyro.MaxTorque = Vector3.zero
					return
				end
				if multiplier.Value <= 0 then
					_G.ForceStopFly = true
					body_velocity.MaxForce = Vector3.zero
					body_velocity.Velocity = Vector3.zero
					gyro.MaxTorque = Vector3.zero
					conn:Disconnect()
					multiplier:Destroy()
					return
				end
				--local safe_ray = workspace:Raycast(root_part.Position,(root_part.Position-(root_part.Position + cam.CFrame.LookVector * multiplier.Value).Unit * (root_part.Position-(root_part.Position + cam.CFrame.LookVector * multiplier.Value))),RaycastParams.new())
				--if safe_ray then
				--	warn("bro??")
				--	body_velocity.Velocity = cam.CFrame.LookVector * (safe_ray.Position-root_part.Position).Magnitude
				--else
				body_velocity.Velocity = cam.CFrame.LookVector * multiplier.Value
				--end
				gyro.CFrame = CFrame.lookAt(root_part.Position,root_part.Position + cam.CFrame.LookVector * multiplier.Value)
			end)
		elseif state == "Slow" then
			local velocity = root_part:FindFirstChildWhichIsA("BodyVelocity")
			if not velocity then
				return
			end
			local multiplier = velocity:FindFirstChild("Multiplier")
			if not multiplier then
				return
			end
			multiplier.Value = 300
			task.wait(0.1)
			tween_service:Create(multiplier,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{Value = 0}):Play()
		elseif state == "FastSlow" then
			local velocity = root_part:FindFirstChildWhichIsA("BodyVelocity")
			if not velocity then
				return
			end
			local multiplier = velocity:FindFirstChild("Multiplier")
			if not multiplier then
				return
			end
			tween_service:Create(multiplier,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{Value = 0}):Play()
		end
	end,
	SpiritSwordExcalibur = function(state)
		local character = player.Character
		local root_part = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChildWhichIsA("Humanoid")

		if state == "Start" then
			warn("slime")
			local body_velocity = root_part:FindFirstChildWhichIsA("BodyVelocity")
			local gyro = root_part:FindFirstChildWhichIsA("BodyGyro")

			_G.Flying = true
			humanoid.PlatformStand = true
			local multiplier = Instance.new("NumberValue")
			multiplier.Name = "Multiplier"
			multiplier.Value = 160
			multiplier.Parent = body_velocity


			local conn
			local Start = os.clock()
			
			conn = run_service.Stepped:Connect(function(dt)
				if not body_velocity.Parent then
					conn:Disconnect()
					gyro.MaxTorque = Vector3.zero
					return
				end
				
			end)
		elseif state == "Slow" then
			local velocity = root_part:FindFirstChildWhichIsA("BodyVelocity")
			if not velocity then
				return
			end
			local multiplier = velocity:FindFirstChild("Multiplier")
			if not multiplier then
				return
			end
			multiplier.Value = 300
			task.wait(0.1)
			tween_service:Create(multiplier,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{Value = 0}):Play()
		elseif state == "FastSlow" then
			local velocity = root_part:FindFirstChildWhichIsA("BodyVelocity")
			if not velocity then
				return
			end
			local multiplier = velocity:FindFirstChild("Multiplier")
			if not multiplier then
				return
			end
			tween_service:Create(multiplier,TweenInfo.new(0.25,Enum.EasingStyle.Linear),{Value = 0}):Play()
		end
	end,
	ForwardVelocity = function(speed,time)
		time = time or 2.5
		local character = player.Character
		if not character then
			return
		end
		local root_part = character:FindFirstChild("HumanoidRootPart")
		if not root_part then
			return
		end
		local velocity = root_part:FindFirstChildWhichIsA("BodyVelocity")
		local gyro = root_part:FindFirstChildWhichIsA("BodyGyro")
		
		--gyro.MaxTorque = Vector3.zero
		--velocity.MaxForce = Vector3.one * 9e9
		--velocity.Velocity = root_part.CFrame.lookVector * 240
		--warn(";-;")
		--task.delay(0.65,function()
		--	velocity.Velocity = Vector3.zero
		--end)
		local Vels = {}
		for i,v in root_part:GetChildren() do
			if v.Name == "BodyVelocity" or v.Name == "BodyGyro" then
				v.Parent = replicated_storage
				v:SetAttribute("MoveBack",true)
			elseif v.Name == "ForwardAttackVelocity" or v.Name == "TempGyro" then
				v:Destroy()
			end
		end
		 
		if not root_part:FindFirstChild("TempGyro") then
			local gyro = Instance.new("BodyGyro")
			gyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
			gyro.P = 500000
			gyro.Name = "TempGyro"
			gyro.Parent = root_part
			spawn(function()
				local conn
				conn = run_service.Stepped:Connect(function()
					if not gyro.Parent then
						conn:Disconnect()
						return
					end
					gyro.CFrame = CFrame.lookAt(root_part.Position, (root_part.Position + cam.CFrame.LookVector))
				end)
			end)
		end
		local value = type(speed) == "number" and speed or 140
		local vel = Instance.new("BodyVelocity")
		vel.MaxForce = Vector3.one * 9e9
		vel.Name = "ForwardAttackVelocity"
		vel.Velocity = root_part.CFrame.lookVector * value
		vel.Parent = root_part
		debris:AddItem(vel,time or 2.5)
		
		for i = 1,5 do
			if not vel.Parent then
				break
			end
			local mult = speed - (i * (speed / 5))
			value = mult
			vel.Velocity = root_part.CFrame.lookVector * mult
			task.wait(time / 8)
		end
	end,
	TripleExplosion = function(eroot)
		local asset = vfx.Goku_Black.explosion:Clone()
		asset.Parent = workspace.Others.Effects
		asset.CFrame = CFrame.new(eroot.Position)
		--asset:SetPrimaryPartCFrame(CFrame.new(eroot.Position))
		
		for i,v in asset:GetDescendants() do
			if not v:GetAttribute("EmitCount") then
				continue
			end
			if v:IsA("ParticleEmitter") then
				task.delay( (v:GetAttribute("EmitDelay") or 0),function()
					v:Emit(v:GetAttribute("EmitCount"))
				end)
			end
		end
	end,
	MoveBackVel = function()
		local character = player.Character
		if not character then
			return
		end
		local root_part = character:FindFirstChild("HumanoidRootPart")
		if not root_part then
			return
		end
		for i,v in root_part:GetChildren() do
			if v.Name == "ForwardAttackVelocity" or v.Name == "TempGyro" then
				v:Destroy()
			end
		end
		_G.ForceFly = true
		for i,v in replicated_storage:GetChildren() do
			if v:GetAttribute("MoveBack") then
				v.Parent = root_part
			end
		end
		--local velocity = root_part:FindFirstChildWhichIsA("BodyVelocity")
		--local gyro = root_part:FindFirstChildWhichIsA("BodyGyro")
		--gyro.MaxTorque = Vector3.zero
		--velocity.Velocity = Vector3.zero
	end,
	Stop = function()
		local character = player.Character
		if not character then
			return
		end
		local root_part = character:FindFirstChild("HumanoidRootPart")
		if not root_part then
			return
		end
		for i,v in root_part:GetChildren() do
			if v.Name == "ForwardAttackVelocity" or v.Name == "TempGyro" then
				v:Destroy()
			end
		end
		--[[_G.ForceFly = true
		for i,v in replicated_storage:GetChildren() do
			if v:GetAttribute("MoveBack") then
				v.Parent = root_part
			end
		end]]
		--local velocity = root_part:FindFirstChildWhichIsA("BodyVelocity")
		--local gyro = root_part:FindFirstChildWhichIsA("BodyGyro")
		--gyro.MaxTorque = Vector3.zero
		--velocity.Velocity = Vector3.zero
	end,
	BindingBlackCamera = function(state,tween_duration)
		if state == "Charge" then
			--reset_camera_tweens()
			local color_correction = Instance.new("ColorCorrectionEffect")
			color_correction.Name = "BindingBlackCC"
			color_correction.Parent = lighting
			debris:AddItem(color_correction,15)
			
			warn(camera_shaker.Presets)
			camera_shaker.Shaker:ShakeSustain(camera_shaker.Presets.HoldShake)
			new_camera_tween(TweenInfo.new(tween_duration,Enum.EasingStyle.Linear),110)
			color_tween = tween_service:Create(color_correction,TweenInfo.new(tween_duration,Enum.EasingStyle.Linear),{TintColor = Color3.fromRGB(255, 42, 46)})
			color_tween:Play()
			--local tween = tween_service:Create(cam,TweenInfo.new(tween_duration,Enum.EasingStyle.Linear),{FieldOfView = 95})
			--tween:Play()
			--table.insert(camera_tweens,tween)
		elseif state == "Release" then
			--reset_camera_tweens()
			camera_shaker.Shaker:StopSustained(0.1)
			camera_shaker.Shaker:ShakeOnce(8,24,0.1,0.25)
			task.delay(0.2,function()
				camera_shaker.Shaker:ShakeSustain(camera_shaker.Presets.RoughVibration)
			end)
			local t_info = TweenInfo.new(0.25,Enum.EasingStyle.Linear)
			local color_correction = lighting:FindFirstChild("BindingBlackCC")
			
			local blur_effect = Instance.new("BlurEffect")
			blur_effect.Name = "BindingBlackBlur"
			blur_effect.Size = 0
			blur_effect.Parent = lighting
			--debris:AddItem(color_correction,12)
			
			if color_correction then
				if color_tween then
					color_tween:Pause()
				end
				reset_camera_tweens()
				tween_service:Create(color_correction,t_info,{TintColor = Color3.fromRGB(255, 42, 46)}):Play()
			end
			tween_service:Create(blur_effect,t_info,{Size = 3}):Play()
			new_camera_tween(t_info,135)
		elseif state == "Over" then
			local tween_info = TweenInfo.new(0.75,Enum.EasingStyle.Linear)
			camera_shaker.Shaker:StopSustained(0.1)
			for i,v in lighting:GetChildren() do
				if v.Name == "BindingBlackCC" then
					tween_service:Create(v,tween_info,{TintColor = Color3.fromRGB(255, 255, 255)}):Play()
					debris:AddItem(v,0.8)
				elseif v.Name == "BindingBlackBlur" then
					tween_service:Create(v,tween_info,{Size = 0}):Play()
					debris:AddItem(v,0.8)
				end
			end
			new_camera_tween(tween_info,70)
			--tween_service:Create(cam,tween_info,{FieldOfView = 70}):Play()
		end
	end,
	-- can be fired to client by server
}
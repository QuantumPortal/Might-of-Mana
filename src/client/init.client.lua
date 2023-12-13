local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService('TweenService')
local player = game:GetService("Players").LocalPlayer
local mouse = player:GetMouse()
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart")
local humanoid = character:FindFirstChild("Humanoid") or character:WaitForChild("Humanoid")
local upperTorso = character:FindFirstChild("UpperTorso") or character:WaitForChild("UpperTorso")
local waist = upperTorso:FindFirstChild("Waist") or upperTorso:WaitForChild("Waist")
local head = character:FindFirstChild("Head") or character:WaitForChild("Head")
local neck = head:FindFirstChild("Neck") or head:WaitForChild("Neck")
local camera = workspace.Camera
--local nbart = workspace:FindFirstChild("nbart") or workspace:WaitForChild("nbart")
--local feedo = workspace:FindFirstChild("feedo") or workspace:WaitForChild("feedo")
--local blo = workspace:FindFirstChild("BLO") or workspace:WaitForChild("BLO")
local cameraTilt = 0
local baseWalkSpeed = 9

local cameraTween = TweenInfo.new(
	0.7,
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.Out,
	0,
	false,
	0
)

humanoid.WalkSpeed = baseWalkSpeed
humanoid.AutoRotate = false
--[[
local function onInputBegan(input, _gameProcessed)
	if input.KeyCode == Enum.KeyCode.E then
		print("balingus." .. player.Name)
		balingus:FireServer();
	elseif input.KeyCode == Enum.KeyCode.Q then
		print("pazingus." .. player.Name)
		pazingus:FireServer();
	end
end
local function haloCheck(step)
	balingus:FireServer(step)
end
]]--

--UserInputService.InputBegan:Connect(onInputBegan)

local function twoVectorToAngle(x, y)

	if x == 0 and y == 0 then
		return 0
	elseif x == 0 and y ~= 0 then
		return -1*math.rad(90 * math.sign(y))
	elseif x ~= 0 and y == 0 then
		return -1*math.rad(90 - math.sign(x) * 90)
	elseif x > 0 and y > 0 then
		print("q1")
		return -1*math.atan(math.abs(y)/math.abs(x))
	elseif x < 0 and y > 0 then
		print("q4")
		return-1*math.rad(180 - math.deg(math.atan(math.abs(y)/math.abs(x))))
	elseif x < 0 and y < 0 then
		print("q3")
		return math.rad(180-math.deg(math.atan(math.abs(y)/math.abs(x))))
	elseif x > 0 and y < 0 then
		print("q2")
		return math.rad(math.deg(math.atan(math.abs(y)/math.abs(x))))
	end
end

RunService.RenderStepped:Connect(function(delay)
	local x, y, z = CFrame.lookAt(rootPart.CFrame.Position, Vector3.new(mouse.Hit.Position.X,mouse.Hit.Position.Y,mouse.Hit.Position.Z)):ToOrientation()
	rootPart.CFrame = rootPart.CFrame:Lerp(CFrame.new(rootPart.CFrame.Position) * CFrame.fromEulerAnglesXYZ(0,y,0),0.2)
	
	waist.C0 = waist.C0:Lerp(CFrame.new(waist.C0.Position) * CFrame.fromEulerAnglesXYZ(0.45*x,0,0.45*z),0.35)
	neck.C0 = neck.C0:Lerp(CFrame.new(neck.C0.Position) * CFrame.fromEulerAnglesXYZ(0.55*x,0,0.55*z), 0.35)
	
	
	

	--local x, y, z = CFrame.Angles(math.rad(humanoid.MoveDirection.X * 90),math.rad(humanoid.MoveDirection.Y * 90),math.rad(humanoid.MoveDirection.Z * 90)):ToOrientation()

	--local x1, y1, z1 = rootPart.CFrame.Rotation:ToOrientation()

	--print(math.deg(x),math.deg(y),math.deg(z))
	
	--print(humanoid.MoveDirection)
	--local v = humanoid.MoveDirection
	--smegus.CFrame = CFrame.new(smegus.CFrame.Position)* CFrame.fromEulerAnglesXYZ(math.atan(humanoid.MoveDirection.Z/humanoid.MoveDirection.X),
	--local grash = twoVectorToAngle(v.X,v.Z)
	--local foop = CFrame.fromEulerAnglesXYZ(0,grash,0)
	--nbart.CFrame = CFrame.new(nbart.CFrame.Position) * rootPart.CFrame.Rotation * CFrame.fromEulerAnglesXYZ(0,math.rad(90),0)

	--feedo.CFrame = CFrame.new(feedo.CFrame.Position) * foop

	--blo.CFrame = CFrame.new(blo.CFrame.Position) * rootPart.CFrame.Rotation * CFrame.fromEulerAnglesXYZ(0,math.rad(90),0) * waist.C0.Rotation * CFrame.fromEulerAnglesXYZ(0,0,0)
	--nbart.CFrame = nbart.CFrame * CFrame.fromEulerAnglesXYZ(0,math.rad(5),0)
	--CFrame.fromEulerAnglesXYZ(0,math.rad(-90),0)
	
	--math.deg(Vector3.new(nbart.CFrame:ToOrientation()).Y)

	

	
	if UserInputService:IsKeyDown(Enum.KeyCode.A) and UserInputService:IsKeyDown(Enum.KeyCode.D) then
		cameraTilt *= 0.9
	elseif UserInputService:IsKeyDown(Enum.KeyCode.A) then
		cameraTilt += (14.5 - cameraTilt)/11
	elseif UserInputService:IsKeyDown(Enum.KeyCode.D) then
		cameraTilt -= (14.5 + cameraTilt)/11
	else
		cameraTilt *= 0.9
	end
	
	
	TweenService:Create(camera,cameraTween, { CFrame = camera.CFrame * CFrame.Angles(0,0,math.rad(cameraTilt))}):Play()
	

	if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
		if humanoid.WalkSpeed < baseWalkSpeed + 10 then
			humanoid.WalkSpeed += (baseWalkSpeed + 10 - humanoid.WalkSpeed)/6
		end
	else
		if humanoid.WalkSpeed > baseWalkSpeed then
			humanoid.WalkSpeed -= (humanoid.WalkSpeed - baseWalkSpeed)/6
		end
		
	end 

	print(humanoid.WalkSpeed)
	camera.FieldOfView = 70 - 9 + humanoid.WalkSpeed
	--Joint.C0 = CFrame.lookAt(Joint.C0.Position, Vector3.new(Mouse.Hit.Position.X, Joint.C0.Position.Y, math.min(-Joint.C0.LookVector.Z, Mouse.Hit.Position.Z))) * if RigType == "R6" then CFrame.Angles(math.pi / 2, math.pi, 0) else CFrame.Angles(0, 0, 0)
end)

--[[
game:GetService("RunService").RenderStepped:Connect(function()
    if humanoid.WalkSpeed > 16 or isRunning == true then --or whatever you call it when you run
              player.Character.Animate.walk.WalkAnim.AnimationId = "rbxassetid://"..animId
    end
end)
]]--

print("glorf")


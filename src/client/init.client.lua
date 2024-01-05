
local player = game:GetService("Players").LocalPlayer

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService('TweenService')

local mouse = player:GetMouse()
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart")
local humanoid = character:FindFirstChild("Humanoid") or character:WaitForChild("Humanoid")
local upperTorso = character:FindFirstChild("UpperTorso") or character:WaitForChild("UpperTorso")
local waist = upperTorso:FindFirstChild("Waist") or upperTorso:WaitForChild("Waist")
local head = character:FindFirstChild("Head") or character:WaitForChild("Head")
local neck = head:FindFirstChild("Neck") or head:WaitForChild("Neck")
local camera = workspace.Camera
local cameraTilt = 0
local baseWalkSpeed = 9
local fireball = game.ReplicatedStorage.Shared:FindFirstChild("Fireball") or game.ReplicatedStorage.Shared:WaitForChild("Fireball")

local cameraTween = TweenInfo.new(
	0.7,
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.Out,
	0,
	false,
	0
)

local torsoTween = TweenInfo.new(
	0.2,
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.Out,
	0,
	false,
	0
)

humanoid.WalkSpeed = baseWalkSpeed
humanoid.AutoRotate = false

game:GetService("UserInputService").InputBegan:Connect(function(input, _gameProcessed)
	if input.KeyCode == Enum.KeyCode.E then
		fireball:FireServer(player);
	elseif input.KeyCode == Enum.KeyCode.Q then
		player:SetAttribute("Mana",player:GetAttribute("Mana") - 20)
		player:SetAttribute("Shield",player:GetAttribute("Shield") - 10)
	end
end)




--UserInputService.InputBegan:Connect(onInputBegan)






RunService.RenderStepped:Connect(function(delay)
	local x, y, z = CFrame.lookAt(rootPart.CFrame.Position, Vector3.new(mouse.Hit.Position.X,mouse.Hit.Position.Y,mouse.Hit.Position.Z)):ToOrientation()
	rootPart.CFrame = rootPart.CFrame:Lerp(CFrame.new(rootPart.CFrame.Position) * CFrame.fromEulerAnglesXYZ(0,y,0),0.2)
	
	waist.C0 = waist.C0:Lerp(CFrame.new(waist.C0.Position) * CFrame.fromEulerAnglesXYZ(0.45*x,0,0.45*z),0.35)
	neck.C0 = neck.C0:Lerp(CFrame.new(neck.C0.Position) * CFrame.fromEulerAnglesXYZ(0.55*x,0,0.55*z), 0.35)
	local moveAngle = rootPart.CFrame.LookVector:Angle(humanoid.MoveDirection,rootPart.CFrame.LookVector)
	if moveAngle > math.pi/2 then
		moveAngle = math.pi - moveAngle
	end
	TweenService:Create(waist,torsoTween, {C0 = waist.C0 * CFrame.fromEulerAnglesXYZ(math.sign(((CFrame.fromEulerAnglesXYZ(0,math.pi/2,0) * rootPart.CFrame).LookVector:Cross(humanoid.MoveDirection)).Y) * math.cos(moveAngle) * (CFrame.fromEulerAnglesXYZ(0,math.pi/2,0) * rootPart.CFrame).LookVector:Angle(humanoid.MoveDirection,rootPart.CFrame.LookVector)/(4),0,math.sign((rootPart.CFrame.LookVector:Cross(humanoid.MoveDirection)).Y) * rootPart.CFrame.LookVector:Angle(humanoid.MoveDirection,rootPart.CFrame.LookVector)/5 * math.sin(moveAngle))

	}):Play()
	
	
	--blo.CFrame *= CFrame.fromEulerAnglesXYZ(0,0,math.sign((rootPart.CFrame.LookVector:Cross(humanoid.MoveDirection)).Y)* pla * math.sin(math.rad(horse)))
	--blo.CFrame *= CFrame.fromEulerAnglesXYZ(math.sign(((CFrame.fromEulerAnglesXYZ(0,math.rad(90),0) * rootPart.CFrame).LookVector:Cross(humanoid.MoveDirection)).Y) * math.cos(math.rad(horse))* pla2,0,0)

	


	
	--local x, y, z = CFrame.Angles(math.rad(humanoid.MoveDirection.X * 90),math.rad(humanoid.MoveDirection.Y * 90),math.rad(humanoid.MoveDirection.Z * 90)):ToOrientation()

	--local x1, y1, z1 = rootPart.CFrame.Rotation:ToOrientation()

	--print(math.deg(x),math.deg(y),math.deg(z))
	
	--print(humanoid.MoveDirection)
	
	--smegus.CFrame = CFrame.new(smegus.CFrame.Position)* CFrame.fromEulerAnglesXYZ(math.atan(humanoid.MoveDirection.Z/humanoid.MoveDirection.X),
	
	
	--nbart.CFrame = CFrame.new(nbart.CFrame.Position) * rootPart.CFrame.Rotation * CFrame.fromEulerAnglesXYZ(0,math.rad(90),0)
	--feedo.CFrame = CFrame.new(feedo.CFrame.Position) * foop

	
	

	--print(math.deg(rootPart.CFrame.LookVector:Angle(humanoid.MoveDirection,rootPart.CFrame.LookVector)))
	
	
	
	--blo.CFrame = rootPart.CFrame * waist.C0.Rotation * CFrame.fromEulerAnglesXYZ(0,0,rootPart.CFrame.LookVector:Angle(humanoid.MoveDirection,rootPart.CFrame.LookVector)/7) + rootPart.CFrame.LookVector * Vector3.new(5,5,5)

	--blo.CFrame = rootPart.CFrame * waist.C0.Rotation  + rootPart.CFrame.LookVector * Vector3.new(5,5,5)
	
	
	

	--math.sign((rootPart.CFrame.LookVector:Cross(humanoid.MoveDirection)).Z)*rootPart.CFrame.LookVector:Angle(humanoid.MoveDirection,rootPart.CFrame.LookVector)*speen
	
	
	
	
	--math.sign((rootPart.CFrame.LookVector:Cross(humanoid.MoveDirection)).X)*rootPart.CFrame.LookVector:Angle(humanoid.MoveDirection,rootPart.CFrame.LookVector)/7 * math.cos(math.rad(horse)),0,0)
	--nbart.CFrame = nbart.CFrame * CFrame.fromEulerAnglesXYZ(0,math.rad(5),0)
	--CFrame.fromEulerAnglesXYZ(0,math.rad(-90),0)
	
	--math.deg(Vector3.new(nbart.CFrame:ToOrientation()).Y)

	

	
	--[[
	if UserInputService:IsKeyDown(Enum.KeyCode.A) and UserInputService:IsKeyDown(Enum.KeyCode.D) then
		cameraTilt *= 0.95
	elseif UserInputService:IsKeyDown(Enum.KeyCode.A) then
		cameraTilt += (14 - cameraTilt)/11
	elseif UserInputService:IsKeyDown(Enum.KeyCode.D) then
		cameraTilt -= (14 + cameraTilt)/11
	else
		cameraTilt *= 0.95
	end
	]]--
	
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



player.CharacterAdded:Connect(function(character)
	player.CharacterAppearanceLoaded:Connect(function()
		
	end)
end)



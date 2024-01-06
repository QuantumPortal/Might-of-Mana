
local Players = game:GetService("Players")
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

local characterFunctions = require(script.character)
--local fireball = game.ReplicatedStorage.Shared:FindFirstChild("Fireball") or game.ReplicatedStorage.Shared:WaitForChild("Fireball")

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

game:GetService("UserInputService").InputBegan:Connect(function(input, _gameProcessed)
	if input.KeyCode == Enum.KeyCode.E then
		--fireball:FireServer(player);
	elseif input.KeyCode == Enum.KeyCode.Q then
		player:SetAttribute("Mana",player:GetAttribute("Mana") - 20)
		player:SetAttribute("Shield",player:GetAttribute("Shield") - 10)
	end
end)


RunService.RenderStepped:Connect(function(delay)
	characterFunctions.DirectionalTilt(player)
	characterFunctions.LookToMouse(player)
	

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

	
end)

--[[
player.CharacterAdded:Connect(function(character)
	print("fla")
	--[[
	player.CharacterAppearanceLoaded:Connect(function()
		print("bla")
		RunService.RenderStepped:Connect(LoadedRStepLoop())
	end)
	
end)
]]--

--[[
game:GetService("RunService").RenderStepped:Connect(function()
    if humanoid.WalkSpeed > 16 or isRunning == true then --or whatever you call it when you run
              player.Character.Animate.walk.WalkAnim.AnimationId = "rbxassetid://"..animId
    end
end)
]]--



print("glorf")







local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService('TweenService')

local characterFunctions = require(script.character)
local cameraFunctions = require(script.camera)

local player = Players.LocalPlayer


local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:FindFirstChild("Humanoid") or character:WaitForChild("Humanoid")
local camera = workspace.Camera
local cameraTilt = 0
local baseWalkSpeed = 9

local baseFOV = 70

--local fireball = game.ReplicatedStorage.Shared:FindFirstChild("Fireball") or game.ReplicatedStorage.Shared:WaitForChild("Fireball")

UserInputService.InputBegan:Connect(function(input, _gameProcessed)
	if input.KeyCode == Enum.KeyCode.E then
		--fireball:FireServer(player);
	elseif input.KeyCode == Enum.KeyCode.Q then
		player:SetAttribute("Mana",player:GetAttribute("Mana") - 20)
		player:SetAttribute("Shield",player:GetAttribute("Shield") - 10)
	end	
end)

humanoid.WalkSpeed = baseWalkSpeed
humanoid.AutoRotate = false

player.CharacterAdded:Connect(function(character)
	humanoid = character:WaitForChild("Humanoid")
	humanoid.WalkSpeed = baseWalkSpeed
	humanoid.AutoRotate = false
end)

RunService.RenderStepped:Connect(function(delay)

	--Held Key section

	--CameraTilt
	if UserInputService:IsKeyDown(Enum.KeyCode.A) and UserInputService:IsKeyDown(Enum.KeyCode.D) then
		cameraTilt *= 0.93
	elseif UserInputService:IsKeyDown(Enum.KeyCode.A) then
		cameraTilt += (14-cameraTilt)/8
	elseif UserInputService:IsKeyDown(Enum.KeyCode.D) then
		cameraTilt += (-14-cameraTilt)/8
	else
		cameraTilt *= 0.93
	end
	cameraTilt = math.sign(cameraTilt) * math.floor(math.abs(cameraTilt)*100)/100
	print(cameraTilt)
	--Sprint speedup/slowdown
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
		if humanoid.WalkSpeed < baseWalkSpeed + 10 then
			humanoid.WalkSpeed += (baseWalkSpeed + 10 - humanoid.WalkSpeed)/6
		end
	else
		if humanoid.WalkSpeed > baseWalkSpeed then
			humanoid.WalkSpeed -= (humanoid.WalkSpeed - baseWalkSpeed)/6
		end
	end 

	
	if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
		characterFunctions.DirectionalTilt(player)
		characterFunctions.LookToMouse(player)
		cameraFunctions.CameraTilt(camera, cameraTilt)
		cameraFunctions.UpdateFOV(camera,baseFOV,humanoid.WalkSpeed - baseWalkSpeed)
	end
end)


humanoid.Died:Connect(function()
	cameraFunctions.UpdateFOV(camera,baseFOV,0)
end)

print("glorf")







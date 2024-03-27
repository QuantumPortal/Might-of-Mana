local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local characterFunctions = require(script.character)
local cameraFunctions = require(script.camera)

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:FindFirstChild("Humanoid") or character:WaitForChild("Humanoid")
local camera = workspace.Camera
local cameraTilt = 0

local baseFOV = 70

--local fireball = game.ReplicatedStorage.Shared:FindFirstChild("Fireball") or game.ReplicatedStorage.Shared:WaitForChild("Fireball")
local test = game.ReplicatedStorage.Remotes:WaitForChild("Test")
local SlowTest = game.ReplicatedStorage.Remotes:WaitForChild("SlowTest")
local SprintBonus = 0

local CoreStats = player:WaitForChild("CoreStats")
local Mana = CoreStats:WaitForChild("Mana")
local Shield = CoreStats:WaitForChild("Shield")
local BaseWalkSpeed = CoreStats:WaitForChild("BaseWalkSpeed")
local SprintSpeed = CoreStats:WaitForChild("SprintSpeed")

local StatusAbnormalities = player:WaitForChild("StatusAbnormalities")
local Slow = StatusAbnormalities:WaitForChild("Slow")

local Buffs = player:WaitForChild("Buffs")
local Speed = Buffs:WaitForChild("Speed")

UserInputService.InputBegan:Connect(function(input, _gameProcessed)
	if input.KeyCode == Enum.KeyCode.E then
		SlowTest:FireServer()
	elseif input.KeyCode == Enum.KeyCode.Q then
		test:FireServer(mouse.Hit.Position)
	end
end)

humanoid.WalkSpeed = BaseWalkSpeed.Value
humanoid.AutoRotate = false

player.CharacterAdded:Connect(function(character)
	humanoid = character:WaitForChild("Humanoid")
	humanoid.WalkSpeed = BaseWalkSpeed.Value
	humanoid.AutoRotate = false
end)


BaseWalkSpeed.Changed:Connect(function()
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
		humanoid.WalkSpeed = BaseWalkSpeed.Value * SprintSpeed.Value
	else
		humanoid.WalkSpeed = BaseWalkSpeed.Value
	end
	
end)


RunService.RenderStepped:Connect(function(delay)

	--Held Key section

	--CameraTilt
	if UserInputService:IsKeyDown(Enum.KeyCode.A) and UserInputService:IsKeyDown(Enum.KeyCode.D) then
		cameraTilt *= 0.93
	elseif UserInputService:IsKeyDown(Enum.KeyCode.A) then
		cameraTilt += (15-cameraTilt)/8
	elseif UserInputService:IsKeyDown(Enum.KeyCode.D) then
		cameraTilt += (-15-cameraTilt)/8
	else
		cameraTilt *= 0.93
	end
	cameraTilt = math.sign(cameraTilt) * math.floor(math.abs(cameraTilt)*100)/100

	--Sprint speedup/slowdown

	if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
		SprintBonus += (SprintSpeed.Value-SprintBonus)/6
	else
		SprintBonus -= (SprintBonus-1)/6
		if SprintBonus < 1 then
			SprintBonus = 1
		end
	end

	humanoid.WalkSpeed = (1+Speed.Value) * (1-Slow.Value/100) * ( BaseWalkSpeed.Value * SprintBonus )

	if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
		characterFunctions.DirectionalTilt(player)
		characterFunctions.LookToMouse(player)
		cameraFunctions.CameraTilt(camera, cameraTilt)
		cameraFunctions.UpdateFOV(camera,baseFOV,humanoid.WalkSpeed - BaseWalkSpeed.Value)
	end
end)


humanoid.Died:Connect(function()
	cameraFunctions.UpdateFOV(camera,baseFOV,0)
end)


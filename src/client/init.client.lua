local characterFunctions = require(script.Character)
local cameraFunctions = require(script.Camera)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")


local SprintStatus = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SprintStatus")
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:FindFirstChild("Humanoid") or character:WaitForChild("Humanoid")
local camera = workspace.Camera
local cameraTilt = 0
local mousePositionRemote = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("System"):WaitForChild("GetMousePos")

local baseFOV = 70

--local fireball = game.ReplicatedStorage.Shared:FindFirstChild("Fireball") or game.ReplicatedStorage.Shared:WaitForChild("Fireball")
local test = game.ReplicatedStorage.Remotes:WaitForChild("Test")
local SlowTest = game.ReplicatedStorage.Remotes:WaitForChild("SlowTest")
local SprintBonus = 0

local CoreStats = player.Character.Humanoid.DataFolder.CoreStats
local Mana = CoreStats:WaitForChild("Mana")
local Shield = CoreStats:WaitForChild("Shield")
local BaseWalkSpeed = CoreStats:WaitForChild("BaseWalkSpeed")
local SprintSpeed = CoreStats:WaitForChild("SprintMultiplier")

local StatusAbnormalities = player.Character.Humanoid.DataFolder.StatusAbnormalities
local Slow = StatusAbnormalities:WaitForChild("Slow")

local Buffs = player.Character.Humanoid.DataFolder.Buffs
local Speed = Buffs:WaitForChild("Speed")


local keybinds = {
	[Enum.KeyCode.Q] = "spell_1",
	[Enum.KeyCode.E] = "spell_2",
	[Enum.KeyCode.R] = "spell_3",
	[Enum.KeyCode.F] = "flash",
}

UserInputService.InputBegan:Connect(function(input, _gameProcessed)
	if keybinds[input.KeyCode] then
		game.ReplicatedStorage.Remotes.Keybinds.Rebindable:FireServer(keybinds[input.KeyCode])
	end
end)


player.CharacterAdded:Connect(function(character)
	humanoid = character:WaitForChild("Humanoid")
	humanoid.WalkSpeed = BaseWalkSpeed.Value
	humanoid.AutoRotate = false
end)


mousePositionRemote.OnClientInvoke = function()
	return mouse.Hit
end

RunService.RenderStepped:Connect(function(delay)
	SprintStatus:FireServer(UserInputService:IsKeyDown(Enum.KeyCode.LeftShift))

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




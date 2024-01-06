local Players = game:GetService("Players")
local player = game:GetService("Players").LocalPlayer

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService('TweenService')

local mouse = player:GetMouse()
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart")
local humanoid = character:FindFirstChild("Humanoid") or character:WaitForChild("Humanoid")
local camera = workspace.Camera
local cameraTilt = 0
local baseWalkSpeed = 9

local characterFunctions = require(script.character)
local cameraFunctions = require(script.camera)
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
	if UserInputService:IsKeyDown(Enum.KeyCode.A) and UserInputService:IsKeyDown(Enum.KeyCode.D) then
		cameraTilt *= 0.93
		cameraTilt = math.sign(cameraTilt) * math.floor(math.abs(cameraTilt)*100)/100
	elseif UserInputService:IsKeyDown(Enum.KeyCode.A) then
		print("fwaa")
		cameraTilt += (14-cameraTilt)/8
		cameraTilt = math.ceil(cameraTilt*100)/100
	elseif UserInputService:IsKeyDown(Enum.KeyCode.D) then
		cameraTilt += (-14-cameraTilt)/8
		cameraTilt = math.floor(cameraTilt*100)/100
	else
		cameraTilt *= 0.93
		cameraTilt = math.sign(cameraTilt) * math.floor(math.abs(cameraTilt)*100)/100
	end
	

	print(cameraTilt)
	if player.Character.Humanoid and player.Character.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
		characterFunctions.DirectionalTilt(player)
		characterFunctions.LookToMouse(player)
		cameraFunctions.CameraTilt(camera, cameraTilt)
	end
	
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







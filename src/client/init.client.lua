local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local balingus = game.ReplicatedStorage.Shared.balingus
local pazingus = game.ReplicatedStorage.Shared.pazingus
local player = game:GetService("Players").LocalPlayer

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
UserInputService.InputBegan:Connect(onInputBegan)
RunService.RenderStepped:Connect(haloCheck)

print("Yowza!")
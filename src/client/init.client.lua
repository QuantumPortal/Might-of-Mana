local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = game:GetService("Players").LocalPlayer
local mouse = player:GetMouse()
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart")
local humanoid = character:FindFirstChild("Humanoid") or character:WaitForChild("Humanoid")
local upperTorso = character:FindFirstChild("UpperTorso") or character:WaitForChild("UpperTorso")
local waist = upperTorso:FindFirstChild("Waist") or upperTorso:WaitForChild("Waist")
local head = character:FindFirstChild("Head") or character:WaitForChild("Head")
local neck = head:FindFirstChild("Neck") or head:WaitForChild("Neck")

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

RunService.RenderStepped:Connect(function(delay)
	local x, y, z = CFrame.lookAt(rootPart.CFrame.Position, Vector3.new(mouse.Hit.Position.X,mouse.Hit.Position.Y,mouse.Hit.Position.Z)):ToOrientation()
	rootPart.CFrame = rootPart.CFrame:Lerp(CFrame.new(rootPart.CFrame.Position) * CFrame.fromEulerAnglesXYZ(0,y,0),0.2)
	
	waist.C0 = waist.C0:Lerp(CFrame.new(waist.C0.Position) * CFrame.fromEulerAnglesXYZ(4*x/10,0,4*z/10),0.35)
	neck.C0 = neck.C0:Lerp(CFrame.new(neck.C0.Position) * CFrame.fromEulerAnglesXYZ(6*x/10,0,6*z/10), 0.35)
	
	--Joint.C0 = CFrame.lookAt(Joint.C0.Position, Vector3.new(Mouse.Hit.Position.X, Joint.C0.Position.Y, math.min(-Joint.C0.LookVector.Z, Mouse.Hit.Position.Z))) * if RigType == "R6" then CFrame.Angles(math.pi / 2, math.pi, 0) else CFrame.Angles(0, 0, 0)
end)

print("Yowza!")
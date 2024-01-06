local players = game:GetService("Players")
local PolicyService = game:GetService("PolicyService")
--local fireball = game.ReplicatedStorage.Shared:FindFirstChild("Fireball") or game.ReplicatedStorage.Shared:WaitForChild("Fireball")


players.PlayerAdded:Connect(function(player)

    player:SetAttribute("MaxShield",100)
    player:SetAttribute("Shield",100)

    player:SetAttribute("MaxMana",100)
    player:SetAttribute("Mana",100)
    
	

    player.CharacterAppearanceLoaded:Connect(function(character)
        --character.Animate.walk.WalkAnim.AnimationId = "rbxassetid://15872307313"
		--character.Animate.run.RunAnim.AnimationId = "rbxassetid://15872263018"
    end)

    
end)

--[[
fireball.OnServerEvent:Connect(function(player)
    
    print(player:GetAttribute("FireballCooldown"))

    print(tick(3))

    if tick() - player:GetAttribute("FireballCooldown") >= 5000 then
        players:SetAttribute("FireballCoolDown",tick())
        print("flurg")
    end
end)
]]--

--[[
local balingus = game.ReplicatedStorage.Shared.balingus
local pazingus = game.ReplicatedStorage.Shared.pazingus

local TweenService = game:GetService("TweenService")
print("Hello world, from server!")

function createHaloPart(player,angle,tilt)
    local haloPart = Instance.new("Part")
    haloPart.Color = Color3.new(0.945098, 0.576470, 0.827450)
    haloPart.Shape = Enum.PartType.Cylinder
    haloPart.Parent = player.Character.Head.HaloRoot
    haloPart.Material = Enum.Material.Neon
    haloPart.Size = Vector3.new(0.0975,0.1,0.1)

    haloPart.CFrame = player.Character.Head.HaloRoot.CFrame * CFrame.fromEulerAnglesXYZ(math.rad(90),0,0)
    haloPart.CFrame += Vector3.new(0.75,0.75,0.75) * haloPart.CFrame.LookVector
    haloPart.CFrame *= CFrame.fromEulerAnglesXYZ(math.rad(90+tilt),math.rad(angle),0)
    haloPart.CFrame += haloPart.CFrame.LookVector * Vector3.new(1.1,1.1,1.1)

    
end

function toggleHalo(player)
    player:SetAttribute("HaloDeploy",not player:GetAttribute("HaloDeploy"))
end

function onJoin(player)
    print("Cool")
    player:SetAttribute("HaloDeploy",false)
    player:SetAttribute("HaloDeployAmount",0)
    player.CharacterAppearanceLoaded:Connect(onLoad)
    
end

function onLoad(character)
    local HaloRoot = Instance.new("Part")
    HaloRoot.Parent = character.Head
    HaloRoot.Size = Vector3.new(0.1,0.1,0.1)
    HaloRoot.Transparency = 100
    HaloRoot.Name = "HaloRoot"
    HaloRoot.CFrame = character.Head.CFrame
    HaloRoot.CanCollide = false

    local Weld = Instance.new("WeldConstraint")
    Weld.Part0 = character.Head
    Weld.Part1 = HaloRoot
    Weld.Parent = character.Head


    for i = 1,73 do
        local HaloPart = Instance.new("Part")
        HaloPart.Name = "Halo" .. (i - 1)
        HaloPart.Parent = HaloRoot
        HaloPart.Color = Color3.new(0.945098, 0.576470, 0.827450)
        HaloPart.Shape = Enum.PartType.Cylinder
        HaloPart.Material = Enum.Material.Neon
        HaloPart.Size = Vector3.new(0.0975,0.1,0.1)
        HaloPart.CanCollide = false
        HaloPart.Transparency = 100
        HaloPart.CFrame = HaloRoot.CFrame * CFrame.fromEulerAnglesXYZ(math.rad(90),0,0)
        HaloPart.CFrame += Vector3.new(0.75,0.75,0.75) * HaloPart.CFrame.LookVector
        HaloPart.CFrame *= CFrame.fromEulerAnglesXYZ(math.rad(90),math.rad(5 * (i-1)),0)
        HaloPart.CFrame += HaloPart.CFrame.LookVector * Vector3.new(1.1,1.1,1.1)

        local Weld = Instance.new("WeldConstraint")
        Weld.Part0 = HaloRoot
        Weld.Part1 = HaloPart
        Weld.Parent = HaloPart
        
    end
end

function haloRender(player,step)

    if player:GetAttribute("HaloDeploy") == true and player:GetAttribute("HaloDeployAmount") <= 100 then
        local DeployAmount = player:GetAttribute("HaloDeployAmount")
        DeployAmount += 25 * step

        for i,gabble in player.Character.Head.HaloRoot:GetChildren() do
            gabble.Transparency = 1 - DeployAmount/100
        end

        player:SetAttribute("HaloDeployAmount",DeployAmount)
    end
end

players.PlayerAdded:Connect(onJoin)
balingus.OnServerEvent:Connect(haloRender)
pazingus.OnServerEvent:Connect(toggleHalo)
]]--

















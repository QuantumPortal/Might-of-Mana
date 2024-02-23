local players = game:GetService("Players")
local PolicyService = game:GetService("PolicyService")
local RunService = game:GetService("RunService")
--local fireball = game.ReplicatedStorage.Shared:FindFirstChild("Fireball") or game.ReplicatedStorage.Shared:WaitForChild("Fireball")

local test = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Test")

local function numValueGeneric(parent,name)
    local thing = Instance.new("NumberValue")
    thing.Parent = parent
    thing.Name = name
end



test.OnServerEvent:Connect(function(player)
    if player.CoreStats.Mana.Value >= 30 then
        player.CoreStats.Mana.Value -= 30
        local fireball = Instance.new("Part")
        fireball.Shape = Enum.PartType.Ball
        fireball.Color = Color3.new(255,51,0)
        fireball.Size = Vector3.new(0.5,0.5,0.5)

        fireball.Parent = workspace.Spells
        fireball.CFrame = player.Character.HumanoidRootPart.CFrame
        fireball.CFrame += Vector3.new(3,3,3) * player.Character.HumanoidRootPart.CFrame.LookVector
    end
end)

players.PlayerAdded:Connect(function(player)

    

	

    player.CharacterAppearanceLoaded:Connect(function(character)
        local folder = Instance.new("Folder")
        folder.Name = "CoreStats"
        folder.Parent = player

        
        numValueGeneric(folder,"Mana")
        numValueGeneric(folder,"MaxMana")
        numValueGeneric(folder,"BaseManaRegen")
        numValueGeneric(folder,"BonusManaRegen")
        numValueGeneric(folder,"MaxBonusManaRegen")
        numValueGeneric(folder,"LastManaFraction")
        numValueGeneric(folder,"Shield")
        numValueGeneric(folder,"MaxShield")
        numValueGeneric(folder,"BaseWalkSpeed")
        numValueGeneric(folder,"SprintSpeed")
        
        folder.BaseWalkSpeed.Value = 9
        folder.SprintSpeed.Value = 2.0
        folder.Mana.Value = 100
        folder.MaxMana.Value = 100
        folder.BaseManaRegen.Value = 2.5
        folder.MaxBonusManaRegen.Value = 20
        folder.Shield.Value = 100
        folder.MaxShield.Value = 100

        local badFolder = Instance.new("Folder")
        badFolder.Name = "StatusAbnormalities"
        badFolder.Parent = player

        numValueGeneric(badFolder,"Slow")

        badFolder.Slow.Value = 0

        local goodFolder = Instance.new("Folder")
        goodFolder.Name = "Buffs"
        goodFolder.Parent = player

        numValueGeneric(goodFolder,"Speed")

        goodFolder.Speed.Value = 0
        --character.Animate.walk.WalkAnim.AnimationId = "rbxassetid://15872307313"
		--character.Animate.run.RunAnim.AnimationId = "rbxassetid://15872263018"

        folder.Mana.Changed:Connect(function()
            local ManaFraction = folder.Mana.Value / folder.MaxMana.Value
            if ManaFraction < folder.LastManaFraction.Value then
                folder.BonusManaRegen.Value = 0
            end
            folder.LastManaFraction.Value = ManaFraction
        end)
    end)

    
    
end)

--[[
while true do
    task.wait(0.5)
    for _, player in players:GetPlayers() do
        print(player:GetAttribute("Mana"))
        player:SetAttribute("Mana",player:GetAttribute("Mana")+0.1)
        print(player:GetAttribute("Mana"))
    end
end
]]--
RunService.Stepped:Connect(function(_currentTime, deltaTime)
    for _, player in players:GetPlayers() do
        if player.HasAppearanceLoaded then
            local CoreStats = player:WaitForChild("CoreStats")
            local Mana = CoreStats:WaitForChild("Mana")
            local MaxMana = CoreStats:WaitForChild("MaxMana")
            local BaseManaRegen = CoreStats:WaitForChild("BaseManaRegen")
            local BonusManaRegen = CoreStats:WaitForChild("BonusManaRegen")
            local MaxBonusManaRegen = CoreStats:WaitForChild("MaxBonusManaRegen")
            local Shield = CoreStats:WaitForChild("Shield")
            local MaxShield = CoreStats:WaitForChild("MaxShield")

            BonusManaRegen.Value += MaxBonusManaRegen.Value * deltaTime * math.clamp(math.pow(BonusManaRegen.Value,3),1,(MaxBonusManaRegen.Value * 5)) * (1/(MaxBonusManaRegen.Value * 5))
            
            if MaxBonusManaRegen.Value < BonusManaRegen.Value then
                BonusManaRegen.Value =  MaxBonusManaRegen.Value    
            end
            Mana.Value += (BaseManaRegen.Value + BonusManaRegen.Value ) * deltaTime  
            

            if Shield.Value > MaxShield.Value then
                Shield.Value = MaxShield.Value
            elseif Shield.Value < 0 then
                Shield.Value = 0
            end
            if Mana.Value > MaxMana.Value then
                Mana.Value = MaxMana.Value
            elseif Mana.Value < 0 then
                Mana.Value = 0
            end
        end
    end
end)
    
        --[[
        task.wait(1)
        local agra = player:GetAttribute("Mana") + 5
        print(player:GetAttribute("Mana"))
        player:SetAttribute("Mana",agra)
        ]]--

        
    
        --[[
        player:SetAttribute("BonusRegen", (player:GetAttribute("BonusRegenCap") - player:GetAttribute("BonusRegen"))/100000 * deltaTime ) 
        player:SetAttribute(
            "Mana", 
            player:GetAttribute("Mana") + player:GetAttribute("BaseRegen")/100000 * deltaTime + player:GetAttribute("BonusRegen") 
        )
        if player:GetAttribute("Mana") > player:GetAttribute("MaxMana") then
            player:SetAttribute("Mana", player:GetAttribute("MaxMana"))
        end
        ]]--


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

















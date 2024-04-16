StatusEffect = require(script.StatusEffect)
Effect = require(script.Effect)
Descriptor = require(script.Descriptor)
Damage = require(script.Damage)

local Debris = game:GetService("Debris")
local players = game:GetService("Players")
local PolicyService = game:GetService("PolicyService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local test = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Test")
local SlowTest = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SlowTest")
local NoMana = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("NoMana")
local ServerStorage = game:GetService("ServerStorage")


local function numValueGeneric(parent,name,value)
    local thing = Instance.new("NumberValue")
    thing.Parent = parent
    thing.Name = name
    if value then
        thing.Value = value
    else
        thing.Value = 0
    end
    
end

local CommonEffects = {
    ["system/cast_cooldown"] = Effect.new(
        "system/cast_cooldown",
        Descriptor.new(
            "System effects",
            "Unable to cast",
            "You shouldn't be able to read this...",
            nil
        ),
        {
            {
                ["TickInterval"] = 0,
                ["VariableDuration"] = true,
                ["Duration"] = function(value)
                    return value
                end,
                ["LastTickFunction"] = function(player,_)
                    player.Variables.CastCooldown.Value -= 1
                end,
                ["Effect"] = function(_,_)
                    --sobs a little
                end,
                ["FirstTickFunction"] = function(player,_)
                    player.Variables.CastCooldown.Value += 1
                end
            }
        },
        "CooldownCombine"
    ),
    ["status_abnormalities/cast_slow"] = Effect.new(
        "status_abnormalities/cast_slow",
        Descriptor.new(
            "Status Abnormality",
            "Casting Concentration",
            "Currently focusing on casting... Temporary reduced movement.",
            nil
        ),
        {
            {
                ["TickInterval"] = 0,
                ["VariableDuration"] = false,
                ["Duration"] = 1.13,
                ["LastTickFunction"] = function(player,value)
                    player.StatusAbnormalities.Slow.Value -= value
                    --print(player.StatusAbnormalities.Slow.Value)
                end,
                ["Effect"] = function(player, elapsedTime, potency, previousTotalValue, _)
                    local curveMultiplier = 1 - math.abs((1.4-(2*elapsedTime))^3 * (math.log10(2.3-2*elapsedTime)))
                    player.StatusAbnormalities.Slow.Value += curveMultiplier * potency - previousTotalValue
                    --print(player.StatusAbnormalities.Slow.Value)
                    return curveMultiplier * potency
                end,
                ["FirstTickFunction"] = function(_,_)
                    --lol
                end
            }
        },
        "None"
    ),
    ["elemental/fire"] = Effect.new(
        "elemental/fire",
        Descriptor.new(
            "Elemental Effect",
            "Burn",
            "Currently being immolated!",
            nil
        ),
        {
            {
                ["TickInterval"] = 0.5,
                ["VariableDuration"] = true,
                ["Duration"] = function(value)
                    return 3 + value/2
                end,
                ["LastTickFunction"] = function(player,_)
                    
                    local fire = player.Character.PrimaryPart:FindFirstChild("elemental/fire_effect")
                    fire:Destroy()
                    fire = nil
                end,
                ["Effect"] = function(player, elapsedTime, potency, _, timeSinceLastTick)
                    Damage.Damage(potency * timeSinceLastTick * (math.log10(3*elapsedTime+1)+1),player,nil,nil)
                end,
                ["FirstTickFunction"] = function(player,_)
                    if not player.Character.PrimaryPart:FindFirstChild("elemental/fire_effect") then
                        local fire = Instance.new("Fire")

                        fire.Parent = player.Character.PrimaryPart
                        fire.Name = "elemental/fire_effect"
                        fire.Heat = 6
                        fire.Size = 6
                    end
                end
            }
        },
        "StrongestReplace"
    )
}





test.OnServerEvent:Connect(function(player,mouseHit)
    if player.CoreStats.Mana.Value >= 30 and player.Variables.CastCooldown.Value == 0 then
        
        player.CoreStats.Mana.Value -= 30
        
        StatusEffect.new(CommonEffects["system/cast_cooldown"],player,3, "SELF"):Apply()
        StatusEffect.new(CommonEffects["status_abnormalities/cast_slow"],player,60, "SELF"):Apply()


        
        task.wait(0.84)
        local fireball = ServerStorage.Assets.FireBall:Clone()
        
        fireball.CanCollide = false

        
        fireball.Parent = workspace.Spells
        --fireball.CFrame = CFrame.new(player.Character.HumanoidRootPart.CFrame.Position) * player.Character.Head.Neck.C0.Rotation
        --fireball.CFrame += Vector3.new(3,3,3) * player.Character.Head.Neck.C0.LookVector

        
        fireball.CFrame = CFrame.lookAt(player.Character.HumanoidRootPart.CFrame.Position,mouseHit)
        fireball.CFrame += Vector3.new(2,2,2) * fireball.CFrame.LookVector

        local attachment = Instance.new("Attachment", fireball)

        local force = Instance.new("LinearVelocity",attachment)
        force.VectorVelocity = fireball.CFrame.LookVector * 0
        force.Parent = fireball
        force.Attachment0 = attachment
        local glarb = 0
        local fireballConnection

        local filter = OverlapParams.new()
        filter.FilterType = Enum.RaycastFilterType.Exclude
        filter:AddToFilter(fireball:FindFirstChild("part1"))
        filter:AddToFilter(fireball:FindFirstChild("Part"))
        filter:AddToFilter(fireball)

        fireballConnection = game:GetService("RunService").Stepped:Connect(function(_currentTime, deltaTime)
            glarb += deltaTime
            if glarb >= 10 then
                fireball:Destroy()
                fireballConnection:Disconnect()
            end
            local collisions = Workspace:GetPartsInPart(fireball:FindFirstChild("hitbox"),filter)

            for i, part in collisions do
                if part.Parent:FindFirstChild("Humanoid") then
                    StatusEffect.new(CommonEffects["elemental/fire"],game:GetService("Players"):GetPlayerFromCharacter(part.Parent),1):Apply()
                    
                end
            end

        end)

        task.wait(0.26)

        
    else
        NoMana:FireClient(player,30/player.CoreStats.MaxMana.Value)
    end
end)



players.PlayerAdded:Connect(function(player)

    player.CharacterAppearanceLoaded:Connect(function(character)
        --MOVE TO IN GAME


        --           -==(CORE STATS)==-
        local statFolder = Instance.new("Folder")
        statFolder.Name = "CoreStats"
        statFolder.Parent = player
        
        numValueGeneric(statFolder,"Mana",100)
        numValueGeneric(statFolder,"MaxMana",100)
        numValueGeneric(statFolder,"BaseManaRegen",2.5)
        numValueGeneric(statFolder,"BonusManaRegen",0)
        numValueGeneric(statFolder,"MaxBonusManaRegen",20)
        numValueGeneric(statFolder,"LastManaFraction")
        numValueGeneric(statFolder,"Shield",100)
        numValueGeneric(statFolder,"MaxShield",100)
        numValueGeneric(statFolder,"BaseWalkSpeed",7)
        numValueGeneric(statFolder,"SprintSpeed",1.9)



        --      -==(Status Abnormalities)==-
        local debuffFolder = Instance.new("Folder")
        debuffFolder.Name = "StatusAbnormalities"
        debuffFolder.Parent = player

        numValueGeneric(debuffFolder,"Slow")



        --            -==(Buffs)==-
        local buffFolder = Instance.new("Folder")
        buffFolder.Name = "Buffs"
        buffFolder.Parent = player

        numValueGeneric(buffFolder,"Speed")



        --          -==(Resistances)==-
        local resistanceFolder = Instance.new("Folder")
        resistanceFolder.Name = "Resistances"
        resistanceFolder.Parent = player
        numValueGeneric(resistanceFolder,"Physical")
        numValueGeneric(resistanceFolder,"Pierce")
        numValueGeneric(resistanceFolder,"Blunt")
        numValueGeneric(resistanceFolder,"Slash")        
        numValueGeneric(resistanceFolder,"Elemental")
        numValueGeneric(resistanceFolder,"Fire")
        numValueGeneric(resistanceFolder,"Ice")
        numValueGeneric(resistanceFolder,"Water")
        numValueGeneric(resistanceFolder,"Electric")
        numValueGeneric(resistanceFolder,"Earth")

        --              -==(MISC)==-
        
        --        -==(PLAYER VARIABLES)==-
        local variableFolder = Instance.new("Folder")
        variableFolder.Name = "Variables"
        variableFolder.Parent = player
        numValueGeneric(variableFolder, "CastCooldown")

        --character.Animate.walk.WalkAnim.AnimationId = "rbxassetid://15872307313"
		--character.Animate.run.RunAnim.AnimationId = "rbxassetid://15872263018"

        statFolder.Mana.Changed:Connect(function()
            local ManaFraction = statFolder.Mana.Value / statFolder.MaxMana.Value
            if ManaFraction < statFolder.LastManaFraction.Value then
                statFolder.BonusManaRegen.Value = 0
            end
            statFolder.LastManaFraction.Value = ManaFraction
        end)
    end)

    
    
end)

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




local burnBrick = workspace.yarrr
local recentlyDamagedCharacters = {}

burnBrick.Touched:Connect(function(otherPart)
    local character = otherPart.Parent
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	local player = game:GetService("Players"):GetPlayerFromCharacter(character)
	
	if player and humanoid and not recentlyDamagedCharacters[character] then
		
		StatusEffect.new(CommonEffects["elemental/fire"],player,5):Apply()
		
		recentlyDamagedCharacters[character] = true
		task.wait(0.2)
		recentlyDamagedCharacters[character] = nil
	end
end)






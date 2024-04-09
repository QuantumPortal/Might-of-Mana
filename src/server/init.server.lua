StatusEffect = require(script.StatusEffect)
Effect = require(script.Effect)
Descriptor = require(script.Descriptor)

local Debris = game:GetService("Debris")
local players = game:GetService("Players")
local PolicyService = game:GetService("PolicyService")
local RunService = game:GetService("RunService")

local test = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Test")
local SlowTest = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SlowTest")
local NoMana = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("NoMana")



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
                    return 5 + value/20
                end,
                ["LastTickFunction"] = function(player,_)
                    
                    local fire = player.Character.PrimaryPart:FindFirstChild("elemental/fire_effect")
                    print("warble",fire)
                    fire:Destroy()
                    fire = nil
                end,
                ["Effect"] = function(player, elapsedTime, potency, _, timeSinceLastTick)
                    print("fwaaing for", potency * timeSinceLastTick * (math.log10(3*elapsedTime+1)+1))
                    player.Character.Humanoid:TakeDamage(potency * timeSinceLastTick * (math.log10(3*elapsedTime+1)+1))
                    

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




local debounce = true
test.OnServerEvent:Connect(function(player,mouseHit)
    if player.CoreStats.Mana.Value >= 30 then
        debounce = false
        player.CoreStats.Mana.Value -= 30
        
        
        StatusEffect.new(CommonEffects["status_abnormalities/cast_slow"],player,60):Apply()


        task.wait(0.84)
        local fireball = Instance.new("Part")
        fireball.Shape = Enum.PartType.Ball
        fireball.Color = Color3.fromHex("#aa5500")
        fireball.Material = Enum.Material.Neon
        fireball.Transparency = 1
        fireball.Size = Vector3.new(0.8,0.8,0.8)
        fireball.CanCollide = false

        local fire = Instance.new("Fire")
        fire.Parent = fireball
        fire.Heat = 0
        fire.TimeScale = 1
        fire.Size = 5.2
        
        fireball.Parent = workspace.Spells
        --fireball.CFrame = CFrame.new(player.Character.HumanoidRootPart.CFrame.Position) * player.Character.Head.Neck.C0.Rotation
        --fireball.CFrame += Vector3.new(3,3,3) * player.Character.Head.Neck.C0.LookVector

        
        fireball.CFrame = CFrame.lookAt(player.Character.HumanoidRootPart.CFrame.Position,mouseHit)
        fireball.CFrame += Vector3.new(2,2,2) * fireball.CFrame.LookVector

        local attachment = Instance.new("Attachment", fireball)

        local force = Instance.new("LinearVelocity",attachment)
        force.VectorVelocity = fireball.CFrame.LookVector * 19
        force.Parent = fireball
        force.Attachment0 = attachment
        
        task.wait(1.1-0.84)

        debounce = true
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






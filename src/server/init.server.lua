StatusEffect = require(script.StatusEffect)
Effect = require(script.Effect)
SingleEffect = require(script.SingleEffect)
Descriptor = require(script.Descriptor)
Damage = require(script.Damage)
Statblock = require(script.Statblock)

local Debris = game:GetService("Debris")
local players = game:GetService("Players")
local PolicyService = game:GetService("PolicyService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local PlayerService = game:GetService("Players")

local test = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Test")
local NoMana = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("NoMana")
local ServerStorage = game:GetService("ServerStorage")


local CommonEffects = {
    ["system/cast_cooldown"] = Effect.New(
        "system/cast_cooldown",
        Descriptor.New(
            "System effects",
            "Unable to cast",
            "You shouldn't be able to read this...",
            nil
        ),
        {
            SingleEffect.New(
                0,
                function(_,_,StatusEffect)
                    return StatusEffect.Potency
                end,
                function(_,_,StatusEffect)
                    StatusEffect.Statblock.DataFolder.System.CastCooldown.Value += 1
                end,
                nil,
                function(_,_,StatusEffect)
                    StatusEffect.Statblock.DataFolder.System.CastCooldown.Value -= 1
                end
            )
        },
        "CooldownCombine"
    ),
    ["status_abnormalities/cast_slow"] = Effect.New(
        "status_abnormalities/cast_slow",
        Descriptor.New(
            "Status Abnormality",
            "Casting Concentration",
            "Currently focusing on casting... Temporary reduced movement.",
            nil
        ),
        {
            SingleEffect.New(
                0,
                function(_,_,_)
                    return 1.13
                end,
                nil,
                function(deltaTime,_,StatusEffect)
                    local previousTime = StatusEffect.ElapsedTime - deltaTime
                    local previousCurveMultiplier = 1 - math.abs((1.4-(2*previousTime))^3 * (math.log10(2.3-2*previousTime)))
                    if StatusEffect.ElapsedTime == deltaTime then
                        previousCurveMultiplier = 0
                    end
                    local curveMultiplier = 1 - math.abs((1.4-(2*StatusEffect.ElapsedTime))^3 * (math.log10(2.3-2*StatusEffect.ElapsedTime)))

                    StatusEffect.Statblock.DataFolder.StatusAbnormalities.Slow.Value += (curveMultiplier - previousCurveMultiplier) * StatusEffect.Potency
                end,
                function(deltaTime,_,StatusEffect)
                    local previousTime = StatusEffect.ElapsedTime - deltaTime
                    local previousCurveValue = 1 - math.abs((1.4-(2*previousTime))^3 * (math.log10(2.3-2*previousTime)))
                    
                    StatusEffect.Statblock.DataFolder.StatusAbnormalities.Slow.Value -= previousCurveValue * StatusEffect.Potency  
                end
            )
        },
        "None"
    ),
    ["elemental/fire"] = Effect.New(
        "elemental/fire",
        Descriptor.New(
            "Elemental Effect",
            "Burn",
            "Currently being immolated!",
            nil
        ),
        {
            SingleEffect.New(
                0.5,
                function(_,_,StatusEffect)
                    return 3 + StatusEffect.Potency / 2
                end,
                function(_,_,StatusEffect)
                    if not StatusEffect.Statblock.Humanoid.Parent.PrimaryPart:FindFirstChild("elemental/fire_effect") then
                        local fire = Instance.new("Fire")

                        fire.Parent = StatusEffect.Statblock.Humanoid.Parent.PrimaryPart
                        fire.Name = "elemental/fire_effect"
                        fire.Heat = 6
                        fire.Size = 6
                    end
                end,
                function(deltaTime,timeSinceLastTick,StatusEffect)
                    Damage.Damage(
                        StatusEffect.Potency * timeSinceLastTick * (math.log10(3*StatusEffect.ElapsedTime+1)+1),
                        StatusEffect.Statblock,
                        nil,
                        nil
                    )
                end,
                function(_,_,StatusEffect)
                    local fire = StatusEffect.Statblock.Humanoid.Parent.PrimaryPart:FindFirstChild("elemental/fire_effect")
                    fire:Destroy()
                    fire = nil
                end
            )
        },
        "StrongestReplace"
    )
}


test.OnServerEvent:Connect(function(player,mouseHit)
    local statblock = Statblock.GetStatblock(player.UserId)
    local coreStats = statblock.DataFolder.CoreStats
    local system = statblock.DataFolder.System

    if coreStats.Mana.Value >= 30 and system.CastCooldown.Value == 0 then
        coreStats.Mana.Value -= 30
        
        StatusEffect.New(CommonEffects["system/cast_cooldown"],statblock,3, "SELF"):Apply()
        StatusEffect.New(CommonEffects["status_abnormalities/cast_slow"],statblock,60, "SELF"):Apply()

        task.wait(0.84)

        local fireball = ServerStorage.Assets.FireBall:Clone()
        fireball.CanCollide = false
        fireball.Parent = workspace.Spells
        fireball.CFrame = CFrame.lookAt(player.Character.HumanoidRootPart.CFrame.Position,mouseHit)
        fireball.CFrame += Vector3.new(2,2,2) * fireball.CFrame.LookVector

        local attachment = Instance.new("Attachment", fireball)
        local force = Instance.new("LinearVelocity",attachment)
        force.VectorVelocity = fireball.CFrame.LookVector * 19
        force.Parent = fireball
        force.Attachment0 = attachment
        local glarb = 0
        local fireballConnection

        local filter = OverlapParams.new()
        filter.FilterType = Enum.RaycastFilterType.Exclude
        filter:AddToFilter(fireball)
        filter:AddToFilter(player.Character)

        fireballConnection = game:GetService("RunService").Stepped:Connect(function(_currentTime, deltaTime)
            glarb += deltaTime
            if glarb >= 4 then
                fireball:Destroy()
                fireballConnection:Disconnect()
            else 
                local collisions = Workspace:GetPartsInPart(fireball:FindFirstChild("hitbox"),filter)

                for i, part in collisions do
                    if part.Parent:FindFirstChild("Humanoid") then
                        if PlayerService:GetPlayerFromCharacter(part.Parent) then
                            local statblock = Statblock.GetStatblock(PlayerService:GetPlayerFromCharacter(part.Parent).UserId)
                            StatusEffect.New(CommonEffects["elemental/fire"],statblock,6):Apply()    
                        else
                            local statblock = Statblock.GetStatblock(part.Parent:FindFirstChild("Humanoid"):GetAttribute("UUID"))
                            StatusEffect.New(CommonEffects["elemental/fire"],statblock,6):Apply()    
                        end
                          
                    end
                end
            end

        end)

        task.wait(0.26)
    else
        NoMana:FireClient(player,30/coreStats.MaxMana.Value)
    end
end)


players.PlayerAdded:Connect(function(player)
    player.CharacterAppearanceLoaded:Connect(function(character)
        local statblock = Statblock.New(
            player,
            player.Character.Humanoid,
            {
                ["CoreStats"] = {
                    ["Mana"] = 100,
                    ["MaxMana"] = 100,
                    ["BaseManaRegen"] = 2.5,
                    ["LastManaFraction"] = 0,
                    ["BonusManaRegen"] = 0,
                    ["MaxBonusManaRegen"] = 20,
                    ["Shield"] = 100,
                    ["MaxShield"] = 100,
                    ["BaseWalkSpeed"] = 7,
                    ["SprintMultiplier"] = 1.9
                },
                ["System"] = {
                    ["CastCooldown"] = 0
                },
                ["Resistances"] = {
                    ["Fire"] = -0.2
                },
                ["StatusAbnormalities"] = {
                    ["Slow"] = 0
                },
                ["Buffs"] = {
                    ["Speed"] = 0
                }
            }
        )

        statblock.DataFolder.CoreStats.Mana.Changed:Connect(function()
            local ManaFraction = statblock.DataFolder.CoreStats.Mana.Value / statblock.DataFolder.CoreStats.MaxMana.Value
            if ManaFraction < statblock.DataFolder.CoreStats.LastManaFraction.Value then
                statblock.DataFolder.CoreStats.BonusManaRegen.Value = 0
            end
            statblock.DataFolder.CoreStats.LastManaFraction.Value = ManaFraction
        end)
    end)
end)


RunService.Stepped:Connect(function(_currentTime, deltaTime)
    for _, player in players:GetPlayers() do
        if player.HasAppearanceLoaded and Statblock.GetStatblock(player.UserId) then
            local statblock = Statblock.GetStatblock(player.UserId)
            local coreStats = statblock.DataFolder.CoreStats


            coreStats.BonusManaRegen.Value += coreStats.MaxBonusManaRegen.Value * deltaTime * math.clamp(
                math.pow(coreStats.BonusManaRegen.Value,3),1,
                (coreStats.MaxBonusManaRegen.Value * 5)) * (1/(coreStats.MaxBonusManaRegen.Value * 5)
            )
            
            if coreStats.MaxBonusManaRegen.Value < coreStats.BonusManaRegen.Value then
                coreStats.BonusManaRegen.Value =  coreStats.MaxBonusManaRegen.Value    
            end
            coreStats.Mana.Value += (coreStats.BaseManaRegen.Value + coreStats.BonusManaRegen.Value ) * deltaTime  
            

            coreStats.Mana.Value = math.clamp(coreStats.Mana.Value,0,coreStats.MaxMana.Value)  
        end
    end
end)


-- TESTING SECTION

local burnBrick = workspace.yarrr
local recentlyDamagedCharacters = {}

burnBrick.Touched:Connect(function(otherPart)
    local character = otherPart.Parent
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	local player = game:GetService("Players"):GetPlayerFromCharacter(character)
	
	if player and humanoid and not recentlyDamagedCharacters[character] then
		
		StatusEffect.New(CommonEffects["elemental/fire"],player,5):Apply()
		
		recentlyDamagedCharacters[character] = true
		task.wait(0.2)
		recentlyDamagedCharacters[character] = nil
	end
end)




local Seb = workspace.Sebastian
Statblock.New(
    nil,
    Seb.Humanoid,
    {
        ["CoreStats"] = {
            ["Mana"] = 100,
            ["MaxMana"] = 100,
            ["BaseManaRegen"] = 2.5,
            ["LastManaFraction"] = 0,
            ["BonusManaRegen"] = 0,
            ["MaxBonusManaRegen"] = 20,
            ["Shield"] = 0,
            ["MaxShield"] = 10,
            ["BaseWalkSpeed"] = 7,
            ["SprintMultiplier"] = 1.9
        },
        ["System"] = {
            ["CastCooldown"] = 0
        },
        ["Resistances"] = {
            ["Fire"] = -0.2
        },
        ["StatusAbnormalities"] = {
            ["Slow"] = 0
        },
        ["Buffs"] = {
            ["Speed"] = 0
        }
    }
)


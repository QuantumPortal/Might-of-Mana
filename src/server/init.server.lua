StatusEffect = require(script.StatusEffect)
Effect = require(script.Effect)
SingleEffect = require(script.SingleEffect)
Descriptor = require(script.Descriptor)
Damage = require(script.Damage)
Statblock = require(script.Statblock)
PlayerFunctions = require(script.PlayerFunctions)
Spell = require(script.Spell)
DamageProfile = require(script.DamageProfile)

local Debris = game:GetService("Debris")
local players = game:GetService("Players")
local PolicyService = game:GetService("PolicyService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local PlayerService = game:GetService("Players")
local TweenService = game:GetService('TweenService')

local test = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Test")
local Rebindable = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Keybinds"):WaitForChild("Rebindable")
local SprintStatus = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SprintStatus")
local NoMana = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("NoMana")
local ServerStorage = game:GetService("ServerStorage")

local CommonSpells = {
    ["Fireball"] = Spell.New(
        Descriptor.New(
            "Spell",
            "Fireball",
            "Flaem ball,,,,,,,,,,,",
            nil
        ),
        "Fireball_Basic",
        20,
        1.13,
        2,
        5,
        function(part)
            local attachment = Instance.new("Attachment",part)
            local force = Instance.new("LinearVelocity",attachment)
            force.Name = "Force"
            force.VectorVelocity = part.CFrame.LookVector * 40
            force.Attachment0 = attachment
        end,
        function(statblock,spell)
            local player = statblock.Player
            local fireballConnection
            local timeout = 0
            local hitStatblocks = {}

            local explodeTween = TweenInfo.new(
                0.2,
                Enum.EasingStyle.Cubic,
                Enum.EasingDirection.Out,
                0,
                false,
                0
            )

            task.wait(spell.SpellCasttime * 1.134 - 0.2 * math.sqrt(spell.SpellCasttime))

            local mouseHit = PlayerFunctions.GetMousePosition(player).Position
            local fireballFolder = ServerStorage.Assets.Spells:FindFirstChild(spell.ModelID):Clone()
            fireballFolder.Parent = workspace.Spells
            fireballFolder.Name = spell.ModelID ..  statblock.Player.UserId
            local hitbox = fireballFolder.Hitbox
            local visual = fireballFolder.Visual

            hitbox.CFrame = CFrame.lookAt(player.Character.HumanoidRootPart.CFrame.Position,mouseHit)
            hitbox.CFrame += Vector3.new(2,2,2) * hitbox.CFrame.LookVector
            visual.CFrame = hitbox.CFrame            
            visual:SetNetworkOwner(player)
            hitbox:SetNetworkOwner(nil)

            spell.MovementBehavior(hitbox)
            spell.MovementBehavior(visual)

            local filter = OverlapParams.new()
            filter.FilterType = Enum.RaycastFilterType.Exclude
            filter:AddToFilter(visual)
            filter:AddToFilter(hitbox)
            filter:AddToFilter(player.Character)            

            local function blowUpFireball()
                TweenService:Create(hitbox,explodeTween, {Size = Vector3.new(7,7,7)}):Play()

                TweenService:Create(visual.part1,explodeTween, {Size = Vector3.new(7,7,7)}):Play()
                TweenService:Create(visual.part1,explodeTween, {Transparency = 1}):Play()

                hitbox.Attachment.Force.VectorVelocity *= 0
                visual.Attachment.Force.VectorVelocity *= 0

                fireballConnection:Disconnect()
                task.wait(0.15)
                fireballFolder:Destroy()
            end

            fireballConnection = RunService.Stepped:Connect(function(_currentTime, deltaTime)
                timeout += deltaTime  
                if timeout >= spell.SpellDuration then
                    blowUpFireball()
                else 
                    local collisions = Workspace:GetPartsInPart(hitbox,filter)
                    local blowup = false
                    for _, part in collisions do
                        local detectedStatblock = nil
                        blowup = true
                        if part.Parent:FindFirstChild("Humanoid") and PlayerService:GetPlayerFromCharacter(part.Parent) then
                            detectedStatblock = Statblock.GetStatblock(PlayerService:GetPlayerFromCharacter(part.Parent).UserId)
                        elseif part.Parent:FindFirstChild("Humanoid") then
                            detectedStatblock = Statblock.GetStatblock(part.Parent:FindFirstChild("Humanoid"):GetAttribute("UUID"))
                        end
                        if detectedStatblock and not hitStatblocks[detectedStatblock.UniqueId] then
                            DamageProfile.New(statblock,detectedStatblock,{
                                ["Fire"] = 35,
                                ["Arcane"] = 15,
                            }, "Normal"
                            ):Activate()
                            StatusEffect.New(Effect.GetCommonEffect("elemental/fire"),detectedStatblock,6):Apply()   
                            hitStatblocks[detectedStatblock.UniqueId] = 1
                        end
                    end
                    if blowup then
                        blowUpFireball()
                    end
                    
                end
            end)
        end
    )
}

local testEquippedSpells = {
                    [1] = CommonSpells["Fireball"],
                    [2] = nil,
                    [3] = nil}

SprintStatus.OnServerEvent:Connect(function(player,sprintStatus)
    local statblock = Statblock.GetStatblock(player.UserId)
    if sprintStatus then
        statblock.DataFolder.CoreStats.IsSprintValue.Value += (1000-statblock.DataFolder.CoreStats.IsSprintValue.Value)/7
    else
        statblock.DataFolder.CoreStats.IsSprintValue.Value -= (statblock.DataFolder.CoreStats.IsSprintValue.Value)/7
    end
    statblock.DataFolder.CoreStats.IsSprintValue.Value = math.round(statblock.DataFolder.CoreStats.IsSprintValue.Value)
end)

Rebindable.OnServerEvent:Connect(function(player,code)
    print("Received Code: ", code)
    if string.split(code,"_")[1] == "spell" then
        local spellIndex = tonumber(string.split(code,"_")[2])
        local statblock = Statblock.GetStatblock(player.UserId)
        local spell = testEquippedSpells[spellIndex]
        if spell and statblock.DataFolder.System.CastCooldown.Value == 0 then
            if spell.ManaCost < statblock.DataFolder.CoreStats.Mana.Value then
                statblock.DataFolder.CoreStats.Mana.Value -= spell.ManaCost
                spell:Activate(statblock)
            else
                NoMana:FireClient(player,spell.Cost/statblock.DataFolder.CoreStats.MaxMana.Value)
            end 
        end
    end
end)


players.PlayerAdded:Connect(function(player)
    player.CharacterAppearanceLoaded:Connect(function(character) 
        local statblock = Statblock.New(
            player,
            character.Humanoid,
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
                    ["SprintMultiplier"] = 0.9,
                    ["IsSprintValue"] = 0
                },
                ["System"] = {
                    ["CastCooldown"] = 0,
                    ["JumpCooldown"] = 0
                },
                ["Resistances"] = {
                    ["Fire"] = -0.2
                },
                ["StatusAbnormalities"] = {
                    ["Slow"] = 0
                },
                ["Buffs"] = {
                    ["Speed"] = 0
                },
            }
        )
        PlayerFunctions.UpdateSpeed(statblock)
        character.Humanoid.AutoRotate = false
        player.Character.Humanoid.JumpHeight = 3
        player.Character.Humanoid.UseJumpPower = false

        statblock.DataFolder.CoreStats.Mana.Changed:Connect(function()
            local ManaFraction = statblock.DataFolder.CoreStats.Mana.Value / statblock.DataFolder.CoreStats.MaxMana.Value
            if ManaFraction < statblock.DataFolder.CoreStats.LastManaFraction.Value then
                statblock.DataFolder.CoreStats.BonusManaRegen.Value = 0
            end
            statblock.DataFolder.CoreStats.LastManaFraction.Value = ManaFraction
        end)

        statblock.DataFolder.CoreStats.SprintMultiplier.Changed:Connect(function()    
            PlayerFunctions.UpdateSpeed(statblock)
        end)
        statblock.DataFolder.CoreStats.BaseWalkSpeed.Changed:Connect(function()    
            PlayerFunctions.UpdateSpeed(statblock)
        end)
        statblock.DataFolder.CoreStats.IsSprintValue.Changed:Connect(function()    
            PlayerFunctions.UpdateSpeed(statblock)
        end)
        statblock.DataFolder.StatusAbnormalities.Slow.Changed:Connect(function()    
            PlayerFunctions.UpdateSpeed(statblock)
        end)
        statblock.DataFolder.Buffs.Speed.Changed:Connect(function()    
            PlayerFunctions.UpdateSpeed(statblock)
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

            statblock.DataFolder.System.JumpCooldown.Value -= deltaTime
            if statblock.DataFolder.System.JumpCooldown.Value < 0 then
                statblock.DataFolder.System.JumpCooldown.Value = 0
            end

        end
    end
end)


-- TESTING SECTION
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
            ["Fire"] = 0
        },
        ["StatusAbnormalities"] = {
            ["Slow"] = 0
        },
        ["Buffs"] = {
            ["Speed"] = 0
        }
    }
)

local Seb2 = workspace.FireproofSebastian
Statblock.New(
    nil,
    Seb2.Humanoid,
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
            ["Fire"] = 0.7
        },
        ["StatusAbnormalities"] = {
            ["Slow"] = 0
        },
        ["Buffs"] = {
            ["Speed"] = 0
        }
    }
)
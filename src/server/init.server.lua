StatusEffect = require(script.StatusEffect)
Effect = require(script.Effect)
SingleEffect = require(script.SingleEffect)
Descriptor = require(script.Descriptor)
Damage = require(script.Damage)
Statblock = require(script.Statblock)
PlayerFunctions = require(script.PlayerFunctions)
Spell = require(script.Spell)

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
        24,
        function(statblock)
            local player = statblock.Player
            task.wait(0.84)
            local fireball = ServerStorage.Assets.FireBall:Clone()
            fireball.CanCollide = false
            fireball.Parent = workspace.Spells
            local mouseCFrame = PlayerFunctions.GetMousePosition(player)
            
            local mouseHit = mouseCFrame.Position
            
            --##TODO## Fix temporarylogic.
            --if mouseHit.Y < player.Character.PrimaryPart.CFrame.Position.Y then
            --    mouseHit = Vector3.new(mouseHit.X,player.Character.PrimaryPart.CFrame.Position.Y ,mouseHit.Z)
           -- end


            fireball.CFrame = CFrame.lookAt(player.Character.HumanoidRootPart.CFrame.Position,mouseHit)
            fireball.CFrame += Vector3.new(2,2,2) * fireball.CFrame.LookVector

            local attachment = Instance.new("Attachment", fireball)
            local force = Instance.new("LinearVelocity",attachment)
            force.VectorVelocity = fireball.CFrame.LookVector * 47
            force.Parent = fireball
            force.Attachment0 = attachment
            local glarb = 0
            local fireballConnection

            local filter = OverlapParams.new()
            filter.FilterType = Enum.RaycastFilterType.Exclude
            filter:AddToFilter(fireball)
            filter:AddToFilter(player.Character)

            local explodeTween = TweenInfo.new(
                0.2,
                Enum.EasingStyle.Cubic,
                Enum.EasingDirection.Out,
                0,
                false,
                0
            )
            local function ablowup()
                TweenService:Create(fireball.part1,explodeTween, {Size = Vector3.new(5,5,5)}):Play()
                        TweenService:Create(fireball.part1,explodeTween, {Transparency = 0.7}):Play()
                        fireballConnection:Disconnect()
                        task.wait(0.1)
                        fireball:Destroy()
            end
            fireballConnection = game:GetService("RunService").Stepped:Connect(function(_currentTime, deltaTime)
                glarb += deltaTime  
                if glarb >= 4 then
                    fireball:Destroy()
                    fireballConnection:Disconnect()
                else 
                    local collisions = Workspace:GetPartsInPart(fireball:FindFirstChild("hitbox"),filter)
                    local blowup = false
                    for i, part in collisions do
                        blowup = true
                        if part.Parent:FindFirstChild("Humanoid") then
                            if PlayerService:GetPlayerFromCharacter(part.Parent) then
                                local statblock = Statblock.GetStatblock(PlayerService:GetPlayerFromCharacter(part.Parent).UserId)
                                Damage.Damage(35,statblock,nil,nil)
                                StatusEffect.New(Effect.GetCommonEffect("elemental/fire"),statblock,6):Apply()   
                                ablowup() 
                            else
                                local statblock = Statblock.GetStatblock(part.Parent:FindFirstChild("Humanoid"):GetAttribute("UUID"))
                                Damage.Damage(35,statblock,nil,nil)
                                StatusEffect.New(Effect.GetCommonEffect("elemental/fire"),statblock,6):Apply()    
                                ablowup()
                            end
                            
                        end
                    end
                    if blowup then
                        ablowup()
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
            if spell.Cost < statblock.DataFolder.CoreStats.Mana.Value then
                statblock.DataFolder.CoreStats.Mana.Value -= spell.Cost
                StatusEffect.New(Effect.GetCommonEffect("system/cast_cooldown"),statblock,3, "SELF"):Apply()
                StatusEffect.New(Effect.GetCommonEffect("status_abnormalities/cast_slow"),statblock,60, "SELF"):Apply()
                spell.SpellFunction(statblock)
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
                },
            }
        )
        PlayerFunctions.UpdateSpeed(statblock)
        character.Humanoid.AutoRotate = false

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
		
		StatusEffect.New(Effect.GetCommonEffect("elemental/fire"),player,5):Apply()
		
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


SingleEffect = require(script.Parent.SingleEffect)
Descriptor = require(script.Parent.Descriptor)
Damage = require(script.Parent.Damage)

Effect = {}
Effect.__index = Effect



function Effect.New(effectID, descriptor, fields, combineType)
    local effect = {}
    setmetatable(effect,Effect)

    effect.Descriptor = descriptor
    effect.EffectID = effectID
    effect.Fields = fields
    effect.CombineType = combineType
    

    return effect
end
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
                function(_,_,StatusEffect)
                    return StatusEffect.Potency
                end,
                nil,
                function(deltaTime,_,StatusEffect)
                    local previousTime = StatusEffect.ElapsedTime - deltaTime
                    local strechedPreviousTime = 2 * previousTime / StatusEffect.Potency
                    local previousCurveMultiplier = 1 - math.abs((1.4-strechedPreviousTime)^3 * (math.log10(2.3-strechedPreviousTime)))
                    
                    if StatusEffect.ElapsedTime == deltaTime then
                        previousCurveMultiplier = 0
                    end
                    local strechedCurrentTime = 2 * StatusEffect.ElapsedTime / StatusEffect.Potency
                    local curveMultiplier = 1 - math.abs((1.4-strechedCurrentTime)^3 * (math.log10(2.3-strechedCurrentTime)))

                    StatusEffect.Statblock.DataFolder.StatusAbnormalities.Slow.Value += (curveMultiplier - previousCurveMultiplier) * 65
                end,
                function(deltaTime,_,StatusEffect)
                    local previousTime = StatusEffect.ElapsedTime - deltaTime
                    local strechedPreviousTime = 2 * previousTime / StatusEffect.Potency
                    local previousCurveMultiplier = 1 - math.abs((1.4-strechedPreviousTime)^3 * (math.log10(2.3-strechedPreviousTime)))
                    
                    StatusEffect.Statblock.DataFolder.StatusAbnormalities.Slow.Value -= previousCurveMultiplier * 65 
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

function Effect.GetCommonEffect(id)
    return CommonEffects[id]
end

return Effect
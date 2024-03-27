StatusEffect = {}
StatusEffect.__index = StatusEffect


function StatusEffect.New(duration, potency, type, effect, transformation)
    local statusEffect = {}
    setmetatable(statusEffect,StatusEffect)

    statusEffect.Time = 0
    statusEffect.LastEffectApply = 0
    statusEffect.Duration = duration
    statusEffect.Potency = potency
    statusEffect.Transformation = transformation
    statusEffect.Type = type
    statusEffect.Effect = effect

    return statusEffect
end

function StatusEffect:Apply(player, deltaTime)
    self.Time += deltaTime
    local modifier = self.Transformation(self.Time)
    player:FindFirstChild(self.Type):FindFirstChild(self.Effect).Value += modifier * self.Potency - self.LastEffectApply
    
    self.LastEffectApply = modifier * self.Potency
end

return StatusEffect
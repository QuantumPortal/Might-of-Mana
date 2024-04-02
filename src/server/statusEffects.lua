StatusEffect = {}
StatusEffect.__index = StatusEffect

local CombineTypes = {
    ["StrongestReplace"] = function(initialEffect,addedEffect,targetPlayer)
        if initialEffect.Potency > addedEffect.Potency then
            initialEffect.Time = 0
        else 
            initialEffect.EffectRun:Disconnect()

            addedEffect:BeginRun(targetPlayer)
        end
    end,
    ["MeanRefresh"] = function(initialEffect,addedEffect)
        return
    end,
}

function StatusEffect.New(duration, potency, effect, transformation, combineType)
    local statusEffect = {}
    
    setmetatable(statusEffect,StatusEffect)

    statusEffect.Descriptor = ""
    statusEffect.Time = 0
    statusEffect.LastEffectApply = 0
    statusEffect.Duration = duration
    statusEffect.Potency = potency
    statusEffect.Transformation = transformation
    statusEffect.Effect = effect
    statusEffect.CombineType = combineType

    statusEffect.EffectRun = nil
    return statusEffect
end

function StatusEffect:Apply(targetPlayer)
    for statEffect in pairs(targetPlayer.Effects:GetChildren()) do
        if statEffect.Effect == self.Effect then
            CombineTypes[statEffect.CombineType](statEffect,self,targetPlayer)
            return
        end
    end

    self:BeginRun(targetPlayer)
end

function StatusEffect:BeginRun(targetPlayer)
    
    
    self.EffectRun = game:GetService("RunService").Stepped:Connect(function(_currentTime, deltaTime)
        self:Step(targetPlayer,deltaTime)
        if self.Duration < self.Time then
            self.EffectRun:Disconnect()
        end
    end)
end


function StatusEffect:Step(player, deltaTime)
    self.Time += deltaTime
    local modifier = self.Transformation(self.Time)
    player:FindFirstChild(self.Effect.TYPE):FindFirstChild(self.Effect.NAME).Value += modifier * self.Potency - self.LastEffectApply
    self.LastEffectApply = modifier * self.Potency

end







return StatusEffect
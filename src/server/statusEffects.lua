StatusEffect = {}
StatusEffect.__index = StatusEffect


statusEffectStorage = {}

local CombineTypes = {
    ["StrongestReplace"] = function(initialEffect,addedEffect,targetPlayer)
        if initialEffect.Potency > addedEffect.Potency then
            initialEffect.Time = 0
        else 
            initialEffect:Stop(targetPlayer)
            
            addedEffect:BeginRun(targetPlayer)
        end
    end,
    ["MeanRefresh"] = function(initialEffect,addedEffect)
        return
    end,
}

function StatusEffect.New(effectid, descriptor, duration, potency, effect, transformation, combineType)
    local statusEffect = {}
    
    setmetatable(statusEffect,StatusEffect)

    statusEffect.EffectID = effectid
    statusEffect.Descriptor = descriptor
    statusEffect.Time = 0
    statusEffect.LastEffectApply = 0
    statusEffect.Duration = duration
    statusEffect.Potency = potency
    statusEffect.Transformation = transformation
    statusEffect.Effect = effect
    statusEffect.CombineType = combineType
    statusEffect.EffectAggregate = 0

    statusEffect.EffectRun = nil
    return statusEffect
end

function StatusEffect:Apply(targetPlayer)
    if not statusEffectStorage[targetPlayer] then
        statusEffectStorage[targetPlayer] = {}
    end

    if statusEffectStorage[targetPlayer][self.EffectID] then
        local initialEffect = statusEffectStorage[targetPlayer][self.EffectID]
        print("Effect exists! Combining as:",initialEffect.CombineType)
        CombineTypes[initialEffect.CombineType](initialEffect,self,targetPlayer)
    else
        print("Creating effect: >",self.EffectID,"< on player",targetPlayer.DisplayName)
        self:BeginRun(targetPlayer)
    end
    
end

function StatusEffect:BeginRun(targetPlayer)
    statusEffectStorage[targetPlayer][self.EffectID] = self

    self.EffectRun = game:GetService("RunService").Stepped:Connect(function(_currentTime, deltaTime)
        self:Step(targetPlayer,deltaTime)
        if self.Duration < self.Time then
            self:Stop(targetPlayer)
        end
    end)
end


function StatusEffect:Step(player, deltaTime)
    self.Time += deltaTime
    local modifier = self.Transformation(self.Time)
    player:FindFirstChild(self.Effect.TYPE):FindFirstChild(self.Effect.NAME).Value += modifier * self.Potency - self.LastEffectApply
    self.EffectAggregate += modifier * self.Potency - self.LastEffectApply
    self.LastEffectApply = modifier * self.Potency
end

function StatusEffect:Stop(player)
    self.EffectRun:Disconnect()
    player:FindFirstChild(self.Effect.TYPE):FindFirstChild(self.Effect.NAME).Value -= self.EffectAggregate
    statusEffectStorage[player][self.EffectID] = nil
end

function StatusEffect.getEffectStorageTable()
    return statusEffectStorage
end




return StatusEffect
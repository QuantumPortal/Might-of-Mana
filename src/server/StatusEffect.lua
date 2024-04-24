StatusEffect = {}
StatusEffect.__index = StatusEffect

local StatusEffectStorage = {}
local CombineTypes = {
    ["StrongestReplace"] = function(initialEffect,addedEffect)
        if initialEffect.Potency >= addedEffect.Potency then
            initialEffect.ElapsedTime = 0
        else 
            initialEffect:Kill()
            addedEffect:Apply()
        end
    end,
    ["MeanRefresh"] = function(initialEffect,addedEffect)
        return
    end,
    ["CooldownCombine"] = function(initialEffect,addedEffect)
        initialEffect.Potency += addedEffect.Potency
    end,
    ["None"] = function(initialEffect,addedEffect) end
}

function StatusEffect.getEffectStorageTable()
    return StatusEffectStorage
end

function StatusEffect.new(effect, player, potency, source)
    local statusEffect = {}
    
    setmetatable(statusEffect,StatusEffect)
    statusEffect.Effect = effect
    statusEffect.Player = player
    statusEffect.Potency = potency
    statusEffect.Source = source

    
    statusEffect.ElapsedTime = 0
    statusEffect.SingleEffectLastTick = {}
    statusEffect.SingleEffectRunning = {}
    statusEffect.Connection = nil

    return statusEffect
end

function StatusEffect:Apply()
    
    if not StatusEffectStorage[self.Player.UserId] then
        StatusEffectStorage[self.Player.UserId] = {}
    end

    if StatusEffectStorage[self.Player.UserId][self.Effect.EffectID] then
        local ExistingStatusEffect = StatusEffectStorage[self.Player.UserId][self.Effect.EffectID]
        print("Effect exists! Combining through",ExistingStatusEffect.Effect.CombineType)
        CombineTypes[ExistingStatusEffect.Effect.CombineType](ExistingStatusEffect,self)
        return
    end

    
    print("Creating effect: >",self.Effect.EffectID,"< on player", self.Player.DisplayName)
    StatusEffectStorage[self.Player.UserId][self.Effect.EffectID] = self
    for i, _ in self.Effect.Fields do
        self.SingleEffectLastTick[i] = 0
        self.SingleEffectRunning[i] = true
    end

    self.Connection = game:GetService("RunService").Stepped:Connect(function(_, deltaTime)
        self.ElapsedTime += deltaTime
        local continueRunning = false
        
        for i, singleEffect in self.Effect.Fields do
            if self.SingleEffectRunning[i] then
                self.SingleEffectLastTick[i] += deltaTime
                local resetLastTick = false
                self.SingleEffectRunning[i], resetLastTick = singleEffect:Execute(deltaTime,self.SingleEffectLastTick[i],self)
                
                if resetLastTick then
                    self.SingleEffectLastTick[i] = 0
                end

                continueRunning = continueRunning or self.SingleEffectRunning[i]
            end
        end
        
        if not continueRunning then
            self:Kill()
        end
        
    end)
end

function StatusEffect:Kill()
    self.Connection:Disconnect()
    self.Connection = nil
    StatusEffectStorage[self.Player.UserId][self.Effect.EffectID] = nil
end






return StatusEffect
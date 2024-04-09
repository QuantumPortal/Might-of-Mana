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
    ["None"] = function(initialEffect,addedEffect) end
}

function StatusEffect.getEffectStorageTable()
    return StatusEffectStorage
end

function StatusEffect.new(effect, player, potency)
    local statusEffect = {}
    
    setmetatable(statusEffect,StatusEffect)
    
    statusEffect.Effect = effect
    statusEffect.Player = player
    statusEffect.Potency = potency

    statusEffect.ElapsedTime = 0

    statusEffect.PerSingleEffectArray = {}
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
    self.Connection = game:GetService("RunService").Stepped:Connect(function(_currentTime, deltaTime)
        
        
        self.ElapsedTime += deltaTime
        local continueRunning = false
        for i, singleEffect in self.Effect.Fields do

            if not self.PerSingleEffectArray[i] then
                self.PerSingleEffectArray[i] = {
                    ["TimeSinceLastTick"] = 0,
                    ["PreviousChange"] = 0,
                    ["CurrentlyRunning"] = true,
                }
            end

            
            self.PerSingleEffectArray[i]["TimeSinceLastTick"] += deltaTime

            if self.PerSingleEffectArray[i]["TimeSinceLastTick"]  > singleEffect["TickInterval"] and self.PerSingleEffectArray[i]["CurrentlyRunning"] then
                local duration = singleEffect["Duration"]
                if singleEffect["VariableDuration"] then
                    duration = singleEffect["Duration"](self.Potency)
                end

                if self.ElapsedTime > duration then
                    self.PerSingleEffectArray[i]["CurrentlyRunning"] = false
                    singleEffect["LastTickFunction"](self.Player, self.PerSingleEffectArray[i]["PreviousChange"])
                    
                else 
                local changeValue = singleEffect["Effect"](
                    self.Player,
                    self.ElapsedTime, 
                    self.Potency, 
                    self.PerSingleEffectArray[i]["PreviousChange"],
                    self.PerSingleEffectArray[i]["TimeSinceLastTick"]
                )

                self.PerSingleEffectArray[i]["TimeSinceLastTick"]  = 0
                self.PerSingleEffectArray[i]["PreviousChange"] = changeValue
                end  
            end
            
            continueRunning = continueRunning or self.PerSingleEffectArray[i]["CurrentlyRunning"]
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
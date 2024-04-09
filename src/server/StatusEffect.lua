StatusEffect = {}
StatusEffect.__index = StatusEffect

local StatusEffectStorage = {}
local CombineTypes = {
    ["StrongestReplace"] = function(initialEffect,addedEffect)
        if initialEffect["STATUSEFFECT"].Potency > addedEffect.Potency then
            initialEffect["STATUSEFFECT"].Time = 0
        else 
            initialEffect["STATUSEFFECT"]:Stop(addedEffect.Player,initialEffect["CONNECTION"])
            
            addedEffect:BeginRun(addedEffect.Player)
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

    if StatusEffectStorage[self.Player.UserId][self.EffectID] then
        local ExistingStatusEffect = StatusEffectStorage[self.Player.UserId][self.EffectID]
        print("Effect exists! Combining through",ExistingStatusEffect.CombineType)
        CombineTypes[ExistingStatusEffect.CombineType](ExistingStatusEffect,self)
        return
    end

    
    print("Creating effect: >",self.EffectID,"< on player", self.Player.DisplayName)
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
                self.PerSingleEffectArray[i]["TimeSinceLastTick"]  = 0
                local rawChangeValue, deltaChangeValue = singleEffect["Effect"](self.Player,self.ElapsedTime, self.Potency, self.PerSingleEffectArray[i]["PreviousChange"])
                self.PerSingleEffectArray[i]["PreviousChange"] = deltaChangeValue
                print(self.Player.StatusAbnormalities.Slow.Value, deltaChangeValue)

                if self.ElapsedTime > singleEffect["Duration"] then
                    self.PerSingleEffectArray[i]["CurrentlyRunning"] = false
                    if singleEffect["RequiresReversal"] then
                        singleEffect["Reversal"](self.Player, rawChangeValue)
                        print("fwaa")
                    end
                end
            end

            continueRunning = continueRunning and self.PerSingleEffectArray["CurrentlyRunning"]
        end

        if continueRunning then
            self.Connection:Disconnect()
            self.Connection = nil
        end

    end)
    
    
end
--[[
function StatusEffect:BeginRun(targetPlayer)
    local EffectRun
    StatusEffectStorage[targetPlayer][self.EffectID] = {
        ["STATUSEFFECT"] = self,
        ["CONNECTION"] = EffectRun
    }

    EffectRun = game:GetService("RunService").Stepped:Connect(function(_currentTime, deltaTime)
        self:Step(targetPlayer,deltaTime)
        if self.Duration < self.Time then
            self:Stop(targetPlayer,EffectRun)
        end
    end)
end


function StatusEffect:Step(player, deltaTime)
    self.Time += deltaTime
    local modifier = self.Transformation(self.Time)

    for Effect in self.Effects do
        Effect(player,deltaTime)
    end

    player:FindFirstChild(self.Effect.TYPE):FindFirstChild(self.Effect.NAME).Value += modifier * self.Potency - self.LastEffectApply
    self.EffectAggregate += modifier * self.Potency - self.LastEffectApply
    self.LastEffectApply = modifier * self.Potency
end
]]--






return StatusEffect
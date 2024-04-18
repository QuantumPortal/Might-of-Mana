SingleEffect = {}
SingleEffect.__index = SingleEffect


function SingleEffect.New(tickInterval, duration, firstTickFunction, perTickFunction, lastTickFunction)
    local singleEffect = {}
    setmetatable(singleEffect,SingleEffect)

    singleEffect.TickInterval = tickInterval
    singleEffect.Duration = duration
    singleEffect.FirstTickFunction = firstTickFunction
    singleEffect.PerTickFunction = perTickFunction
    singleEffect.LastTickFunction = lastTickFunction

    return singleEffect
end

function SingleEffect:Execute(deltaTime,timeSinceLastTick,statusEffect)
    if statusEffect.ElapsedTime == deltaTime then
        if self.FirstTickFunction then
            self.FirstTickFunction(deltaTime,timeSinceLastTick,statusEffect)
        end
    end
    
    
    if statusEffect.ElapsedTime > self.Duration(deltaTime,timeSinceLastTick,statusEffect) then
        if self.LastTickFunction then
            self.LastTickFunction(deltaTime,timeSinceLastTick,statusEffect)
        end
        return false, false
    elseif timeSinceLastTick > self.TickInterval then
        if self.PerTickFunction then
            self.PerTickFunction(deltaTime,timeSinceLastTick,statusEffect)
        end
        return true, true
    else
        return true, false
    end
        
    
end

return SingleEffect



Effect = {}
Effect.__index = Effect


function Effect.new(effectID, descriptor, fields, combineType)
    local effect = {}
    setmetatable(effect,Effect)

    effect.Descriptor = descriptor
    effect.EffectID = effectID
    effect.Fields = fields
    effect.CombineType = combineType
    

    return effect
end


return Effect
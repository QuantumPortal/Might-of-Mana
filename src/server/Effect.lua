Effect = {}
Effect.__index = Effect


function Effect.New(fields)
    local effect = {}
    setmetatable(effect,Effect)

    effect.Descriptor = "None"
    effect.Fields = fields
    effect.Image = ""

    return effect
end


return Effect
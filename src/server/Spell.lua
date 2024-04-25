Spell = {}
Spell.__index = Spell


function Spell.New(descriptor,cost,spellFunction)
    local spell = {}
    setmetatable(spell,Spell)
    
    spell.Descriptor = descriptor
    spell.Cost = cost
    spell.SpellFunction = spellFunction
    return spell
end


return Spell
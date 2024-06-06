StatusEffect = require(script.Parent.StatusEffect)
Effect = require(script.Parent.Effect)

local ServerStorage = game:GetService("ServerStorage")

Spell = {}
Spell.__index = Spell




function Spell.New(descriptor,modelID,manaCost,spellCasttime,spellCooldown,spellDuration,movementBehavior,spellFunction)
    local spell = {}
    setmetatable(spell,Spell)
    
    spell.Descriptor = descriptor
    spell.ModelID = modelID
    spell.ManaCost = manaCost
    spell.SpellCasttime = spellCasttime
    spell.SpellCooldown = spellCooldown
    spell.SpellDuration = spellDuration
    spell.MovementBehavior = movementBehavior
    spell.SpellFunction = spellFunction

    return spell
end

function Spell:Activate(statblock)
    StatusEffect.New(Effect.GetCommonEffect("status_abnormalities/cast_slow"),statblock,self.SpellCasttime, "SELF"):Apply()
    StatusEffect.New(Effect.GetCommonEffect("system/cast_cooldown"),statblock,self.SpellCooldown, "SELF"):Apply()

    self.SpellFunction(statblock,self)
end


return Spell
Damage = require(script.Parent.Damage)

DamageProfile = {}
DamageProfile.__index = DamageProfile

function DamageProfile.New(agressorStatblock, receiverStatblock, damageArray, damageType)
    local damageProfile = {}
    setmetatable(damageProfile,DamageProfile)

    damageProfile.AgressorStatblock = agressorStatblock
    damageProfile.ReceiverStatblock = receiverStatblock
    damageProfile.DamageArray = damageArray
    damageProfile.DamageType = damageType

    return damageProfile
end

function DamageProfile:Activate()
    --[[if self.DamageType == "Normal" then
        for key, value in pairs(self.ReceiverStatblock.DataFolder.OnDamageFunctions) do
        
        end
        for key, value in pairs(self.AgressorStatblock.DataFolder.OnAttackFunctions) do
        
        end
    end]]--

    for element, value in pairs(self.DamageArray) do
        local damageValue = value

        for _, resistance in pairs(self.ReceiverStatblock.DataFolder.Resistances:GetChildren()) do
            if resistance.Name == element then
                damageValue = value * (1-self.ReceiverStatblock.DataFolder.Resistances[element].Value)
            end
        end
        print(element,damageValue)
        Damage.Damage(damageValue,self.ReceiverStatblock)
    end

end

return DamageProfile
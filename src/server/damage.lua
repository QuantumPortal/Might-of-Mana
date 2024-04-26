local DamageService = {}

function DamageService.Damage(value, statblock)
    if statblock.DataFolder.CoreStats.Shield.Value > 0 then
        statblock.DataFolder.CoreStats.Shield.Value -= value
        
    else
        statblock.Humanoid:TakeDamage(value)  
    end
end

--
return DamageService
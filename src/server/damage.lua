local DamageService = {}

function DamageService.Damage(value, player,source,type)
    if player.CoreStats.Shield.Value > 0 then
        player.CoreStats.Shield.Value -= value
        
    else
        player.Character.Humanoid:TakeDamage(value)  
    end
end


return DamageService
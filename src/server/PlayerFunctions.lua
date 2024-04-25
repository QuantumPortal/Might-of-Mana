local mousePositionRemote = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("System"):WaitForChild("GetMousePos")
local PlayerFunctions = {}

function PlayerFunctions.UpdateSpeed(statblock)
    statblock.Humanoid.WalkSpeed = (
        (1+statblock.DataFolder.Buffs.Speed.Value/100) * 
        (1-statblock.DataFolder.StatusAbnormalities.Slow.Value/100) *  
        (1 + statblock.DataFolder.CoreStats.SprintMultiplier.Value * statblock.DataFolder.CoreStats.IsSprintValue.Value/1000) * 
        statblock.DataFolder.CoreStats.BaseWalkSpeed.Value
    )
end

function PlayerFunctions.GetMousePosition(player)
    return mousePositionRemote:InvokeClient(player)
end


return PlayerFunctions
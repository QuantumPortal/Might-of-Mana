Statblock = {}
Statblock.__index = Statblock



function Statblock.New(player,humanoid, folders)
    local statblock = {}
    setmetatable(statblock,Statblock)

    statblock.Player = player 
    statblock.Humanoid = humanoid

    if player then
        statblock.UniqueId = player.UserId
    else 
        statblock.UniqueId = humanoid.BasePart.UniqueId
    end

    statblock.StatusEffects = {}

    local dataFolder = Instance.new("Folder")
    dataFolder.Parent = statblock.Humanoid
    dataFolder.Name = "DataFolder"

    for category, categoryValues in pairs(folders) do
        local categoryFolder = Instance.new("Folder")
        categoryFolder.Parent = dataFolder
        categoryFolder.name = category

        for stat, statValue in pairs(categoryValues) do
            local numValueStat = Instance.new("NumberValue")
            numValueStat.Parent = categoryFolder
            numValueStat.Name = stat
            numValueStat.Value = statValue
        end
    end

    return statblock
end



return Statblock
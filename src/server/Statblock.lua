local HttpService = game:GetService("HttpService")
Statblock = {}
Statblock.__index = Statblock

StatblockArray = {}

function Statblock.New(player,humanoid, folders)
    local statblock = {}
    setmetatable(statblock,Statblock)

    if player then
        print("Initializing new statblock for player >> ", player.DisplayName, " <<")
    end
    
    statblock.Player = player 
    statblock.Humanoid = humanoid

    if player then
        statblock.UniqueId = player.UserId
    else 
        statblock.UniqueId = HttpService:GenerateGUID(false)
        humanoid:SetAttribute("UUID",statblock.UniqueId)
    end

    statblock.StatusEffects = {}

    local dataFolder = Instance.new("Folder")
    dataFolder.Parent = statblock.Humanoid
    dataFolder.Name = "DataFolder"
    print("Data folder created!")

    for category, categoryValues in pairs(folders) do
        print(category, " folder created!")
        local categoryFolder = Instance.new("Folder")
        categoryFolder.Parent = dataFolder
        categoryFolder.Name = category

        for stat, statValue in pairs(categoryValues) do
            local numValueStat = Instance.new("NumberValue")
            numValueStat.Parent = categoryFolder
            numValueStat.Name = stat
            numValueStat.Value = statValue
        end
    end

    statblock.DataFolder = dataFolder
    StatblockArray[statblock.UniqueId] = statblock

    return statblock
end

function Statblock.GetStatblock(uniqueId)
    return StatblockArray[uniqueId]
end


return Statblock
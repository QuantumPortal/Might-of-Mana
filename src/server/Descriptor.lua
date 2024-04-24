Descriptor = {}
Descriptor.__index = Descriptor

function Descriptor.New(category, name, flavourText, imageID)
    local descriptor = {}
    setmetatable(descriptor,Descriptor)

    descriptor.Category = category
    descriptor.Name = name
    descriptor.FlavourText = flavourText
    descriptor.ImageID = imageID

    return descriptor
end

return Descriptor
--[[
        © AsterionStaff 2024.
        This script was created from the developers of the AsterionTeam.
        You can get more information from one of the links below:
            Site - https://asterion.games
            Discord - https://discord.gg/CtfS8r5W3M
        
        developer(s):
            Selenter - https://steamcommunity.com/id/selenter

        ——— Chop your own wood and it will warm you twice.
]]--


function csp.zone:Add(data)
    local zone = self:Create(data, data.id)

    return zone
end

net.Receive("csp.zone:Add", function(len)
    local id = net.ReadUInt(16)

    local maxPosition = net.ReadVector()
    local minPosition = net.ReadVector()
    local maxSyncPosition = net.ReadVector()
    local minSyncPosition = net.ReadVector()

    local props = {}
    local propsCount = net.ReadUInt(16)
    for i = 1, propsCount do
        local propID = net.ReadUInt(16)

        props[propID] = true
    end

    csp.zone:Add({
        id = id,
        minPosition = maxPosition,
        maxPosition = minPosition,
        maxSyncPosition = maxSyncPosition,
        minSyncPosition = minSyncPosition,
        props = props
    })
end)


function csp.zone:Remove(id)
    local zone = self.instances[id]
    if !zone then return end

    -- eh..
end

net.Receive("csp.zone:Remove", function(len)
    local id = net.ReadUInt(16)

    csp.zone:Remove(id)
end)


net.Receive("csp.zone:Clear", function(len)
    csp.zone:Clear()
end)


timer.Create("csp.zone:Update", 2, 0, function()
    local eyePos = EyePos()

    local data = {}
    for _, zone in ipairs(csp.zone.instances) do
        local bIsVector = eyePos:WithinAABox(zone:GetMinSyncPosition(), zone:GetMaxSyncPosition())
        if !bIsVector then continue end

        for propID in pairs(zone.props) do
            data[propID] = true
        end
    end

    for id, prop in pairs(csp.prop.instances) do
        local entity = prop.csEnt
        local bValid = IsValid(entity)

        if data[id] then
            if !bValid then
                prop:Render()
            end
        else
            if bValid then
                entity:Remove()
            end

            prop.csEnt = nil
        end
    end
end)
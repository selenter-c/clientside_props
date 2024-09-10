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


util.AddNetworkString("csp.zone:Add")
util.AddNetworkString("csp.zone:Remove")
util.AddNetworkString("csp.zone:Clear")

local table_equal = include("libs/table_equal.lua")

local function getAllPropsNear(position, allCheck)
    local data = {}

    for _, prop in pairs(csp.prop.instances) do
        local id = prop:GetID()
        if allCheck[id] then continue end

        local pos = prop:GetPosition()

        if pos:Distance(position) <= csp.zone.compound_distance then
            data[id] = true
            allCheck[id] = true

            local otherData = getAllPropsNear(pos, allCheck)
            for k, v in pairs(otherData) do
                data[k] = true
            end
        end
    end

    return data
end

local function clear_equal(data)
    for i = 1, #data do
        for i2 = 1, #data do
            if i == i2 then continue end

            if table_equal(data[i], data[i2]) then
                table.remove(data, i2)

                return clear_equal(data)
            end
        end
    end

    return data
end

local function collectObjects()
    local data = {}

    for _, prop in pairs(csp.prop.instances) do
        local props = getAllPropsNear(prop:GetPosition(), {})

        data[prop:GetID()] = props
    end

    for _, array in pairs(data) do
        local props = {}
        for propID in pairs(array) do
            props[#props + 1] = propID
        end

        if #props > 1 then
            for i = 2, #props do
                data[props[i]] = nil
            end
        end
    end

    return data
end

local function convertPropsToPosition(data)
    local result = {}

    for k, v in pairs(data) do
        local prop = csp.prop.instances[k]
        if !prop then continue end

        result[#result + 1] = prop:GetPosition()
    end

    return result
end

local function VectorMax(x, y, z, distance)
    local maxX = math.max(unpack(x)) + distance
    local maxY = math.max(unpack(y)) + distance
    local maxZ = math.max(unpack(z)) + distance * 0.5

    return Vector(maxX, maxY, maxZ)
end

local function VectorMin(x, y, z, distance)
    local minX = math.min(unpack(x)) - distance
    local minY = math.min(unpack(y)) - distance
    local minZ = math.min(unpack(z)) - distance * 0.5

    return Vector(minX, minY, minZ)
end

local function getVectorsInPositions(positions)
    local x, y, z = {}, {}, {}

    for _, pos in ipairs(positions) do
        x[#x + 1] = pos.x
        y[#y + 1] = pos.y
        z[#z + 1] = pos.z
    end

    local indentation_dist = csp.zone.indentation_distance
    local sync_distance = csp.zone.sync_distance

    return VectorMin(x, y, z, indentation_dist), VectorMax(x, y, z, indentation_dist),
        VectorMin(x, y, z, sync_distance), VectorMax(x, y, z, sync_distance)
end

function csp.zone:Update()
    self:Clear()

    local collects = collectObjects()
    for _, props in pairs(collects) do
        local positions = convertPropsToPosition(props)
        local minVector, maxVector, minSyncVector, maxSyncVector = getVectorsInPositions(positions)

        self.lastID = self.lastID + 1

        local zone = csp.zone:Add({
            id = self.lastID,
            maxPosition = maxVector,
            minPosition = minVector,
            maxSyncPosition = maxSyncVector,
            minSyncPosition = minSyncVector,
            props = props
        })
        zone:Sync()
    end
end

function csp.zone:Sync(id, receivers)
    local zone = self.instances[id]
    if !zone then return end

    net.Start("csp.zone:Add")
        -- main
        net.WriteUInt(zone.id, 16)

        net.WriteVector(zone.maxPosition)
        net.WriteVector(zone.minPosition)
        net.WriteVector(zone.maxSyncPosition)
        net.WriteVector(zone.minSyncPosition)

        -- props
        net.WriteUInt(table.Count(zone.props), 16)
        for propID in pairs(zone.props) do
            net.WriteUInt(propID, 16)
        end
    if receivers then
        net.Send(receivers)
    else
        net.Broadcast()
    end
end

function csp.zone:SyncAll(recivers)
    net.Start("csp.zone:Clear")
    net.Broadcast()

    timer.Simple(1, function()
        for _, zone in pairs(self.instances) do
            zone:Sync(recivers)
        end
    end)
end

function csp.zone:Add(data)
    local zone = self:Create(data, data.id)

    return zone
end

util.AddNetworkString("csp.zone:Teleport")

net.Receive("csp.zone:Teleport", function(len, client)
    local id = net.ReadUInt(16)

    local message = csp:TeleportZone(client, id)
    if message then
        client:ChatPrint(csp.prefix .. " " .. message)
    end
end)


hook.Add("PlayerInitialSpawn", "csp.zone:CreateTimer", function(client)
    local uniqueID = "csp.zone:Timer_" .. client:SteamID()
    timer.Create(uniqueID, 4, 0, function()
        if !IsValid(client) then return timer.Remove(uniqueID) end

        local pos = client:GetPos()
        for _, zone in ipairs(csp.zone.instances) do
            local bIsVector = pos:WithinAABox(zone:GetMinSyncPosition(), zone:GetMaxSyncPosition())
            if !bIsVector then continue end

            zone:SyncProps(client)
        end
    end)
end)
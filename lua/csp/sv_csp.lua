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


function csp:TransformEntity(client, entity)
    if !IsValid(entity) then return "Invalid entity!" end

    local bAllow = hook.Run("csp:OnCanTransformEntity", client, entity)
    if bAllow != true then return "No Access!" end

    local data = self:GetEntityInfo(entity)
    if !data then return "Impossible to obtain information about the object!" end

    local prop = csp.prop:Add(data)
    prop:SetCSOwner(client)
    prop:Sync(client)

    entity:Remove()

    hook.Run("csp:OnTransformEntity", client, prop)

    local id = prop:GetID()
    return "CSProp with id \"" .. id .. "\" was successfully created!"
end

function csp:TeleportEntity(client, id)
    local prop = csp.prop:GetByID(id)
    if !prop then return "CSProp with id \"" .. id .. "\" not found!" end

    local bAllow = hook.Run("csp:OnCanTeleportEntity", client, prop)
    if bAllow != true then return "No Access!" end

    client:SetPos(prop:GetPosition())

    hook.Run("csp:OnTeleportEntity", client, prop)

    return "Player " .. tostring(client) .. " teleported to CSProp with id \"" .. id .. "\"!"
end

function csp:TeleportZone(client, id)
    local zone = csp.zone:GetByID(id)
    if !zone then return "Zone with id \"" .. id .. "\" not found!" end

    local bAllow = hook.Run("csp:OnCanTeleportZone", client, zone)
    if bAllow != true then return "No Access!" end

    client:SetPos(zone:GetMinPosition())

    hook.Run("csp:OnTeleportZone", client, zone)

    return "Player " .. tostring(client) .. " teleported to Zone with id \"" .. id .. "\"!"
end

function csp:ReturnEntity(client, id)
    local prop = csp.prop:GetByID(id)
    if !prop then return "CSProp with id \"" .. id .. "\" not found!" end

    local bAllow = hook.Run("csp:OnCanReturnEntity", client, prop)
    if bAllow != true then return "No Access!" end

    prop:ReturnToServer()

    hook.Run("csp:OnReturnEntity", client, id)

    return "CSProp with id \"" .. id .. "\" was successfully returned!"
end

function csp:RemoveEntity(client, id)
    local prop = csp.prop:GetByID(id)
    if !prop then return "CSProp with id \"" .. id .. "\" not found!" end

    local bAllow = hook.Run("csp:OnCanRemoveEntity", client, prop)
    if bAllow != true then return "No Access!" end

    prop:Remove()

    hook.Run("csp:OnRemoveEntity", client, id)

    return "CSProp with id \"" .. id .. "\" was successfully removed!"
end

file.CreateDir(csp.path)
file.CreateDir(csp.path .. "/" .. game.GetMap())

function csp:GetFilePath(name)
    local filePath = csp.path .. "/" .. game.GetMap() .. "/" .. name .. ".txt"

    return filePath
end

function csp:ReadConfig(name)
    local filePath = csp:GetFilePath(name)

    local content = file.Read(filePath, "DATA")
    local data = content and util.JSONToTable(content) or csp.default_config

    return data
end

function csp:LoadConfig(name)
    local data = self:ReadConfig(name)

    for _, info in ipairs(data.props) do
        csp.prop:Add(info, true)
    end

    csp.zone:Update()
end

-- Содержит Entity объектов. Нам они не нужны в сохранении
local noSaveInfo = {
    csEnt = true,
    csOwner = true,
    owner = true
}

function csp:SaveConfig(name)
    local data = self:ReadConfig(name)

    for k, v in pairs(csp.prop.instances) do
        local info = v:GetInfo()

        local infoSave = {}
        for k2, v2 in pairs(info) do
            if noSaveInfo[k2] then continue end

            infoSave[k2] = v2
        end

        data.props[#data.props + 1] = infoSave
    end

    local filePath = csp:GetFilePath(name)
    file.Write(filePath, util.TableToJSON(data))
end


util.AddNetworkString("csp:ClientReady")

local load_queue = {}
net.Receive("csp:ClientReady", function(len, client)
    if load_queue[client] then return end

    load_queue[client] = true

    for id, zone in ipairs(csp.zone.instances) do
        zone:Sync(client)
    end
end)
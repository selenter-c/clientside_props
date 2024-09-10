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


csp.zone = csp.zone or {}
csp.zone.instances = {}
csp.zone.lastID = 0

csp.zone.indentation_distance = 20
csp.zone.compound_distance = 200
csp.zone.sync_distance = 3000

function csp.zone:New(id)
    if self.instances[id] then
        return self.instances[id]
    end

    local zone = {id = id, props = {}, syncs = {}}
    setmetatable(zone, csp.meta.zone)

    self.instances[id] = zone

    return zone
end

function csp.zone:Create(data, id)
    if !id then
        self.lastID = self.lastID + 1

        id = self.lastID
    end

    local zone = self:New(id)
    zone:SetMaxPosition(data.maxPosition)
    zone:SetMinPosition(data.minPosition)
    zone:SetMaxSyncPosition(data.maxSyncPosition)
    zone:SetMinSyncPosition(data.minSyncPosition)
    zone:SetProps(data.props)

    return zone
end

function csp.zone:GetByID(id)
    return self.instances[id]
end

function csp.zone:Clear()
    for _, zone in pairs(self.instances) do
        zone:Destroy()
    end

    self.instances = {}
    self.lastID = 0

    if SERVER then
        net.Start("csp.zone:Clear")
        net.Broadcast()
    elseif CLIENT then
        csp:UpdateAppList()
    end
end


AddCSLuaFile(csp.path .. "/cl_csp_zone.lua")
if CLIENT then
    include(csp.path .. "/cl_csp_zone.lua")
end

if SERVER then
    include(csp.path .. "/sv_csp_zone.lua")
end
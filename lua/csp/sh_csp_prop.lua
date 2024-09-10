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


csp.prop = csp.prop or {}
csp.prop.instances = {}
csp.prop.lastID = 0

function csp.prop:New(id)
    if self.instances[id] then
        return self.instances[id]
    end

    local prop = {id = id, syncs = {}}
    setmetatable(prop, csp.meta.prop)

    self.instances[id] = prop

    return prop
end

function csp.prop:Create(data, id)
    if !id then
        self.lastID = self.lastID + 1

        id = self.lastID
    end

    local prop = self:New(id)
    prop:SetPosition(data.position)
    prop:SetAngle(data.angle)
    prop:SetModel(data.model)
    prop:SetSkin(data.skin)
    prop:SetColor(data.color)
    prop:SetMaterial(data.material)
    prop:SetRenderMode(data.rendermode)

    if data.owner then
        prop:SetOwner(data.owner)
    end

    if data.csOwner then
        prop:SetCSOwner(data.csOwner)
    end

    for k, v in pairs(data.bodygroups) do
        prop:SetBodygroup(k, v)
    end

    for k, v in pairs(data.submaterials) do
        prop:SetSubMaterial(k, v)
    end

    return prop
end

function csp.prop:GetByID(id)
    return self.instances[id]
end

function csp.prop:Clear()
    for _, prop in pairs(self.instances) do
        prop:Destroy()
    end

    self.instances = {}
    self.lastID = 0

    if SERVER then
        net.Start("csp.prop:Clear")
        net.Broadcast()
    elseif CLIENT then
        csp:UpdateAppList()
    end
end


AddCSLuaFile(csp.path .. "/cl_csp_prop.lua")
if CLIENT then
    include(csp.path .. "/cl_csp_prop.lua")
end

if SERVER then
    include(csp.path .. "/sv_csp_prop.lua")
end
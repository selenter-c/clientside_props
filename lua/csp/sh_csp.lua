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

csp.configs = {}
csp.config_default = nil
csp.default_config = {
    props = {},
    default = false
}

function csp:GetConfigs()
    return csp.configs
end

-- Использует ли пользователь ClientSide Props Tool
function csp:IsUsesTool(client)
    if !IsValid(client) then return false end

    local weapon = client:GetActiveWeapon()
    if !IsValid(weapon) then return false end

    local class = weapon:GetClass()
    if class != "gmod_tool" then return false end

    local tool = client:GetTool() and client:GetTool().Name or nil
    if tool != "ClientSide Props Tool" then return false end

    return true
end

-- Получаем информацию о ClientSide Props Tool
function csp:GetToolData(client)
    if !self:IsUsesTool(client) then return end

    local trace = client:GetEyeTrace()

    local data = {
        hitPos = trace.HitPos,
        hitNormal = trace.HitNormal,
        entity = trace.Entity
    }

    return data
end

-- Получаем информацию об объекте
function csp:GetEntityInfo(entity)
    local data = {
        position = entity:GetPos(),
        angle = entity:GetAngles(),
        model = entity:GetModel(),
        skin = entity:GetSkin(),
        color = entity:GetColor(),
        material = entity:GetMaterial(),
        rendermode = entity:GetRenderMode(),
        owner = entity:GetOwner(),

        submaterials = {},
        bodygroups = {}
    }

    data.submaterials = {}
    local sm = entity:GetMaterials()
    if sm then
        for k, v in ipairs(sm) do
            local mat = entity:GetSubMaterial(k - 1)

            if mat and mat != "" then
                data.submaterials[k - 1] = mat
            end
        end
    end

    data.bodygroups = {}
    local bg = entity:GetBodyGroups()
    if bg then
        for k, v in ipairs(bg) do
            local bodygroup = entity:GetBodygroup(v.id)

            if bodygroup > 0 then
                data.bodygroups[v.id] = bodygroup
            end
        end
    end

    return data
end

function csp:GetEntityToPosition(position)
    local data = {}
    for _, prop in pairs(csp.prop.instances) do
        local id = prop:GetID()
        local pos = prop:GetPosition()
        local distance = position:Distance(pos)

        if distance <= 100 then
            data[id] = distance
        end
    end

    if table.Count(data) <= 0 then return "Nearest ClientSide Prop was not found!" end

    local pack = {}
    for id, distance in pairs(data) do
        pack[#pack + 1] = distance
    end

    local min = math.min(unpack(pack))
    if !min then return "Nearest ClientSide Prop was not found!" end

    for id, distance in pairs(data) do
        if math.floor(distance) == math.floor(min) then
            local prop = csp.prop:GetByID(id)
            if !prop then continue end

            return prop
        end
    end
end


AddCSLuaFile(csp.path .. "/sh_csp_prop.lua")
AddCSLuaFile(csp.path .. "/sh_csp_zone.lua")
include(csp.path .. "/sh_csp_prop.lua")
include(csp.path .. "/sh_csp_zone.lua")


AddCSLuaFile(csp.path .. "/sh_config.lua")
include(csp.path .. "/sh_config.lua")
--[[
        © AsterionStaff 2024.
        This script was created from the developers of the Asterion Staff.
        You can get more information from one of the links below:
            Site - https://asterion.games
            Discord - https://discord.gg/Np5evb5ZsR
        
        developer(s):
            Selenter - https://steamcommunity.com/id/selenter

        ——— Chop your own wood and it will warm you twice.
]]--


local PROP = {}
PROP.__index = PROP
PROP.id = 0

PROP.position = Vector(0, 0, 0)
PROP.angle = Angle(0, 0, 0)
PROP.model = "models/error.mdl"
PROP.skin = 0
PROP.color = Color(255, 255, 255)
PROP.material = ""
PROP.rendermode = 0

PROP.bodygroups = {}
PROP.submaterials = {}

PROP.csEnt = nil
PROP.csOwner = nil
PROP.owner = nil

PROP.syncs = {}

function PROP:__tostring()
    local entity = self:GetEntity()
    local name = IsValid(entity) and "Entity(" .. entity:EntIndex() .. ")" or "NULL Entity"

    return "CSP PROP[" .. self.id .. "][" .. name .. "][" .. self.model .. "]"
end

function PROP:__eq(other)
    return self:GetID() == other:GetID()
end

function PROP:GetID()
    return self.id
end

function PROP:SetPosition(position)
    self.position = isvector(position) and position or nil
end

function PROP:GetPosition()
    return self.position
end

function PROP:SetAngle(angle)
    self.angle = isangle(angle) and angle or nil
end

function PROP:GetAngle()
    return self.angle
end

function PROP:SetModel(model)
    self.model = tostring(model)
end

function PROP:GetModel()
    return self.model
end

function PROP:SetSkin(skin)
    self.skin = tonumber(skin)
end

function PROP:GetSkin()
    return self.skin
end

function PROP:SetColor(color)
    self.color = IsColor(color) and color or nil
end

function PROP:GetColor()
    return self.color
end

function PROP:SetMaterial(material)
    self.material = tostring(material)
end

function PROP:GetMaterial()
    return self.material
end

function PROP:SetRenderMode(renderMode)
    self.rendermode = tonumber(renderMode)
end

function PROP:GetRenderMode()
    return self.rendermode
end

function PROP:SetBodygroup(index, value)
    self.bodygroups[tonumber(index)] = tonumber(value)
end

function PROP:GetBodygroup(index)
    return self.bodygroups[index]
end

function PROP:SetSubMaterial(index, material)
    self.submaterials[tonumber(index)] = tonumber(material)
end

function PROP:GetSubMaterial(index)
    return self.submaterials[index]
end

function PROP:GetEntity()
    return self.csEnt
end

function PROP:SetOwner(owner)
    self.owner = owner
end

function PROP:GetOwner()
    return self.owner
end

function PROP:SetCSOwner(owner)
    self.csOwner = owner
end

function PROP:GetCSOwner()
    return self.csOwner
end

function PROP:Render()
    if IsValid(self.csEnt) then
        self.csEnt:Remove()
        self.csEnt = nil
    end

    local csEnt = ClientsideModel(self.model)
    csEnt:SetPos(self.position)
    csEnt:SetAngles(self.angle)
    csEnt:SetSkin(self.skin)
    csEnt:SetColor(self.color)
    csEnt:SetMaterial(self.material)
    csEnt:SetRenderMode(self.rendermode)

    for k, v in pairs(self.bodygroups) do
        csEnt:SetBodygroup(k, v)
    end

    for k, v in pairs(self.submaterials) do
        csEnt:SetSubMaterial(k, v)
    end

    self.csEnt = csEnt
end

function PROP:GetInfo()
    local data = {
        id = self.id,
        position = self.position,
        angle = self.angle,
        model = self.model,
        skin = self.skin,
        color = self.color,
        material = self.material,
        rendermode = self.rendermode,
        csEnt = self.csEnt,
        csOwner = self.csOwner,
        owner = self.owner,
        bodygroups = self.bodygroups,
        submaterials = self.submaterials
    }

    return data
end

function PROP:Dump()
    local info = self:GetInfo()
    for k, v in pairs(info) do
        if istable(v) then
            print(k .. ":")
            for k2, v2 in pairs(v) do
                print(k2 .. ": ", v2)
            end
        else
            print(k .. ": ", v)
        end
    end
end

function PROP:Destroy()
    if IsValid(self.csEnt) then
        self.csEnt:Remove()
    end

    self.csEnt = nil
    csp.prop.instances[self.id] = nil
end

if SERVER then
    function PROP:Sync(receivers)
        csp.prop:Sync(self.id, receivers)
    end

    function PROP:Remove(bNoUpdateZone)
        net.Start("csp.prop:Remove")
            net.WriteUInt(self:GetID(), 16)
        net.Broadcast()

        self:Destroy()

        if !bNoUpdateZone then
            csp.zone:Update()
        end
    end

    function PROP:ReturnToServer()
        local entity = ents.Create("prop_physics")
        entity:SetModel(self.model)
        entity:SetPos(self.position)
        entity:SetAngles(self.angle)
        entity:SetSkin(self.skin)
        entity:SetColor(self.color)
        entity:SetMaterial(self.material)
        entity:SetRenderMode(self.rendermode)
        entity:Spawn()

        for k, v in pairs(self.bodygroups) do
            entity:SetBodygroup(k, v)
        end

        for k, v in pairs(self.submaterials) do
            entity:SetSubMaterial(k, v)
        end

        local physObj = entity:GetPhysicsObject()
        if IsValid(physObj) then
            physObj:EnableMotion(false)
        end

        self:Remove()
    end
elseif CLIENT then
    local color_green = Color(0, 255, 0)
    local color_red = Color(255, 0, 0)

    function PROP:DrawInfo()
        local position = self:GetPosition()

        if EyePos():DistToSqr(position) >= 15000000 then return end

        local data2D = position:ToScreen()
        if !data2D.visible then return end

        local idx = self:GetID()
        local model = self:GetModel()
        local entity = self:GetEntity()

        local color = IsValid(entity) and color_green or color_red

        local _, height = draw.SimpleText("ID: " .. idx, "Default", data2D.x, data2D.y, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(model, "Default", data2D.x, height + data2D.y, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end


csp.meta.prop = PROP
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


local ZONE = {}
ZONE.__index = ZONE
ZONE.id = 0

ZONE.maxPosition = Vector(0, 0, 0)
ZONE.minPosition = Vector(0, 0, 0)
ZONE.maxSyncPosition = Vector(0, 0, 0)
ZONE.minSyncPosition = Vector(0, 0, 0)
ZONE.props = {}
ZONE.syncs = {}

-- eh...

function ZONE:__tostring()
    return "CSP ZONE[" .. self.id .. "]"
end

function ZONE:__eq(other)
    return self:GetID() == other:GetID()
end

function ZONE:GetID()
    return self.id
end

function ZONE:SetMaxPosition(position)
    self.maxPosition = isvector(position) and position or nil
end

function ZONE:GetMaxPosition()
    return self.maxPosition
end

function ZONE:SetMinPosition(position)
    self.minPosition = isvector(position) and position or nil
end

function ZONE:GetMinPosition()
    return self.minPosition
end

function ZONE:SetMaxSyncPosition(position)
    self.maxSyncPosition = isvector(position) and position or nil
end

function ZONE:GetMaxSyncPosition()
    return self.maxSyncPosition
end

function ZONE:SetMinSyncPosition(position)
    self.minSyncPosition = isvector(position) and position or nil
end

function ZONE:GetMinSyncPosition()
    return self.minSyncPosition
end

function ZONE:SetProps(props)
    self.props = istable(props) and props or nil
end

function ZONE:GetProps()
    return self.props
end

function ZONE:Destroy()
    csp.zone.instances[self.id] = nil
end


if SERVER then
    function ZONE:Sync(receivers)
        csp.zone:Sync(self.id, receivers)
    end

    function ZONE:SyncProps(receivers)
        if isentity(receivers) and receivers:IsPlayer() then
            if self.syncs[receivers] then return end

            self.syncs[receivers] = true
        elseif istable(receivers) then
            for k, v in ipairs(receivers) do
                if self.syncs[v] then
                    table.remove(receivers, k)
                end

                self.syncs[v] = true
            end
        end

        if istable(receivers) and #receivers <= 0 then return end

        print("sync", zone.id)

        for id in pairs(self.props) do
            local prop = csp.prop:GetByID(id)
            if !prop then continue end

            timer.Simple(math.random() * 10, function()
                if !prop then return end

                prop:Sync(receivers)
            end)
        end
    end
elseif CLIENT then
    local vector_nil = Vector(0, 0, 0)
    local angle_nil = Angle(0, 0, 0)

    -- local color_green = Color(0, 255, 0)
    -- local color_red = Color(255, 0, 0)

    function ZONE:DrawInfo()
        render.DrawWireframeBox(vector_nil, angle_nil, self:GetMinPosition(), self:GetMaxPosition(), Color(255, 255, 255))

        render.DrawWireframeBox(vector_nil, angle_nil, self:GetMinSyncPosition(), self:GetMaxSyncPosition(), Color(0, 110, 255))
    end
end

csp.meta.zone = ZONE
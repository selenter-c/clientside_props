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

csp.ui = csp.ui or {}

function csp:UpdateAppList()
    local propsList = csp.ui.appPropsList
    if IsValid(propsList) then
        propsList:Clear()

        for _, prop in pairs(csp.prop.instances) do
            local id = prop:GetID()
            local model = prop:GetModel()
            local position = prop:GetPosition()

            local x = math.floor(position.x)
            local y = math.floor(position.y)
            local z = math.floor(position.z)

            local panel = propsList:AddLine(id, model, x .. ", " .. y .. ", " .. z)
            panel.Paint = function(this, w, h)
                local isValid = prop and IsValid(prop:GetEntity())

                surface.SetDrawColor(isValid and 0 or 255, isValid and 255 or 0, 0)
                surface.DrawRect(0, 0, w, h)
            end
        end
    end

    local zonesList = csp.ui.appZonesList
    if IsValid(zonesList) then
        zonesList:Clear()

        for _, zone in pairs(csp.zone.instances) do
            local id = zone:GetID()

            local panel = zonesList:AddLine(id)
            panel.Paint = function(this, w, h)
                -- eh...
            end
        end
    end
end


hook.Add("InitPostEntity", "csp:Ready", function()
    timer.Simple(0, function()
        net.Start("csp:ClientReady")
        net.SendToServer()
    end)
end)
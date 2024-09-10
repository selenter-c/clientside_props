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


hook.Add("csp:OnCanTransformEntity", "csp.default", function(client, entity)
    return client:IsAdmin()
end)

hook.Add("csp:OnCanTeleportEntity", "csp.default", function(client, prop)
    return client:IsAdmin()
end)

hook.Add("csp:OnCanTeleportZone", "csp.default", function(client, zone)
    return client:IsAdmin()
end)

hook.Add("csp:OnCanReturnEntity", "csp.default", function(client, prop)
    return client:IsAdmin()
end)

hook.Add("csp:OnCanRemoveEntity", "csp.default", function(client, prop)
    return client:IsAdmin()
end)



hook.Add("csp.zone:OnCanSaveConfig", "csp.default", function(client, name)
    return client:IsAdmin()
end)

hook.Add("csp.zone:OnCanLoadConfig", "csp.default", function(client, name)
    return client:IsAdmin()
end)

hook.Add("csp.zone:OnCanRemoveConfig", "csp.default", function(client, name)
    return client:IsAdmin()
end)

hook.Add("csp.zone:OnCanSetDefaultConfig", "csp.default", function(client, name)
    return client:IsSuperAdmin()
end)
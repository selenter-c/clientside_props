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

-- ----------------------------------------------------------------
csp = csp or {meta = {}}
csp._INFORMATION = csp._INFORMATION or {
    _TITLE = "ClientSide Props",
    _DESCRIPTION = "System allows you to turn server objects into client objects",
    _AUTHOR = "Selenter",
    _VERSION = 0.1
}
-- ----------------------------------------------------------------

-- путь к папке хранения
csp.path = "csp"

-- префикс сообщений в чате
csp.prefix = "[CSP]"


-- Инклаидаем остальные файлы
do
    -- libs
    AddCSLuaFile(csp.path .. "/libs/sh_sfs.lua")
    include(csp.path .. "/libs/sh_sfs.lua")

    -- cl
    AddCSLuaFile(csp.path .. "/cl_csp.lua")
    if CLIENT then
        include(csp.path .. "/cl_csp.lua")
    end

    -- meta sh
    AddCSLuaFile(csp.path .. "/meta/sh_meta_prop.lua")
    AddCSLuaFile(csp.path .. "/meta/sh_meta_zone.lua")
    include(csp.path .. "/meta/sh_meta_prop.lua")
    include(csp.path .. "/meta/sh_meta_zone.lua")

    -- sh
    AddCSLuaFile(csp.path .. "/sh_csp.lua")
    include(csp.path .. "/sh_csp.lua")

    -- sv
    if SERVER then
        include(csp.path .. "/sv_csp.lua")
    end
end
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


AddCSLuaFile()

TOOL.Name = "ClientSide Props Tool" -- Название
TOOL.Category = "Asterion Tools" -- Категория
TOOL.Information = { -- Дополнительная информация
    {name = "left", stage = 0},
    {name = "right", stage = 0},
    {name = "reload", stage = 0},
}

TOOL.ClientConVar.drawcsprops = 1
TOOL.ClientConVar.drawzones = 1

-- Добавляем язык
if CLIENT then
    language.Add("tool.clientsideprops.name", "ClientSide Props Tool")
    language.Add("tool.clientsideprops.desc", "Allows you to turn ordinary objects into Client Side Props")
    language.Add("tool.clientsideprops.left", "Click the left mouse button to turn the server object into a client prop.")
    language.Add("tool.clientsideprops.right", "Return client prop to server prop.")
    language.Add("tool.clientsideprops.reload", "Right click to delete client prop.")
end

-- Левая кнопка мыши
function TOOL:LeftClick(trace)
    if CLIENT then return true end

    local client = self:GetOwner()

    local data = csp:GetToolData(client)
    if !data then return end

    local entity = data.entity
    if !IsValid(entity) then return client:ChatPrint(csp.prefix .. " Not valid Entity!") end

    local message = csp:TransformEntity(client, data.entity)
    if message then
        client:ChatPrint(csp.prefix .. " " .. message)
    end

    return true
end

-- Правая кнопка мыши
function TOOL:RightClick(trace)
    if CLIENT then return true end

    local client = self:GetOwner()

    local data = csp:GetToolData(client)
    if !data then return end

    local prop = csp:GetEntityToPosition(data.hitPos)
    if !prop or isstring(prop) then
        return client:ChatPrint(csp.prefix .. " " .. prop)
    end

    local message = csp:ReturnEntity(client, prop:GetID())
    if message then
        client:ChatPrint(csp.prefix .. " " .. message)
    end

    return true
end

-- Перезарядка
function TOOL:Reload(trace)
    if CLIENT then return true end

    local client = self:GetOwner()

    local data = csp:GetToolData(client)
    if !data then return end

    local prop = csp:GetEntityToPosition(data.hitPos)
    if !prop or isstring(prop) then
        return client:ChatPrint(csp.prefix .. " " .. prop)
    end

    local message = csp:RemoveEntity(client, prop:GetID())
    if message then
        client:ChatPrint(csp.prefix .. " " .. message)
    end

    return true
end

properties.Add("csp_transform", {
    MenuLabel = csp.prefix .. " Transform",
    Order = 999,
    MenuIcon = "icon16/ipod_cast.png",
    Filter = function(self, entity, client)
        return IsValid(entity)
    end,
    Action = function(self, entity)
        self:MsgStart()
            net.WriteEntity(entity)
        self:MsgEnd()
    end,
    Receive = function(self, length, client)
        local entity = net.ReadEntity()

        local message = csp:TransformEntity(client, entity)
        if message then
            client:ChatPrint(csp.prefix .. " " .. message)
        end
    end
})

if CLIENT then
    local l = "clientsideprops_"

    function TOOL.BuildCPanel(CPanel)
        CPanel:AddControl("Header",{
            Description = "This tool allows you to easily convert server-side to client-side objects. This can increase the performance of your server."
        })

        local saveButton = vgui.Create("DButton")
        saveButton:SetText("Configs")
        saveButton:Dock(BOTTOM)
        saveButton.DoClick = function()
            local Menu = DermaMenu()

            -- local data = csp:GetConfigs()
            -- for k, v in ipairs(data) do
            --     local option = Menu:AddOption(v.name, function()
            --         -- eh...
            --     end)

            --     if v.default then
            --         option:SetIcon("icon16/accept.png")
            --     end
            -- end

            Menu:AddOption("Save props", function()
            end):SetIcon("icon16/add.png")

            local childList, parentList = Menu:AddSubMenu("List")
            parentList:SetIcon("icon16/arrow_down.png")

            Menu:Open()
        end
        CPanel:AddPanel(saveButton)

        local drawProps = vgui.Create("DCheckBoxLabel")
        drawProps:SetText("Draw Props")
        drawProps:SetConVar(l .. "drawcsprops")
        drawProps:SetValue(GetConVar(l .. "drawcsprops"):GetBool())
        drawProps:SetTextColor(Color(0, 0, 0))
        CPanel:AddPanel(drawProps)

        local drawZones = vgui.Create("DCheckBoxLabel")
        drawZones:SetText("Draw Zones")
        drawZones:SetConVar(l .. "drawzones")
        drawZones:SetValue(GetConVar(l .. "drawzones"):GetBool())
        drawZones:SetTextColor(Color(0, 0, 0))
        CPanel:AddPanel(drawZones)

        local appPropsListLabel = vgui.Create("DLabel")
        appPropsListLabel:SetText("List Props:")
        appPropsListLabel:SetDark(true)
        CPanel:AddPanel(appPropsListLabel)

        local appPropsList = vgui.Create("DListView")
        appPropsList:SetTall(400)
        appPropsList:SetMultiSelect(false)
        appPropsList:AddColumn("ID")
        appPropsList:AddColumn("Model")
        appPropsList:AddColumn("Position")
        appPropsList.OnRowSelected = function(this, index, pnl)
            local Menu = DermaMenu()

            Menu:AddOption("Teleport", function()
                local idx = pnl:GetColumnText(1)

                net.Start("csp.prop:Teleport")
                    net.WriteUInt(idx, 16)
                net.SendToServer()
            end):SetIcon("icon16/control_play_blue.png")

            Menu:AddOption("Dump to Console", function()
                local idx = pnl:GetColumnText(1)

                local prop = csp.prop.instances[idx]
                if prop then
                    prop:Dump()
                end
            end):SetIcon("icon16/page_red.png")

            Menu:AddOption("Return", function()
                local idx = pnl:GetColumnText(1)

                net.Start("csp.prop:Return")
                    net.WriteUInt(idx, 16)
                net.SendToServer()
            end):SetIcon("icon16/arrow_rotate_clockwise.png")

            Menu:AddOption("Remove", function()
                local idx = pnl:GetColumnText(1)

                net.Start("csp.prop:Remove")
                    net.WriteUInt(idx, 16)
                net.SendToServer()
            end):SetIcon("icon16/delete.png")

            Menu:Open()
        end
        CPanel:AddPanel(appPropsList)
        csp.ui.appPropsList = appPropsList

        local appZonesListLabel = vgui.Create("DLabel")
        appZonesListLabel:SetText("List Zones:")
        appZonesListLabel:SetDark(true)
        CPanel:AddPanel(appZonesListLabel)

        local appZonesList = vgui.Create("DListView")
        appZonesList:SetTall(100)
        appZonesList:SetMultiSelect(false)
        appZonesList:AddColumn("ID")
        appZonesList.OnRowSelected = function(this, index, pnl)
            local Menu = DermaMenu()

            Menu:AddOption("Teleport", function()
                local idx = pnl:GetColumnText(1)

                net.Start("csp.zone:Teleport")
                    net.WriteUInt(idx, 16)
                net.SendToServer()
            end):SetIcon("icon16/control_play_blue.png")

            Menu:Open()
        end
        CPanel:AddPanel(appZonesList)
        csp.ui.appZonesList = appZonesList

        csp:UpdateAppList()

        local updateButton = vgui.Create("DButton")
        updateButton:SetText("Update ClientSide Props in Menu")
        updateButton.DoClick = function()
            csp:UpdateAppList()
        end
        CPanel:AddPanel(updateButton)
    end

    local updatePostDraw = RealTime()
    function TOOL:DrawHUD()
        updatePostDraw = RealTime() + 0.1 -- спасибо разрабам гмода что wireframe не работает в HUDPaint!!!

        local showdrawcsprops = GetConVar(l .. "drawcsprops"):GetBool()
        if !showdrawcsprops then return end

        local instances = csp.prop.instances
        for _, prop in pairs(instances) do
            prop:DrawInfo()
        end
    end

    hook.Add( "PostDrawTranslucentRenderables", "csp:PostDrawTranslucentRenderables", function()
        -- не рисуем если у игрока не в руках тул с инструментом
        if RealTime() >= updatePostDraw then return end

        local showdrawzones = GetConVar(l .. "drawzones"):GetBool()
        if !showdrawzones then return end

        local instances = csp.zone.instances
        for _, zone in pairs(instances) do
            zone:DrawInfo()
        end
    end)
end
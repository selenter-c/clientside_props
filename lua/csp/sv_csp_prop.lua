util.AddNetworkString("csp.prop:Add")
util.AddNetworkString("csp.prop:Remove")
util.AddNetworkString("csp.prop:Clear")


function csp.prop:Sync(id, receivers)
    local prop = self.instances[id]
    if !prop then return end

    net.Start("csp.prop:Add")
        -- main
        net.WriteUInt(prop.id, 16)

        net.WriteVector(prop.position)
        net.WriteAngle(prop.angle)
        net.WriteString(prop.model)

        net.WriteUInt(prop.skin, 5)
        net.WriteColor(prop.color, true)
        net.WriteString(prop.material)
        net.WriteUInt(prop.rendermode, 4)

        -- bodygroups
        net.WriteUInt(table.Count(prop.bodygroups), 5)
        for index, value in pairs(prop.bodygroups) do
            net.WriteUInt(index, 5)
            net.WriteUInt(value, 5)
        end

        -- submaterials
        net.WriteUInt(table.Count(prop.submaterials), 5)
        for index, value in pairs(prop.submaterials) do
            net.WriteUInt(index, 5)
            net.WriteUInt(value, 5)
        end
    if receivers then
        net.Send(receivers)
    else
        net.Broadcast()
    end
end

function csp.prop:SyncAll(recivers)
    net.Start("csp.prop:Clear")
    net.Broadcast()

    timer.Simple(1, function()
        for _, prop in pairs(self.instances) do
            prop:Sync(recivers)
        end
    end)
end


function csp.prop:Add(data, bNoUpdateZone)
    local prop = self:Create(data, data.id)

    if !bNoUpdateZone then
        csp.zone:Update()
    end

    return prop
end

util.AddNetworkString("csp.prop:Transform")
util.AddNetworkString("csp.prop:Teleport")
util.AddNetworkString("csp.prop:Return")
util.AddNetworkString("csp.prop:Remove")

net.Receive("csp.prop:Transform", function(len, client)
    local id = net.ReadUInt(16)

    local message = csp:TransformEntity(client, Entity(id))
    if message then
        client:ChatPrint(csp.prefix .. " " .. message)
    end
end)

net.Receive("csp.prop:Teleport", function(len, client)
    local id = net.ReadUInt(16)

    local message = csp:TeleportEntity(client, id)
    if message then
        client:ChatPrint(csp.prefix .. " " .. message)
    end
end)

net.Receive("csp.prop:Return", function(len, client)
    local id = net.ReadUInt(16)

    local message = csp:ReturnEntity(client, id)
    if message then
        client:ChatPrint(csp.prefix .. " " .. message)
    end
end)

net.Receive("csp.prop:Remove", function(len, client)
    local id = net.ReadUInt(16)

    local message = csp:RemoveEntity(client, id)
    if message then
        client:ChatPrint(csp.prefix .. " " .. message)
    end
end)
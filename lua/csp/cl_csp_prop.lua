-- предназначен для создания нового клиентского объекта
function csp.prop:Add(data)
    local prop = self:Create(data, data.id)
    prop:Render()

    csp:UpdateAppList()

    return prop
end

net.Receive("csp.prop:Add", function(len)
    local id = net.ReadUInt(16)

    local position = net.ReadVector()
    local angle = net.ReadAngle()
    local model = net.ReadString()

    local skin = net.ReadUInt(5)
    local color = net.ReadColor()
    local material = net.ReadString()
    local rendermode = net.ReadUInt(4)

    local bodygroups = {}
    local bodygroupCount = net.ReadUInt(5)
    for i = 1, bodygroupCount do
        local idx = net.ReadUInt(5)
        local value = net.ReadUInt(5)

        bodygroups[idx] = value
    end

    local submaterials = {}
    local submaterialCount = net.ReadUInt(5)
    for i = 1, submaterialCount do
        local idx = net.ReadUInt(5)
        local value = net.ReadUInt(5)

        submaterials[idx] = value
    end

    csp.prop:Add({
        -- если не передавать id, будет присовено максимальному + 1
        id = id,

        position = position,
        angle = angle,
        model = model,

        skin = skin,
        color = color,
        material = material,
        rendermode = rendermode,

        bodygroups = bodygroups,
        submaterials = submaterials
    })
end)


-- Удаление клиентских объектов
function csp.prop:Remove(id)
    local prop = self.instances[id]
    if !prop then return end

    prop:Destroy()

    csp:UpdateAppList()
end

net.Receive("csp.prop:Remove", function(len)
    local id = net.ReadUInt(16)

    csp.prop:Remove(id)
end)


-- предназначен для чистки всех клиентских объектов
net.Receive("csp.prop:Clear", function(len)
    csp.prop:Clear()
end)
--[[
    TBD:
    
    AS SEPARATE FUNCTION
    local Response = {
        Translate = Translate,
        RotationQuat = RotationQuat,
        HumanRotation = HumanRotation
    }

    Channels.EntityTransform:Broadcast(Response)

]]




Globals.CreatedLightsServer = {}
Globals.selectedUuid = nil
Globals.selectedEntity = nil

INITIAL_LIGHT_TEMPLATE_0_POINT = 'd92ed2ec-a332-4a28-ae3d-99f79ee0fa92'
INITIAL_LIGHT_TEMPLATE_1_SPOT = '8b02ea30-6dcc-4b45-b6b4-d174f07bb2a1' --'fd55b15f-d82b-4743-a9fb-629b8b7c6636'
INITIAL_LIGHT_TEMPLATE_2_DIR = 'e4e90f6d-aa3e-4fb7-af3a-2ec279368083'



local function translate(entity)
    local Translate = entity.Transform.Transform.Translate
    return Translate[1], Translate[2], Translate[3]
end



local function rotation(entity)
    local RotationQuat = entity.Transform.Transform.RotationQuat
    local Deg = Helpers.Math.QuatToEuler(RotationQuat)
    return Deg[1], Deg[2], Deg[3]
end



local function getAvailableRootTemplate()
    for uuid, state in pairs(RootTemplates) do
        if state == true then
            RootTemplates[uuid] = false
            return uuid
        end
    end
    DPrint('No available slots')
    return nil
end



local function resetAvailableRootTemplate()
    for uuid, _ in pairs(RootTemplates) do
        RootTemplates[uuid] = true
        -- DPrint('%s, %s', uuid, RootTemplates[uuid])
    end
    DDump(RootTemplates)
end



local function changeRootTemplateState(uuid)
    RootTemplates[uuid] = not RootTemplates[uuid]
    DDump(RootTemplates)
end




Channels.CreateLight:SetRequestHandler(function (Data)

    local offset = 1
    local uuid = getAvailableRootTemplate()

    local x, y, z = Data.Position[1], Data.Position[2], Data.Position[3]

    if uuid then

        Globals.selectedUuid = Osi.CreateAt(uuid, x, y + offset, z, 0, 0, '')
        Globals.selectedEntity = Ext.Entity.Get(Globals.selectedUuid)

        Globals.CreatedLightsServer[Globals.selectedUuid] = Globals.selectedUuid
    
        local Response = {
            Globals.CreatedLightsServer,
            Globals.selectedUuid
        }
        
        return Response
    else
        return nil
    end
end)




Channels.SelectedLight:SetHandler(function (selectedLight)
    Globals.selectedUuid = selectedLight
    Globals.selectedEntity = Ext.Entity.Get(Globals.selectedUuid)
end)




Channels.DeleteLight:SetHandler(function (selectedLight)
    if selectedLight == 'All' then
        for _, entUuid in pairs(Globals.CreatedLightsServer) do
            Osi.RequestDelete(entUuid)
            Globals.CreatedLightsServer = {}
        end
        resetAvailableRootTemplate()
    else
        local uuid = Ext.Entity.Get(selectedLight).GameObjectVisual.RootTemplateId
        changeRootTemplateState(uuid)
        Osi.RequestDelete(selectedLight)
        Globals.CreatedLightsServer[selectedLight] = nil
    end
    DDump(Globals.CreatedLightsServer)
end)




Channels.EntityTranslate:SetHandler(function (Data)

    local axis = Data.axis
    local step = Data.step
    local offset = Data.offset

    local entity = Globals.selectedEntity
    local character = _C()
    local uuid = Globals.selectedUuid

    local rx, ry, rz = Osi.GetRotation(uuid)
    local x, y, z = Osi.GetPosition(uuid)


    
    if axis == 'x' then
        local x = x + offset / step
        Osi.ToTransform(uuid, x, y, z, rx, ry, rz)
        entity.Transform.Transform.Translate = {x,y,z}
        
    elseif  axis == 'y' then
        local y = y + offset / step
        Osi.ToTransform(uuid, x, y, z, rx, ry, rz)
        entity.Transform.Transform.Translate = {x,y,z}
        
    elseif  axis == 'z' then
        local z = z + offset / step
        Osi.ToTransform(uuid, x, y, z, rx, ry, rz)
        entity.Transform.Transform.Translate = {x,y,z}

    else
        local pos = character.Transform.Transform.Translate
        Osi.ToTransform(uuid, pos[1], pos[2], pos[3], rx, ry, rz)
    end

    entity.ServerItem.TransformChanged = true

    
    local RotationQuat = entity.Transform.Transform.RotationQuat
    local Translate = entity.Transform.Transform.Translate
    local HumanRotation = {rx,ry,rz}

    local Response = {
        Translate = Translate,
        RotationQuat = RotationQuat,
        HumanRotation = HumanRotation
    }

    Channels.EntityTransform:Broadcast(Response)


    -- return Response
    -- local rx, ry, rz = Osi.GetRotation(uuid)
    -- local x, y, z = Osi.GetPosition(uuid)

    -- DPrint('x: %s, y: %s, z: %s, rx: %s, ry: %s, rz: %s', x, y, z, rx, ry, rz)

end)




Channels.EntityRotation:SetHandler(function (Data)

    local axis = Data.axis
    local step = Data.step
    local offset = Data.offset

    local uuid = Globals.selectedUuid
    local entity = Globals.selectedEntity

    local rx, ry, rz = Osi.GetRotation(uuid)
    local x, y, z = Osi.GetPosition(uuid)

    if axis == 'x' then
        local rx = rx + offset / step
        Osi.ToTransform(uuid, x, y, z, rx, ry, rz)

    elseif  axis == 'y' then
        local ry = ry + offset / step
        Osi.ToTransform(uuid, x, y, z, rx, ry, rz)

    elseif  axis == 'z' then
        local rz = rz + offset / step
        Osi.ToTransform(uuid, x, y, z, rx, ry, rz)

    else
        Osi.ToTransform(uuid, x, y, z, 0, 0, 0)
    end
    
    local RotationQuat = entity.Transform.Transform.RotationQuat
    local Translate = entity.Transform.Transform.Translate
    local HumanRotation = {rx,ry,rz}

    local Response = {
        Translate = Translate,
        RotationQuat = RotationQuat,
        HumanRotation = HumanRotation
    }

    Channels.EntityTransform:Broadcast(Response)

    return Response

end)



Channels.StickToCamera:SetHandler(function (Data)
    local x,y,z = table.unpack(Data.Translate)
    local rx,ry,rz = table.unpack(Helpers.Math.QuatToEuler(Data.RotationQuat))
    Osi.ToTransform(Globals.selectedUuid, x, y, z, rx, ry, rz)
end)







--- mmmmmmmm slop tasty slop m m m m :P 

Globals.OrbitParams = Globals.OrbitParams or {}

Channels.EntityRotationOrbit:SetHandler(function (Data)
    local character = _C()
    local uuid = Globals.selectedUuid
    local entity = Ext.Entity.Get(uuid)
    if not uuid then return end

    local centerX, centerY, centerZ = translate(_C())

    local curX, curY, curZ = Osi.GetPosition(uuid)
    local curRx, curRy, curRz = Osi.GetRotation(uuid)

    if not Globals.OrbitParams[uuid] then
        Globals.OrbitParams[uuid] = { angle = 0, radius = 1, height = 0, rx = 0, ry = 0, rz = 0 }
        InitOrbitParamsFromCurrent(uuid, Globals.OrbitParams[uuid], centerX, centerY, centerZ)
    end

    local params = Globals.OrbitParams[uuid]
    
    local epsPos = 0.001
    local epsRot = 0.01
    local posChanged = math.abs(curX - (params.baseX or curX)) > epsPos
    or math.abs(curY - (params.baseY or curY)) > epsPos
    or math.abs(curZ - (params.baseZ or curZ)) > epsPos
    local rotChanged = math.abs(curRx - (params.lastActualRx or curRx)) > epsRot
    or math.abs(curRy - (params.lastActualRy or curRy)) > epsRot
    or math.abs(curRz - (params.lastActualRz or curRz)) > epsRot
    
    if posChanged or rotChanged then
        InitOrbitParamsFromCurrent(uuid, params, centerX, centerY, centerZ)
    end
    
    local change = Data.offset / Data.step
    
    if Data.axis == 'x' then
        params.angle = params.angle + change*50
    elseif Data.axis == 'y' then
        params.height = params.height + change
    elseif Data.axis == 'z' then
        params.radius = math.max(0.1, params.radius + change)
    else
        local charX, charY, charZ = translate(character)
        Osi.ToTransform(uuid, charX, charY, charZ, curRx, curRy, curRz)
        Globals.OrbitParams[uuid] = nil
        return
    end
    
    RotateAroundPoint(uuid, centerX, centerY, centerZ, params)
    LookAtCenter(uuid, centerX, centerY, centerZ, 1, params)
    
    params.baseX, params.baseY, params.baseZ = Osi.GetPosition(uuid)
    local arx, ary, arz = Osi.GetRotation(uuid)
    params.lastActualRx = arx
    params.lastActualRy = ary
    params.lastActualRz = arz
    
    
    
    local RotationQuat = entity.Transform.Transform.RotationQuat
    local Response = {
        Translate = {params.baseX, params.baseY, params.baseZ},
        RotationQuat = RotationQuat,
        HumanRotation = {arx, ary, arz}
    }
    

    Channels.EntityTransform:Broadcast(Response)

    -- return Response
end)


function ComputeLookAtRotation(x, y, z, centerX, centerY, centerZ, heightOffset)
    local dx, dy, dz = centerX - x, centerY + (heightOffset or 0) - y, centerZ - z
    local distance = math.sqrt(dx*dx + dy*dy + dz*dz)
    if distance == 0 then
        return 0, 0, 0
    end
    local pitch = math.deg(math.asin(-dy / distance))
    local yaw = math.deg(Ext.Math.Atan2(dx / distance, dz / distance))
    local roll = 0
    return pitch, yaw, roll
end


function InitOrbitParamsFromCurrent(uuid, params, centerX, centerY, centerZ)
    local x, y, z = Osi.GetPosition(uuid)
    local rx, ry, rz = Osi.GetRotation(uuid)

    local angle, radius, height = GetOrbitParameters(uuid, centerX, centerY, centerZ)
    local lookPitch, lookYaw, lookRoll = ComputeLookAtRotation(x, y, z, centerX, centerY, centerZ, 1)

    params.angle = angle
    params.radius = radius
    params.height = height

    params.rx = rx - lookPitch
    params.ry = ry - lookYaw
    params.rz = rz - lookRoll

    params.baseX = x
    params.baseY = y
    params.baseZ = z
    params.lastActualRx = rx
    params.lastActualRy = ry
    params.lastActualRz = rz
end


function GetOrbitParameters(uuid, centerX, centerY, centerZ)
    local x, y, z = Osi.GetPosition(uuid)
    local dx, dz = x - centerX, z - centerZ
    return math.deg(Ext.Math.Atan2(dz, dx)), math.sqrt(dx * dx + dz * dz), y - centerY
end


function RotateAroundPoint(uuid, centerX, centerY, centerZ, params)
    local angle = math.rad(params.angle)
    local newX = centerX + params.radius * math.cos(angle)
    local newZ = centerZ + params.radius * math.sin(angle)
    local newY = centerY + params.height
    Osi.ToTransform(uuid, newX, newY, newZ, params.rx, params.ry, params.rz)
end


function LookAtCenter(uuid, centerX, centerY, centerZ, heightOffset, params)
    local x, y, z = Osi.GetPosition(uuid)
    local dx, dy, dz = centerX - x, centerY + heightOffset - y, centerZ - z
    local distance = math.sqrt(dx * dx + dy * dy + dz * dz)
    
    local pitch = math.deg(math.asin(-dy / distance))
    local yaw = math.deg(Ext.Math.Atan2(dx / distance, dz / distance))
    local roll = params.rz or 0

    pitch = pitch + (params.rx or 0)
    yaw = yaw + (params.ry or 0)

    Osi.ToTransform(uuid, x, y, z, pitch, yaw, roll)
end
--[[
    TBD:
    
    AS SEPARATE FUNCTION
    local Response = {
        Translate = Translate,
        RotationQuat = RotationQuat,
        HumanRotation = HumanRotation
    }

    Channels.CurrentEntityTransform:Broadcast(Response)

]]




Globals.CreatedLightsServer = {}
Globals.LightParametersServer = {}
Globals.selectedUuid = nil
Globals.selectedEntity = nil

Globals.States = {}

Globals.CreatedAllMakers = {}


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
    -- DDump(RootTemplates)
end



local function changeRootTemplateState(uuid)
    RootTemplates[uuid] = not RootTemplates[uuid]
    -- DDump(RootTemplates)
end




Channels.CreateLight:SetRequestHandler(function (Data)
    local HumanRotation
    local offset = 2
    local uuid = getAvailableRootTemplate()

    local x, y, z = Data.Position[1], Data.Position[2], Data.Position[3]

    if uuid then
        
        Globals.selectedUuid = Osi.CreateAt(uuid, x, y + offset, z, 0, 0, '')
        HumanRotation = {0, 0, 0}
        
        if Data.type == 'Spotlight' then
            HumanRotation = {90, 0, 0}
            local rx, ry, rz = table.unpack(HumanRotation)
            Osi.ToTransform(Globals.selectedUuid, x, y + offset, z, rx, ry, rz)
        end
        
        
        Globals.LightParametersServer[Globals.selectedUuid] = {}
        Globals.LightParametersServer[Globals.selectedUuid].Translate = {x,y + offset ,z}
        Globals.LightParametersServer[Globals.selectedUuid].RotationQuat = Math:EulerToQuats(HumanRotation)
        Globals.LightParametersServer[Globals.selectedUuid].HumanRotation = HumanRotation

        Globals.selectedEntity = Ext.Entity.Get(Globals.selectedUuid)
        
        Globals.CreatedLightsServer[Globals.selectedUuid] = Globals.selectedUuid

        -- DDump(Globals.LightParametersServer)
        
        local Response = {
            Globals.CreatedLightsServer,
            Globals.selectedUuid
        }
        
        if Globals.markerUuid then
            UpdateMarkerPosition()
        else
            CreateMarker(true)
        end
        
        
        local Response = {
            Globals.CreatedLightsServer,
            Globals.selectedUuid,
            Globals.markerUuid
        }
        
        return Response
    else
        return nil
    end
end)


Channels.DuplicateLight:SetRequestHandler(function ()
    local uuid = getAvailableRootTemplate()
    local x,y,z = table.unpack(Globals.LightParametersServer[Globals.selectedUuid].Translate)
    local rx,ry,rz = table.unpack(Globals.LightParametersServer[Globals.selectedUuid].HumanRotation)

    Globals.selectedUuid = Osi.CreateAt(uuid, x, y, z, 0, 0, '')
    Osi.ToTransform(Globals.selectedUuid, x, y, z, rx, ry, rz)
    

    Globals.selectedEntity = Ext.Entity.Get(Globals.selectedUuid)


    local HumanRotation = {rx,ry,rz}
    Globals.LightParametersServer[Globals.selectedUuid] = {}
    Globals.LightParametersServer[Globals.selectedUuid].Translate = {x,y,z}
    Globals.LightParametersServer[Globals.selectedUuid].RotationQuat = Math:EulerToQuats(HumanRotation)
    Globals.LightParametersServer[Globals.selectedUuid].HumanRotation = HumanRotation


    Globals.CreatedLightsServer[Globals.selectedUuid] = Globals.selectedUuid

    DPrint(Globals.selectedUuid)
    
    if Globals.markerUuid then
        UpdateMarkerPosition()
    else
        CreateMarker(true)
    end
    
    local Response = {
        Globals.CreatedLightsServer,
        Globals.selectedUuid,
        Globals.LightParametersServer[Globals.selectedUuid]
    }
    

    return Response
end)



Globals.States.AllMarkers = false
function CreateMarker(single)
    
    local rOffset = 90

    if single then
        local x,y,z = table.unpack(Globals.LightParametersServer[Globals.selectedUuid].Translate)
        local rx,ry,rz = table.unpack(Globals.LightParametersServer[Globals.selectedUuid].HumanRotation)
        
        local uuid = lightMarkerGUID
        Globals.markerUuid = Osi.CreateAt(uuid, x, y, z, 0, 0, '')
        Osi.ToTransform(Globals.markerUuid, x, y, z, rx - rOffset, ry, rz)
    else
        
        Globals.States.AllMarkers = not Globals.States.AllMarkers

        if Globals.States.AllMarkers then
            for k,v in pairs(Globals.CreatedLightsServer) do

                local x,y,z = table.unpack(Globals.LightParametersServer[v].Translate)
                local rx,ry,rz = table.unpack(Globals.LightParametersServer[v].HumanRotation)
                
                local uuid = lightMarker2GUID

                local markerUuid = Osi.CreateAt(uuid, x, y, z, 0, 0, '')
                Osi.ToTransform(markerUuid, x, y, z, rx - rOffset, ry, rz)
                table.insert(Globals.CreatedAllMakers, markerUuid)
            end
        else
            for _, markerUuid in pairs(Globals.CreatedAllMakers) do
                Osi.RequestDelete(markerUuid)
            end
            Globals.CreatedAllMakers = {}
        end

    end
end



function CreateAllMarkers()

    for k, v in pairs(Globals.CreatedLightsServer) do
        DPrint(k)
        DPrint(v)
    end

    -- local rOffset = 90
    -- local x,y,z = table.unpack(Globals.LightParametersServer[Globals.selectedUuid].Translate)
    -- local rx,ry,rz = table.unpack(Globals.LightParametersServer[Globals.selectedUuid].HumanRotation)
    
    -- local uuid = lightMarkerGUID
    -- Globals.markerUuid = Osi.CreateAt(uuid, x, y, z, 0, 0, '')
    -- Osi.ToTransform(Globals.markerUuid, x, y, z, rx - rOffset, ry, rz)
end


function UpdateMarkerPosition()
    if Globals.markerUuid and Globals.LightParametersServer[Globals.selectedUuid] then
        local rOffset = 90    
        local x,y,z = table.unpack(Globals.LightParametersServer[Globals.selectedUuid].Translate)
        local rx,ry,rz = table.unpack(Globals.LightParametersServer[Globals.selectedUuid].HumanRotation)
        Osi.ToTransform(Globals.markerUuid, x, y, z, rx - rOffset, ry, rz)
        -- DPrint('Marker updated')
    end
end

Channels.MarkerHandler:SetRequestHandler(function (Data)

    CreateMarker()
    
    return nil
end)




Channels.SelectedLight:SetHandler(function (selectedUuid)
    Globals.selectedUuid = selectedUuid
    Globals.selectedEntity = Ext.Entity.Get(Globals.selectedUuid)
    -- DPrint('Selected light: %s', Globals.selectedUuid)
    UpdateMarkerPosition()
end)



Channels.DeleteLight:SetHandler(function (request)
    if request == 'All' then

        for _, lightUuid in pairs(Globals.CreatedLightsServer) do
            Osi.RequestDelete(lightUuid)
        end
        

        for _, markerUuid in pairs(Globals.CreatedAllMakers) do
            Osi.RequestDelete(markerUuid)
        end


        Globals.CreatedLightsServer = {}
        Globals.LightParametersServer = {}
        Globals.CreatedAllMakers = {}
        Globals.States.AllMarkers = false

        if Globals.markerUuid then
            Osi.RequestDelete(Globals.markerUuid)
            Globals.markerUuid = nil
        end

        resetAvailableRootTemplate()
        return
    end

    if request then

        local ent = Ext.Entity.Get(request)
        if ent and ent.GameObjectVisual and ent.GameObjectVisual.RootTemplateId then
            local rootId = ent.GameObjectVisual.RootTemplateId
            Osi.RequestDelete(request)

            Globals.CreatedLightsServer[request] = nil
            Globals.LightParametersServer[request] = nil

            changeRootTemplateState(rootId)
        end

        --TBD: find a better solution later, because I'm sleepy af rn
        local count = 0
        for _ in pairs(Globals.CreatedLightsServer) do count = count + 1 end
        if count == 0 and Globals.markerUuid then
            Osi.RequestDelete(Globals.markerUuid)
            Globals.markerUuid = nil
        end
    else
        if Globals.markerUuid then
            Osi.RequestDelete(Globals.markerUuid)
            Globals.markerUuid = nil
        end
    end
end)



Globals.States.sourceClient = false
        


Channels.CurrentEntityTransform:SetHandler(function (Data)
    if Data then
        -- DPrint('Client source: %s', Globals.States.sourceClient)
        Globals.States.sourceClient = true
        Globals.SourceClientTranslate = Data
    else
        -- DPrint('Client source: %s', Globals.States.sourceClient)
        Globals.States.sourceClient = false
    end
end)



function getSourcePosition()
    -- DPrint('Client source: %s', Globals.States.sourceClient)
    if Globals.States.sourceClient then
        SourceTranslate = Globals.SourceClientTranslate
    else
        SourceTranslate = _C().Transform.Transform.Translate
    end
    return SourceTranslate
end



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
        local pos = table.unpack(getSourcePosition())
        Osi.ToTransform(uuid, pos[1], pos[2], pos[3], rx, ry, rz)
    end

    entity.ServerItem.TransformChanged = true


    --- TBD: REFACTOR THESE ONES 
    local RotationQuat = entity.Transform.Transform.RotationQuat
    local Translate = entity.Transform.Transform.Translate
    local HumanRotation = {rx,ry,rz}

    
    Globals.LightParametersServer[Globals.selectedUuid].Translate = Translate
    Globals.LightParametersServer[Globals.selectedUuid].RotationQuat = RotationQuat
    Globals.LightParametersServer[Globals.selectedUuid].HumanRotation = HumanRotation

    local Response = {
        Translate = Translate,
        RotationQuat = RotationQuat,
        HumanRotation = HumanRotation
    }
    
    Globals.OrbitParams[uuid] = nil

    Channels.CurrentEntityTransform:Broadcast(Response)

    UpdateMarkerPosition()

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

    Globals.LightParametersServer[Globals.selectedUuid].Translate = Translate
    Globals.LightParametersServer[Globals.selectedUuid].RotationQuat = RotationQuat
    Globals.LightParametersServer[Globals.selectedUuid].HumanRotation = HumanRotation

    local Response = {
        Translate = Translate,
        RotationQuat = RotationQuat,
        HumanRotation = HumanRotation
    }
    
    Globals.OrbitParams[uuid] = nil

    Channels.CurrentEntityTransform:Broadcast(Response)
    
    UpdateMarkerPosition()


    return Response

end)



Channels.StickToCamera:SetHandler(function (Data)
    local x,y,z = table.unpack(Data.Translate)
    local rx,ry,rz = table.unpack(Helpers.Math.QuatToEuler(Data.RotationQuat))

    Globals.LightParametersServer[Globals.selectedUuid].Translate = {x, y, z}
    Globals.LightParametersServer[Globals.selectedUuid].RotationQuat = Data.RotationQuat
    Globals.LightParametersServer[Globals.selectedUuid].HumanRotation = {rx, ry, rz}

    UpdateMarkerPosition()
    Osi.ToTransform(Globals.selectedUuid, x, y, z, rx, ry, rz)
end)







--- mmmmmmmm slop tasty slop m m m m :P 

Globals.OrbitParams = Globals.OrbitParams or {}

Channels.EntityRotationOrbit:SetHandler(function (Data)
    -- local character = _C()
    
    -- local Translate = table.unpack(Globals.SourceTranslate)

    local uuid = Globals.selectedUuid
    local entity = Ext.Entity.Get(uuid)

    local centerX, centerY, centerZ = table.unpack(getSourcePosition())
    
    local curX, curY, curZ = Osi.GetPosition(uuid)
    local curRx, curRy, curRz = Osi.GetRotation(uuid)

    if not Globals.OrbitParams[uuid] then
        Globals.OrbitParams[uuid] = { 
            angle = 0, radius = 1, height = 0, rx = 0, ry = 0, rz = 0,
            lastCenterX = centerX,
            lastCenterY = centerY,
            lastCenterZ = centerZ
        }
        InitOrbitParamsFromCurrent(uuid, Globals.OrbitParams[uuid], centerX, centerY, centerZ)
    end

    local params = Globals.OrbitParams[uuid]
    
    local centerMoved = centerX ~= params.lastCenterX 
        or centerY ~= params.lastCenterY 
        or centerZ ~= params.lastCenterZ
    
    local posChanged = curX ~= (params.baseX or curX) 
        or curY ~= (params.baseY or curY) 
        or curZ ~= (params.baseZ or curZ)
    local rotChanged = curRx ~= (params.lastActualRx or curRx) 
        or curRy ~= (params.lastActualRy or curRy) 
        or curRz ~= (params.lastActualRz or curRz)
    
    if centerMoved or posChanged or rotChanged or not params.baseX then
        InitOrbitParamsFromCurrent(uuid, params, centerX, centerY, centerZ)
        params.lastCenterX = centerX
        params.lastCenterY = centerY
        params.lastCenterZ = centerZ
    end
    
    local change = Data.offset / Data.step
    
    if Data.axis == 'x' then
        params.angle = params.angle + change*50
    elseif Data.axis == 'y' then
        params.height = params.height + change
    elseif Data.axis == 'z' then
        params.radius = math.max(0.1, params.radius + change)
    else
        local charX, charY, charZ = table.unpack(getSourcePosition())
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

    Globals.LightParametersServer[Globals.selectedUuid].Translate = {params.baseX, params.baseY, params.baseZ}
    local RotationQuat = entity.Transform.Transform.RotationQuat
    Globals.LightParametersServer[Globals.selectedUuid].RotationQuat = RotationQuat
    Globals.LightParametersServer[Globals.selectedUuid].HumanRotation = {arx, ary, arz}
    
    local Response = {
        Translate = {params.baseX, params.baseY, params.baseZ},
        RotationQuat = RotationQuat,
        HumanRotation = {arx, ary, arz}
    }

    UpdateMarkerPosition()
    Channels.CurrentEntityTransform:Broadcast(Response)
end)



function GetOrbitParameters(uuid, centerX, centerY, centerZ)
    local x, y, z = Osi.GetPosition(uuid)
    local dx, dz = x - centerX, z - centerZ
    return math.deg(Ext.Math.Atan2(dz, dx)), math.sqrt(dx * dx + dz * dz), y - centerY
end



function InitOrbitParamsFromCurrent(uuid, params, centerX, centerY, centerZ)
    local x, y, z = Osi.GetPosition(uuid)
    local rx, ry, rz = Osi.GetRotation(uuid)

    local angle, radius, height = GetOrbitParameters(uuid, centerX, centerY, centerZ)

    params.angle = angle
    params.radius = radius
    params.height = height

    params.baseX = x
    params.baseY = y
    params.baseZ = z
    params.lastActualRx = rx
    params.lastActualRy = ry
    params.lastActualRz = rz
end


function RotateAroundPoint(uuid, centerX, centerY, centerZ, params)
    local angle = math.rad(params.angle)
    local newX = centerX + params.radius * math.cos(angle)
    local newZ = centerZ + params.radius * math.sin(angle)
    local newY = centerY + params.height
    
    local rx, ry, rz = Osi.GetRotation(uuid)
    Osi.ToTransform(uuid, newX, newY, newZ, rx, ry, rz)
end



function LookAtCenter(uuid, centerX, centerY, centerZ, heightOffset, params)
    local x, y, z = Osi.GetPosition(uuid)
    local dx, dy, dz = centerX - x, centerY + heightOffset - y, centerZ - z
    local distance = math.sqrt(dx * dx + dy * dy + dz * dz)
    
    local pitch = math.deg(math.asin(-dy / distance))
    local yaw = math.deg(Ext.Math.Atan2(dx / distance, dz / distance))
    local roll = 0

    Osi.ToTransform(uuid, x, y, z, pitch, yaw, roll)
end
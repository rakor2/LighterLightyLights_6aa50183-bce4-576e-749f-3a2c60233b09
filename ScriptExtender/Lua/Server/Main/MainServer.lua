--[[
    TBD:

    AS SEPARATE FUNCTION
    local Response = {
        Translate = Translate,
        RotationQuat = RotationQuat,
        HumanRotation = HumanRotation
    }

    Ch.CurrentEntityTransform:Broadcast(Response)

]]
_GLL.CreatedLightsServer = {}
_GLL.LightParametersServer = {}
_GLL.selectedUuid = nil
_GLL.selectedEntity = nil

_GLL.States = {}
_GLL.States.allMarkersExisting = false
_GLL.States.beamExisting = false
_GLL.States.lastMode = {}

_GLL.CreatedAllMarkers = {}

MAZZLE_BEAM = 'ee3cf097-6e5f-40a2-8ed7-68073d50225f'



Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function(levelName, isEditorMode)
    getLevelAvailableLTNTriggers()
    getLevelAvailableATMTriggers()
    Ext.Net.BroadcastMessage('LL_WhenLevelGameplayStarted', Ext.Json.Stringify(data))
end)



function getAvailableRootTemplate()
    for uuid, state in pairs(RootTemplates) do
        if state == true then
            RootTemplates[uuid] = false
            -- DPrint('Available RootTemplates ---------------------')
            -- DDump(RootTemplates)
            return uuid
        end
    end
    DPrint('No available slots')
    return nil
end



Ext.RegisterConsoleCommand('llrtavail', function (cmd, ...)
    DPrint('Available RootTemplates ---------------------')
    DDump(RootTemplates)
end)



local function resetAvailableRootTemplate()
    for uuid, _ in pairs(RootTemplates) do
        RootTemplates[uuid] = true
    end
end



local function changeRootTemplateState(uuid)
    RootTemplates[uuid] = not RootTemplates[uuid]
end



function CreateLight(x, y, z, HumanRotation, OrbitParams, rtUuid)
    if rtUuid then changeRootTemplateState(rtUuid) end
    local rtUuid = rtUuid or getAvailableRootTemplate()
    if not rtUuid then return nil end


    local entUuid = Osi.CreateAt(rtUuid, x, y, z, 0, 0, '')
    local rx, ry, rz = table.unpack(HumanRotation)
    Osi.ToTransform(entUuid, x, y, z, rx, ry, rz)

    _GLL.selectedUuid   = entUuid
    _GLL.selectedEntity = Ext.Entity.Get(entUuid)

    _GLL.LightParametersServer[entUuid] = {
        Translate     = {x, y, z},
        RotationQuat  = Math.EulerToQuats(HumanRotation),
        HumanRotation = HumanRotation,
    }
    _GLL.OrbitParams[entUuid]          = OrbitParams
    _GLL.CreatedLightsServer[entUuid]  = rtUuid
    _GLL.States.lastMode[entUuid]      = 'World'

    if _GLL.markerUuid then
        UpdateMarkerPosition()
        UpdateBeamPosition()
    else
        CreateMarker(true)
    end


    return {
        _GLL.CreatedLightsServer,
        entUuid,
        _GLL.markerUuid,
    }
end



Ch.CreateLight:SetRequestHandler(function(Data)
    local OFFSET = 2
    local x, y, z = table.unpack(getSourcePosition())

    local HumanRotation = {0, 0, 0}

    if Data.lightType == 'Spotlight' then
        HumanRotation = {90, 0, 0}
    end

    local uuid = Data.uuid or nil

    return CreateLight(x, y + OFFSET, z, HumanRotation, nil, uuid)
end)



Ch.DuplicateLight:SetRequestHandler(function()
    if not _GLL.selectedUuid then return end

    local prev    = _GLL.LightParametersServer[_GLL.selectedUuid]
    local x, y, z = table.unpack(prev.Translate)
    local HumanRotation = prev.HumanRotation

    local Response = CreateLight(x, y, z, HumanRotation, _GLL.OrbitParams[_GLL.selectedUuid])
    if not Response then return nil end

    Response[3] = _GLL.LightParametersServer[Response[2]]

    return Response
end)



function CreateMarker(single)
    local R_OFFSET = 90

    if single then
        local x,y,z = table.unpack(_GLL.LightParametersServer[_GLL.selectedUuid].Translate)
        local rx,ry,rz = table.unpack(_GLL.LightParametersServer[_GLL.selectedUuid].HumanRotation)
        local uuid = lightMarkerGUID
        _GLL.markerUuid = Osi.CreateAt(uuid, x, y, z, 0, 0, '')
        Osi.ToTransform(_GLL.markerUuid, x, y, z, rx - R_OFFSET, ry, rz)
        Data = _GLL.markerUuid
        Ch.MarkerHandler:Broadcast(Data)
        return _GLL.markerUuid
    else
        _GLL.States.allMarkersExisting = not _GLL.States.allMarkersExisting

        if _GLL.States.allMarkersExisting then
            for lightUuid, _ in pairs(_GLL.CreatedLightsServer) do
                _GLL.CreatedAllMarkers[lightUuid] = _GLL.CreatedAllMarkers[lightUuid] or {}
                local x,y,z = table.unpack(_GLL.LightParametersServer[lightUuid].Translate)
                local rx,ry,rz = table.unpack(_GLL.LightParametersServer[lightUuid].HumanRotation)
                local uuid = lightMarker2GUID

                local markerUuid = Osi.CreateAt(uuid, x, y, z, 0, 0, '')
                Osi.ToTransform(markerUuid, x, y, z, rx - R_OFFSET, ry, rz)
                _GLL.CreatedAllMarkers[lightUuid] = markerUuid
                return _GLL.CreatedAllMarkers
            end
        else
            for lightUuid, markerUuid in pairs(_GLL.CreatedAllMarkers) do
                Osi.RequestDelete(markerUuid)
            end

            _GLL.CreatedAllMarkers = {}
        end

    end
end



function UpdateMarkerPosition()
    if _GLL.markerUuid and _GLL.LightParametersServer[_GLL.selectedUuid] then
        local R_OFFSET = 90
        local x,y,z = table.unpack(_GLL.LightParametersServer[_GLL.selectedUuid].Translate)
        local rx,ry,rz = table.unpack(_GLL.LightParametersServer[_GLL.selectedUuid].HumanRotation)
        Osi.ToTransform(_GLL.markerUuid, x, y, z, rx - R_OFFSET, ry, rz)
    end
end



function UpdateAllMarkersPosition()
    if not _GLL.States.allMarkersExisting then return end
    local R_OFFSET = 90
    for uuid, _ in pairs(_GLL.CreatedLightsServer) do
        local x, y, z = table.unpack(_GLL.LightParametersServer[uuid].Translate)
        local rx, ry, rz = table.unpack(_GLL.LightParametersServer[uuid].HumanRotation)
        local markerUuid = _GLL.CreatedAllMarkers[uuid]
        Osi.ToTransform(markerUuid, x, y, z, rx - R_OFFSET, ry, rz)
    end
end



function UpdateBeamPosition()
    if not _GLL.beamUuid then return end

    local uuid = _GLL.selectedUuid
    local rx, ry, rz = Osi.GetRotation(uuid)
    local x, y, z = Osi.GetPosition(uuid)
    local OFFSET = 180
    Osi.ToTransform(_GLL.beamUuid, x, y, z, rx + OFFSET, ry, rz)
end



Ch.MarkerHandler:SetRequestHandler(function (Data)
    return CreateMarker(false)
end)



Ch.SelectedLight:SetHandler(function (selectedUuid)
    _GLL.selectedUuid = selectedUuid
    _GLL.selectedEntity = Ext.Entity.Get(_GLL.selectedUuid)
    UpdateMarkerPosition()
    UpdateBeamPosition()
end)



Ch.DeleteLight:SetHandler(function (request)
    if request == 'All' then
        for lightUuid, _ in pairs(_GLL.CreatedLightsServer) do
            Osi.RequestDelete(lightUuid)
        end

        for _, markerUuid in pairs(_GLL.CreatedAllMarkers) do
            Osi.RequestDelete(markerUuid)
        end

        _GLL.CreatedLightsServer = {}
        _GLL.LightParametersServer = {}
        _GLL.beamUuid = nil
        _GLL.selectedEntity = nil
        _GLL.selectedUuid = nil
        _GLL.CreatedAllMarkers = {}
        _GLL.States.allMarkersExisting = false
        _GLL.GoboLightMap = {}
        _GLL.GoboDistances = {}
        _GLL.beamUuid = nil
        _GLL.States.beamExisting = false

        if _GLL.markerUuid then
            Osi.RequestDelete(_GLL.markerUuid)
            _GLL.markerUuid = nil
        end

        resetAvailableRootTemplate()
        return
    end



    if request then
        local lightUuidFromClientJustToMakeSureBecauseIHadProblemsForSomeReasonImProbablyDumb = request
        local ent = Ext.Entity.Get(lightUuidFromClientJustToMakeSureBecauseIHadProblemsForSomeReasonImProbablyDumb)

        if ent and ent.GameObjectVisual and ent.GameObjectVisual.RootTemplateId then
            local rootId = ent.GameObjectVisual.RootTemplateId
            Osi.RequestDelete(lightUuidFromClientJustToMakeSureBecauseIHadProblemsForSomeReasonImProbablyDumb)
            _GLL.CreatedLightsServer[lightUuidFromClientJustToMakeSureBecauseIHadProblemsForSomeReasonImProbablyDumb] = nil
            _GLL.LightParametersServer[lightUuidFromClientJustToMakeSureBecauseIHadProblemsForSomeReasonImProbablyDumb] = nil
            _GLL.GoboLightMap[lightUuidFromClientJustToMakeSureBecauseIHadProblemsForSomeReasonImProbablyDumb] = nil

            if _GLL.GoboDistances then _GLL.GoboDistances[lightUuidFromClientJustToMakeSureBecauseIHadProblemsForSomeReasonImProbablyDumb] = nil end

            changeRootTemplateState(rootId)
        end

        --TBD: find a better solution later, because I'm sleepy af rn
        --now I'm too lazy
        local count = 0
        for _ in pairs(_GLL.CreatedLightsServer) do
            count = count + 1
        end

        if count == 0 and _GLL.markerUuid then
            Osi.RequestDelete(_GLL.markerUuid)
            _GLL.markerUuid = nil

            if _GLL.beamUuid then
                Osi.RequestDelete(_GLL.beamUuid)
                _GLL.beamUuid = nil
                _GLL.States.beamExisting = false
            end

        end

    else
        if _GLL.markerUuid then
            Osi.RequestDelete(_GLL.markerUuid)
            _GLL.markerUuid = nil

        end
    end
    UpdateBeamPosition()
end)



Ext.RegisterConsoleCommand('lldumpall', function (cmd, ...)
    DPrint('CreatedLightsServer -----------------------------------')
    DDump(_GLL.CreatedLightsServer)
    DPrint('LightParametersServer ---------------------------------')
    DDump(_GLL.LightParametersServer)
    DPrint('LightParametersServer ---------------------------------')
    DDump(_GLL.selectedUuid)
    DPrint('allMarkersExisting ------------------------------------')
    DDump(_GLL.CreatedAllMarkers)
    DPrint('States.allMarkersExisting -----------------------------')
    DDump(_GLL.States.allMarkersExisting)
    DPrint('States.GoboLightMap -----------------------------------')
    DDump(_GLL.GoboLightMap)
end)



_GLL.States.sourceClient = false



Ch.CurrentEntityTransform:SetHandler(function (Data)
    if Data then
        _GLL.States.sourceClient = true
        _GLL.SourceClientTranslate = Data
    else
        _GLL.States.sourceClient = false
    end
end)



function getSourcePosition()
    if _GLL.States.sourceClient then
        SourceTranslate = _GLL.SourceClientTranslate
    else
        SourceTranslate = _C().Transform.Transform.Translate
    end
    return SourceTranslate
end



Ch.StickToCamera:SetHandler(function (Data)
    if not _GLL.selectedUuid then return end
    if not _GLL.LightParametersServer  then return end
    if not _GLL.LightParametersServer[_GLL.selectedUuid] then return end

    local uuid = _GLL.selectedUuid
    local x,y,z = table.unpack(Data.Translate)
    local rx,ry,rz = table.unpack(Helpers.Math.QuatToEuler(Data.RotationQuat))

    _GLL.LightParametersServer[_GLL.selectedUuid].Translate = {x, y, z}
    _GLL.LightParametersServer[_GLL.selectedUuid].RotationQuat = Data.RotationQuat
    _GLL.LightParametersServer[_GLL.selectedUuid].HumanRotation = {rx, ry, rz}

    Osi.ToTransform(_GLL.selectedUuid, x, y, z, rx, ry, rz)

    --- For look at
    local centerX, centerY, centerZ = table.unpack(getSourcePosition())
    local curX, curY, curZ = Osi.GetPosition(uuid)
    local dx, dy, dz = centerX - curX, centerY - curY, centerZ - curZ
    local distance = math.sqrt(dx*dx + dy*dy + dz*dz)
    local baseYaw = math.deg(Ext.Math.Atan2(dx / distance, dz / distance))
    local basePitch = math.deg(math.asin(-dy / distance))

    local curRx, curRy, curRz = Osi.GetRotation(uuid)

    local params = _GLL.OrbitParams[uuid] or {}
    params.userYawOffset = curRy - baseYaw
    params.userPitchOffset = curRx - basePitch
    _GLL.OrbitParams[uuid] = params


    UpdateMarkerPosition()
    UpdateGoboPosition()
    UpdateBeamPosition()
end)



Ch.SaveLoadLightPos:SetHandler(function (action)
    if action == 'Save' then
        _GLL.LightParametersServer[_GLL.selectedUuid].SavedPosition = _GLL.LightParametersServer[_GLL.selectedUuid.SavedPosition] or {}

        _GLL.LightParametersServer[_GLL.selectedUuid].SavedPosition.Translate = _GLL.LightParametersServer[_GLL.selectedUuid].Translate
        _GLL.LightParametersServer[_GLL.selectedUuid].SavedPosition.RotationQuat = _GLL.LightParametersServer[_GLL.selectedUuid].RotationQuat
        _GLL.LightParametersServer[_GLL.selectedUuid].SavedPosition.HumanRotation = _GLL.LightParametersServer[_GLL.selectedUuid].HumanRotation
    end

    if action == 'Load' then
        local x,y,z = table.unpack(_GLL.LightParametersServer[_GLL.selectedUuid].SavedPosition.Translate)
        local rx,ry,rz = table.unpack(_GLL.LightParametersServer[_GLL.selectedUuid].SavedPosition.HumanRotation)


        _GLL.LightParametersServer[_GLL.selectedUuid].Translate = {x,y,z}
        _GLL.LightParametersServer[_GLL.selectedUuid].HumanRotation = {rx,ry,rz}


        local Response = {
            Translate = _GLL.LightParametersServer[_GLL.selectedUuid].SavedPosition.Translate,
            RotationQuat = _GLL.LightParametersServer[_GLL.selectedUuid].SavedPosition.RotationQuat,
            HumanRotation = _GLL.LightParametersServer[_GLL.selectedUuid].SavedPosition.HumanRotation
        }

        Ch.CurrentEntityTransform:Broadcast(Response)

        Osi.ToTransform(_GLL.selectedUuid, x, y, z, rx, ry, rz)

        UpdateMarkerPosition()
        UpdateGoboPosition()
        UpdateBeamPosition()
    end
end)



Ch.DeleteEverything:SetHandler(function (Data)
    for _, uuid in ipairs(Data) do
        Osi.RequestDelete(uuid)
    end
end)



Ch.MazzleBeam:SetHandler(function (Data)
    if not _GLL.selectedUuid then return end

    _GLL.States.beamExisting = not _GLL.States.beamExisting

    if _GLL.States.beamExisting then
        local uuid = _GLL.selectedUuid
        local rx, ry, rz = Osi.GetRotation(uuid)
        local x, y, z = Osi.GetPosition(uuid)
        local R_OFFSET = 180

        _GLL.beamUuid =  Osi.CreateAt(MAZZLE_BEAM, x, y, z, 0, 0, '')

        Helpers.Timer:OnTicks(1, function ()
            Osi.ToTransform(_GLL.beamUuid, x, y, z, rx + R_OFFSET, ry, rz)
        end)

    else
        Osi.RequestDelete(_GLL.beamUuid)
        _GLL.beamUuid = nil
    end
end)


local function GetBaseAngles(uuid, centerX, centerY, centerZ, heightOffset)
    local x, y, z = Osi.GetPosition(uuid)
    local targetY = centerY + (heightOffset or 0)
    local dx, dy, dz = centerX - x, targetY - y, centerZ - z
    local distance = math.sqrt(dx*dx + dy*dy + dz*dz)
    return math.deg(math.asin(-dy / distance)),
           math.deg(Ext.Math.Atan2(dx / distance, dz / distance))
end


Ch.EntityTranslate:SetHandler(function (Data)
    if not _GLL.selectedUuid then return end

    local axis = Data.axis
    local step = Data.step
    local OFFSET = Data.offset
    local entity = _GLL.selectedEntity
    -- local uuid = _GLL.selectedUuid
    local uuid = Data.lightUuid
    local rx, ry, rz = Osi.GetRotation(uuid)
    local x, y, z = Osi.GetPosition(uuid)

    if axis == 'x' then
        local x = x + OFFSET / step
        Osi.ToTransform(uuid, x, y, z, rx, ry, rz)

    elseif  axis == 'y' then
        local y = y + OFFSET / step
        Osi.ToTransform(uuid, x, y, z, rx, ry, rz)

    elseif  axis == 'z' then
        local z = z + OFFSET / step
        Osi.ToTransform(uuid, x, y, z, rx, ry, rz)

    else
        local x, y, z = table.unpack(getSourcePosition())
        Osi.ToTransform(uuid, x, y, z, rx, ry, rz)
    end

    --- TBD: REFACTOR THESE ONES
    local RotationQuat = entity.Transform.Transform.RotationQuat
    local Translate = entity.Transform.Transform.Translate
    local HumanRotation = {rx,ry,rz}

    _GLL.LightParametersServer[uuid].Translate = Translate
    _GLL.LightParametersServer[uuid].RotationQuat = RotationQuat
    _GLL.LightParametersServer[uuid].HumanRotation = HumanRotation

    local Response = {
        Translate = Translate,
        RotationQuat = RotationQuat,
        HumanRotation = HumanRotation
    }

    -- _GLL.OrbitParams[uuid] = nil

    Ch.CurrentEntityTransform:Broadcast(Response)

    UpdateMarkerPosition()
    UpdateGoboPosition()
    UpdateBeamPosition()

    _GLL.States.lastMode[uuid] = 'World'
end)



Ch.EntityRotation:SetHandler(function (Data)
    if not _GLL.selectedUuid then return end

    local axis = Data.axis
    local uuid = Data.lightUuid
    local entity = _GLL.selectedEntity
    local x, y, z = Osi.GetPosition(uuid)
    local Translate = entity.Transform.Transform.Translate

    _GLL.LightParametersServer[uuid].Translate = Translate

    if axis == 'x' or axis == 'y' or axis == 'z' then
        local delta = math.rad(Data.offset / Data.step)
        local currentQuat = entity.Transform.Transform.RotationQuat
        local axisVec = ({x={1,0,0}, y={0,1,0}, z={0,0,1}})[axis]
        local newQuat = Ext.Math.QuatRotateAxisAngle(currentQuat, axisVec, delta)

        local HumanRotation = Helpers.Math.QuatToEuler(newQuat)
        local rx, ry, rz = table.unpack(HumanRotation)
        Osi.ToTransform(uuid, x, y, z, rx, ry, rz)

        local RotationQuat = entity.Transform.Transform.RotationQuat
        _GLL.LightParametersServer[uuid].RotationQuat = RotationQuat
        _GLL.LightParametersServer[uuid].HumanRotation = HumanRotation

        local Response = {Translate = Translate, RotationQuat = RotationQuat, HumanRotation = HumanRotation}
        Ch.CurrentEntityTransform:Broadcast(Response)

        local centerX, centerY, centerZ = table.unpack(getSourcePosition())
        local basePitch, baseYaw = GetBaseAngles(uuid, centerX, centerY, centerZ)
        local curRx, curRy, curRz = Osi.GetRotation(uuid)
        local params = _GLL.OrbitParams[uuid] or {}
        params.userYawOffset = curRy - baseYaw
        params.userPitchOffset = curRx - basePitch
        _GLL.OrbitParams[uuid] = params

        UpdateMarkerPosition()
        UpdateGoboPosition()
        UpdateBeamPosition()
        return Response

    else
        local centerX, centerY, centerZ = table.unpack(getSourcePosition())
        local resetPitch, resetYaw = GetBaseAngles(uuid, centerX, centerY, centerZ, 1.3)
        Osi.ToTransform(uuid, x, y, z, resetPitch, resetYaw, 0)

        local RotationQuat = entity.Transform.Transform.RotationQuat
        local HumanRotation = {resetPitch, resetYaw, 0}
        _GLL.LightParametersServer[uuid].RotationQuat = RotationQuat
        _GLL.LightParametersServer[uuid].HumanRotation = HumanRotation
        _GLL.OrbitParams[uuid] = {userYawOffset = 0, userPitchOffset = 0}

        local Response = {Translate = Translate, RotationQuat = RotationQuat, HumanRotation = HumanRotation}
        Ch.CurrentEntityTransform:Broadcast(Response)
        UpdateMarkerPosition()
        UpdateGoboPosition()
        UpdateBeamPosition()
        return Response
    end
end)



--- mmmmmmmm slop tasty slop m m m m :P
_GLL.OrbitParams = _GLL.OrbitParams or {}

Ch.EntityRotationOrbit:SetHandler(function (Data)
    if not _GLL.selectedUuid then return end

    -- local uuid = _GLL.selectedUuid
    local uuid = Data.lightUuid
    local entity = Ext.Entity.Get(uuid)
    local centerX, centerY, centerZ = table.unpack(getSourcePosition())
    local curX, curY, curZ = Osi.GetPosition(uuid)
    local curRx, curRy, curRz = Osi.GetRotation(uuid)

    if not _GLL.OrbitParams[uuid] then
        _GLL.OrbitParams[uuid] = {
            angle = 0,
            radius = 1,
            height = 0,
            lastCenterX = centerX,
            lastCenterY = centerY,
            lastCenterZ = centerZ
        }
        InitOrbitParamsFromCurrent(uuid, _GLL.OrbitParams[uuid], centerX, centerY, centerZ)
    end

    local params = _GLL.OrbitParams[uuid]
    local centerMoved = centerX ~= params.lastCenterX or centerY ~= params.lastCenterY or centerZ ~= params.lastCenterZ
    local posChanged = curX ~= (params.baseX or curX) or curY ~= (params.baseY or curY) or curZ ~= (params.baseZ or curZ)
    local rotChanged = curRx ~= (params.lastActualRx or curRx) or curRy ~= (params.lastActualRy or curRy) or curRz ~= (params.lastActualRz or curRz)

    if centerMoved or posChanged or rotChanged or not params.baseX then
        InitOrbitParamsFromCurrent(uuid, params, centerX, centerY, centerZ)
        params.lastCenterX = centerX
        params.lastCenterY = centerY
        params.lastCenterZ = centerZ
    end

    -- local change = Data.offset / Data.step
    local change = Data.offset

    if Data.axis == 'x' then
        -- params.angle = params.angle + change*50
        params.angle = change

    elseif Data.axis == 'y' then
        -- params.height = params.height + change
        params.height = change/100

    elseif Data.axis == 'z' then
        -- params.radius = math.max(0.1, params.radius + change)
        params.radius = change/100

    else
        local charX, charY, charZ = table.unpack(getSourcePosition())
        Osi.ToTransform(uuid, charX, charY, charZ, curRx, curRy, curRz)
        _GLL.OrbitParams[uuid] = nil
        return
    end

    RotateAroundPoint(uuid, centerX, centerY, centerZ, params)
    LookAtCenter(uuid, centerX, centerY, centerZ, 1.3, params)

    local newX, newY, newZ = Osi.GetPosition(uuid)
    local basePitch, baseYaw = GetBaseAngles(uuid, centerX, centerY, centerZ, 1.3)
    local actualRx, actualRy, actualRz = Osi.GetRotation(uuid)


    params.userYawOffset = actualRy - baseYaw
    params.userPitchOffset = actualRx - basePitch
    params.baseX, params.baseY, params.baseZ = newX, newY, newZ
    params.lastActualRx = actualRx
    params.lastActualRy = actualRy
    params.lastActualRz = actualRz

    _GLL.LightParametersServer[uuid].Translate = {params.baseX, params.baseY, params.baseZ}
    local RotationQuat = entity.Transform.Transform.RotationQuat
    _GLL.LightParametersServer[uuid].RotationQuat = RotationQuat
    _GLL.LightParametersServer[uuid].HumanRotation = {actualRx, actualRy, actualRz}

    local Response = {
        Translate = {params.baseX, params.baseY, params.baseZ},
        RotationQuat = RotationQuat,
        HumanRotation = {actualRx, actualRy, actualRz}
    }

    UpdateMarkerPosition()
    UpdateAllMarkersPosition()
    UpdateGoboPosition()
    UpdateBeamPosition()

    _GLL.States.lastMode[uuid] = 'Orbit'
    Ch.CurrentEntityTransform:Broadcast(Response)
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

    local targetY = centerY + 1.3
    local dx, dy, dz = centerX - x, targetY - y, centerZ - z
    local distance = math.sqrt(dx*dx + dy*dy + dz*dz)
    local baseYaw = math.deg(Ext.Math.Atan2(dx / distance, dz / distance))
    local basePitch = math.deg(math.asin(-dy / distance))

    params.userYawOffset = ry - baseYaw
    params.userPitchOffset = rx - basePitch

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
    local targetY = centerY + (heightOffset or 0)
    local dx, dy, dz = centerX - x, targetY - y, centerZ - z
    local distance = math.sqrt(dx * dx + dy * dy + dz * dz)
    local basePitch = math.deg(math.asin(-dy / distance))
    local baseYaw = math.deg(Ext.Math.Atan2(dx / distance, dz / distance))
    local pitch = basePitch + (params.userPitchOffset or 0)
    local yaw = baseYaw + (params.userYawOffset or 0)
    local roll = 0
    Osi.ToTransform(uuid, x, y, z, pitch, yaw, roll)
end



Ch.PlayAnimation:SetHandler(function(Data)
    DPrint(Data)
    PlayLoopingAnimation(Data, '', '555f55c9-860d-4e5d-85ac-ceae8b1dde6e', '', '','','', '')
end)



-- Ext.RegisterConsoleCommand('dagger', function()
--     local x,y,z = table.unpack(_C().Transform.Transform.Translate)
--     Osi.CreateAt('bfadc906-02cd-442f-beff-04d5a40543fe', x, y, z, 0, 0, '')
-- end)



Ch.GetDaggers:SetHandler(function(Data)
    local character = _C().Uuid.EntityUuid
    Osi.TemplateAddTo('bfadc906-02cd-442f-beff-04d5a40543fe', character, 1)
    Osi.TemplateAddTo('bfadc906-02cd-442f-beff-04d5a40543fe', character, 1)
end)




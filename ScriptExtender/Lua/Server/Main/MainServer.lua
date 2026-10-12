--[[
    TBD:

    AS SEPARATE FUNCTION
    local Response = {
        Translate = Translate,
        RotationQuat = RotationQuat,
        HumanRotation = HumanRotation
    }

    Ch.CurrentEntityTransform:Broadcast(Response)

]]--

--- TBD: Temp. Add settings to server
local HEIGHT_OFFSET = Settings.orbitHeightOffset or 1.3

_GLL.CreatedLightsServer       = {}
_GLL.LightParametersServer     = {}
_GLL.selectedUuid              = nil
_GLL.selectedEntity            = nil

_GLL.States                    = {}
_GLL.States.allMarkersExisting = false
_GLL.States.beamExisting       = false
_GLL.States.lastMode           = {}

_GLL.CreatedAllMarkers         = {}

MAZZLE_BEAM = 'ee3cf097-6e5f-40a2-8ed7-68073d50225f'



Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function(levelName, isEditorMode)
    -- getLevelAvailableLTNTriggers()
    -- getLevelAvailableATMTriggers()
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



Ext.RegisterConsoleCommand('llrt', function (cmd, ...)
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
    local PosFallback = _C().Transform.Transform.Translate
    local Translate = Data.Position or PosFallback
    if not Data.Position then DPrint('Ch.CreateLight fallback to _C()') end
    local x, y, z = table.unpack(Translate)

    if not Data.Position then
        DWarn('No Data.Position in CreateLight. Using last selected character as source')
    end

    local HumanRotation = {0, 0, 0}

    if Data.lightType == 'Spotlight' then
        HumanRotation = {90, 0, 0}
    end

    local uuid = Data.uuid or nil

    return CreateLight(x, y + OFFSET, z, HumanRotation, nil, uuid)
end)



Ch.DuplicateLight:SetRequestHandler(function()
    if not _GLL.selectedUuid then return end
    local Prev = _GLL.LightParametersServer[_GLL.selectedUuid]

    local x, y, z = table.unpack(Prev.Translate)
    local HumanRotation = Prev.HumanRotation

    local Response = CreateLight(x, y, z, HumanRotation, _GLL.OrbitParams[_GLL.selectedUuid])

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

        _GLL.CreatedLightsServer       = {}
        _GLL.LightParametersServer     = {}
        _GLL.beamUuid                  = nil
        _GLL.selectedEntity            = nil
        _GLL.selectedUuid              = nil
        _GLL.CreatedAllMarkers         = {}
        _GLL.States.allMarkersExisting = false
        _GLL.GoboLightMap              = {}
        _GLL.GoboDistances             = {}
        _GLL.beamUuid                  = nil
        _GLL.States.beamExisting       = false

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

        --- TBD: find a better solution later, because I'm sleepy af rn
        --- now I'm too lazy
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



Ch.Source:SetHandler(function(Data)
    _GLL.SourceTranslate = Data
end)



function getSourcePosition()
    DPrint('Fallback')
    local SourceTranslate
    local userId = _C().ServerCharacter.UserID
    Ch.Source:RequestToClient('', userId, function(Response)
        DPrint('Response')
        DDump(Response)
        _GLL.SourceTranslate = Response
        return Response
    end)
end



function BroadcastEntityTransformsAndOrbit(Transforms, Orbit, lightUuid)
    if not Orbit then
        local uuid = lightUuid or _GLL.selectedUuid
        local centerX, centerY, centerZ = table.unpack(_GLL.SourceTranslate or getSourcePosition()) --- idk, fix later when buuged???????
        local angle, radius, height = GetOrbitParameters(uuid, centerX, centerY, centerZ)
        Orbit = {angle, radius, height, uuid}
    end
    Ch.CurrentOrbit:Broadcast(Orbit)
    Ch.CurrentEntityTransform:Broadcast(Transforms)
end



local function CreateTransforms(translate, rotationQuat, humanRotation)
    return {
        Translate = translate,
        RotationQuat = rotationQuat,
        HumanRotation = humanRotation
    }
end



local function SaveLightTransform(uuid, translate, rotationQuat, humanRotation)
    local lightParameters = _GLL.LightParametersServer[uuid]
    lightParameters.Translate = translate
    lightParameters.RotationQuat = rotationQuat
    lightParameters.HumanRotation = humanRotation
end



local function UpdatePositionsForSomeBS(updateAllMarkers)
    UpdateMarkerPosition()
    if updateAllMarkers then
        UpdateAllMarkersPosition()
    end
    UpdateGoboPosition()
    UpdateBeamPosition()
end



local function GetBaseAngles(uuid, centerX, centerY, centerZ, heightOffset)
    local x, y, z = Osi.GetPosition(uuid)
    local targetY = centerY + (heightOffset or 0)
    local dx, dy, dz = centerX - x, targetY - y, centerZ - z
    local distance = math.sqrt(dx * dx + dy * dy + dz * dz)
    return math.deg(math.asin(-dy / distance)),
           math.deg(Ext.Math.Atan2(dx / distance, dz / distance))
end



local ROTATION_AXES = {
    x = {1, 0, 0},
    y = {0, 1, 0},
    z = {0, 0, 1}
}



local function UpdateOrbitOffsets(uuid, centerX, centerY, centerZ, heightOffset, rx, ry)
    local basePitch, baseYaw = GetBaseAngles(uuid, centerX, centerY, centerZ, heightOffset)
    if rx == nil or ry == nil then
        rx, ry = Osi.GetRotation(uuid)
    end

    local params = _GLL.OrbitParams[uuid] or {}
    params.userYawOffset = ry - baseYaw
    params.userPitchOffset = rx - basePitch
    _GLL.OrbitParams[uuid] = params
end



Ch.StickToCamera:SetHandler(function (Data)
    local uuid = _GLL.selectedUuid
    if not uuid or not _GLL.LightParametersServer or not _GLL.LightParametersServer[uuid] then
        return
    end

    local x, y, z = table.unpack(Data.Translate)
    local rx, ry, rz = table.unpack(Helpers.Math.QuatToEuler(Data.RotationQuat))
    local sourceTranslate = Data.SourceTranslate
    local translate = {x, y, z}
    local humanRotation = {rx, ry, rz}

    SaveLightTransform(uuid, translate, Data.RotationQuat, humanRotation)
    Osi.ToTransform(uuid, x, y, z, rx, ry, rz)

    local centerX, centerY, centerZ = table.unpack(sourceTranslate)
    UpdateOrbitOffsets(uuid, centerX, centerY, centerZ)
    local angle, radius, height = GetOrbitParameters(uuid, centerX, centerY, centerZ)

    BroadcastEntityTransformsAndOrbit(
        CreateTransforms(translate, Data.RotationQuat, humanRotation),
        {angle, radius, height}
    )
    UpdatePositionsForSomeBS()
end)


--- TBD: compress
Ch.SaveLoadLightPos:SetHandler(function (action)

    if action == 'Save' then
        local LPS = _GLL.LightParametersServer[_GLL.selectedUuid]
        LPS.SavedPosition = {}
        LPS.SavedPosition.Translate = LPS.Translate
        LPS.SavedPosition.RotationQuat = LPS.RotationQuat
        LPS.SavedPosition.HumanRotation = LPS.HumanRotation
    end

    if action == 'SaveAll' then
        for lightUuid in pairs(_GLL.LightParametersServer) do
            local LPS = _GLL.LightParametersServer[lightUuid]
            LPS.SavedPosition = {}
            LPS.SavedPosition.Translate = LPS.Translate
            LPS.SavedPosition.RotationQuat = LPS.RotationQuat
            LPS.SavedPosition.HumanRotation = LPS.HumanRotation
        end
    end

    if action == 'Load' then
        local LPS = _GLL.LightParametersServer[_GLL.selectedUuid]
        local x,y,z = table.unpack(LPS.SavedPosition.Translate)
        local rx,ry,rz = table.unpack(LPS.SavedPosition.HumanRotation)

        LPS.Translate = {x,y,z}
        LPS.HumanRotation = {rx,ry,rz}

        local Response = {
            Translate     = LPS.SavedPosition.Translate,
            RotationQuat  = LPS.SavedPosition.RotationQuat,
            HumanRotation = LPS.SavedPosition.HumanRotation
        }

        Osi.ToTransform(_GLL.selectedUuid, x, y, z, rx, ry, rz)

        BroadcastEntityTransformsAndOrbit(Response, nil)
        UpdateMarkerPosition()
        UpdateGoboPosition()
        UpdateBeamPosition()
    end

    if action == 'LoadAll' then
        for lightUuid in pairs(_GLL.LightParametersServer) do
            local LPS = _GLL.LightParametersServer[lightUuid]
            local x,y,z = table.unpack(LPS.SavedPosition.Translate)
            local rx,ry,rz = table.unpack(LPS.SavedPosition.HumanRotation)

            LPS.Translate = {x,y,z}
            LPS.HumanRotation = {rx,ry,rz}

            local Response = {
                Translate     = LPS.SavedPosition.Translate,
                RotationQuat  = LPS.SavedPosition.RotationQuat,
                HumanRotation = LPS.SavedPosition.HumanRotation,
                lightUuid     = lightUuid
            }

            Osi.ToTransform(lightUuid, x, y, z, rx, ry, rz)

            BroadcastEntityTransformsAndOrbit(Response, nil, lightUuid)
            UpdateMarkerPosition()
            UpdateGoboPosition()
            UpdateBeamPosition()
        end
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



Ch.EntityTranslate:SetHandler(function (Data)
    if not _GLL.selectedUuid then return end

    local axis = Data.axis
    local uuid = Data.lightUuid
    local sourceTranslate = Data.SourceTranslate
    local entity = _GLL.selectedEntity
    local rx, ry, rz = Osi.GetRotation(uuid)
    local x, y, z = Osi.GetPosition(uuid)

    _GLL.SourceTranslate = sourceTranslate

    if axis == 'x' or axis == 'y' or axis == 'z' then
        local translationOffset = Data.offset / Data.step
        if axis == 'x' then
            x = x + translationOffset
        elseif axis == 'y' then
            y = y + translationOffset
        else
            z = z + translationOffset
        end
    else
        x, y, z = table.unpack(sourceTranslate)
        y = y + 2
    end
    Osi.ToTransform(uuid, x, y, z, rx, ry, rz)

    local transform = entity.Transform.Transform
    local rotationQuat = transform.RotationQuat
    local translate = transform.Translate
    local humanRotation = {rx, ry, rz}

    SaveLightTransform(uuid, translate, rotationQuat, humanRotation)
    BroadcastEntityTransformsAndOrbit(CreateTransforms(translate, rotationQuat, humanRotation))
    UpdatePositionsForSomeBS()

    _GLL.States.lastMode[uuid] = 'World'
end)



Ch.EntityRotation:SetHandler(function (Data)
    if not _GLL.selectedUuid then return end

    local axis = Data.axis
    local uuid = Data.lightUuid
    local entity = _GLL.selectedEntity
    local sourceTranslate = Data.SourceTranslate
    local x, y, z = Osi.GetPosition(uuid)
    local translate = entity.Transform.Transform.Translate
    _GLL.LightParametersServer[uuid].Translate = translate

    _GLL.SourceTranslate = sourceTranslate

    local rotationQuat
    local humanRotation

    if Data.absolute then
        local rx, ry, rz = Data.rx, Data.ry, Data.rz
        Osi.ToTransform(uuid, x, y, z, rx, ry, rz)

        rotationQuat = entity.Transform.Transform.RotationQuat
        humanRotation = {rx, ry, rz}
        local centerX, centerY, centerZ = table.unpack(sourceTranslate)
        UpdateOrbitOffsets(uuid, centerX, centerY, centerZ, nil, rx, ry)

    elseif axis == 'x' or axis == 'y' or axis == 'z' then
        local delta = math.rad(Data.offset / Data.step)
        local currentQuat = entity.Transform.Transform.RotationQuat
        local newQuat = Ext.Math.QuatRotateAxisAngle(currentQuat, ROTATION_AXES[axis], delta)
        humanRotation = Helpers.Math.QuatToEuler(newQuat)

        local rx, ry, rz = table.unpack(humanRotation)
        Osi.ToTransform(uuid, x, y, z, rx, ry, rz)

        rotationQuat = entity.Transform.Transform.RotationQuat
        local centerX, centerY, centerZ = table.unpack(_GLL.SourceTranslate or getSourcePosition())
        UpdateOrbitOffsets(uuid, centerX, centerY, centerZ)
    else
        local centerX, centerY, centerZ = table.unpack(_GLL.SourceTranslate or getSourcePosition())
        local resetPitch, resetYaw = GetBaseAngles(uuid, centerX, centerY, centerZ, HEIGHT_OFFSET)
        Osi.ToTransform(uuid, x, y, z, resetPitch, resetYaw, 0)
        rotationQuat = entity.Transform.Transform.RotationQuat
        humanRotation = {resetPitch, resetYaw, 0}
        _GLL.OrbitParams[uuid] = {userYawOffset = 0, userPitchOffset = 0}
    end

    SaveLightTransform(uuid, translate, rotationQuat, humanRotation)
    local transforms = CreateTransforms(translate, rotationQuat, humanRotation)
    Ch.CurrentEntityTransform:Broadcast(transforms)

    UpdatePositionsForSomeBS()
    return transforms
end)

_GLL.OrbitParams = _GLL.OrbitParams or {}

Ch.EntityRotationOrbit:SetHandler(function (Data)
    if not _GLL.selectedUuid then return end

    local uuid = Data.lightUuid
    local entity = Ext.Entity.Get(uuid)
    local sourceTranslate = Data.SourceTranslate
    local centerX, centerY, centerZ = table.unpack(sourceTranslate)
    local curX, curY, curZ = Osi.GetPosition(uuid)
    local curRx, curRy, curRz = Osi.GetRotation(uuid)

    _GLL.SourceTranslate = sourceTranslate

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
    local centerMoved = centerX ~= params.lastCenterX
        or centerY ~= params.lastCenterY
        or centerZ ~= params.lastCenterZ
    local positionChanged = curX ~= (params.baseX or curX)
        or curY ~= (params.baseY or curY)
        or curZ ~= (params.baseZ or curZ)
    local rotationChanged = curRx ~= (params.lastActualRx or curRx)
        or curRy ~= (params.lastActualRy or curRy)
        or curRz ~= (params.lastActualRz or curRz)

    if centerMoved or positionChanged or rotationChanged or not params.baseX then
        InitOrbitParamsFromCurrent(uuid, params, centerX, centerY, centerZ)
        params.lastCenterX = centerX
        params.lastCenterY = centerY
        params.lastCenterZ = centerZ
    end

    local change = Data.offset

    if Data.axis == 'x' then
        params.angle = change
    elseif Data.axis == 'y' then
        params.height = change / 100
    elseif Data.axis == 'z' then
        params.radius = change / 100
    else
        local charX, charY, charZ = table.unpack(_GLL.SourceTranslate or getSourcePosition())
        Osi.ToTransform(uuid, charX, charY, charZ, curRx, curRy, curRz)
        _GLL.OrbitParams[uuid] = nil
        return
    end

    RotateAroundPoint(uuid, centerX, centerY, centerZ, params)
    LookAtCenter(uuid, centerX, centerY, centerZ, HEIGHT_OFFSET, params)

    local newX, newY, newZ = Osi.GetPosition(uuid)
    local actualRx, actualRy, actualRz = Osi.GetRotation(uuid)

    UpdateOrbitOffsets(uuid, centerX, centerY, centerZ, HEIGHT_OFFSET, actualRx, actualRy)
    params.baseX, params.baseY, params.baseZ = newX, newY, newZ
    params.lastActualRx = actualRx
    params.lastActualRy = actualRy
    params.lastActualRz = actualRz

    local translate = {params.baseX, params.baseY, params.baseZ}
    local rotationQuat = entity.Transform.Transform.RotationQuat
    local humanRotation = {actualRx, actualRy, actualRz}
    SaveLightTransform(uuid, translate, rotationQuat, humanRotation)

    local response = CreateTransforms(translate, rotationQuat, humanRotation)
    UpdatePositionsForSomeBS(true)

    _GLL.States.lastMode[uuid] = 'Orbit'
    Ch.CurrentEntityTransform:Broadcast(response)
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

    local targetY = centerY + HEIGHT_OFFSET
    local dx, dy, dz = centerX - x, targetY - y, centerZ - z
    local distance = math.sqrt(dx*dx + dy*dy + dz*dz)
    local baseYaw = math.deg(Ext.Math.Atan2(dx / distance, dz / distance))
    local basePitch = math.deg(math.asin(-dy / distance))

    params.userYawOffset = ry - baseYaw
    params.userPitchOffset = rx - basePitch
    return
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
    Osi.PlayLoopingAnimation(Data, '', '555f55c9-860d-4e5d-85ac-ceae8b1dde6e', '', '','','', '')
end)



Ch.GetDaggers:SetHandler(function(Data)
    local character = _C().Uuid.EntityUuid
    Osi.TemplateAddTo('bfadc906-02cd-442f-beff-04d5a40543fe', character, 1)
    Osi.TemplateAddTo('bfadc906-02cd-442f-beff-04d5a40543fe', character, 1)
end)



Ch.RemoveSurface:SetHandler(function()
    for k, v in pairs(Ext.Entity.GetAllEntitiesWithComponent('ServerSurface')) do
        if v.ServerSurface.Surface.Type == 'Blood' then
            v.ServerSurface.Surface.Meta.LifeTime = 0
        end
    end
end)

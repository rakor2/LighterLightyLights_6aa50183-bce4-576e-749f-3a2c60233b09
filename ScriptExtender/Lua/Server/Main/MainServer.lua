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
LLGlobals.CreatedLightsServer = {}
LLGlobals.LightParametersServer = {}
LLGlobals.selectedUuid = nil
LLGlobals.selectedEntity = nil

LLGlobals.States = {}
LLGlobals.States.allMarkersExisting = false
LLGlobals.States.beamExisting = false
LLGlobals.States.lastMode = {}

LLGlobals.CreatedAllMarkers = {}

MAZZLE_BEAM = 'ee3cf097-6e5f-40a2-8ed7-68073d50225f'



Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function(levelName, isEditorMode)
    getLevelAvailableLTNTriggers()
    getLevelAvailableATMTriggers()
    Ext.Net.BroadcastMessage('LL_WhenLevelGameplayStarted', Ext.Json.Stringify(data))
end)



local function getAvailableRootTemplate()
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



Ch.CreateLight:SetRequestHandler(function (Data)
    local HumanRotation
    local OFFSET = 2
    local uuid = getAvailableRootTemplate()

    if not uuid then return end

    local x, y, z = table.unpack(getSourcePosition())

    if uuid then
        LLGlobals.selectedUuid = Osi.CreateAt(uuid, x, y + OFFSET, z, 0, 0, '')
        HumanRotation = {0, 0, 0}

        if Data.lightType == 'Spotlight' then
            HumanRotation = {90, 0, 0}
            local rx, ry, rz = table.unpack(HumanRotation)
            Osi.ToTransform(LLGlobals.selectedUuid, x, y + OFFSET, z, rx, ry, rz)
        end


        LLGlobals.LightParametersServer[LLGlobals.selectedUuid] = {}
        LLGlobals.LightParametersServer[LLGlobals.selectedUuid].Translate = {x,y + OFFSET ,z}
        LLGlobals.LightParametersServer[LLGlobals.selectedUuid].RotationQuat = Math:EulerToQuats(HumanRotation)
        LLGlobals.LightParametersServer[LLGlobals.selectedUuid].HumanRotation = HumanRotation
        LLGlobals.selectedEntity = Ext.Entity.Get(LLGlobals.selectedUuid)
        LLGlobals.CreatedLightsServer[LLGlobals.selectedUuid] = LLGlobals.selectedUuid

        if LLGlobals.markerUuid then
            UpdateMarkerPosition()
            UpdateBeamPosition()
        else
            CreateMarker(true)
        end

        local Response = {
            LLGlobals.CreatedLightsServer,
            LLGlobals.selectedUuid,
            LLGlobals.markerUuid
        }

        LLGlobals.States.lastMode[LLGlobals.selectedUuid] = 'World'

        return Response
    else
        return nil
    end
end)



Ch.DuplicateLight:SetRequestHandler(function ()
    local uuid = getAvailableRootTemplate()
    local x,y,z = table.unpack(LLGlobals.LightParametersServer[LLGlobals.selectedUuid].Translate)
    local rx,ry,rz = table.unpack(LLGlobals.LightParametersServer[LLGlobals.selectedUuid].HumanRotation)
    local PreviousOrbitParams = LLGlobals.OrbitParams[LLGlobals.selectedUuid]

    LLGlobals.selectedUuid = Osi.CreateAt(uuid, x, y, z, 0, 0, '')
    Osi.ToTransform(LLGlobals.selectedUuid, x, y, z, rx, ry, rz)

    LLGlobals.selectedEntity = Ext.Entity.Get(LLGlobals.selectedUuid)


    local HumanRotation = {rx,ry,rz}
    LLGlobals.LightParametersServer[LLGlobals.selectedUuid] = {}
    LLGlobals.LightParametersServer[LLGlobals.selectedUuid].Translate = {x,y,z}
    LLGlobals.LightParametersServer[LLGlobals.selectedUuid].RotationQuat = Math:EulerToQuats(HumanRotation)
    LLGlobals.LightParametersServer[LLGlobals.selectedUuid].HumanRotation = HumanRotation
    LLGlobals.OrbitParams[LLGlobals.selectedUuid] = PreviousOrbitParams
    LLGlobals.CreatedLightsServer[LLGlobals.selectedUuid] = LLGlobals.selectedUuid

    if LLGlobals.markerUuid then
        UpdateMarkerPosition()
        UpdateBeamPosition()
    else
        CreateMarker(true)
    end

    local Response = {
        LLGlobals.CreatedLightsServer,
        LLGlobals.selectedUuid,
        LLGlobals.LightParametersServer[LLGlobals.selectedUuid]
    }

    LLGlobals.States.lastMode[LLGlobals.selectedUuid] = 'World'

    return Response
end)



function CreateMarker(single)
    local R_OFFSET = 90

    if single then
        local x,y,z = table.unpack(LLGlobals.LightParametersServer[LLGlobals.selectedUuid].Translate)
        local rx,ry,rz = table.unpack(LLGlobals.LightParametersServer[LLGlobals.selectedUuid].HumanRotation)
        local uuid = lightMarkerGUID
        LLGlobals.markerUuid = Osi.CreateAt(uuid, x, y, z, 0, 0, '')
        Osi.ToTransform(LLGlobals.markerUuid, x, y, z, rx - R_OFFSET, ry, rz)
        Data = LLGlobals.markerUuid
        Ch.MarkerHandler:Broadcast(Data)
    else
        LLGlobals.States.allMarkersExisting = not LLGlobals.States.allMarkersExisting

        if LLGlobals.States.allMarkersExisting then
            for k,v in pairs(LLGlobals.CreatedLightsServer) do
                local x,y,z = table.unpack(LLGlobals.LightParametersServer[v].Translate)
                local rx,ry,rz = table.unpack(LLGlobals.LightParametersServer[v].HumanRotation)
                local uuid = lightMarker2GUID

                local markerUuid = Osi.CreateAt(uuid, x, y, z, 0, 0, '')
                Osi.ToTransform(markerUuid, x, y, z, rx - R_OFFSET, ry, rz)
                table.insert(LLGlobals.CreatedAllMarkers, markerUuid)
            end
        else
            for _, markerUuid in pairs(LLGlobals.CreatedAllMarkers) do
                Osi.RequestDelete(markerUuid)
            end

            LLGlobals.CreatedAllMarkers = {}
        end

    end
end



function UpdateMarkerPosition()
    if LLGlobals.markerUuid and LLGlobals.LightParametersServer[LLGlobals.selectedUuid] then
        local R_OFFSET = 90
        local x,y,z = table.unpack(LLGlobals.LightParametersServer[LLGlobals.selectedUuid].Translate)
        local rx,ry,rz = table.unpack(LLGlobals.LightParametersServer[LLGlobals.selectedUuid].HumanRotation)
        Osi.ToTransform(LLGlobals.markerUuid, x, y, z, rx - R_OFFSET, ry, rz)
    end
end



function UpdateAllMarkersPosition()
    if not LLGlobals.States.allMarkersExisting then return end
    local R_OFFSET = 90
    for uuid, _ in pairs(LLGlobals.CreatedLightsServer) do
        local x, y, z = table.unpack(LLGlobals.LightParametersServer[uuid].Translate)
        local rx, ry, rz = table.unpack(LLGlobals.LightParametersServer[uuid].HumanRotation)
        local markerUuid = LLGlobals.CreatedAllMarkers[uuid]
        Osi.ToTransform(markerUuid, x, y, z, rx - R_OFFSET, ry, rz)
    end
end



function UpdateBeamPosition()
    if not LLGlobals.beamUuid then return end

    local uuid = LLGlobals.selectedUuid
    local rx, ry, rz = Osi.GetRotation(uuid)
    local x, y, z = Osi.GetPosition(uuid)
    local OFFSET = 180
    Osi.ToTransform(LLGlobals.beamUuid, x, y, z, rx + OFFSET, ry, rz)
end



Ch.MarkerHandler:SetRequestHandler(function (Data)
    CreateMarker(false)
    return Reseponse
end)



Ch.SelectedLight:SetHandler(function (selectedUuid)
    LLGlobals.selectedUuid = selectedUuid
    LLGlobals.selectedEntity = Ext.Entity.Get(LLGlobals.selectedUuid)
    UpdateMarkerPosition()
    UpdateBeamPosition()
end)



Ch.DeleteLight:SetHandler(function (request)
    if request == 'All' then
        for _, lightUuid in pairs(LLGlobals.CreatedLightsServer) do
            Osi.RequestDelete(lightUuid)
        end

        for _, markerUuid in pairs(LLGlobals.CreatedAllMarkers) do
            Osi.RequestDelete(markerUuid)
        end

        LLGlobals.CreatedLightsServer = {}
        LLGlobals.LightParametersServer = {}
        LLGlobals.beamUuid = nil
        LLGlobals.selectedEntity = nil
        LLGlobals.selectedUuid = nil
        LLGlobals.CreatedAllMarkers = {}
        LLGlobals.States.allMarkersExisting = false
        LLGlobals.GoboLightMap = {}
        LLGlobals.GoboDistances = {}
        LLGlobals.beamUuid = nil
        LLGlobals.States.beamExisting = false

        if LLGlobals.markerUuid then
            Osi.RequestDelete(LLGlobals.markerUuid)
            LLGlobals.markerUuid = nil
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
            LLGlobals.CreatedLightsServer[lightUuidFromClientJustToMakeSureBecauseIHadProblemsForSomeReasonImProbablyDumb] = nil
            LLGlobals.LightParametersServer[lightUuidFromClientJustToMakeSureBecauseIHadProblemsForSomeReasonImProbablyDumb] = nil
            LLGlobals.GoboLightMap[lightUuidFromClientJustToMakeSureBecauseIHadProblemsForSomeReasonImProbablyDumb] = nil

            if LLGlobals.GoboDistances then LLGlobals.GoboDistances[lightUuidFromClientJustToMakeSureBecauseIHadProblemsForSomeReasonImProbablyDumb] = nil end

            changeRootTemplateState(rootId)
        end

        --TBD: find a better solution later, because I'm sleepy af rn
        --now I'm too lazy
        local count = 0
        for _ in pairs(LLGlobals.CreatedLightsServer) do
            count = count + 1
        end

        if count == 0 and LLGlobals.markerUuid then
            Osi.RequestDelete(LLGlobals.markerUuid)
            LLGlobals.markerUuid = nil

            if LLGlobals.beamUuid then
                Osi.RequestDelete(LLGlobals.beamUuid)
                LLGlobals.beamUuid = nil
                LLGlobals.States.beamExisting = false
            end

        end

    else
        if LLGlobals.markerUuid then
            Osi.RequestDelete(LLGlobals.markerUuid)
            LLGlobals.markerUuid = nil

        end
    end
    UpdateBeamPosition()
end)


Ext.RegisterConsoleCommand('lldumpall', function (cmd, ...)
    DPrint('CreatedLightsServer -----------------------------------')
    DDump(LLGlobals.CreatedLightsServer)
    DPrint('LightParametersServer ---------------------------------')
    DDump(LLGlobals.LightParametersServer)
    DPrint('LightParametersServer ---------------------------------')
    DDump(LLGlobals.selectedUuid)
    DPrint('allMarkersExisting ------------------------------------')
    DDump(LLGlobals.CreatedAllMarkers)
    DPrint('States.allMarkersExisting -----------------------------')
    DDump(LLGlobals.States.allMarkersExisting)
    DPrint('States.GoboLightMap -----------------------------------')
    DDump(LLGlobals.GoboLightMap)
end)



LLGlobals.States.sourceClient = false



Ch.CurrentEntityTransform:SetHandler(function (Data)
    if Data then
        LLGlobals.States.sourceClient = true
        LLGlobals.SourceClientTranslate = Data
    else
        LLGlobals.States.sourceClient = false
    end
end)



function getSourcePosition()
    if LLGlobals.States.sourceClient then
        SourceTranslate = LLGlobals.SourceClientTranslate
    else
        SourceTranslate = _C().Transform.Transform.Translate
    end
    return SourceTranslate
end



Ch.StickToCamera:SetHandler(function (Data)
    if not LLGlobals.selectedUuid then return end
    if not LLGlobals.LightParametersServer  then return end
    if not LLGlobals.LightParametersServer[LLGlobals.selectedUuid] then return end

    local uuid = LLGlobals.selectedUuid
    local x,y,z = table.unpack(Data.Translate)
    local rx,ry,rz = table.unpack(Helpers.Math.QuatToEuler(Data.RotationQuat))

    LLGlobals.LightParametersServer[LLGlobals.selectedUuid].Translate = {x, y, z}
    LLGlobals.LightParametersServer[LLGlobals.selectedUuid].RotationQuat = Data.RotationQuat
    LLGlobals.LightParametersServer[LLGlobals.selectedUuid].HumanRotation = {rx, ry, rz}

    Osi.ToTransform(LLGlobals.selectedUuid, x, y, z, rx, ry, rz)

    --- For look at
    local centerX, centerY, centerZ = table.unpack(getSourcePosition())
    local curX, curY, curZ = Osi.GetPosition(uuid)
    local dx, dy, dz = centerX - curX, centerY - curY, centerZ - curZ
    local distance = math.sqrt(dx*dx + dy*dy + dz*dz)
    local baseYaw = math.deg(Ext.Math.Atan2(dx / distance, dz / distance))
    local basePitch = math.deg(math.asin(-dy / distance))

    local curRx, curRy, curRz = Osi.GetRotation(uuid)

    local params = LLGlobals.OrbitParams[uuid] or {}
    params.userYawOffset = curRy - baseYaw
    params.userPitchOffset = curRx - basePitch
    LLGlobals.OrbitParams[uuid] = params


    UpdateMarkerPosition()
    UpdateGoboPosition()
    UpdateBeamPosition()
end)



Ch.SaveLoadLightPos:SetHandler(function (action)
    if action == 'Save' then
        LLGlobals.LightParametersServer[LLGlobals.selectedUuid].SavedPosition = LLGlobals.LightParametersServer[LLGlobals.selectedUuid.SavedPosition] or {}

        LLGlobals.LightParametersServer[LLGlobals.selectedUuid].SavedPosition.Translate = LLGlobals.LightParametersServer[LLGlobals.selectedUuid].Translate
        LLGlobals.LightParametersServer[LLGlobals.selectedUuid].SavedPosition.RotationQuat = LLGlobals.LightParametersServer[LLGlobals.selectedUuid].RotationQuat
        LLGlobals.LightParametersServer[LLGlobals.selectedUuid].SavedPosition.HumanRotation = LLGlobals.LightParametersServer[LLGlobals.selectedUuid].HumanRotation
    end

    if action == 'Load' then
        local x,y,z = table.unpack(LLGlobals.LightParametersServer[LLGlobals.selectedUuid].SavedPosition.Translate)
        local rx,ry,rz = table.unpack(LLGlobals.LightParametersServer[LLGlobals.selectedUuid].SavedPosition.HumanRotation)


        LLGlobals.LightParametersServer[LLGlobals.selectedUuid].Translate = {x,y,z}
        LLGlobals.LightParametersServer[LLGlobals.selectedUuid].HumanRotation = {rx,ry,rz}


        local Response = {
            Translate = LLGlobals.LightParametersServer[LLGlobals.selectedUuid].SavedPosition.Translate,
            RotationQuat = LLGlobals.LightParametersServer[LLGlobals.selectedUuid].SavedPosition.RotationQuat,
            HumanRotation = LLGlobals.LightParametersServer[LLGlobals.selectedUuid].SavedPosition.HumanRotation
        }

        Ch.CurrentEntityTransform:Broadcast(Response)

        Osi.ToTransform(LLGlobals.selectedUuid, x, y, z, rx, ry, rz)

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
    if not LLGlobals.selectedUuid then return end

    LLGlobals.States.beamExisting = not LLGlobals.States.beamExisting

    if LLGlobals.States.beamExisting then
        local uuid = LLGlobals.selectedUuid
        local rx, ry, rz = Osi.GetRotation(uuid)
        local x, y, z = Osi.GetPosition(uuid)
        local R_OFFSET = 180

        LLGlobals.beamUuid =  Osi.CreateAt(MAZZLE_BEAM, x, y, z, 0, 0, '')

        Helpers.Timer:OnTicks(1, function ()
            Osi.ToTransform(LLGlobals.beamUuid, x, y, z, rx + R_OFFSET, ry, rz)
        end)

    else
        Osi.RequestDelete(LLGlobals.beamUuid)
        LLGlobals.beamUuid = nil
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
    if not LLGlobals.selectedUuid then return end

    local axis = Data.axis
    local step = Data.step
    local OFFSET = Data.offset
    local entity = LLGlobals.selectedEntity
    -- local uuid = LLGlobals.selectedUuid
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

    LLGlobals.LightParametersServer[uuid].Translate = Translate
    LLGlobals.LightParametersServer[uuid].RotationQuat = RotationQuat
    LLGlobals.LightParametersServer[uuid].HumanRotation = HumanRotation

    local Response = {
        Translate = Translate,
        RotationQuat = RotationQuat,
        HumanRotation = HumanRotation
    }

    -- LLGlobals.OrbitParams[uuid] = nil

    Ch.CurrentEntityTransform:Broadcast(Response)

    UpdateMarkerPosition()
    UpdateGoboPosition()
    UpdateBeamPosition()

    LLGlobals.States.lastMode[uuid] = 'World'
end)



Ch.EntityRotation:SetHandler(function (Data)
    if not LLGlobals.selectedUuid then return end

    local axis = Data.axis
    local uuid = Data.lightUuid
    local entity = LLGlobals.selectedEntity
    local x, y, z = Osi.GetPosition(uuid)
    local Translate = entity.Transform.Transform.Translate

    LLGlobals.LightParametersServer[uuid].Translate = Translate

    if axis == 'x' or axis == 'y' or axis == 'z' then
        local delta = math.rad(Data.offset / Data.step)
        local currentQuat = entity.Transform.Transform.RotationQuat
        local axisVec = ({x={1,0,0}, y={0,1,0}, z={0,0,1}})[axis]
        local newQuat = Ext.Math.QuatRotateAxisAngle(currentQuat, axisVec, delta)

        local HumanRotation = Helpers.Math.QuatToEuler(newQuat)
        local rx, ry, rz = table.unpack(HumanRotation)
        Osi.ToTransform(uuid, x, y, z, rx, ry, rz)

        local RotationQuat = entity.Transform.Transform.RotationQuat
        LLGlobals.LightParametersServer[uuid].RotationQuat = RotationQuat
        LLGlobals.LightParametersServer[uuid].HumanRotation = HumanRotation

        local Response = {Translate = Translate, RotationQuat = RotationQuat, HumanRotation = HumanRotation}
        Ch.CurrentEntityTransform:Broadcast(Response)

        local centerX, centerY, centerZ = table.unpack(getSourcePosition())
        local basePitch, baseYaw = GetBaseAngles(uuid, centerX, centerY, centerZ)
        local curRx, curRy, curRz = Osi.GetRotation(uuid)
        local params = LLGlobals.OrbitParams[uuid] or {}
        params.userYawOffset = curRy - baseYaw
        params.userPitchOffset = curRx - basePitch
        LLGlobals.OrbitParams[uuid] = params

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
        LLGlobals.LightParametersServer[uuid].RotationQuat = RotationQuat
        LLGlobals.LightParametersServer[uuid].HumanRotation = HumanRotation
        LLGlobals.OrbitParams[uuid] = {userYawOffset = 0, userPitchOffset = 0}

        local Response = {Translate = Translate, RotationQuat = RotationQuat, HumanRotation = HumanRotation}
        Ch.CurrentEntityTransform:Broadcast(Response)
        UpdateMarkerPosition()
        UpdateGoboPosition()
        UpdateBeamPosition()
        return Response
    end
end)



--- mmmmmmmm slop tasty slop m m m m :P
LLGlobals.OrbitParams = LLGlobals.OrbitParams or {}

Ch.EntityRotationOrbit:SetHandler(function (Data)
    if not LLGlobals.selectedUuid then return end

    -- local uuid = LLGlobals.selectedUuid
    local uuid = Data.lightUuid
    local entity = Ext.Entity.Get(uuid)
    local centerX, centerY, centerZ = table.unpack(getSourcePosition())
    local curX, curY, curZ = Osi.GetPosition(uuid)
    local curRx, curRy, curRz = Osi.GetRotation(uuid)

    if not LLGlobals.OrbitParams[uuid] then
        LLGlobals.OrbitParams[uuid] = {
            angle = 0,
            radius = 1,
            height = 0,
            lastCenterX = centerX,
            lastCenterY = centerY,
            lastCenterZ = centerZ
        }
        InitOrbitParamsFromCurrent(uuid, LLGlobals.OrbitParams[uuid], centerX, centerY, centerZ)
    end

    local params = LLGlobals.OrbitParams[uuid]
    local centerMoved = centerX ~= params.lastCenterX or centerY ~= params.lastCenterY or centerZ ~= params.lastCenterZ
    local posChanged = curX ~= (params.baseX or curX) or curY ~= (params.baseY or curY) or curZ ~= (params.baseZ or curZ)
    local rotChanged = curRx ~= (params.lastActualRx or curRx) or curRy ~= (params.lastActualRy or curRy) or curRz ~= (params.lastActualRz or curRz)

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
        LLGlobals.OrbitParams[uuid] = nil
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

    LLGlobals.LightParametersServer[uuid].Translate = {params.baseX, params.baseY, params.baseZ}
    local RotationQuat = entity.Transform.Transform.RotationQuat
    LLGlobals.LightParametersServer[uuid].RotationQuat = RotationQuat
    LLGlobals.LightParametersServer[uuid].HumanRotation = {actualRx, actualRy, actualRz}

    local Response = {
        Translate = {params.baseX, params.baseY, params.baseZ},
        RotationQuat = RotationQuat,
        HumanRotation = {actualRx, actualRy, actualRz}
    }

    UpdateMarkerPosition()
    UpdateAllMarkersPosition()
    UpdateGoboPosition()
    UpdateBeamPosition()

    LLGlobals.States.lastMode[uuid] = 'Orbit'
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




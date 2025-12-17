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



LLGlobals.CreatedLightsServer = {}
LLGlobals.LightParametersServer = {}
LLGlobals.selectedUuid = nil
LLGlobals.selectedEntity = nil


LLGlobals.States = {}
LLGlobals.States.allMarkersExisting = false
LLGlobals.States.beamExisting = false
LLGlobals.States.lastMode = {}

LLGlobals.CreatedAllMakers = {}


-- INITIAL_LIGHT_TEMPLATE_0_POINT = 'd92ed2ec-a332-4a28-ae3d-99f79ee0fa92'
-- INITIAL_LIGHT_TEMPLATE_1_SPOT = '8b02ea30-6dcc-4b45-b6b4-d174f07bb2a1' --'fd55b15f-d82b-4743-a9fb-629b8b7c6636'
-- INITIAL_LIGHT_TEMPLATE_2_DIR = 'e4e90f6d-aa3e-4fb7-af3a-2ec279368083'


MAZZLE_BEAM = 'ee3cf097-6e5f-40a2-8ed7-68073d50225f'



Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function(levelName, isEditorMode)

    getLevelAvailableLTNTriggers()
    getLevelAvailableATMTriggers()

    Ext.Net.BroadcastMessage('LL_WhenLevelGameplayStarted', Ext.Json.Stringify(data))
end)



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

    if not uuid then return end

    -- DPrint('Creating new light using: %s', uuid)

    local x, y, z = table.unpack(getSourcePosition())

    if uuid then

        LLGlobals.selectedUuid = Osi.CreateAt(uuid, x, y + offset, z, 0, 0, '')
        HumanRotation = {0, 0, 0}

        if Data.lightType == 'Spotlight' then
            HumanRotation = {90, 0, 0}
            local rx, ry, rz = table.unpack(HumanRotation)
            Osi.ToTransform(LLGlobals.selectedUuid, x, y + offset, z, rx, ry, rz)
        end


        LLGlobals.LightParametersServer[LLGlobals.selectedUuid] = {}
        LLGlobals.LightParametersServer[LLGlobals.selectedUuid].Translate = {x,y + offset ,z}
        LLGlobals.LightParametersServer[LLGlobals.selectedUuid].RotationQuat = Math:EulerToQuats(HumanRotation)
        LLGlobals.LightParametersServer[LLGlobals.selectedUuid].HumanRotation = HumanRotation

        LLGlobals.selectedEntity = Ext.Entity.Get(LLGlobals.selectedUuid)

        LLGlobals.CreatedLightsServer[LLGlobals.selectedUuid] = LLGlobals.selectedUuid

        -- DDump(LLGlobals.LightParametersServer)


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



Channels.DuplicateLight:SetRequestHandler(function ()
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

    local rOffset = 90

    if single then
        local x,y,z = table.unpack(LLGlobals.LightParametersServer[LLGlobals.selectedUuid].Translate)
        local rx,ry,rz = table.unpack(LLGlobals.LightParametersServer[LLGlobals.selectedUuid].HumanRotation)

        local uuid = lightMarkerGUID
        LLGlobals.markerUuid = Osi.CreateAt(uuid, x, y, z, 0, 0, '')
        Osi.ToTransform(LLGlobals.markerUuid, x, y, z, rx - rOffset, ry, rz)

        Data = LLGlobals.markerUuid
        Channels.MarkerHandler:Broadcast(Data)

    else

        LLGlobals.States.allMarkersExisting = not LLGlobals.States.allMarkersExisting

        if LLGlobals.States.allMarkersExisting then
            for k,v in pairs(LLGlobals.CreatedLightsServer) do

                local x,y,z = table.unpack(LLGlobals.LightParametersServer[v].Translate)
                local rx,ry,rz = table.unpack(LLGlobals.LightParametersServer[v].HumanRotation)

                local uuid = lightMarker2GUID

                local markerUuid = Osi.CreateAt(uuid, x, y, z, 0, 0, '')
                Osi.ToTransform(markerUuid, x, y, z, rx - rOffset, ry, rz)
                table.insert(LLGlobals.CreatedAllMakers, markerUuid)
            end
        else
            for _, markerUuid in pairs(LLGlobals.CreatedAllMakers) do
                Osi.RequestDelete(markerUuid)
            end
            LLGlobals.CreatedAllMakers = {}
        end

    end
end



function UpdateMarkerPosition()
    if LLGlobals.markerUuid and LLGlobals.LightParametersServer[LLGlobals.selectedUuid] then
        local rOffset = 90
        local x,y,z = table.unpack(LLGlobals.LightParametersServer[LLGlobals.selectedUuid].Translate)
        local rx,ry,rz = table.unpack(LLGlobals.LightParametersServer[LLGlobals.selectedUuid].HumanRotation)
        Osi.ToTransform(LLGlobals.markerUuid, x, y, z, rx - rOffset, ry, rz)
    end
end



function UpdateBeamPosition()

    if not LLGlobals.beamUuid then return end

    local uuid = LLGlobals.selectedUuid

    local rx, ry, rz = Osi.GetRotation(uuid)
    local x, y, z = Osi.GetPosition(uuid)

    local offset = 180

    Osi.ToTransform(LLGlobals.beamUuid, x, y, z, rx + offset, ry, rz)

end



Channels.MarkerHandler:SetRequestHandler(function (Data)
    -- if Data.single then
    --     CreateMarker()
    -- else

        CreateMarker(false)

    -- end
    -- local Reseponse = 0
    return Reseponse
end)



Channels.SelectedLight:SetHandler(function (selectedUuid)
    LLGlobals.selectedUuid = selectedUuid
    LLGlobals.selectedEntity = Ext.Entity.Get(LLGlobals.selectedUuid)
    -- DPrint('Selected light: %s', LLGlobals.selectedUuid)
    UpdateMarkerPosition()
    UpdateBeamPosition()
end)



Channels.DeleteLight:SetHandler(function (request)
    if request == 'All' then

        for _, lightUuid in pairs(LLGlobals.CreatedLightsServer) do
            Osi.RequestDelete(lightUuid)
        end


        for _, markerUuid in pairs(LLGlobals.CreatedAllMakers) do
            Osi.RequestDelete(markerUuid)
        end


        LLGlobals.CreatedLightsServer = {}
        LLGlobals.LightParametersServer = {}


        LLGlobals.beamUuid = nil
        LLGlobals.selectedEntity = nil
        LLGlobals.selectedUuid = nil


        LLGlobals.CreatedAllMakers = {}
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
        local count = 0
        for _ in pairs(LLGlobals.CreatedLightsServer) do
            count = count + 1
        end

        if count == 0 and LLGlobals.markerUuid then

            Osi.RequestDelete(LLGlobals.markerUuid)
            LLGlobals.markerUuid = nil

            Osi.RequestDelete(LLGlobals.beamUuid)
            LLGlobals.beamUuid = nil
            LLGlobals.States.beamExisting = false

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
    DDump(LLGlobals.CreatedAllMakers)
    DPrint('States.allMarkersExisting -----------------------------')
    DDump(LLGlobals.States.allMarkersExisting)
    DPrint('States.GoboLightMap -----------------------------------')
    DDump(LLGlobals.GoboLightMap)
end)


LLGlobals.States.sourceClient = false



Channels.CurrentEntityTransform:SetHandler(function (Data)
    if Data then
        -- DPrint('Client source: %s', LLGlobals.States.sourceClient)
        LLGlobals.States.sourceClient = true
        LLGlobals.SourceClientTranslate = Data
    else
        -- DPrint('Client source: %s', LLGlobals.States.sourceClient)
        LLGlobals.States.sourceClient = false
    end
end)



function getSourcePosition()
    -- DPrint('Client source: %s', LLGlobals.States.sourceClient)
    if LLGlobals.States.sourceClient then
        SourceTranslate = LLGlobals.SourceClientTranslate
    else
        SourceTranslate = _C().Transform.Transform.Translate
    end
    return SourceTranslate
end




Channels.StickToCamera:SetHandler(function (Data)

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






Channels.SaveLoadLightPos:SetHandler(function (Data)

    if Data == 'Save' then
        LLGlobals.LightParametersServer[LLGlobals.selectedUuid].SavedPosition = LLGlobals.LightParametersServer[LLGlobals.selectedUuid.SavedPosition] or {}

        LLGlobals.LightParametersServer[LLGlobals.selectedUuid].SavedPosition.Translate = LLGlobals.LightParametersServer[LLGlobals.selectedUuid].Translate
        LLGlobals.LightParametersServer[LLGlobals.selectedUuid].SavedPosition.RotationQuat = LLGlobals.LightParametersServer[LLGlobals.selectedUuid].RotationQuat
        LLGlobals.LightParametersServer[LLGlobals.selectedUuid].SavedPosition.HumanRotation = LLGlobals.LightParametersServer[LLGlobals.selectedUuid].HumanRotation
    end

    if Data == 'Load' then
        local x,y,z = table.unpack(LLGlobals.LightParametersServer[LLGlobals.selectedUuid].SavedPosition.Translate)
        local rx,ry,rz = table.unpack(LLGlobals.LightParametersServer[LLGlobals.selectedUuid].SavedPosition.HumanRotation)


        LLGlobals.LightParametersServer[LLGlobals.selectedUuid].Translate = {x,y,z}
        LLGlobals.LightParametersServer[LLGlobals.selectedUuid].HumanRotation = {rx,ry,rz}


        local Response = {
            Translate = LLGlobals.LightParametersServer[LLGlobals.selectedUuid].SavedPosition.Translate,
            RotationQuat = LLGlobals.LightParametersServer[LLGlobals.selectedUuid].SavedPosition.RotationQuat,
            HumanRotation = LLGlobals.LightParametersServer[LLGlobals.selectedUuid].SavedPosition.HumanRotation
        }

        Channels.CurrentEntityTransform:Broadcast(Response)

        Osi.ToTransform(LLGlobals.selectedUuid, x, y, z, rx, ry, rz)

        UpdateMarkerPosition()
        UpdateGoboPosition()
        UpdateBeamPosition()
    end

end)






Channels.DeleteEverything:SetHandler(function (Data)
    for _, uuid in ipairs(Data) do
        Osi.RequestDelete(uuid)
    end
end)



Channels.MazzleBeam:SetHandler(function (Data)

    if not LLGlobals.selectedUuid then return end


    LLGlobals.States.beamExisting = not LLGlobals.States.beamExisting


    if LLGlobals.States.beamExisting then

        local uuid = LLGlobals.selectedUuid

        local rx, ry, rz = Osi.GetRotation(uuid)
        local x, y, z = Osi.GetPosition(uuid)

        local rOffset = 180

        LLGlobals.beamUuid =  Osi.CreateAt(MAZZLE_BEAM, x, y, z, 0, 0, '')

        Helpers.Timer:OnTicks(1, function ()

            Osi.ToTransform(LLGlobals.beamUuid, x, y, z, rx + rOffset, ry, rz)
        end)

    else
        Osi.RequestDelete(LLGlobals.beamUuid)
        LLGlobals.beamUuid = nil
    end


end)


Channels.EntityTranslate:SetHandler(function (Data)

    if not LLGlobals.selectedUuid then return end

    local axis = Data.axis
    local step = Data.step
    local offset = Data.offset

    local entity = LLGlobals.selectedEntity
    local uuid = LLGlobals.selectedUuid

    local rx, ry, rz = Osi.GetRotation(uuid)
    local x, y, z = Osi.GetPosition(uuid)



    if axis == 'x' then
        local x = x + offset / step
        Osi.ToTransform(uuid, x, y, z, rx, ry, rz)

    elseif  axis == 'y' then
        local y = y + offset / step
        Osi.ToTransform(uuid, x, y, z, rx, ry, rz)

    elseif  axis == 'z' then
        local z = z + offset / step
        Osi.ToTransform(uuid, x, y, z, rx, ry, rz)

    else
        local x, y, z = table.unpack(getSourcePosition())
        Osi.ToTransform(uuid, x, y, z, rx, ry, rz)
    end



    --- TBD: REFACTOR THESE ONES
    local RotationQuat = entity.Transform.Transform.RotationQuat
    local Translate = entity.Transform.Transform.Translate
    local HumanRotation = {rx,ry,rz}


    LLGlobals.LightParametersServer[LLGlobals.selectedUuid].Translate = Translate
    LLGlobals.LightParametersServer[LLGlobals.selectedUuid].RotationQuat = RotationQuat
    LLGlobals.LightParametersServer[LLGlobals.selectedUuid].HumanRotation = HumanRotation

    local Response = {
        Translate = Translate,
        RotationQuat = RotationQuat,
        HumanRotation = HumanRotation
    }

    -- LLGlobals.OrbitParams[uuid] = nil

    Channels.CurrentEntityTransform:Broadcast(Response)

    UpdateMarkerPosition()
    UpdateGoboPosition()
    UpdateBeamPosition()

    LLGlobals.States.lastMode[LLGlobals.selectedUuid] = 'World'

    -- return Response
    -- local rx, ry, rz = Osi.GetRotation(uuid)
    -- local x, y, z = Osi.GetPosition(uuid)

    -- DPrint('x: %s, y: %s, z: %s, rx: %s, ry: %s, rz: %s', x, y, z, rx, ry, rz)

end)



Channels.EntityRotation:SetHandler(function (Data)


    if not LLGlobals.selectedUuid then return end


    local axis = Data.axis
    local step = Data.step
    local offset = Data.offset

    local uuid = LLGlobals.selectedUuid
    local entity = LLGlobals.selectedEntity

    local rx, ry, rz = Osi.GetRotation(uuid)
    local x, y, z = Osi.GetPosition(uuid)


    local RotationQuat = entity.Transform.Transform.RotationQuat
    local Translate = entity.Transform.Transform.Translate
    local HumanRotation = {rx,ry,rz}


    LLGlobals.LightParametersServer[LLGlobals.selectedUuid].Translate = Translate
    LLGlobals.LightParametersServer[LLGlobals.selectedUuid].RotationQuat = RotationQuat


    if axis == 'x' then
        local rx = rx + offset / step
        Osi.ToTransform(uuid, x, y, z, rx, ry, rz)
        HumanRotation = {rx,ry,rz}

    elseif  axis == 'y' then
        local ry = ry + offset / step
        Osi.ToTransform(uuid, x, y, z, rx, ry, rz)
        HumanRotation = {rx,ry,rz}

    elseif  axis == 'z' then
        local rz = rz + offset / step
        Osi.ToTransform(uuid, x, y, z, rx, ry, rz)
        HumanRotation = {rx,ry,rz}

    else
        Osi.ToTransform(uuid, x, y, z, 0, 0, 0)
        LLGlobals.LightParametersServer[LLGlobals.selectedUuid].HumanRotation = {0,0,0}
        LLGlobals.OrbitParams[LLGlobals.selectedUuid] = nil

        local centerX, centerY, centerZ = table.unpack(getSourcePosition())
        local curX, curY, curZ = Osi.GetPosition(uuid)
        local targetY = centerY + 1.3
        local dx, dy, dz = centerX - curX, targetY - curY, centerZ - curZ
        local distance = math.sqrt(dx*dx + dy*dy + dz*dz)

        local resetPitch = math.deg(math.asin(-dy / distance))
        local resetYaw = math.deg(Ext.Math.Atan2(dx / distance, dz / distance))
        local resetRoll = 0

        Osi.ToTransform(uuid, x, y, z, resetPitch, resetYaw, resetRoll)

        RotationQuat = entity.Transform.Transform.RotationQuat
        HumanRotation = {resetPitch, resetYaw, resetRoll}

        LLGlobals.LightParametersServer[LLGlobals.selectedUuid].HumanRotation = HumanRotation
        LLGlobals.LightParametersServer[LLGlobals.selectedUuid].RotationQuat = RotationQuat

        LLGlobals.OrbitParams[uuid] = {
            userYawOffset = 0,
            userPitchOffset = 0
        }

        local Response = {
            Translate = Translate,
            RotationQuat = RotationQuat,
            HumanRotation = HumanRotation
        }

        Channels.CurrentEntityTransform:Broadcast(Response)
        UpdateMarkerPosition()
        UpdateGoboPosition()
        UpdateBeamPosition()

        return Response
    end

    LLGlobals.LightParametersServer[LLGlobals.selectedUuid].HumanRotation = HumanRotation

    local Response = {
        Translate = Translate,
        RotationQuat = RotationQuat,
        HumanRotation = HumanRotation
    }

    -- LLGlobals.OrbitParams[uuid] = nil

    Channels.CurrentEntityTransform:Broadcast(Response)


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


    return Response

end)




--- mmmmmmmm slop tasty slop m m m m :P

LLGlobals.OrbitParams = LLGlobals.OrbitParams or {}

Channels.EntityRotationOrbit:SetHandler(function (Data)

    if not LLGlobals.selectedUuid then return end

    local uuid = LLGlobals.selectedUuid
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
    local targetY = centerY + 1.3
    local dx, dy, dz = centerX - newX, targetY - newY, centerZ - newZ
    local distance = math.sqrt(dx*dx + dy*dy + dz*dz)
    local baseYaw = math.deg(Ext.Math.Atan2(dx / distance, dz / distance))
    local basePitch = math.deg(math.asin(-dy / distance))


    local actualRx, actualRy, actualRz = Osi.GetRotation(uuid)

    params.userYawOffset = actualRy - baseYaw
    params.userPitchOffset = actualRx - basePitch


    params.baseX, params.baseY, params.baseZ = newX, newY, newZ
    params.lastActualRx = actualRx
    params.lastActualRy = actualRy
    params.lastActualRz = actualRz

    LLGlobals.LightParametersServer[LLGlobals.selectedUuid].Translate = {params.baseX, params.baseY, params.baseZ}
    local RotationQuat = entity.Transform.Transform.RotationQuat
    LLGlobals.LightParametersServer[LLGlobals.selectedUuid].RotationQuat = RotationQuat
    LLGlobals.LightParametersServer[LLGlobals.selectedUuid].HumanRotation = {actualRx, actualRy, actualRz}

    local Response = {
        Translate = {params.baseX, params.baseY, params.baseZ},
        RotationQuat = RotationQuat,
        HumanRotation = {actualRx, actualRy, actualRz}
    }

    UpdateMarkerPosition()
    UpdateGoboPosition()
    UpdateBeamPosition()
    LLGlobals.States.lastMode[LLGlobals.selectedUuid] = 'Orbit'
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

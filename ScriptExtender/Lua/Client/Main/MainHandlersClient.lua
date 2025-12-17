LLGlobals.States = LLGlobals.States or {}



Ext.RegisterNetListener('LL_WhenLevelGameplayStarted', function (channel, payload, user)
    LLGlobals.SourceTranslate = _C().Transform.Transform.Translate

    Ext.Stats.GetStatsManager().ExtraData["PhotoModeCameraFloorDistance"] = -99887766
    Ext.Stats.GetStatsManager().ExtraData["PhotoModeCameraRange"] = 11223344

    CharacterLightSetupState(lightSetupState)
end)





Ext.Events.ResetCompleted:Subscribe(function()
    LLGlobals.SourceTranslate = _C().Transform.Transform.Translate
end)


-- function setSourceTranslate(SourceTranslate)
--     -- local SourceTranslate = _C().Transform.Transform.Translate
--     return SourceTranslate
-- end




function getSelectedUuid()
    if  LLGlobals.LightsUuidNameMap       and
        E.comboIHateCombos.SelectedIndex  and
        E.comboIHateCombos.Options[E.comboIHateCombos.SelectedIndex + 1]
    then
        for _, light in pairs(LLGlobals.LightsUuidNameMap) do
            if light.name == E.comboIHateCombos.Options[E.comboIHateCombos.SelectedIndex + 1] then
                return light.uuid
            end
        end
    end
end



function getSelectedEntity()
    local uuid = getSelectedUuid()
    if uuid then return Ext.Entity.Get(uuid) end
end



function getSelectedLightEntity()
    local entity = getSelectedEntity()
    if entity and entity.Effect and entity.Effect.Timeline and entity.Effect.Timeline.Components[2] then
    return entity.Effect.Timeline.Components[2].LightEntity.Light end
end



function getSelectedLightEntityWithoutLight()
    local entity = getSelectedEntity()
    if entity then return entity.Effect.Timeline.Components[2].LightEntity end
end



function getSelectedLightName()
    return E.comboIHateCombos.Options[E.comboIHateCombos.SelectedIndex + 1]
end



function getSelectedLightType()
    local entity = getSelectedLightEntity()
    if not entity then return end
    local lightType = entity.LightType
    if      lightType == 2 then  return 'Directional'
    elseif  lightType == 1 then  return 'Spotlight'
    else                    return 'Point'
    end
end



function getLightEntity(uuid)
    local entity = Ext.Entity.Get(uuid)
    if entity and entity.Effect and entity.Effect.Timeline then
        return entity.Effect.Timeline.Components[2].LightEntity.Light
    end
end



function sanitySelectedLight()
    for name, uuid in pairs(LLGlobals.LightsUuidNameMap) do
        if uuid == LLGlobals.selectedUuid then
            -- DPrint('Sanity selected light: %s, %s', name, LLGlobals.selectedUuid)
        end
    end
end



-- function translate(entity)
--     local Translate = entity.Transform.Transform.Translate
--     return Translate[1], Translate[2], Translate[3]
-- end



-- function rotation(entity)
--     local RotationQuat = entity.Transform.Transform.RotationQuat
--     local Deg = Helpers.Math.QuatToEuler(RotationQuat)
--     return Deg[1], Deg[2], Deg[3]
-- end



-- local function LightVisibilty()
--     Helpers.Timer:OnTicks(10, function ()
--         local lightEntity = getSelectedLightEntity()
--         -- DPrint('Light visibility entity: %s', lightEntity)
--         if lightEntity then
--             if lightEntity.LightChannelFlag == 255 then
--                 textLightVisibility.Label = getSelectedLightName() .. ' is on'
--             else
--                 textLightVisibility.Label = getSelectedLightName() .. ' is off'
--             end
--         end
--     end)
-- end


function SelectLight()
    LLGlobals.selectedUuid = getSelectedUuid()
    LLGlobals.selectedEntity = getSelectedEntity()
    LLGlobals.selectedLightType = getSelectedLightType()
    local name = getSelectedLightName()
    Channels.SelectedLight:SendToServer(LLGlobals.selectedUuid)
    UpdateCreatedLightsCombo()
    UpdateElements(LLGlobals.selectedUuid)


    -- DPrint('Selected light uuid', LLGlobals.selectedUuid)
    -- DPrint('Selected light name', name)
    -- DPrint('Selected light entity', LLGlobals.selectedEntity)
    -- DPrint('Selected light type', LLGlobals.selectedLightType)

    -- DPrint('Selected light parameters -----------------------')
    -- DDump(LLGlobals.LightParametersClient[LLGlobals.selectedUuid])


    if not LLGlobals.selectedEntity then return end

    local x,y,z = table.unpack(LLGlobals.selectedEntity.Transform.Transform.Translate)
    local rx,ry,rz = table.unpack(Helpers.Math.QuatToEuler(LLGlobals.selectedEntity.Transform.Transform.RotationQuat))
    UpdateTranformInfo(x,y,z,rx,ry,rz)


    -- local lightName = getSelectedLightName()
    -- selectedLightNotification.Label = lightName
    -- DPrint('Selected index: %s', LLGlobals.syncedSelectedIndex)
end

Ext.RegisterConsoleCommand('llparams', function (cmd, ...)
    DPrint('All lights parameters -----------------------')
    DDump(LLGlobals.LightParametersClient)
end)


function UpdateCreatedLightsCombo()
    LLGlobals.LightsNames = {}
    for _, light in pairs(LLGlobals.LightsUuidNameMap) do
        table.insert(LLGlobals.LightsNames, light.name)
    end

    E.comboIHateCombos.Options = LLGlobals.LightsNames
    E.comboIHateCombos2.Options = LLGlobals.LightsNames



    Helpers.Timer:OnTicks(5, function ()
        local lightName = getSelectedLightName() or 'None'
        if lightName then selectedLightNotification.Label = lightName end
    end)



end


function RegisterNewLight(uuid, lightType)
    nameIndex = nameIndex + 1
    -- DPrint('nameIndex in Register: %s', nameIndex)
    local name = '+' .. ' ' .. '#' .. nameIndex .. ' ' .. lightType

    table.insert(LLGlobals.LightsUuidNameMap, {
        uuid = LLGlobals.CreatedLightsServer[uuid],
        name = name,
        nameIndex = nameIndex
    })


    -- DDump(LLGlobals.LightsUuidNameMap)

    UpdateCreatedLightsCombo()
    E.comboIHateCombos.SelectedIndex = #E.comboIHateCombos.Options - 1

end


function UpdateTranformInfo(x, y, z, rx, ry, rz)
    textPositionInfo.Label = string.format('x: %.2f, y: %.2f, z: %.2f', x, y, z)
    textRotationInfo.Label = string.format('pitch: %.2f, roll: %.2f, yaw: %.2f', rx, rz, ry)
end


lightType = defaultLightType


function CreateLight()
    if LLGlobals.States.allowLightCreation then
        LLGlobals.States.allowLightCreation = false
        E.btnCreate2.Disabled = true
        local Position = LLGlobals.SourceTranslate
        local Data = {
            lightType = lightType or 'Point',
            Position = Position
        }


        Channels.CreateLight:RequestToServer(Data, function (Response)
            if Response then
                LLGlobals.CreatedLightsServer = Response[1]
                LLGlobals.selectedUuid = Response[2]
                LLGlobals.markerUuid = Response[3]

                Helpers.Timer:OnTicks(10, function ()
                    LLGlobals.LightParametersClient[LLGlobals.selectedUuid] =  {}
                    LLGlobals.selectedEntity = Ext.Entity.Get(LLGlobals.selectedUuid)


                    Helpers.Timer:OnTicks(8, function ()
                        if lightType == 'Spotlight' then
                            SetLightType(1)
                        elseif lightType == 'Directional' then
                            SetLightType(2)
                        else
                            SetLightType(0)
                        end
                        LLGlobals.selectedLightType = lightType --TBD
                    end)

                    -- DPrint('Callback Create: %s, %s', LLGlobals.selectedUuid, LLGlobals.selectedEntity)


                    RegisterNewLight(LLGlobals.selectedUuid, lightType)


                    if stickToggleOff and Utils.subID and Utils.subID['Stick'] then
                        E.checkStick.Checked = false
                        stickToCameraCheck()
                    end

                    Helpers.Timer:OnTicks(10, function ()
                        local x,y,z = table.unpack(Position)
                        UpdateElements(LLGlobals.selectedUuid)
                        UpdateTranformInfo(x, y, z, 90, 0, 0)
                        if markerOff then
                            ToggleMarker(LLGlobals.markerUuid)
                        end
                    end)
                end)
            else
                LLGlobals.States.allowLightCreation = true
                E.btnCreate2.Disabled = false
            end
        end)
    end
end







--- TBD: remove some DUPLICATIONS HAHAHAHAH GET IT????? LMAOOOOOOOOOOOOOOOOOO
function DuplicateLight()

    local prevoiusUuid = LLGlobals.selectedUuid
    local OriginalLight = LLGlobals.LightParametersClient[prevoiusUuid]

    Channels.DuplicateLight:RequestToServer(Data, function (Response)
        if Response then
            LLGlobals.CreatedLightsServer = Response[1]
            LLGlobals.selectedUuid = Response[2]


            LLGlobals.LightParametersClient[LLGlobals.selectedUuid] = LLGlobals.LightParametersClient[LLGlobals.selectedUuid] or {}



            local lightTypeOld = OriginalLight.LightType

            if lightTypeOld == 1 then
               lightTypeOld = 'Spotlight'

            elseif lightTypeOld == 2 then
                lightTypeOld = 'Directional'

            else
                lightTypeOld = 'Point'

            end

            RegisterNewLight(LLGlobals.selectedUuid, lightTypeOld)


            Helpers.Timer:OnTicks(15, function ()
                LLGlobals.selectedEntity = Ext.Entity.Get(LLGlobals.selectedUuid)

                --- TBD: perhaps as a separate function? But what's the point?

                SetLightType(OriginalLight.LightType)
                SetLightColor(OriginalLight.Color)
                SetLightIntensity(OriginalLight.Intensity)
                SetLightRadius(OriginalLight.Radius)
                SetLightOuterAngle(OriginalLight.SpotLightOuterAngle)
                SetLightInnerAngle(OriginalLight.SpotLightInnerAngle)

                SetLightDirectionalParameters('DirectionLightAttenuationEnd', OriginalLight.DirectionLightAttenuationEnd)
                SetLightDirectionalParameters('DirectionLightAttenuationFunction', OriginalLight.DirectionLightAttenuationFunction)
                SetLightDirectionalParameters('DirectionLightAttenuationSide', OriginalLight.DirectionLightAttenuationSide)
                SetLightDirectionalParameters('DirectionLightAttenuationSide2', OriginalLight.DirectionLightAttenuationSide2)
                SetLightDirectionalParameters('DirectionLightDimensions', OriginalLight.DirectionLightDimensions)


                SetLightFill(OriginalLight.Flags)
                SetLightScattering(OriginalLight.ScatteringIntensityScale)
                SetLightEdgeSharp(OriginalLight.EdgeSharpening)

                SetLightChannel(OriginalLight.SliderLightChannelFlag)

            end)


            if stickToggleOff and Utils.subID and Utils.subID['Stick'] then
                E.checkStick.Checked = false
                stickToCameraCheck()
            end

            Helpers.Timer:OnTicks(16, function ()
                local x,y,z = table.unpack(Response[3].Translate)
                local rx,ry,rz = table.unpack(Response[3].HumanRotation)
                UpdateElements(LLGlobals.selectedUuid)
                UpdateTranformInfo(x, y, z, rx, ry, rz)
            end)

        end
    end)
end




Channels.CurrentEntityTransform:SetHandler(function (Data)
    local rx, ry, rz = table.unpack(Data.HumanRotation)
    local x,y,z = table.unpack(Data.Translate)
    UpdateTranformInfo(x, y, z, rx, ry, rz)
end)




function GatherLightsAndMarkers()

    local Guido = {
        'a0d2ac1c',
        'c1c8b026',
        '4eab6f6d',
        '13c358b1',
        '34329d13',
        '0435655f',
        '213674c9',
        'fc270e8b',
        '1b86fb4a',
        '08a26239',
        'e6748263',

        '62a459e2',
        'cabc9b70',
        '12f13f99',

        'ee3cf097',

    }

    local EntitiesToDelete = {}

    local gov = Ext.Entity.GetAllEntitiesWithComponent('GameObjectVisual')
    for _, entity in ipairs(gov) do
        for _, guid in pairs(Guido) do
            if entity.GameObjectVisual.RootTemplateId:find(guid) then
                -- DPrint(entity)
                table.insert(EntitiesToDelete, entity.Uuid.EntityUuid)
            end
        end
    end

    local effects = Ext.Entity.GetAllEntitiesWithComponent('Effect')
    for _, entity in ipairs(effects) do
        if entity.Effect.EffectName:find('LLL_') then
            table.insert(EntitiesToDelete, entity.Uuid.EntityUuid)
        end
    end

    Channels.DeleteEverything:SendToServer(EntitiesToDelete)

end

--[[
local gov = Ext.Entity.GetAllEntitiesWithComponent('GameObjectVisual')
for _, entity in ipairs(gov) do
    if entity.GameObjectVisual.RootTemplateId:find('1b86fb4a') then
        _P(entity.GameObjectVisual.RootTemplateId)
    end
end
]]--



function UpdateElements(selectedUuid)
    if not selectedUuid then return end
    -- DDump(LLGlobals.LightParametersClient[selectedUuid])

    E.slIntLightType.Value = {LLGlobals.LightParametersClient[selectedUuid].LightType or 0, 0, 0, 0}

    local Color = LLGlobals.LightParametersClient[selectedUuid] and LLGlobals.LightParametersClient[selectedUuid].Color
    E.pickerLightColor.Color = Color and {Color[1], Color[2], Color[3], 1} or {1, 1, 1, 1}

    E.slLightIntensity.Value = {LLGlobals.LightParametersClient[selectedUuid].Intensity or 1, 0, 0, 0}
    E.slLightTemp.Value = {LLGlobals.LightParametersClient[selectedUuid].Temperature or 5600, 0, 0, 0}
    E.slLightRadius.Value = {LLGlobals.LightParametersClient[selectedUuid].Radius or 1, 0, 0, 0}


    E.slLightDirEnd.Value = {LLGlobals.LightParametersClient[selectedUuid].DirectionLightAttenuationEnd or 0, 0, 0, 0}

    E.slIntLightDirFunc.Value = {LLGlobals.LightParametersClient[selectedUuid].DirectionLightAttenuationFunction or 0, 0, 0, 0}


    local lightType = E.slIntLightType.Value[1]
    if lightType == 2 then

        local value = E.slIntLightDirFunc.Value[1]
        if value == 0 then funcType = 'Linear' end
        if value == 1 then funcType = 'Inv sqr' end
        if value == 2 then funcType = 'SmoothStep' end
        if value == 3 then funcType = 'SmootherStep' end

        textFunc.Label = funcType
    else
        textFunc.Label = 'Attenuation'
    end


    E.slLightDirSide.Value = {LLGlobals.LightParametersClient[selectedUuid].DirectionLightAttenuationSide or 0, 0, 0, 0}
    E.slLightDirSide2.Value = {LLGlobals.LightParametersClient[selectedUuid].DirectionLightAttenuationSide2 or 0, 0, 0, 0}
--
    local Dim = LLGlobals.LightParametersClient[selectedUuid] and LLGlobals.LightParametersClient[selectedUuid].DirectionLightDimensions
    E.slLightDirDim.Value = Dim and {Dim[1], Dim[2],Dim[3], 0} or {0, 0, 0, 0}


    E.slLightOuterAngle.Value = {LLGlobals.LightParametersClient[selectedUuid].SpotLightOuterAngle or 45, 0, 0, 0}
    E.slLightInnerAngle.Value = {LLGlobals.LightParametersClient[selectedUuid].SpotLightInnerAngle or 1, 0, 0, 0}



    E.checkLightFill.Checked = (LLGlobals.LightParametersClient[selectedUuid].Flags or 184) == 184


    E.checkLightChannel.Value = {LLGlobals.LightParametersClient[selectedUuid].SliderLightChannelFlag or 1, 0, 0, 0}

    local value = E.checkLightChannel.Value[1]
    if value == 1 then channelType = 'Character + world' end
    if value == 2 then channelType = 'Character' end
    if value == 3 then channelType = 'World' end
    textChannel.Label = channelType


    E.slLightScattering.Value = {LLGlobals.LightParametersClient[selectedUuid].ScatteringIntensityScale or 0, 0, 0, 0}
    E.slLightEdgeSharp.Value = {LLGlobals.LightParametersClient[selectedUuid].EdgeSharpening or 0, 0, 0, 0}

    LLGlobals.States.allowLightCreation = true
    E.btnCreate2.Disabled = false
end



function UpdateVisibilityStateToNames(lightName, state)
    for _, light in pairs(LLGlobals.LightsUuidNameMap) do
        if light.name == lightName then
        light.name = light.name:gsub('^[+-]%s+', '')
            if state then
                light.name = '+ ' .. light.name
            else
                light.name = '- ' .. light.name
            end
        end
    end
    UpdateCreatedLightsCombo()
end


Channels.MarkerHandler:SetHandler(function (Data)
    Helpers.Timer:OnTicks(15, function ()
        LLGlobals.markerEntity = Ext.Entity.Get(Data)
        LLGlobals.markerEntity.Visual.Visual:SetWorldScale({markerScale, markerScale, markerScale})
    end)
end)


LLGlobals.States.markerToggled = false
function ToggleMarker(uuid)
    local newScaleX
    local entity = Ext.Entity.Get(uuid)
    if entity and entity.Visual then
        local scaleX = entity.Visual.Visual.WorldTransform.Scale[1]
        newScaleX = scaleX == 0 and markerScale or 0
        entity.Visual.Visual:SetWorldScale({newScaleX,newScaleX,newScaleX})
        LLGlobals.States.markerToggled = not LLGlobals.States.markerToggled
    end
end



function SetLightType(value)
    local lightEntity = getSelectedLightEntity()
    if lightEntity and value then
        lightEntity.LightType = value
        LLGlobals.LightParametersClient[LLGlobals.selectedUuid].LightType = value
    end
end



function SetLightColor(value)
    local lightEntity = getSelectedLightEntity()
    if lightEntity and value then
        lightEntity.Color = value
        LLGlobals.LightParametersClient[LLGlobals.selectedUuid].Color = value
    end
end



function SetLightIntensity(value)
    if value then
        LLGlobals.selectedEntity.Effect.EffectResource.Constructor.EffectComponents[1].Properties['Appearance.Intensity'].KeyFrames[1].Frames[1].Value = value
        LLGlobals.selectedEntity.Effect.EffectResource.Constructor.EffectComponents[1].Properties['Appearance.Intensity'].KeyFrames[1].Frames[2].Value = value
        LLGlobals.LightParametersClient[LLGlobals.selectedUuid].Intensity = value
        --#region
    -- local lightEntity = getSelectedLightEntityWithoutLight()
    -- if lightEntity then
    --     lightEntity.Light.Intensity = value
    --     LightEntities[lightEntity] = LightEntities[lightEntity] or {}
    --     LightEntities[lightEntity].Intensity = value
    --     Utils:SubUnsubToTick('sub', LLGlobals.selectedUuid, function () --[[ "Let it live its happy spinny life, why does everything have to be for the player" Aahz (Top 1 optick leaderboard) ]]
    --         for entity, parameter in pairs(LightEntities) do
    --             if Ext.Entity.Get(entity).Light then
    --                 -- DPrint('%s , %s ', entity, parameter.Intensity)
    --                 Ext.Entity.Get(entity).Light.Intensity = parameter.Intensity
    --             end
    --         end
    --     end)
    -- end
    --#endregion
    end
end



function SetLightRadius(value)
    if value then
        LLGlobals.selectedEntity.Effect.EffectResource.Constructor.EffectComponents[1].Properties['Appearance.Radius'].KeyFrames[1].Frames[1].Value = value
        LLGlobals.selectedEntity.Effect.EffectResource.Constructor.EffectComponents[1].Properties['Appearance.Radius'].KeyFrames[1].Frames[2].Value = value
        LLGlobals.LightParametersClient[LLGlobals.selectedUuid].Radius = value
        --#region
    --     -- DDump(LLGlobals.selectedEntity.Effect.EffectResource.Constructor.EffectComponents[1])
    --     lightEntity.Light.Radius = value
    --     LightEntities[lightEntity] = LightEntities[lightEntity] or {}
    --     LightEntities[lightEntity].Radius = value
    --     Utils:SubUnsubToTick('sub', LLGlobals.selectedUuid, function () --[[ "Let it live its happy spinny life, why does everything have to be for the player" Aahz (Top 1 optick leaderboard) ]]
    --         for entity, parameter in pairs(LightEntities) do
    --             if Ext.Entity.Get(entity).Light then
    --                 -- DPrint('%s , %s ', entity, parameter.Radius)
    --                 Ext.Entity.Get(entity).Light.Radius = parameter.Radius
    --             end
    --         end
    --     end)
    -- end
    --#endregion
    end
end



function SetLightOuterAngle(value)
    local lightEntity = getSelectedLightEntity()
    if lightEntity and value then
        lightEntity.SpotLightOuterAngle = value
        LLGlobals.LightParametersClient[LLGlobals.selectedUuid].SpotLightOuterAngle = value
    end
end



function SetLightInnerAngle(value)
    local lightEntity = getSelectedLightEntity()
    if lightEntity and value then
        lightEntity.SpotLightInnerAngle = value
        LLGlobals.LightParametersClient[LLGlobals.selectedUuid].SpotLightInnerAngle = value
    end
end



function SetLightDirectionalParameters(parameter, value)
    local lightEntity = getSelectedLightEntity()
    if lightEntity and value then
        if parameter == 'DirectionLightAttenuationEnd' then
            lightEntity.DirectionLightAttenuationEnd = value

        elseif parameter == 'DirectionLightAttenuationFunction' then
            lightEntity.DirectionLightAttenuationFunction = value

            if value == 0 then funcType = 'Linear' end
            if value == 1 then funcType = 'Inv sqr' end
            if value == 2 then funcType = 'SmoothStep' end
            if value == 3 then funcType = 'SmootherStep' end


            textFunc.Label = funcType


        elseif parameter == 'DirectionLightAttenuationSide' then
            lightEntity.DirectionLightAttenuationSide = value

        elseif parameter == 'DirectionLightAttenuationSide2' then
            lightEntity.DirectionLightAttenuationSide2 = value

        elseif parameter == 'DirectionLightDimensions' then
            lightEntity.DirectionLightDimensions = value

        end
        LLGlobals.LightParametersClient[LLGlobals.selectedUuid][parameter] = value

    end
end



function SetLightFill(value)
    local lightEntity = getSelectedLightEntity()
    if lightEntity and value then
        lightEntity.Flags = value
        LLGlobals.LightParametersClient[LLGlobals.selectedUuid].Flags = value
    end
end


function SetLightChannel(value)
    local lightEntity = getSelectedLightEntity()
    if lightEntity and value then
        LLGlobals.LightParametersClient[LLGlobals.selectedUuid].SliderLightChannelFlag = value
        if value == 1 then value = 255; textChannel.Label = 'Character + world' end
        if value == 2 then value = 32;  textChannel.Label = 'Character' end
        if value == 3 then value = 1 ;  textChannel.Label = 'World' end
        lightEntity.LightChannelFlag = value
        LLGlobals.LightParametersClient[LLGlobals.selectedUuid].LightChannelFlag = value
    end
end



function SetLightScattering(value)
    local lightEntity = getSelectedLightEntity()
    if lightEntity and value then
        lightEntity.ScatteringIntensityScale = value
        LLGlobals.LightParametersClient[LLGlobals.selectedUuid].ScatteringIntensityScale = value
    end
end



function MoveEntity(entity, axis, offset, step, mode, objectType)
    if entity then
        local Data = {
            axis = axis,
            step = step,
            offset = offset,
            Translate = LLGlobals.SourceTranslate
        }

        if objectType == 'Light' then
            if mode == 'World' then
                Channels.EntityTranslate:SendToServer(Data)
            else
                Channels.EntityRotationOrbit:SendToServer(Data)
            end

        elseif objectType == 'Point' then
            Channels.MoveOriginPoint:SendToServer(Data)

        elseif objectType == 'Gobo' then
            return 0
        end
    end
end



function RotateEntity(entity, axis, offset, step, objectType)
    if entity then
        local Data = {
            axis = axis,
            step = step,
            offset = offset,
            Translate = LLGlobals.SourceTranslate
        }
        if objectType == 'Light' then
            Channels.EntityRotation:SendToServer(Data)

        elseif objectType == 'Point' then

        elseif objectType == 'Gobo' then
            return 0
        end
    end
end



function SourceCutscene(state)
    local entity = _C()

    if not entity then return end

    E.checkPMSrc.Checked = false
    E.checkClientSrc.Checked = false
    E.checkOriginSrc.Checked = false

    if state then
        Utils:SubUnsubToTick('sub', 'SourceCutscene', function ()

        if not E.checkCutsceneSrc.Checked then return end

        if Dummy:TLPreviewDummyPlayer() then
            local Transform = Dummy:TLPreviewDummyPlayerTransform()
            LLGlobals.SourceTranslate = Transform.Translate
            Channels.CurrentEntityTransform:SendToServer(LLGlobals.SourceTranslate)
        else
            Utils:SubUnsubToTick('unsub', 'SourceCutscene',_)
            -- DPrint('SourceCutscene off')
            E.checkCutsceneSrc.Checked = false
            LLGlobals.SourceTranslate = entity.Transform.Transform.Translate
            Channels.CurrentEntityTransform:SendToServer(nil)
        end
    end)
    else
        if Utils.subID['SourceCutscene'] then
            Utils:SubUnsubToTick('unsub', 'SourceCutscene',_)
            -- DPrint('SourceCutscene off 2')
            LLGlobals.SourceTranslate = entity.Transform.Transform.Translate
        end
        Channels.CurrentEntityTransform:SendToServer(nil)
    end
end



function SourcePoint(state)
    local entity = LLGlobals.pointEntity

    if not entity then E.checkOriginSrc.Checked = false return end

    E.checkPMSrc.Checked = false
    E.checkClientSrc.Checked = false
    E.checkCutsceneSrc.Checked = false

    if state then

        Utils:SubUnsubToTick('sub', 'SourcePoint', function ()

        if not E.checkOriginSrc.Checked then return end
        if not entity.Transform then return end

        local Transform = entity.Transform.Transform
        LLGlobals.SourceTranslate = Transform.Translate
        Channels.CurrentEntityTransform:SendToServer(LLGlobals.SourceTranslate)
    end)
    else
        if Utils.subID and Utils.subID['SourcePoint'] then
            Utils:SubUnsubToTick('unsub', 'SourcePoint',_)
            LLGlobals.SourceTranslate = _C().Transform.Transform.Translate
        end
        Channels.CurrentEntityTransform:SendToServer(nil)
    end
    return 0
end

--- TBD: fix this garbo
function SourcePhotoMode(state)
    if not LLGlobals.DummyNameMap then E.checkPMSrc.Checked = false return end

    E.checkClientSrc.Checked = false
    E.checkCutsceneSrc.Checked = false
    E.checkOriginSrc.Checked = false

    if state then

        Utils:SubUnsubToTick('sub', 'SourcePhotoMode', function ()

        if not E.checkPMSrc.Checked then return end

        local entity = LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]]
        if not entity or not entity.Visual then E.checkPMSrc.Checked = false return end
        local Transform = entity.Visual.Visual.WorldTransform
        LLGlobals.SourceTranslate = Transform.Translate
        Channels.CurrentEntityTransform:SendToServer(LLGlobals.SourceTranslate)
    end)
    else
        if Utils.subID and Utils.subID['SourcePhotoMode'] then
            Utils:SubUnsubToTick('unsub', 'SourcePhotoMode',_)
            LLGlobals.SourceTranslate = _C().Transform.Transform.Translate
        end
        Channels.CurrentEntityTransform:SendToServer(nil)
    end
    return 0
end



function SourceClient(state)

    E.checkPMSrc.Checked = false
    E.checkCutsceneSrc.Checked = false
    E.checkOriginSrc.Checked = false

    if state then
        Utils:SubUnsubToTick('sub', 'SourceClient', function ()
        if not E.checkClientSrc.Checked then return end
        if _C() and _C().Visual and _C().Visual.Visual.WorldTransform then
            local Transform = _C().Visual.Visual.WorldTransform
            LLGlobals.SourceTranslate = Transform.Translate
            Channels.CurrentEntityTransform:SendToServer(LLGlobals.SourceTranslate)
        end
    end)
    else
        if Utils.subID['SourceClient'] then
            Utils:SubUnsubToTick('unsub', 'SourceClient',_)
            LLGlobals.SourceTranslate = _C().Transform.Transform.Translate
        end
        Channels.CurrentEntityTransform:SendToServer(nil)
    end
end

function stickToCameraCheck()
    Utils:SubUnsubToTick('sub', 'Stick', function ()
        if E.checkStick.Checked then

            local Translate = Camera:GetActiveCamera().Transform.Transform.Translate
            local RotationQuat = Camera:GetActiveCamera().Transform.Transform.RotationQuat
            local Data = {
                Translate = Translate,
                RotationQuat = RotationQuat
            }
            Channels.StickToCamera:SendToServer(Data)


            local x,y,z = table.unpack(Translate)
            local rx,ry,rz = table.unpack(Helpers.Math.QuatToEuler(RotationQuat))
            UpdateTranformInfo(x,y,z,rx,ry,rz)

        else
            Utils:SubUnsubToTick('unsub', 'Stick', _)
        end
    end)
end






function CreateLightNumberNotification(lightName)
        local lightName = lightName or 'None'
        windowNotification =  Ext.IMGUI.NewWindow('Selected light')
        windowNotification.Visible = false
        ApplyStyle(windowNotification, StyleSettings.selectedStyle)
        local p = windowNotification
        local ViewportSize = Ext.IMGUI.GetViewportSize()
        p:SetPos({ViewportSize[1] / 2, ViewportSize[2] / 2})
        p.NoDecoration = true

        selectedLightNotification = p:AddText(lightName)
        windowNotification.AlwaysAutoResize = true
end

CreateLightNumberNotification()



function CharacterLightSetupState(state)
    local entities
    local _, e = pcall(function ()
        entities = Ext.Entity.GetAllEntitiesWithComponent('CharacterLight')
        for _, entity in pairs(entities) do
            entity.CharacterLight.Enabled = state
        end
    end)
    if e then return DPrint('Only available for SE Devel') end
end





---Moved from old files
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------










LLGlobals.DummyNameMap = {}
visTemplatesOptionsIndex = {}

rotMod = 1500
stepMod = 1500
scaleMod = 1500

-- function GetEmzptyVisualTemplatesAndPopulateCombo()
--     LLGlobals.DummyNameMap = {}
--     visTemplatesOptionsIndex = {}
--     GetEmptyVisualTemplates()
-- end



-- function GetEmptyVisualTemplates()
--     visTemplates = Ext.Entity.GetAllEntitiesWithComponent("Visual")
--     for i = 1, #visTemplates do
--             if visTemplates[i].Visual and visTemplates[i].Visual.Visual
--                 and visTemplates[i].Visual.Visual.VisualResource
--                 and visTemplates[i].Visual.Visual.VisualResource.Template == "EMPTY_VISUAL_TEMPLATE"
--                 --and visTemplates[i]:GetAllComponentNames(false)[2] == "ecl::dummy::AnimationStateComponent"
--             then
--                     -- DPrint(visTemplates[i].Visual.Visual.VisualResource.Template .. '  ' .. i)
--                     -- DDump(visTemplates[i]:GetAllComponentNames(false))
--                     table.insert(LLGlobals.DummyNameMap, visTemplates[i])
--                     visTemplatesOptionsIndex = {}
--                         for o = 1, #LLGlobals.DummyNameMap do
--                             table.insert(visTemplatesOptionsIndex, o)
--                         end
--                     -- DDump(visTemplatesOptionsIndex)
--             end
--     end
--     E.visTemComob.Options = visTemplatesOptionsIndex
-- end



LLGlobals.CameraPositions = {}
function CameraSaveLoadPosition(index)
    local activeCam = Camera:GetActiveCamera()
    local pmCamera = Camera:GetPhotoModeCamera()

    if pmCamera and activeCam then
        LLGlobals.CameraPositions[tostring(index)] = {
            activeTranslate = activeCam.Transform.Transform.Translate,
            activeRotationQuat = activeCam.Transform.Transform.RotationQuat,
            activeScale = activeCam.Transform.Transform.Scale,
        }
    end

    return LLGlobals.CameraPositions
end



function CameraControlls(type, value)
    local camera = Camera:GetActiveCamera()
    if camera then
        if type == 'Far_plane' then
            camera.Camera.Controller.FarPlane = value
        else
            camera.Camera.Controller.NearPlane = value
        end
    end
end




LLGlobals.SaveLoad = {}

MCM.SetKeybindingCallback('ll_move_to_cursor', function()
    if LLGlobals.DummyNameMap then
        local index = E.visTemComob.SelectedIndex + 1
        local entity = LLGlobals.DummyNameMap[E.visTemComob.Options[index]]
        local mousePos = Utils:GetMouseover().Inner.Position
        entity.Visual.Visual.WorldTransform.Translate = mousePos
        entity.DummyOriginalTransform.Transform.Translate = mousePos
        UpdateCharacterInfo(index)
    end
end)


function UpdateCharacterInfo(index)
    Helpers.Timer:OnTicks(5, function ()
    if index and LLGlobals.DummyNameMap and LLGlobals.DummyNameMap[E.visTemComob.Options[index]]  and
    LLGlobals.DummyNameMap[E.visTemComob.Options[index]].Visual                                 and
    LLGlobals.DummyNameMap[E.visTemComob.Options[index]].Visual.Visual                          then


            local transform = LLGlobals.DummyNameMap[E.visTemComob.Options[index]].Visual.Visual.WorldTransform
            E.posInput.Value = {transform.Translate[1], transform.Translate[2], transform.Translate[3], 0}
            E.scaleInput.Value = {transform.Scale[1], transform.Scale[2], transform.Scale[3], 0}
            local deg = Helpers.Math.QuatToEuler(transform.RotationQuat)
            E.rotInput.Value = {deg[1], deg[2], deg[3], 0}
        else
            E.posInput.Value = {0,0,0,0}
            E.rotInput.Value = {0,0,0,0}
            E.scaleInput.Value = {0,0,0,0}
        end
    end)
end



function MoveCharacter(axis, value, stepMod, index)

    if LLGlobals.DummyNameMap then


        -- DPrint('Selected character MoveCharacter: %s', selectedCharacter)


        local entity = LLGlobals.DummyNameMap[E.visTemComob.Options[index]]
        if entity then
            local pos = entity.Visual.Visual.WorldTransform.Translate
            local original_pos = entity.DummyOriginalTransform.Transform.Translate
            if axis == 'x' then
                pos.x = value
                pos[1] = pos[1] + (pos.x/stepMod)
                original_pos[1] = original_pos[1] + (pos.x/stepMod)
            elseif axis == 'y' then
                pos.y = value
                pos[2] = pos[2] + (pos.y/stepMod)
                original_pos[2] = original_pos[2] + (pos.y/stepMod)
            elseif axis == 'z' then
                pos.z = value
                pos[3] = pos[3] + (pos.z/stepMod)
                original_pos[3] = original_pos[3] + (pos.z/stepMod)
            end
            entity.Visual.Visual.WorldTransform.Translate = {pos[1], pos[2], pos[3]}
            entity.DummyOriginalTransform.Transform.Translate = {original_pos[1], original_pos[2], original_pos[3]}
            for q = 1, #entity.Visual.Visual.Attachments do
                for i = 1, #entity.Visual.Visual.Attachments[q].Visual.ObjectDescs do
                    local objDesc = entity.Visual.Visual.Attachments[q].Visual.ObjectDescs[i]
                    if objDesc and objDesc.Renderable and objDesc.Renderable.WorldTransform then
                        objDesc.Renderable.WorldTransform.Translate = {pos[1], pos[2], pos[3]}
                    end
                end
            end

            for k,v in pairs(Ext.Entity.GetAllEntitiesWithComponent('PhotoModeDummy')) do
                if v.PhotoModeDummy.Entity == _C() then
                    v.PhotoModeDummyTransform.Transform.Translate = {pos[1], pos[2], pos[3]}
                    -- DDump(v.PhotoModeDummyTransform.Transform.Translate)
                end
            end

            -- Ext.Entity.GetAllEntitiesWithComponent('PhotoModeDummy')[4]:GetAllComponents()


            UpdateCharacterInfo(index)
        end
    end
end


function RotateCharacter(axis, value, rotMod, index)
    if LLGlobals.DummyNameMap then
        local entity = LLGlobals.DummyNameMap[E.visTemComob.Options[index]]
        if entity then
            local rot = entity.Visual.Visual.WorldTransform.RotationQuat
            local original_rot = entity.DummyOriginalTransform.Transform.RotationQuat
            local currentQuat = {rot[1], rot[2], rot[3], rot[4]}
            local rotationAngle = value / rotMod
            local axisVec = {0, 0, 0}

            if axis == 'x' then
                axisVec = {1, 0, 0}
            elseif axis == 'y' then
                axisVec = {0, 1, 0}
            elseif axis == 'z' then
                axisVec = {0, 0, 1}
            end
            local quat = Ext.Math.QuatRotateAxisAngle(currentQuat, axisVec, rotationAngle)
            local original_quat = Ext.Math.QuatRotateAxisAngle(original_rot, axisVec, rotationAngle)
            entity.Visual.Visual.WorldTransform.RotationQuat = quat
            entity.DummyOriginalTransform.Transform.RotationQuat = original_quat
            for q = 1, #entity.Visual.Visual.Attachments do
                for i = 1, #entity.Visual.Visual.Attachments[q].Visual.ObjectDescs do
                    local objDesc = entity.Visual.Visual.Attachments[q].Visual.ObjectDescs[i]
                    if objDesc and objDesc.Renderable and objDesc.Renderable.WorldTransform then
                        objDesc.Renderable.WorldTransform.RotationQuat = quat
                    end
                end
            end
            UpdateCharacterInfo(index)
        end
    end
end


function ScaleCharacter(axis, value, scaleMod, index)
    if LLGlobals.DummyNameMap then
        local entity = LLGlobals.DummyNameMap[E.visTemComob.Options[index]]
        if entity then
            local scale = entity.Visual.Visual.WorldTransform.Scale
            local original_scale = entity.DummyOriginalTransform.Transform.Scale
            if axis == 'x' then
                scale.x = value
                scale[1] = scale[1] + (scale.x/scaleMod)
                original_scale[1] = original_scale[1] + (scale.x/scaleMod)
            elseif axis == 'y' then
                scale.y = value
                scale[2] = scale[2] + (scale.y/scaleMod)
                original_scale[2] = original_scale[2] + (scale.y/scaleMod)
            elseif axis == 'z' then
                scale.z = value
                scale[3] = scale[3] + (scale.z/scaleMod)
                original_scale[3] = original_scale[3] + (scale.z/scaleMod)
            elseif axis == 'all' then
                scale.x = value
                scale[1] = scale[1] + (scale.x/scaleMod)
                original_scale[1] = original_scale[1] + (scale.x/scaleMod)
                scale.y = value
                scale[2] = scale[2] + (scale.y/scaleMod)
                original_scale[2] = original_scale[2] + (scale.y/scaleMod)
                scale.z = value
                scale[3] = scale[3] + (scale.z/scaleMod)
                original_scale[3] = original_scale[3] + (scale.z/scaleMod)
            end
            entity.Visual.Visual.WorldTransform.Scale = {scale[1], scale[2], scale[3]}
            entity.DummyOriginalTransform.Transform.Scale = {original_scale[1], original_scale[2], original_scale[3]}
            for q = 1, #entity.Visual.Visual.Attachments do
                for i = 1, #entity.Visual.Visual.Attachments[q].Visual.ObjectDescs do
                    local objDesc = entity.Visual.Visual.Attachments[q].Visual.ObjectDescs[i]
                    if objDesc and objDesc.Renderable and objDesc.Renderable.WorldTransform then
                        objDesc.Renderable.WorldTransform.Scale = {scale[1], scale[2], scale[3]}
                    end
                end
            end
            UpdateCharacterInfo(index)
        end
    end
end



local size = 38
local savedTransforms = {}
local buttons = {}
local buttonCount = 0

--refactored by slop. too lazy
function SaveVisTempCharacterPosition()
    local index = E.visTemComob.SelectedIndex + 1
    local selectedName = E.visTemComob.Options[index]

    if not selectedName or not LLGlobals.DummyNameMap[selectedName] then return end

    local worldTransform = LLGlobals.DummyNameMap[selectedName].Visual.Visual.WorldTransform

    savedTransforms[selectedName] = {
        pos = {worldTransform.Translate[1], worldTransform.Translate[2], worldTransform.Translate[3]},
        rot = {worldTransform.RotationQuat[1], worldTransform.RotationQuat[2], worldTransform.RotationQuat[3], worldTransform.RotationQuat[4]},
        scale = {worldTransform.Scale[1], worldTransform.Scale[2], worldTransform.Scale[3]},
        originalName = selectedName
    }

    local saved = savedTransforms[selectedName]
    local buttonLabel = string.format("%s; x = %.2f; y = %.2f; z = %.2f",
        string.gsub(selectedName, "##.*", ""),
        saved.pos[1], saved.pos[2], saved.pos[3])

    local function LoadTransform()
        -- Получаем ТЕКУЩЕГО выбранного персонажа
        local currentIndex = E.visTemComob.SelectedIndex + 1
        local currentSelectedName = E.visTemComob.Options[currentIndex]

        if not currentSelectedName or not LLGlobals.DummyNameMap[currentSelectedName] then return end

        local dummy = LLGlobals.DummyNameMap[currentSelectedName]

        dummy.Visual.Visual.WorldTransform.Translate = {saved.pos[1], saved.pos[2], saved.pos[3]}
        dummy.Visual.Visual.WorldTransform.RotationQuat = {saved.rot[1], saved.rot[2], saved.rot[3], saved.rot[4]}
        dummy.Visual.Visual.WorldTransform.Scale = {saved.scale[1], saved.scale[2], saved.scale[3]}
        dummy.DummyOriginalTransform.Transform.Translate = {saved.pos[1], saved.pos[2], saved.pos[3]}
        dummy.DummyOriginalTransform.Transform.RotationQuat = {saved.rot[1], saved.rot[2], saved.rot[3], saved.rot[4]}
        dummy.DummyOriginalTransform.Transform.Scale = {saved.scale[1], saved.scale[2], saved.scale[3]}

        UpdateCharacterInfo(currentIndex)
    end

    if buttons[selectedName] then
        buttons[selectedName].load.Label = buttonLabel
        buttons[selectedName].load.OnClick = LoadTransform
    else
        saveLoadWindow.Size = {saveLoadWindow.Size[1], saveLoadWindow.Size[2] + size}
        buttonCount = buttonCount + 1

        local deleteBtn = saveLoadWindow:AddButton('x')
        deleteBtn.IDContext = 'xBtn' .. Ext.Math.Random()
        deleteBtn.OnClick = function()
            buttonCount = buttonCount - 1

            if buttons[selectedName] then
                buttons[selectedName].load:Destroy()
                buttons[selectedName].delete:Destroy()
                buttons[selectedName] = nil
            end

            savedTransforms[selectedName] = nil

            if buttonCount == 0 then
                savedTransforms = {}
                buttons = {}
            end

            saveLoadWindow.Size = {saveLoadWindow.Size[1], saveLoadWindow.Size[2] - size}
        end

        local loadBtn = saveLoadWindow:AddButton(buttonLabel)
        loadBtn.IDContext = 'loadBtn' .. Ext.Math.Random()
        loadBtn.SameLine = true
        loadBtn.OnClick = LoadTransform

        buttons[selectedName] = {delete = deleteBtn, load = loadBtn}
    end
end




function MoveTail(axis, value, stepMod, index)
    local tailVis = nil
    local pos
    if LLGlobals.DummyNameMap[E.visTemComob.Options[index]]and LLGlobals.DummyNameMap[E.visTemComob.Options[index]].Visual then
        for i = 1, #LLGlobals.DummyNameMap[E.visTemComob.Options[index]].Visual.Visual.Attachments do
            if LLGlobals.DummyNameMap[E.visTemComob.Options[index]].Visual.Visual.Attachments[i].Visual.VisualResource.Objects[1].ObjectID:lower():find("tail") then
                pos = LLGlobals.DummyNameMap[E.visTemComob.Options[index]].Visual.Visual.Attachments[i].Visual.WorldTransform.Translate
                tailVis = LLGlobals.DummyNameMap[E.visTemComob.Options[index]].Visual.Visual.Attachments[i]
                break
            end
        end
        if tailVis then
            if axis == 'x' then
                pos.x = value
                pos[1] = pos[1] + (pos.x/stepMod)
            elseif axis == 'y' then
                pos.y = value
                pos[2] = pos[2] + (pos.y/stepMod)
            elseif axis == 'z' then
                pos.z = value
                pos[3] = pos[3] + (pos.z/stepMod)
            end
            tailVis.Visual:SetWorldTranslate({pos[1], pos[2], pos[3]})
        end
    end
end



function RotateTail(axis, value, rotMod, index)
    local tailVis = nil
    if LLGlobals.DummyNameMap[E.visTemComob.Options[index]]and LLGlobals.DummyNameMap[E.visTemComob.Options[index]].Visual then
        for i = 1, #LLGlobals.DummyNameMap[E.visTemComob.Options[index]].Visual.Visual.Attachments do
            if LLGlobals.DummyNameMap[E.visTemComob.Options[index]].Visual.Visual.Attachments[i].Visual.VisualResource.Objects[1].ObjectID:lower():find("tail") then
                tailVis = LLGlobals.DummyNameMap[E.visTemComob.Options[index]].Visual.Visual.Attachments[i]
                break
            end
        end
        if tailVis then
            local rot = tailVis.Visual.WorldTransform.RotationQuat
            local currentQuat = {rot[1], rot[2], rot[3], rot[4]}

            local rotationAngle = value / rotMod
            local axisVec = {0, 0, 0}

            if axis == 'x' then
                axisVec = {1, 0, 0}
            elseif axis == 'y' then
                axisVec = {0, 1, 0}
            elseif axis == 'z' then
                axisVec = {0, 0, 1}
            end
            local quat = Ext.Math.QuatRotateAxisAngle(currentQuat, axisVec, rotationAngle)
            tailVis.Visual:SetWorldRotate(quat)
        end
    end
end




function MoveHorns(axis, value, stepMod, index)
    local tailVis = nil
    local pos
    if LLGlobals.DummyNameMap[E.visTemComob.Options[index]]and LLGlobals.DummyNameMap[E.visTemComob.Options[index]].Visual then
        for i = 1, #LLGlobals.DummyNameMap[E.visTemComob.Options[index]].Visual.Visual.Attachments do
            if LLGlobals.DummyNameMap[E.visTemComob.Options[index]].Visual.Visual.Attachments[i].Visual.VisualResource.Objects[1].ObjectID:lower():find("horns") then
                pos = LLGlobals.DummyNameMap[E.visTemComob.Options[index]].Visual.Visual.Attachments[i].Visual.WorldTransform.Translate
                tailVis = LLGlobals.DummyNameMap[E.visTemComob.Options[index]].Visual.Visual.Attachments[i]
                break
            end
        end
        if tailVis then
            if axis == 'x' then
                pos.x = value
                pos[1] = pos[1] + (pos.x/stepMod)
            elseif axis == 'y' then
                pos.y = value
                pos[2] = pos[2] + (pos.y/stepMod)
            elseif axis == 'z' then
                pos.z = value
                pos[3] = pos[3] + (pos.z/stepMod)
            end
            tailVis.Visual:SetWorldTranslate({pos[1], pos[2], pos[3]})
        end
    end
end



function RotateHorns(axis, value, rotMod, index)
    local tailVis = nil
    if LLGlobals.DummyNameMap[E.visTemComob.Options[index]]and LLGlobals.DummyNameMap[E.visTemComob.Options[index]].Visual then
        for i = 1, #LLGlobals.DummyNameMap[E.visTemComob.Options[index]].Visual.Visual.Attachments do
            if LLGlobals.DummyNameMap[E.visTemComob.Options[index]].Visual.Visual.Attachments[i].Visual.VisualResource.Objects[1].ObjectID:lower():find("horns") then
                tailVis = LLGlobals.DummyNameMap[E.visTemComob.Options[index]].Visual.Visual.Attachments[i]
                break
            end
        end
        if tailVis then
            local rot = tailVis.Visual.WorldTransform.RotationQuat
            local currentQuat = {rot[1], rot[2], rot[3], rot[4]}
            local rotationAngle = value / rotMod
            local axisVec = {0, 0, 0}
            if axis == 'x' then
                axisVec = {1, 0, 0}
            elseif axis == 'y' then
                axisVec = {0, 1, 0}
            elseif axis == 'z' then
                axisVec = {0, 0, 1}
            end
            local quat = Ext.Math.QuatRotateAxisAngle(currentQuat, axisVec, rotationAngle)
            tailVis.Visual:SetWorldRotate(quat)
        end
    end
end



function DisableVFXEffects(isChecked)
    if vfxSubscription then
        Ext.Events.Tick:Unsubscribe(vfxSubscription)
        vfxSubscription = nil
    end

    if not isChecked then
        return
    end

    vfxSubscription = Ext.Events.Tick:Subscribe(function()
        local effects = Ext.Entity.GetAllEntitiesWithComponent("Effect")
        for _, entity in ipairs(effects) do
            if entity.Effect and string.find(entity.Effect.EffectName, "VFX_") then
                local components = entity.Effect.Timeline.Components
                if components then
                    for _, component in ipairs(components) do
                        for property, values in pairs(component.Properties) do
                            if values.FullName == "Radial Blur.Opacity" then
                                for _, keyFrame in ipairs(values.KeyFrames) do
                                    if keyFrame.Frames then
                                        for _, frame in ipairs(keyFrame.Frames) do
                                            if frame then
                                                local success, value = pcall(function() return frame.Value end)
                                                if success then
                                                    frame.Value = 0
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            if values.FullName == "Falloff Start-End" then
                                values.Min = 0
                                values.Max = 0
                            end
                        end
                    end
                end
            end
        end
        tickCounter = tickCounter + 1
    end)
end


function StartFollowIGCS()
    Utils:SubUnsubToTick('sub', 'look', function ()
        local camera = Camera:GetActiveCamera()
        local Transform = camera.Transform.Transform
        Camera:GetPhotoModeCamera().PhotoModeCameraTransform.Transform = Transform
    end)
end



function StopFollowIGCS()
    if Utils.subID and Utils.subID['look'] then
        Utils:SubUnsubToTick('unsub', 'look', _)
    end
    E.checkFollowIGCS.Checked = false
end



Ext.RegisterConsoleCommand('look', function (cmd, ...)
    Utils:SubUnsubToTick('sub', 'look', function ()
        local Transform = Camera:GetActiveCamera().Transform.Transform
        Camera:GetPhotoModeCamera().PhotoModeCameraTransform.Transform = Transform
    end)
end)



Ext.RegisterConsoleCommand('looks', function (cmd, ...)
    Utils:SubUnsubToTick('unsub', 'look', _)
end)





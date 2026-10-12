_GLL.CameraPositions = {}
_GLL.DummyNameMap    = {}
_GLL.SaveLoad        = {}
_GLL.OrbitDragValues = {}
_GLL.RotDragValues   = {}

DRAG_SENSE = 100


local EnumFuncType = {
    [0] = 'Linear',
    [1] = 'Inv sqr',
    [2] = 'SmoothStep',
    [3] = 'SmootherStep',
}


local EnumChannelType = {
    [1] = 'Character + world',
    [2] = 'Character',
    [3] = 'World',
}


local EnumChannelBits = {
    [1] = 255,
    [2] = 32,
    [3] = 1,
}


local EnumLighType = {
    [0] = 'Point',
    [1] = 'Spotlight',
    [2] = 'Directional',
}


local EnumLighTypeDecypher = {
    ['Point']     = 'Point',
    ['Spot']      = 'Spotlight',
    ['Direction'] = 'Directional',
}


Ch.WhenLevelGameplayStarted:SetHandler(function(Data)
    Helpers.Timer:OnTicks(100, function()
        if POGGERS then
            _GLL.SourceTranslate = getSourcePositionCl()
            Ext.Stats.GetStatsManager().ExtraData["PhotoModeCameraFloorDistance"] = -99887766
            Ext.Stats.GetStatsManager().ExtraData["PhotoModeCameraRange"] = 11223344
            CharacterLightSetupState(Settings.lightSetupState)
            DisplayBlockedLevel()
        end
    end)
end)



Ext.Events.ResetCompleted:Subscribe(function()
    Helpers.Timer:OnTicks(100, function()
        _GLL.SourceTranslate = getSourcePositionCl()
    end)
    CharacterLightSetupState(Settings.lightSetupState)
    -- DisplayBlockedLevel()
end)



function getSelectedUuid()
    if _GLL.LightsUuidNameMap
        and E.comboIHateCombos.SelectedIndex
        and E.comboIHateCombos.Options[E.comboIHateCombos.SelectedIndex + 1]
    then
        for _, light in pairs(_GLL.LightsUuidNameMap) do
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
    if entity
        and entity.Effect and entity.Effect.Timeline
        and entity.Effect.Timeline.Components[2]
        and entity.Effect.Timeline.Components[2].LightEntity
        and entity.Effect.Timeline.Components[2].LightEntity.Light
    then
    return entity.Effect.Timeline.Components[2].LightEntity.Light end
end



function getSelectedLightName()
    return E.comboIHateCombos.Options[E.comboIHateCombos.SelectedIndex + 1]
end



function getSelectedLightType()
    local entity = getSelectedLightEntity()
    if not entity then return end
    local lightType = entity.LightType
    return EnumLighTypeDecypher[lightType]
end



function getLightEntity(uuid)
    local entity = Ext.Entity.Get(uuid)
    if entity and entity.Effect and entity.Effect.Timeline then
        return entity.Effect.Timeline.Components[2].LightEntity.Light
    end
end



function getDummyOwnerUuid(entity)
    if entity and entity.Dummy then
        local characterUuid = entity.Dummy.Entity.Uuid.EntityUuid
        if characterUuid then
            return characterUuid
        end
    end
end



function getSelectedDummy()
    if not _GLL.DummyNameMap then return end
    if selectedCharacter
        and _GLL.DummyNameMap
        and E.cmbBoneDummies.Options[selectedCharacter]
        and _GLL.DummyNameMap[E.cmbBoneDummies.Options[selectedCharacter]]
    then
        local entity = _GLL.DummyNameMap[E.cmbBoneDummies.Options[selectedCharacter]]
        return entity
    end
end



function getSelectedDummyOwnerUuid()
    -- DPrint('getSelectedDummyOwnerUuid')
    -- DPrint('_GLL.DummyNameMap')
    -- DDump(_GLL.DummyNameMap)
    -- DPrint('E.cmbBoneDummies.Options')
    -- DDump(E.cmbBoneDummies.Options)
    -- DPrint('selectedCharacter')
    -- DDump(selectedCharacter)
    if selectedCharacter
        and _GLL.DummyNameMap
        and E.cmbBoneDummies.Options[selectedCharacter]
        and _GLL.DummyNameMap[E.cmbBoneDummies.Options[selectedCharacter]]
    then
        local entity = _GLL.DummyNameMap[E.cmbBoneDummies.Options[selectedCharacter]]
        if entity then
            local characterUuid = entity.Dummy.Entity.Uuid.EntityUuid
            if characterUuid then
                return characterUuid
            end
        end
    end
end



function SelectLight()
    if not getSelectedEntity() then return end

    _GLL.selectedEntity    = getSelectedEntity()
    _GLL.selectedUuid      = getSelectedUuid()
    _GLL.selectedLightType = getSelectedLightType()

    Ch.SelectedLight:SendToServer(_GLL.selectedUuid)

    UpdateCreatedLightsCombo()
    UpdateElements(_GLL.selectedUuid)

    local x,y,z    = table.unpack(_GLL.selectedEntity.Transform.Transform.Translate)
    local rx,ry,rz = table.unpack(Helpers.Math.QuatToEuler(_GLL.selectedEntity.Transform.Transform.RotationQuat))

    UpdateTranformInfo(x,y,z,rx,ry,rz)
end



Ext.RegisterConsoleCommand('llparams', function (cmd, ...)
    DPrint('All lights parameters -----------------------')
    DDump(_GLL.LightParametersClient)
end)



function UpdateCreatedLightsCombo()
    _GLL.LightsNames = {}

    for _, light in pairs(_GLL.LightsUuidNameMap) do
        table.insert(_GLL.LightsNames, light.name)
    end

    E.comboIHateCombos.Options  = _GLL.LightsNames
    E.comboIHateCombos2.Options = _GLL.LightsNames

    Helpers.Timer:OnTicks(5, function ()
        local lightName = getSelectedLightName() or 'None'
        if lightName then selectedLightNotification.Label = lightName end
    end)
end



function RegisterNewLight(uuid, lightType)
    nameIndex = nameIndex + 1
    local name = '+' .. ' ' .. '#' .. nameIndex .. ' ' .. lightType

    table.insert(_GLL.LightsUuidNameMap, {
        -- uuid = _GLL.CreatedLightsServer[uuid],
        uuid = uuid,
        name = name,
        nameIndex = nameIndex
    })

    UpdateCreatedLightsCombo()
    E.comboIHateCombos.SelectedIndex = #E.comboIHateCombos.Options - 1
end



function UpdateTranformInfo(x, y, z, rx, ry, rz)
    textPositionInfo.Label = string.format('x: %.2f, y: %.2f, z: %.2f', x, y, z)
    textRotationInfo.Label = string.format('pitch: %.2f, roll: %.2f, yaw: %.2f', rx, rz, ry)
end



function getSourcePositionCl()
    local source

    if E.checkOriginSrc and E.checkOriginSrc.Checked then
        source = 'Origin'
        return SourcePoint(true), source

    elseif _GLL.States.inPhotoMode then
        source = 'Dummy'
        return SourcePhotoMode(true), source

    elseif E.checkClientSrc and E.checkClientSrc.Checked then
        source = 'Client'
        return SourceClient(true), source

    elseif E.checkCutsceneSrc and E.checkCutsceneSrc.Checked then
        source = 'Cutscene'
        return _C().Transform.Transform.Translate, source
        -- return SourceCutscene(true), source

    else
        source = 'Else'
        return _C().Transform.Transform.Translate, source
    end
end



lightType = Settings.defaultLightType ---TBD: remove this

-- local xd = 0

function CreateLight(uuid)
    AntiSpamOnTicks(10, function()
        _GLL.States.allowLightCreation = false
        E.btnCreate2.Disabled = true

        local Position, source = getSourcePositionCl()
        if not Position then DPrint('No position, type: %s', source) end

        local Data = {
            uuid = uuid or nil,
            lightType = lightType or 'Point',
            Position  = Position,
        }

        Ch.CreateLight:RequestToServer(Data, function(Response)
            _GLL.CreatedLightsServer = Response[1]
            _GLL.selectedUuid        = Response[2]
            _GLL.markerUuid          = Response[3]

            local s, err = pcall(function()
                -- xd = xd + 1
                -- if xd == 5 then
                --     assert(false)
                -- end

                if not Response then
                    _GLL.States.allowLightCreation = true
                    -- E.btnCreate2.Disabled = false
                    return
                end

                Helpers.Timer:OnTicks(10 + Settings.lightCreateDelay, function()
                    _GLL.LightParametersClient[_GLL.selectedUuid] = {}
                    _GLL.selectedEntity = Ext.Entity.Get(_GLL.selectedUuid)



                    Helpers.Timer:OnTicks(8 + Settings.lightCreateDelay, function()
                        local Types = {Spotlight = 1, Directional = 2}
                        SetLightType(Types[lightType] or 0)
                        _GLL.selectedLightType = lightType
                    end)

                    RegisterNewLight(_GLL.selectedUuid, lightType)

                    if Settings.stickToggleOff and Utils.subID and Utils.subID['Stick'] then
                        E.checkStick.Checked = false
                        StickToCamera()
                    end

                    Helpers.Timer:OnTicks(10 + Settings.lightCreateDelay, function()
                        if Position then
                            local x, y, z = table.unpack(Position)
                            UpdateElements(_GLL.selectedUuid)
                            UpdateTranformInfo(x, y, z, 90, 0, 0)
                            _GLL.States.allowLightCreation = true
                            E.btnCreate2.Disabled = false
                            if Settings.markerOff then ToggleMarker(_GLL.markerUuid) end
                        else
                            local txtError = E.grpErr:AddText('An error occured. No position found.')
                            OnTicks(200, function()
                                Imgui.ClearChildren(E.grpErr)
                            end)
                            Ch.Source:SendToServer(getSourcePositionCl())
                        end
                    end)
                end)
            end)
            if s then
                Imgui.ClearChildren(E.grpErr)
            end
            if err then
                DPrint('NO LIGTH CREATED NOT XD')
                local txtError = E.grpErr:AddText('An error occured. The game cant keep up.')
                DeleteLightJank(Response[2])
                _GLL.States.allowLightCreation = true
                E.btnCreate2.Disabled = false
                DDump(err)
                OnTicks(200, function()
                    Imgui.ClearChildren(E.grpErr)
                end)
            end
        end)
        OnTicks(100, function()
            _GLL.States.allowLightCreation = true
            E.btnCreate2.Disabled = false
        end)
    end)
end



--- TBD: remove some DUPLICATIONS HAHAHAHAH GET IT????? LMAOOOOOOOOOOOOOOOOOO
function DuplicateLight()
    AntiSpamOnTicks(10, function()
        if _GLL.States.allowLightCreation and _GLL.selectedUuid then
            _GLL.States.allowLightCreation = false
            E.btnCreate2.Disabled = true

            local prevoiusUuid = _GLL.selectedUuid
            local OrigLight = _GLL.LightParametersClient[prevoiusUuid]

            Ch.DuplicateLight:RequestToServer(Data, function (Response)
                local s, err = pcall(function()
                    _GLL.selectedUuid = Response[2]
                    if Response then
                        _GLL.CreatedLightsServer = Response[1]
                        _GLL.LightParametersClient[_GLL.selectedUuid] = _GLL.LightParametersClient[_GLL.selectedUuid] or {}
                        local lightTypeOld = OrigLight.LightType

                        -- if lightTypeOld == 1 then
                        --    lightTypeOld = 'Spotlight'
                        -- elseif lightTypeOld == 2 then
                        --     lightTypeOld = 'Directional'
                        -- else
                        --     lightTypeOld = 'Point'
                        -- end

                        RegisterNewLight(_GLL.selectedUuid, EnumLighType[lightTypeOld])

                        Helpers.Timer:OnTicks(15, function ()
                            _GLL.selectedEntity = Ext.Entity.Get(_GLL.selectedUuid)

                            --- TBD: perhaps as a separate function? But what's the point?

                            SetLightType(OrigLight.LightType)
                            SetLightColor(OrigLight.Color)
                            SetLightIntensity(OrigLight.Intensity)
                            SetLightRadius(OrigLight.Radius)
                            SetLightOuterAngle(OrigLight.SpotLightOuterAngle)
                            SetLightInnerAngle(OrigLight.SpotLightInnerAngle)

                            SetLightDirectionalParameters('DirectionLightAttenuationEnd', OrigLight.DirectionLightAttenuationEnd)
                            SetLightDirectionalParameters('DirectionLightAttenuationFunction', OrigLight.DirectionLightAttenuationFunction)
                            SetLightDirectionalParameters('DirectionLightAttenuationSide', OrigLight.DirectionLightAttenuationSide)
                            SetLightDirectionalParameters('DirectionLightAttenuationSide2', OrigLight.DirectionLightAttenuationSide2)
                            SetLightDirectionalParameters('DirectionLightDimensions', OrigLight.DirectionLightDimensions)


                            SetLightFill(OrigLight.Flags)
                            SetLightScattering(OrigLight.ScatteringIntensityScale)
                            SetLightEdgeSharp(OrigLight.EdgeSharpening)

                            SetLightChannel(OrigLight.SliderLightChannelFlag)
                        end)

                        if Settings.stickToggleOff and Utils.subID and Utils.subID['Stick'] then
                            E.checkStick.Checked = false
                            StickToCamera()
                        end

                        local x,y,z     = table.unpack(Response[3].Translate)
                        local rx,ry,rz  = table.unpack(Response[3].HumanRotation)
                        local OrigOrbit = _GLL.OrbitDragValues[prevoiusUuid]
                        local OrigRot   = _GLL.RotDragValues[prevoiusUuid]

                        if OrigOrbit then
                            _GLL.OrbitDragValues[_GLL.selectedUuid] = {OrigOrbit[1], OrigOrbit[2], OrigOrbit[3]}
                        end

                        if OrigRot then
                            _GLL.RotDragValues[_GLL.selectedUuid] = {OrigRot[1], OrigRot[2], OrigRot[3]}
                        end

                        OnTicks(25, function ()
                            UpdateElements(_GLL.selectedUuid)
                            UpdateTranformInfo(x, y, z, rx, ry, rz)
                            OnTicks(10, function()
                                _GLL.States.allowLightCreation = true
                                E.btnCreate2.Disabled = false
                            end)
                        end)
                    end
                end)
                if s then
                    Imgui.ClearChildren(E.grpErr)
                end
                if err then
                    DPrint('NO LIGTH CREATED NOT XD')
                    local txtError = E.grpErr:AddText('An error occured. Last light was no')
                    OnTicks(200, function()
                        Imgui.ClearChildren(E.grpErr)
                    end)
                    DPrint(Response[2])
                    DeleteLightJank(Response[2])
                    _GLL.States.allowLightCreation = true
                    E.btnCreate2.Disabled = false
                    DDump(err)
                end
            end)
            OnTicks(100, function()
                _GLL.States.allowLightCreation = true
                E.btnCreate2.Disabled = false
            end)
        end
    end)
end


function DeleteLight(uuid)
    local uuid = uuid or _GLL.selectedUuid
    if not uuid then return end

    local uuidToDelete = uuid
    local selectedName = getSelectedLightName()

    Ch.DeleteGobo:SendToServer('Single')
    _GLL.CreatedLightsServer[uuidToDelete]    = nil
    _GLL.LightParametersClient[uuidToDelete]  = nil

    for k, light in pairs(_GLL.LightsUuidNameMap) do
        if light.name == selectedName then
            table.remove(_GLL.LightsUuidNameMap, k)
        end
    end

    for k, light in pairs(_GLL.LightsNames) do
        if light == selectedName then
            _GLL.LightsNames[k] = nil
        end
    end

    UpdateCreatedLightsCombo()

    E.comboIHateCombos.SelectedIndex = E.comboIHateCombos.SelectedIndex - 1
    if E.comboIHateCombos.SelectedIndex < 0 then
        E.comboIHateCombos.SelectedIndex = 0
    end

    if E.comboIHateCombos.Options and #E.comboIHateCombos.Options > 0 then
        local uuid_ = getSelectedUuid()
        if uuid_ then
            SelectLight()
        else
            _GLL.selectedUuid   = nil
            _GLL.selectedEntity = nil
            _GLL.markerUuid     = nil
            _GLL.markerEntity   = nil
        end
    else
        _GLL.selectedUuid   = nil
        _GLL.selectedEntity = nil
        _GLL.markerUuid     = nil
        _GLL.markerEntity   = nil
        nameIndex = 0
        UpdateTranformInfo(0, 0, 0, 0, 0, 0)
    end

    Ch.DeleteLight:SendToServer(uuidToDelete)
    Ch.SelectedLight:SendToServer(_GLL.selectedUuid)
end



function DeleteLightJank(uuid)
    if not uuid then return end

    local uuidToDelete = uuid
    local selectedName = getSelectedLightName()

    _GLL.CreatedLightsServer[uuidToDelete]    = nil
    _GLL.LightParametersClient[uuidToDelete]  = nil
    Ch.DeleteLight:SendToServer(uuidToDelete)
end



Ch.CurrentEntityTransform:SetHandler(function (Data)
    local rx, ry, rz = table.unpack(Data.HumanRotation)
    local x,y,z = table.unpack(Data.Translate)
    UpdateTranformInfo(x, y, z, rx, ry, rz)

    local ry = ry % 360
    if ry < 0 then ry = ry + 360 end

    _GLL.RotDragValues[Data.lightUuid or _GLL.selectedUuid] = {rx, ry, rz}

    E.slRotTiltSlider.Value = {rx, 0, 0, 0}
    E.slRotYawSlider.Value  = {ry, 0, 0, 0}
    E.slRotRollSlider.Value = {rz, 0, 0, 0}
end)



Ch.CurrentOrbit:SetHandler(function(Data)
    local angle = Data[1] % 360
    if angle < 0 then angle = angle + 360 end

    _GLL.OrbitDragValues[Data[4] or _GLL.selectedUuid] = {angle, Data[3]*100, Data[2]*100}

    E.slPosOrbX.Value = {angle, 0,0,0}
    E.slPosOrbZ.Value = {Data[2]*100, 0,0,0}
    E.slPosOrbY.Value = {Data[3]*100, 0,0,0}
end)



function GatherLightsAndMarkers()
    local EntitiesToDelete = {}
    local Guido = {
        'a0d2ac1c','c1c8b026','4eab6f6d', '13c358b1', '34329d13',
        '0435655f', '213674c9', 'fc270e8b', '1b86fb4a','08a26239',
        'e6748263','62a459e2', 'cabc9b70', 'ee3cf097',
    }

    local GOV = Ext.Entity.GetAllEntitiesWithComponent('GameObjectVisual')
    for _, entity in ipairs(GOV) do
        for _, guid in pairs(Guido) do
            if entity.GameObjectVisual.RootTemplateId:find(guid) then
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
    Ch.DeleteEverything:SendToServer(EntitiesToDelete)
end



function UpdateElements(selectedUuid)
    if not selectedUuid then return end

    local Light = _GLL.LightParametersClient[selectedUuid]

    if Light then
        E.slIntLightType.Value    = {Light.LightType or 0, 0, 0, 0}
        local Color               = Light and Light.Color
        E.pickerLightColor.Color  = Color and {Color[1], Color[2], Color[3], 1} or {1, 1, 1, 1}
        E.slLightIntensity.Value  = {Light.Intensity or 1, 0, 0, 0}
        E.slLightTemp.Value       = {Light.Temperature or 5600, 0, 0, 0}
        E.slLightRadius.Value     = {Light.Radius and Light.Radius*DRAG_SENSE or DRAG_SENSE, 0, 0, 0}
        E.slLightDirEnd.Value     = {Light.DirectionLightAttenuationEnd or 0, 0, 0, 0}
        E.slIntLightDirFunc.Value = {Light.DirectionLightAttenuationFunction or 0, 0, 0, 0}
        local lightType           = E.slIntLightType.Value[1]

        if lightType == 2 then
            local value = E.slIntLightDirFunc.Value[1]
             --- TBD: use enums
            -- if value == 0 then funcType = 'Linear' end
            -- if value == 1 then funcType = 'Inv sqr' end
            -- if value == 2 then funcType = 'SmoothStep' end
            -- if value == 3 then funcType = 'SmootherStep' end
            textFunc.Label = EnumFuncType[value]
        else
            textFunc.Label = 'Attenuation'
        end

        E.slLightDirSide.Value    = {Light.DirectionLightAttenuationSide or 0, 0, 0, 0}
        E.slLightDirSide2.Value   = {Light.DirectionLightAttenuationSide2 or 0, 0, 0, 0}
        local Dim                 = Light and Light.DirectionLightDimensions
        E.slLightDirDim.Value     = Dim and {Dim[1], Dim[2], Dim[3], 0} or {5, 5, 15, 0}
        E.slLightOuterAngle.Value = {Light.SpotLightOuterAngle or 45, 0, 0, 0}
        E.slLightInnerAngle.Value = {Light.SpotLightInnerAngle or 1, 0, 0, 0}
        E.checkLightFill.Checked  = (Light.Flags or 184) == 184
        E.checkLightChannel.Value = {Light.SliderLightChannelFlag or 1, 0, 0, 0}
        local value               = E.checkLightChannel.Value[1]

         --- TBD: use enums
        -- if value == 1 then channelType = 'Character + world' end
        -- if value == 2 then channelType = 'Character' end
        -- if value == 3 then channelType = 'World' end
        textChannel.Label = EnumChannelType[value]

        E.slLightScattering.Value = {Light.ScatteringIntensityScale and Light.ScatteringIntensityScale*DRAG_SENSE or 0, 0, 0, 0}
        E.slLightEdgeSharp.Value  = {Light.EdgeSharpening or 0, 0, 0, 0}

        local OrbDrag = _GLL.OrbitDragValues[selectedUuid] or {0, 200, 0}

        E.slPosOrbX.Value = {OrbDrag[1], 0, 0, 0}
        E.slPosOrbY.Value = {OrbDrag[2], 0, 0, 0}
        E.slPosOrbZ.Value = {OrbDrag[3], 0, 0, 0}

        local RotDrag = _GLL.RotDragValues[selectedUuid] or {0,0,0}
        E.slRotTiltSlider.Value = {RotDrag[1], 0, 0, 0}
        E.slRotYawSlider.Value  = {RotDrag[2], 0, 0, 0}
        E.slRotRollSlider.Value = {RotDrag[3], 0, 0, 0}

        ColorizeMarkers()
    end
end



function UpdateVisibilityStateToNames(lightName, state)
    for _, light in pairs(_GLL.LightsUuidNameMap) do
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



function ColorizeMarkers(Color)
    if not Settings.colorfulMarkers then return end
    local entity = getSelectedLightEntity()
    if entity then
        local Color = Color or entity and entity.Color
        local marker = _GLL.markerEntity
        if marker and marker.Visual and marker.Visual.Visual then
            marker.Visual.Visual.ObjectDescs[1].Renderable.ActiveMaterial:SetVector3('GlowColor', Color)
        end
    end
end



Ch.MarkerHandler:SetHandler(function (Data)
    Helpers.Timer:OnTicks(15, function ()
        _GLL.markerEntity = Ext.Entity.Get(Data)
        if _GLL.markerEntity and Entity:hasVisual(_GLL.markerEntity) then
            _GLL.markerEntity.Visual.Visual:SetWorldScale({Settings.markerScale, Settings.markerScale, Settings.markerScale})
        end
    end)
end)



_GLL.States.markerToggled = false

function ToggleMarker(uuid)
    local newScaleX
    local entity = Ext.Entity.Get(uuid)

    if entity and entity.Visual then
        local scaleX = entity.Visual.Visual.WorldTransform.Scale[1]
        newScaleX = scaleX == 0 and Settings.markerScale or 0
        entity.Visual.Visual:SetWorldScale({newScaleX,newScaleX,newScaleX})
        _GLL.States.markerToggled = not _GLL.States.markerToggled
    end
end



function ToggleOrigin(uuid)
    local newScaleX
    local entity = Ext.Entity.Get(uuid)

    if entity and entity.Visual then
        local scaleX = entity.Visual.Visual.WorldTransform.Scale[1]
        newScaleX = scaleX == 0 and 1 or 0
        entity.Visual.Visual:SetWorldScale({newScaleX,newScaleX,newScaleX})
    end
end



function SetLightType(value)
    local lightEntity = getSelectedLightEntity()
    if lightEntity and lightEntity.LightType and value then
        lightEntity.LightType = value
        if _GLL.selectedUuid
            and _GLL.LightParametersClient[_GLL.selectedUuid]
        then
            _GLL.LightParametersClient[_GLL.selectedUuid].LightType = value
        end
    end
end



function SetLightColor(value)
    local lightEntity = getSelectedLightEntity()
    if lightEntity and lightEntity.Color and value then
        lightEntity.Color = value
        _GLL.LightParametersClient[_GLL.selectedUuid].Color = value
        ColorizeMarkers()
    end
end



function SetLightIntensity(value)
    if value and _GLL.selectedEntity.Effect and _GLL.selectedEntity.Effect.EffectResource then
        _GLL.selectedEntity.Effect.EffectResource.Constructor.EffectComponents[1].Properties['Appearance.Intensity'].KeyFrames[1].Frames[1].Value = value
        _GLL.selectedEntity.Effect.EffectResource.Constructor.EffectComponents[1].Properties['Appearance.Intensity'].KeyFrames[1].Frames[2].Value = value
        _GLL.LightParametersClient[_GLL.selectedUuid].Intensity = value
    end
end



function SetLightRadius(value)
    if value and _GLL.selectedEntity.Effect and _GLL.selectedEntity.Effect.EffectResource then
        _GLL.selectedEntity.Effect.EffectResource.Constructor.EffectComponents[1].Properties['Appearance.Radius'].KeyFrames[1].Frames[1].Value = value
        _GLL.selectedEntity.Effect.EffectResource.Constructor.EffectComponents[1].Properties['Appearance.Radius'].KeyFrames[1].Frames[2].Value = value
        _GLL.LightParametersClient[_GLL.selectedUuid].Radius = value
    end
end



function SetLightOuterAngle(value)
    local lightEntity = getSelectedLightEntity()
    if lightEntity and value then
        lightEntity.SpotLightOuterAngle = value
        _GLL.LightParametersClient[_GLL.selectedUuid].SpotLightOuterAngle = value
    end
end



function SetLightInnerAngle(value)
    local lightEntity = getSelectedLightEntity()
    if lightEntity and value then
        lightEntity.SpotLightInnerAngle = value
        _GLL.LightParametersClient[_GLL.selectedUuid].SpotLightInnerAngle = value
    end
end



function SetLightDirectionalParameters(parameter, value)
    local lightEntity = getSelectedLightEntity()
    if lightEntity and value then
        if parameter == 'DirectionLightAttenuationEnd' then
            lightEntity.DirectionLightAttenuationEnd = value

        elseif parameter == 'DirectionLightAttenuationFunction' then
            lightEntity.DirectionLightAttenuationFunction = value


            --- TBD: use enums
            -- if value == 0 then funcType = 'Linear' end
            -- if value == 1 then funcType = 'Inv sqr' end
            -- if value == 2 then funcType = 'SmoothStep' end
            -- if value == 3 then funcType = 'SmootherStep' end

            textFunc.Label = EnumFuncType[value]

        elseif parameter == 'DirectionLightAttenuationSide' then
            lightEntity.DirectionLightAttenuationSide = value
        elseif parameter == 'DirectionLightAttenuationSide2' then
            lightEntity.DirectionLightAttenuationSide2 = value
        elseif parameter == 'DirectionLightDimensions' then
            lightEntity.DirectionLightDimensions = value
        end
        _GLL.LightParametersClient[_GLL.selectedUuid][parameter] = value
    end
end



function SetLightFill(value)
    local lightEntity = getSelectedLightEntity()
    if lightEntity and value then
        lightEntity.Flags = value
        _GLL.LightParametersClient[_GLL.selectedUuid].Flags = value
    end
end


--- TBD: figure flags
function SetLightChannel(value)
    local lightEntity = getSelectedLightEntity()
    if lightEntity and value then
        _GLL.LightParametersClient[_GLL.selectedUuid].SliderLightChannelFlag = value
         --- TBD: use enums

        textChannel.Label = EnumChannelType[value]

        -- if value == 1 then
        --     value = 255
        -- end
        -- if value == 2 then
        --     value = 32
        -- end
        -- if value == 3 then
        --     value = 1
        -- end

        lightEntity.LightChannelFlag = EnumChannelBits[value]
        _GLL.LightParametersClient[_GLL.selectedUuid].LightChannelFlag = EnumChannelBits[value]
    end
end



function SetLightScattering(value)
    local lightEntity = getSelectedLightEntity()
    if lightEntity and value then
        lightEntity.ScatteringIntensityScale = value
        _GLL.LightParametersClient[_GLL.selectedUuid].ScatteringIntensityScale = value
    end
end



function MoveEntity(entity, axis, offset, step, mode, objectType)
    if entity then
        -- Ch.Source:SendToServer(getSourcePositionCl())
        local Data = {
            axis = axis,
            step = step,
            offset = offset,
            lightUuid = entity.Uuid.EntityUuid,
            SourceTranslate = getSourcePositionCl()
        }

        if objectType == 'Light' then
            if mode == 'World' then
                Ch.EntityTranslate:SendToServer(Data)
            else -- 'Orbit' Character relatve
                Ch.EntityRotationOrbit:SendToServer(Data)
            end
        elseif objectType == 'Point' then
            Ch.MoveOriginPoint:SendToServer(Data)
        end
    end
end



function RotateEntity(entity, axis, offset, step, objectType)
    if entity then
        -- Ch.Source:SendToServer(getSourcePositionCl())
        if objectType == 'Light' then
            Ch.EntityRotation:SendToServer({
                axis = axis,
                step = step,
                offset = offset,
                lightUuid = entity.Uuid.EntityUuid,
                SourceTranslate = getSourcePositionCl()
            })

        elseif objectType == 'Point' then
        elseif objectType == 'Gobo' then
        end
    end
end



function RotateEntityAbs(entity, rx, ry, rz)
    if entity then
        -- Ch.Source:SendToServer(getSourcePositionCl())
        Ch.EntityRotation:SendToServer({
            absolute  = true,
            rx        = rx,
            ry        = ry,
            rz        = rz,
            lightUuid = entity.Uuid.EntityUuid,
            SourceTranslate = getSourcePositionCl(),
        })
    end
end



Ch.Source:SetRequestHandler(function()
    -- DPrint('Ch.Source:SetRequestHandler')
    -- DDump(_GLL.SourceTranslate)
    return _GLL.SourceTranslate
end)



function SourceCutscene(state)
    -- E.checkPMSrc.Checked = false
    E.checkClientSrc.Checked = false
    E.checkOriginSrc.Checked = false
    local entity = Dummy:TLPreviewDummyPlayer()
    if state and entity then
        -- DPrint('CUT: Getting position from cutscene')
        _GLL.SourceTranslate = entity.Transform.Transform.Translate
        -- Ch.Source:SendToServer(_GLL.SourceTranslate)
    else
        -- DPrint('CUT: Fallback to _C()')
        _GLL.SourceTranslate = _C().Transform.Transform.Translate
        -- Ch.Source:SendToServer(_GLL.SourceTranslate)
    end
    -- DDump(_GLL.SourceTranslate)
    return _GLL.SourceTranslate
end



function SourcePoint(state)
    local entity = _GLL.pointEntity

    if state and entity then
        -- E.checkPMSrc.Checked = false
        E.checkClientSrc.Checked = false
        E.checkCutsceneSrc.Checked = false
        -- TBD: [string "LighterLightyLights/Client/Main/MainHandlersC..."]:976: attempt to index a nil value (field 'Transform')
        -- DPrint('POINT: Getting position from origin')
        _GLL.SourceTranslate = entity.Transform.Transform.Translate
        -- Ch.Source:SendToServer(_GLL.SourceTranslate)
    else
        -- DPrint('POINT: Fallback to _C()')
        E.checkOriginSrc.Checked = false
        _GLL.SourceTranslate = _C().Transform.Transform.Translate
        -- Ch.Source:SendToServer(_GLL.SourceTranslate)
    end
    -- DDump(_GLL.SourceTranslate)
    return _GLL.SourceTranslate
end



function SourcePhotoMode(state)
    -- if not _GLL.DummyNameMap then E.checkPMSrc.Checked = false return end
    if not _GLL.DummyNameMap then return end
    local entity = getSelectedDummy()

    E.checkClientSrc.Checked   = false
    E.checkCutsceneSrc.Checked = false
    E.checkOriginSrc.Checked   = false

    if state and entity then
        -- if not entity then E.checkPMSrc.Checked = false return end
        -- DPrint('PM: Getting position from dummy')
        _GLL.SourceTranslate = entity.Visual.Visual.WorldTransform.Translate
        -- Ch.Source:SendToServer(_GLL.SourceTranslate)
    else
        -- DPrint('PM: Fallback to _C()')
        _GLL.SourceTranslate = _C().Transform.Transform.Translate
        -- Ch.Source:SendToServer(_GLL.SourceTranslate)
    end
    -- DDump(_GLL.SourceTranslate)
    return _GLL.SourceTranslate
end



function SourceClient(state)
    local entity = _C()
    -- E.checkPMSrc.Checked = false
    E.checkCutsceneSrc.Checked = false
    E.checkOriginSrc.Checked   = false

    if state and entity and Entity:hasVisual(entity)then
        -- DPrint('CLIENT: Getting position from client')
        _GLL.SourceTranslate = entity.Visual.Visual.WorldTransform.Translate
        -- Ch.Source:SendToServer(_GLL.SourceTranslate)
    else
        -- DPrint('CLIENT: Fallback to _C()')
        _GLL.SourceTranslate = _C().Transform.Transform.Translate
        -- Ch.Source:SendToServer(_GLL.SourceTranslate)
    end
    -- DDump(_GLL.SourceTranslate)
    return _GLL.SourceTranslate
end



function StickToCamera()
    Utils:SubUnsubToTick(1, 'Stick', function ()
        if E.checkStick.Checked and Camera:GetActiveCamera() then

            local Translate = Camera:GetActiveCamera().Transform.Transform.Translate
            local RotationQuat = Camera:GetActiveCamera().Transform.Transform.RotationQuat
            -- Ch.Source:SendToServer(_GLL.SourceTranslate)
            local Data = {
                Translate = Translate,
                RotationQuat = RotationQuat,
                SourceTranslate = getSourcePositionCl()
            }
            Ch.StickToCamera:SendToServer(Data)


            local x,y,z = table.unpack(Translate)
            local rx,ry,rz = table.unpack(Helpers.Math.QuatToEuler(RotationQuat))
            UpdateTranformInfo(x,y,z,rx,ry,rz)

        else
            Utils:SubUnsubToTick(0, 'Stick', _)
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
    local Entities = Ext.Entity.GetAllEntitiesWithComponent('CharacterLight')
    for _, entity in pairs(Entities) do
        entity.CharacterLight.Enabled = not state
    end
end



function DarkVisionState(state)
    local Dummies = Dummy:GetAll()
    for _, dummy in pairs(Dummies) do
        if dummy
            and dummy.DummyVFXEntities
            and dummy.DummyVFXEntities.field_0
        then
            local field_0 = dummy.DummyVFXEntities.field_0

            for _, entity in pairs(field_0) do
                local CEH = entity.ClientEffectHandler

                if CEH
                    and CEH.Handler
                    and CEH.Handler.ConditionalEffects
                    and CEH.Handler.ConditionalEffects[1]
                    and CEH.Handler.ConditionalEffects[1].Effect
                then
                    local Effect = CEH.Handler.ConditionalEffects[1].Effect.Effect

                    if Effect.EffectName:lower():find('darkvision')
                        and Effect.Timeline
                        and Effect.Timeline.Components[2]
                        and Effect.Timeline.Components[2].LightEntity
                        and Effect.Timeline.Components[2].LightEntity.Light
                    then
                        Effect.Timeline.IsPaused = state
                        Effect.Timeline.Components[2].LightEntity.Light.Intensity = 0
                    end
                end
            end
        end
    end
end



MCM.SetKeybindingCallback('ll_move_to_cursor', function()
    if _GLL.DummyNameMap then
        local index = E.comboDummies.SelectedIndex + 1
        local entity = _GLL.DummyNameMap[E.comboDummies.Options[index]]

        if not entity then return end

        local mousePos = Utils:GetMouseover().Inner.Position
        entity.Visual.Visual.WorldTransform.Translate = mousePos
        entity.DummyOriginalTransform.Transform.Translate = mousePos
        UpdateCharacterInfo(index)
    end
end)



ROT_MOD   = 1500
STEP_MOD  = 1500
SCALE_MOD = 1500


function MoveCharacter(axis, value, STEP_MOD, index)
    -- DPrint(index)
    if _GLL.DummyNameMap then
        -- DPrint(E.comboDummies.Options[index])
        -- DPrint(_GLL.DummyNameMap[E.comboDummies.Options[index]])
        local entity = _GLL.DummyNameMap[E.comboDummies.Options[index]]
        if entity then
        -- DPrint(entity)
            local pos = entity.Visual.Visual.WorldTransform.Translate
            local dPos = entity.DummyOriginalTransform.Transform.Translate

            if axis == 'x' then
                pos.x = value
                pos[1] = pos[1] + (pos.x/STEP_MOD)
                dPos[1] = dPos[1] + (pos.x/STEP_MOD)

            elseif axis == 'y' then
                pos.y = value
                pos[2] = pos[2] + (pos.y/STEP_MOD)
                dPos[2] = dPos[2] + (pos.y/STEP_MOD)

            elseif axis == 'z' then
                pos.z = value
                pos[3] = pos[3] + (pos.z/STEP_MOD)
                dPos[3] = dPos[3] + (pos.z/STEP_MOD)
            elseif axis == 'reset' then
                pos[1] = value[1]
                pos[2] = value[2]
                pos[3] = value[3]

                dPos[1] = value[1]
                dPos[2] = value[2]
                dPos[3] = value[3]
            end

            entity.Visual.Visual.WorldTransform.Translate     = {pos[1],  pos[2],  pos[3]}
            entity.DummyOriginalTransform.Transform.Translate = {dPos[1], dPos[2], dPos[3]}

            for q = 1, #entity.Visual.Visual.Attachments do
                for i = 1, #entity.Visual.Visual.Attachments[q].Visual.ObjectDescs do
                    local objDesc = entity.Visual.Visual.Attachments[q].Visual.ObjectDescs[i]

                    if objDesc and objDesc.Renderable and objDesc.Renderable.WorldTransform then
                        objDesc.Renderable.WorldTransform.Translate = {pos[1], pos[2], pos[3]}
                    end
                end
            end

            for k, v in pairs(Ext.Entity.GetAllEntitiesWithComponent('PhotoModeDummy')) do
                if v.PhotoModeDummy.Entity == _C() then
                    v.PhotoModeDummyTransform.Transform.Translate = {pos[1], pos[2], pos[3]}
                    -- DDump(v.PhotoModeDummyTransform.Transform.Translate)
                end
            end
            UpdateCharacterInfo(index)
        end
    end
end



function RotateCharacter(axis, value, ROT_MOD, index)
    if _GLL.DummyNameMap then
        local entity = _GLL.DummyNameMap[E.comboDummies.Options[index]]

        if entity then
            local rot = entity.Visual.Visual.WorldTransform.RotationQuat
            local dRot = entity.DummyOriginalTransform.Transform.RotationQuat
            local currentQuat = {rot[1], rot[2], rot[3], rot[4]}
            local rotationAngle
            if type(value) ~= 'table' then
                rotationAngle = value / ROT_MOD
            end
            local axisVec = {0, 0, 0}
            local quat, original_quat

            if axis == 'x' then
                axisVec = {1, 0, 0}
            elseif axis == 'y' then
                axisVec = {0, 1, 0}
            elseif axis == 'z' then
                axisVec = {0, 0, 1}
            elseif axis == 'reset' then
                quat = value
                original_quat = value
            end

            quat = quat or Ext.Math.QuatRotateAxisAngle(currentQuat, axisVec, rotationAngle)
            original_quat = original_quat or Ext.Math.QuatRotateAxisAngle(dRot, axisVec, rotationAngle)

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


--- TBD: Hack
_GLL.SavedDummyScale = {}

function ScaleCharacter(axis, value, SCALE_MOD, index)
    if _GLL.DummyNameMap then
        local entity = _GLL.DummyNameMap[E.comboDummies.Options[index]]

        if entity then
            local scale = entity.Visual.Visual.WorldTransform.Scale
            local dScale = entity.DummyOriginalTransform.Transform.Scale

            if axis == 'x' then
                scale.x = value
                scale[1] = scale[1] + (scale.x/SCALE_MOD)
                dScale[1] = dScale[1] + (scale.x/SCALE_MOD)

            elseif axis == 'y' then
                scale.y = value
                scale[2] = scale[2] + (scale.y/SCALE_MOD)
                dScale[2] = dScale[2] + (scale.y/SCALE_MOD)

            elseif axis == 'z' then
                scale.z = value
                scale[3] = scale[3] + (scale.z/SCALE_MOD)
                dScale[3] = dScale[3] + (scale.z/SCALE_MOD)
            elseif axis == 'all' then
                scale.x = value
                scale[1] = scale[1] + (scale.x/SCALE_MOD)
                dScale[1] = dScale[1] + (scale.x/SCALE_MOD)
                scale.y = value
                scale[2] = scale[2] + (scale.y/SCALE_MOD)
                dScale[2] = dScale[2] + (scale.y/SCALE_MOD)
                scale.z = value
                scale[3] = scale[3] + (scale.z/SCALE_MOD)
                dScale[3] = dScale[3] + (scale.z/SCALE_MOD)

            elseif axis == 'reset' then
                scale[1] = 1
                scale[2] = 1
                scale[3] = 1

                dScale[1] = 1
                dScale[1] = 1
                dScale[1] = 1
            end

            entity.Visual.Visual.WorldTransform.Scale     = {scale[1],  scale[2],  scale[3]}
            entity.DummyOriginalTransform.Transform.Scale = {dScale[1], dScale[2], dScale[3]}

            for q = 1, #entity.Visual.Visual.Attachments do
                for i = 1, #entity.Visual.Visual.Attachments[q].Visual.ObjectDescs do
                    local objDesc = entity.Visual.Visual.Attachments[q].Visual.ObjectDescs[i]

                    if objDesc and objDesc.Renderable and objDesc.Renderable.WorldTransform then
                        objDesc.Renderable.WorldTransform.Scale = {scale[1], scale[2], scale[3]}
                    end
                end
            end

            UpdateCharacterInfo(index)
            _GLL.SavedDummyScale[E.comboDummies.Options[index]] = {scale[1],  scale[2],  scale[3]}
        end
    end
end



local size = 50
_GLL.SavedTransforms = {}
-- local Seletable = {}
local selectableCnt = 0



--- refactored by slop. too lazy and don't care xd
--- TBD: refactor normally
--- UPD: Done
local BtnsLoad  = {}
local BtnsDelete = {}

function SaveDummyTransformAndCreateSelectable()
    local index = E.comboDummies.SelectedIndex + 1
    local dummyName = E.comboDummies.Options[index]

    BtnsLoad[dummyName] = BtnsLoad[dummyName] or {}
    BtnsDelete[dummyName] = BtnsDelete[dummyName] or {}

    if not dummyName or not _GLL.DummyNameMap[dummyName] then return end

    local WT = Ext.Types.Serialize(_GLL.DummyNameMap[dummyName].Visual.Visual.WorldTransform)
    _GLL.SavedTransforms[dummyName] = WT

    local ST = _GLL.SavedTransforms[dummyName]
    local buttonLabel = string.format("%s; x = %.2f; y = %.2f; z = %.2f", string.gsub(dummyName, "##.*", ""),
                                        ST.Translate[1], ST.Translate[2], ST.Translate[3])

    local function LoadTransform()
        local currentIndex = E.comboDummies.SelectedIndex + 1
        local currentDummyName = E.comboDummies.Options[currentIndex]

        if not currentDummyName or not _GLL.DummyNameMap[currentDummyName] then return end

        local dummy = _GLL.DummyNameMap[currentDummyName]

        dummy.Visual.Visual.WorldTransform = ST
        dummy.DummyOriginalTransform.Transform = ST

        UpdateCharacterInfo(currentIndex)
    end

    if BtnsLoad[dummyName].Label then
        BtnsLoad[dummyName].Label   = buttonLabel
        BtnsLoad[dummyName].OnClick = LoadTransform
    else
        -- saveLoadWindow.Size = {saveLoadWindow.Size[1], saveLoadWindow.Size[2] + size}
        selectableCnt = selectableCnt + 1

        BtnsDelete[dummyName] = saveLoadWindow:AddButton('x')
        BtnsDelete[dummyName].IDContext = 'xBtn' .. Ext.Math.Random()
        BtnsDelete[dummyName].OnClick = function()
            selectableCnt = selectableCnt - 1

            BtnsDelete[dummyName]:Destroy()
            BtnsLoad[dummyName]:Destroy()
            BtnsDelete[dummyName] = nil
            BtnsLoad[dummyName] = nil

            _GLL.SavedTransforms[dummyName] = nil

            if selectableCnt == 0 then
                _GLL.SavedTransforms = {}
                -- Seletable = {}
            end
            -- saveLoadWindow.Size = {saveLoadWindow.Size[1], saveLoadWindow.Size[2] - size}
        end

        BtnsLoad[dummyName] = saveLoadWindow:AddButton(buttonLabel)
        BtnsLoad[dummyName].IDContext = 'loadBtn' .. Ext.Math.Random()
        BtnsLoad[dummyName].SameLine = true
        BtnsLoad[dummyName].OnClick = LoadTransform
        -- Seletable[dummyName] = {delete = deleteBtn, load = loadBtn}
    end
end



-- local shiftIsHeld = false

-- Ext.Events.KeyInput:Subscribe(function (e)
--     if e.Key == "LSHIFT" then
--         shiftIsHeld = e.Pressed
--     end
-- end)



-- Ext.Events.MouseButtonInput:Subscribe(function (e)
--     if (e.Button == 1 or e.Button == 3) and shiftIsHeld then
--         local button = e.Button
--         local InitialPos = Utils:GetMouseover().WindowCursorPos

--         if e.Pressed then
--             pcall(function()
--                 oldFov = Ext.UI.GetRoot():Find("ContentRoot"):Child(21).DataContext.FieldOfView
--             end)
--             local oldSpeed = Ext.Stats.GetStatsManager().ExtraData['PhotoModeCameraMovementSpeed']
--             local oldFov = Camera:GetActiveCamera().Camera.Controller.FOV

--             Utils:SubUnsubToTick(1, 'camfov', function()
--                 local CurrentPost = Utils:GetMouseover().WindowCursorPos
--                 local Distance = Vec2.__sub(InitialPos, CurrentPost)
--                 local value = Distance[1]

--                 if button == 1 then
--                     pcall(function()
--                         Ext.UI.GetRoot():Find("ContentRoot"):Child(21).DataContext.FieldOfView = value/1000 + oldFov
--                     end)
--                     Camera:GetActiveCamera().Camera.Controller.FOV = value/1000 + oldFov
--                 else
--                     Ext.Stats.GetStatsManager().ExtraData['PhotoModeCameraMovementSpeed'] = -value/50 + oldSpeed
--                     if Ext.Stats.GetStatsManager().ExtraData['PhotoModeCameraMovementSpeed'] < 0 then
--                         Ext.Stats.GetStatsManager().ExtraData['PhotoModeCameraMovementSpeed'] = 1
--                     end
--                     E.camSpeed.Value = {Ext.Stats.GetStatsManager().ExtraData['PhotoModeCameraMovementSpeed'],0,0,0}
--                 end
--             end)
--         else
--             Utils:SubUnsubToTick(0, 'camfov', nil)
--         end
--     end
-- end)



-- function Create()
--     local Scene = Ext.Entity.GetAllEntitiesWithComponent('Scene')[1]
--     local CullFlags = 1537
--     local RootLevel = _D(Ext.Entity.GetAllEntitiesWithComponent('LevelRoot')[1])
--     local LevelName = RootLevel.LevelRoot.LevelName

--     local entity = Ext.Entity.Create()

--     entity:CreateComponent('Level')
--     entity.Level.RootLevel = RootLevel
--     entity.Level.LevelName = LevelName

--     entity:CreateComponent('Transform')
--     entity.Transform.Transform.Translate = _C().Transform.Transform.Translate

--     entity:CreateComponent('SceneAttach')

--     entity:CreateComponent('Cull')
--     entity.Cull.CullFlags = 1537

--     entity:CreateComponent('Light')
-- end
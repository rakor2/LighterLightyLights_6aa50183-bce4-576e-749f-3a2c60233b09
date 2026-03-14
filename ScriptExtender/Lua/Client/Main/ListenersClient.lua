local boneZoneInit = false

_GLL.DummyVeryOriginalTransforms = {}

local HEIGHT_OFFSET = 2
local MAX_DISTANCE = 11



local function photoModeExists()
    return Ext.Entity.GetAllEntitiesWithComponent('PhotoModeSession')[1] and true or false
end



local function AttachWindowToEntity(w, TargetTranslate, WinSize)
    local Pos = Screen.WorldToScreenPoint(TargetTranslate)
    if not Pos then w.Visible = false return end
    if not WinSize then WinSize = {0,0} end

    local WindowCenter = {WinSize[1]*0.5, WinSize[2]*0.5}
    w:SetPos(Vec2.__sub({Pos[1], Pos[2]}, WindowCenter))
end



local function OnPhotoModeCreate()
    PM.DummyWidgets = {}

    if E.checkAutoTail.Checked then
        DisableTailPhysics()
    else
        EnableTailPhysics()
    end

    Helpers.Timer:OnTicks(30, function ()
        _GLL.States.inPhotoMode = true
        _GLL.DummyNameMap = {}

        local Dummies = Ext.Entity.GetAllEntitiesWithComponent('Dummy')

        for index, dummy in pairs(Dummies) do
            _GLL.DummyVeryOriginalTransforms[dummy.Dummy.Entity.Uuid.EntityUuid] = Ext.Types.Serialize(dummy.Transform.Transform)

            --- Dummy name and map mhm
            local dummyName = Dummy:Name(dummy)
            local dummyId = dummyName .. '##' .. dummy.Dummy.Entity.Uuid.EntityUuid
            _GLL.DummyNameMap[dummyId] = dummy
            _GLL.DummyNames = Utils:MapToArray(_GLL.DummyNameMap)


            E.visTemComob.Options = _GLL.DummyNames
            E.cmbBoneDummies.Options = _GLL.DummyNames


            GetGenomeVariablesIndicies(dummy)
            if not boneZoneInit then
                TableBoneValues(dummy)
            end

            --- Selected dummy widgets
            local wn =  Ext.IMGUI.NewWindow(Ext.Math.Random(1, 100))
            wn.Visible = false
            ApplyStyle(wn, StyleSettings.selectedStyle)
            wn.NoDecoration = true
            wn.AlwaysAutoResize = true

            local x, y, z = table.unpack(dummy.DummyOriginalTransform.Transform.Translate)
            local TargetTranslate = {x, y + HEIGHT_OFFSET, z}

            AttachWindowToEntity(wn, TargetTranslate)

            local selectedLightNotification = wn:AddText(dummyName)
            PM.DummyWidgets[dummyId] = {Window = wn, Size = wn.LastSize, Dummy = dummy, Name = dummyName}


            --- Reaplying saved transforms on photomode enter
            --- TBD: refactor temp garbo
            if _GLL.SavedTransforms and _GLL.SavedTransforms[dummyId] then
                -- DDump(_GLL.SavedTransforms[dummyId])
                local saved = _GLL.SavedTransforms[dummyId]
                dummy.Visual.Visual.WorldTransform.Translate = {saved.pos[1], saved.pos[2], saved.pos[3]}
                dummy.Visual.Visual.WorldTransform.RotationQuat = {saved.rot[1], saved.rot[2], saved.rot[3], saved.rot[4]}
                dummy.Visual.Visual.WorldTransform.Scale = {saved.scale[1], saved.scale[2], saved.scale[3]}
                dummy.DummyOriginalTransform.Transform.Translate = {saved.pos[1], saved.pos[2], saved.pos[3]}
                dummy.DummyOriginalTransform.Transform.RotationQuat = {saved.rot[1], saved.rot[2], saved.rot[3], saved.rot[4]}
                dummy.DummyOriginalTransform.Transform.Scale = {saved.scale[1], saved.scale[2], saved.scale[3]}
            end
        end


        --- Abusing tick for some bs
        Utils:SubUnsubToTick('sub', 'PhotoMode', function ()

            --- Copying dof distance value from noesis
            pcall(function()
                local distance = Ext.UI.GetRoot():Find("ContentRoot"):Child(21).DataContext.DOFDistance
                E.dofDistance.Value = {distance, 0, 0, 0}
            end)

            --- Updating widget position for all dummies
            if E.checkDummiesPop.Checked then
                for index, dummy in ipairs(E.visTemComob.Options) do
                    local tbl = PM.DummyWidgets[dummy]
                    local x, y, z = table.unpack(tbl.Dummy.DummyOriginalTransform.Transform.Translate)
                    local TargetTranslate = {x, y + HEIGHT_OFFSET, z}
                    local CamTranslate = Camera:GetActiveCamera().Transform.Transform.Translate
                    local distanceToTarget = Ext.Math.Distance(TargetTranslate, CamTranslate)

                    if E.checkDummiesPop.Checked then
                        tbl.Window.Visible = distanceToTarget < MAX_DISTANCE
                    end
                    AttachWindowToEntity(tbl.Window, TargetTranslate, tbl.Size)
                end
            end
        end)


        CharacterLightSetupState(lightSetupState)
        UpdateCharacterInfo(E.visTemComob.SelectedIndex + 1)


        --- BoneZone


        --- TBD: to one pass
        if boneZoneInit then
            for index, dummy in pairs(Dummies) do
                SetValuesToVars(dummy)
            end
        end
        SetVarValuesToSliders()

        boneZoneInit = true


        --- Gitzmo
        -- _GLL.gizmo:SetActive(true)
    end)
end




local function OnPhotoModeDestroy()
    if E.checkAutoTail.Checked then
        EnableTailPhysics()
    end

    _GLL.States.inPhotoMode = false

    _GLL.DummyNameMap = nil
    _GLL.DummyNames = nil

    E.visTemComob.Options = {'Not in Photo Mode'}
    E.cmbBoneDummies.Options = {'Not in Photo Mode'}

    E.visTemComob.SelectedIndex = 0
    E.checkPMSrc.Checked = false

    if Utils.subID and Utils.subID['SourcePhotoMode'] then
        Utils:SubUnsubToTick('unsub', 'SourcePhotoMode',_)
    end

    if Utils.subID and Utils.subID['PhotoMode'] then
        Utils:SubUnsubToTick('unsub', 'PhotoMode',_)
    end

    UpdateCharacterInfo(nil)

    ResetSliderValue()

    E.checkDummiesPop.Checked = false
    for _, v in pairs(PM.DummyWidgets) do
        v.Window:Destroy()
    end

    -- _GLL.gizmo:SetActive(false)
end



Ext.Entity.OnCreate('PhotoModeSession', function ()
    OnPhotoModeCreate()
end)



Ext.Entity.OnDestroy('PhotoModeSession', function ()
    OnPhotoModeDestroy()
end)



Ext.Events.ResetCompleted:Subscribe(function()
    Helpers.Timer:OnTicks(10, function()
        if photoModeExists() then OnPhotoModeCreate() end
    end)
end)



Ext.RegisterNetListener('LL_SendLookAtTargetUuid', function(channel, payload)
    _GLL.tragetUuid = payload
    Helpers.Timer:OnTicks(3, function ()
        _GLL.tragetEntity = Ext.Entity.Get(_GLL.tragetUuid)
    end)
    CharacterLightSetupState(E.checkLightSetupState.Checked)
end)



Ext.Entity.OnChange('CCState', function ()
    Helpers.Timer:OnTicks(200, function ()
        CharacterLightSetupState(lightSetupState)
    end)
end)



Ext.RegisterNetListener('LL_JumpFollow', function(channel, payload)
    Helpers.Timer:OnTicks(100, function()
        -- DPrint('xdddddddddddd')
        CharacterLightSetupState(lightSetupState)
        -- Ch.CurrentResource:RequestToServer({}, function(Response)
        --     SetCurrentAtmosphereAndLighting(Response)
        -- end)
    end)
end)



Ext.RegisterNetListener('LLL_LevelStarted', function (channel, payload, user)
    -- Ch.CurrentResource:RequestToServer({}, function(Response)
    --     SetCurrentAtmosphereAndLighting(Response)
    -- end)
end)
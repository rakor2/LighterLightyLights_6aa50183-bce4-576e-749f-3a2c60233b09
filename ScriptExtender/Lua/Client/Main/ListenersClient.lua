local boneZoneInit   = false
local HEIGHT_OFFSET  = 2
local MAX_DISTANCE   = 11



_GLL.DummyVeryOriginalTransforms = {}



local function photoModeExists()
    return Ext.Entity.GetAllEntitiesWithComponent('PhotoModeSession')[1] ~= nil
end



local function AttachWindowToEntity(window, targetTranslate, winSize)
    local pos = Screen.WorldToScreenPoint(targetTranslate)
    if not pos then window.Visible = false return end

    winSize = winSize or {0, 0}
    local center = {winSize[1] * 0.5, winSize[2] * 0.5}
    window:SetPos(Vec2.__sub({pos[1], pos[2]}, center))
end



local function createDummySelectionCheckbox(dummy, dummyId)
    E.checkAddTarget          = E.checkAddTarget or {}
    E.checkAddTarget[dummyId] = E.grpGizmoDummies:AddCheckbox(dummyId)

    UI:Config(E.checkAddTarget[dummyId], {
        SameLine = true,
        OnChange = function(e)
            local uuid = dummy.Dummy.Entity.Uuid.EntityUuid

            if e.Checked then
                _GLL.gizmo:AddTarget(dummy.Dummy.Entity)
            else
                _GLL.gizmo:RemoveTarget(dummy.Dummy.Entity)
            end
        end,
    })
end



local function createDummyFloatingWidget(dummy, dummyName)
    local wn = Ext.IMGUI.NewWindow(Ext.Math.Random(1, 100))
    wn.Visible       = false
    wn.NoDecoration  = true
    wn.AlwaysAutoResize = true
    ApplyStyle(wn, StyleSettings.selectedStyle)

    local x, y, z = table.unpack(dummy.DummyOriginalTransform.Transform.Translate)
    AttachWindowToEntity(wn, {x, y + HEIGHT_OFFSET, z})
    wn:AddText(dummyName)

    return wn
end



local function applySavedTransform(dummy, dummyId)
    if not (_GLL.SavedTransforms and _GLL.SavedTransforms[dummyId] and E.checkAutoSave.Checked) then return end

    local ST = _GLL.SavedTransforms[dummyId]
    local Pos   = {ST.pos[1],   ST.pos[2],   ST.pos[3]}
    local Rot   = {ST.rot[1],   ST.rot[2],   ST.rot[3],   ST.rot[4]}
    local Scale = {ST.scale[1], ST.scale[2], ST.scale[3]}

    dummy.Visual.Visual.WorldTransform.Translate             = Pos
    dummy.Visual.Visual.WorldTransform.RotationQuat          = Rot
    dummy.Visual.Visual.WorldTransform.Scale                 = Scale
    dummy.DummyOriginalTransform.Transform.Translate         = Pos
    dummy.DummyOriginalTransform.Transform.RotationQuat      = Rot
    dummy.DummyOriginalTransform.Transform.Scale             = Scale
end



local function initDummy(dummy)
    local uuid     = dummy.Dummy.Entity.Uuid.EntityUuid
    local name     = Dummy:Name(dummy)
    local dummyId       = name .. '##' .. uuid

    --- Store original transforms
    _GLL.DummyVeryOriginalTransforms[uuid] = Ext.Types.Serialize(dummy.Transform.Transform)

    --- Name map
    _GLL.DummyNameMap[dummyId] = dummy
    _GLL.DummyNames       = Utils:MapToArray(_GLL.DummyNameMap)

    E.visTemComob.Options  = _GLL.DummyNames
    E.cmbBoneDummies.Options = _GLL.DummyNames

    --- UI
    createDummySelectionCheckbox(dummy, dummyId)

    local window = createDummyFloatingWidget(dummy, name)
    PM.DummyWidgets[dummyId] = {Window = window, Size = window.LastSize, Dummy = dummy, Name = name}

    --- BoneZone
    GetGenomeVariablesIndicies(dummy)
    if not boneZoneInit then
        TableBoneValues(dummy)
    end

    --- Restore saved transforms
    applySavedTransform(dummy, dummyId)
end



local function syncDofDistance()
    pcall(function()
        local distance = Ext.UI.GetRoot():Find("ContentRoot"):Child(21).DataContext.DOFDistance
        E.dofDistance.Value = {distance, 0, 0, 0}
    end)
end



local function updateFloatingWidgets()
    if not E.checkDummiesPop.Checked then return end

    for _, key in ipairs(E.visTemComob.Options) do
        local entry = PM.DummyWidgets[key]
        local x, y, z = table.unpack(entry.Dummy.Visual.Visual.WorldTransform.Translate)
        local target   = {x, y + HEIGHT_OFFSET, z}
        local camPos   = Camera:GetActiveCamera().Transform.Transform.Translate
        local distance = Ext.Math.Distance(target, camPos)

        entry.Window.Visible = distance < MAX_DISTANCE
        AttachWindowToEntity(entry.Window, target, entry.Size)
    end
end



local function onPhotoModeTick()
    syncDofDistance()
    updateFloatingWidgets()
end



local function OnPhotoModeCreate()
    PM.DummyWidgets = {}

    if E.checkAutoTail.Checked then DisableTailPhysics() else EnableTailPhysics() end

    Helpers.Timer:OnTicks(30, function()
        _GLL.States.inPhotoMode = true
        _GLL.DummyNameMap       = {}

        local dummies = Ext.Entity.GetAllEntitiesWithComponent('Dummy')
        for _, dummy in pairs(dummies) do
            initDummy(dummy)
        end

        if Mods.GizmoLib then
            E.grpGizmoDummies:AddText(' | Gizmo selections').SameLine = true
        end

        Utils:SubUnsubToTick('sub', 'PhotoMode', onPhotoModeTick)

        CharacterLightSetupState(lightSetupState)
        UpdateCharacterInfo(E.visTemComob.SelectedIndex + 1)

        --- BoneZone
        if boneZoneInit then
            for _, dummy in pairs(dummies) do
                SetValuesToVars(dummy)
            end
        end
        SetVarValuesToSliders()
        boneZoneInit = true


        --- Gizmo
        if Mods.GizmoLib then
            _GLL.gizmo:SetActive(true)
            Helpers.Timer:OnTicks(5, function()
                --- Delete the main gizmo, cuz it creates on initialization
                local globalEditor = GL_GLOBALS.TransformEditor
                if not globalEditor.Gizmo.Guid then
                    NetChannel.ManageGizmo:RequestToServer({Clear = true}, function(response)
                        globalEditor.Gizmo.Guid = nil
                        globalEditor.Gizmo.SavedGizmos = {}
                    end)
                end
                globalEditor.Gizmo:DeleteItem()
                globalEditor.Target = nil
            end)
        end

    end)
end



local function OnPhotoModeDestroy()
    if E.checkAutoTail.Checked then EnableTailPhysics() end

    _GLL.States.inPhotoMode = false
    _GLL.DummyNameMap       = nil
    _GLL.DummyNames         = nil

    E.visTemComob.Options    = {'Not in Photo Mode'}
    E.cmbBoneDummies.Options = {'Not in Photo Mode'}
    E.visTemComob.SelectedIndex = 0
    -- E.checkPMSrc.Checked     = false

    -- for _, key in ipairs({'SourcePhotoMode', 'PhotoMode'}) do
    --     if Utils.subID and Utils.subID[key] then
    --         Utils:SubUnsubToTick('unsub', key, _)
    --     end
    -- end

    UpdateCharacterInfo(nil)
    ResetSliderValue()

    E.checkDummiesPop.Checked = false
    for _, entry in pairs(PM.DummyWidgets) do
        entry.Window:Destroy()
    end

    _GLL.BZHistory      = {}
    _GLL.BZHistoryIndex = {}
    _GLL.BZOldValues    = {}

    _GLL.GizmoDummySelections = {}
    GL_GLOBALS.TransformEditor.Target = {}

    Imgui.ClearChildren(E.grpGizmoDummies)

    if Mods.GizmoLib then
        _GLL.GizmoDummySelections = {}
        GL_GLOBALS.TransformEditor.Target = {}

        Imgui.ClearChildren(E.grpGizmoDummies)

        _GLL.gizmo:SetActive(false)
        _GLL.gizmo:Clear()
    end
end



Ext.Entity.OnCreate('PhotoModeSession',  OnPhotoModeCreate)
Ext.Entity.OnDestroy('PhotoModeSession', OnPhotoModeDestroy)



Ext.Events.ResetCompleted:Subscribe(function()
    Helpers.Timer:OnTicks(10, function()
        if photoModeExists() then OnPhotoModeCreate() end
    end)
end)



Ext.RegisterNetListener('LL_SendLookAtTargetUuid', function(channel, payload)
    _GLL.tragetUuid = payload
    Helpers.Timer:OnTicks(3, function()
        _GLL.tragetEntity = Ext.Entity.Get(_GLL.tragetUuid)
    end)
    CharacterLightSetupState(E.checkLightSetupState.Checked)
end)



Ext.Entity.OnChange('CCState', function()
    Helpers.Timer:OnTicks(200, function()
        CharacterLightSetupState(lightSetupState)
    end)
end)



Ext.RegisterNetListener('LL_JumpFollow', function(channel, payload)
    Helpers.Timer:OnTicks(100, function()
        CharacterLightSetupState(lightSetupState)
    end)
end)



Ext.RegisterNetListener('LLL_LevelStarted', function(channel, payload, user)
    --- XD
end)
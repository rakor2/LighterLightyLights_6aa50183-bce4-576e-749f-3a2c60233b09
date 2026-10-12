boneZoneInit = false
local HEIGHT_OFFSET  = 2
local MAX_DISTANCE   = 11
POGGERS = false



_GLL.DummyVeryOriginalTransforms = {}



local function PhotoModeExists()
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



local function ApplySavedTransform(dummy, dummyId)
    if not (_GLL.SavedTransforms and _GLL.SavedTransforms[dummyId] and E.checkAutoSave.Checked) then return end

    local ST = _GLL.SavedTransforms[dummyId]
    -- local Pos   = {ST.pos[1],   ST.pos[2],   ST.pos[3]}
    -- local Rot   = {ST.rot[1],   ST.rot[2],   ST.rot[3],   ST.rot[4]}
    -- local Scale = {ST.scale[1], ST.scale[2], ST.scale[3]}

    Ext.Types.Unserialize(dummy.Visual.Visual.WorldTransform, ST)
    Ext.Types.Unserialize(dummy.DummyOriginalTransform.Transform, ST)

    -- dummy.Visual.Visual.WorldTransform.Translate        = Pos
    -- dummy.Visual.Visual.WorldTransform.RotationQuat     = Rot
    -- dummy.Visual.Visual.WorldTransform.Scale            = Scale
    -- dummy.DummyOriginalTransform.Transform.Translate    = Pos
    -- dummy.DummyOriginalTransform.Transform.RotationQuat = Rot
    -- dummy.DummyOriginalTransform.Transform.Scale        = Scale
end



local function GetClientControlIndex()
    local entity = Ext.Entity.GetAllEntitiesWithComponent('ClientControl')[1]
    if entity then
        for id, dummy in pairs(_GLL.DummyNameMap) do
            if entity.Uuid.EntityUuid == dummy.Dummy.Entity.Uuid.EntityUuid then
                return table.find(_GLL.DummyNames, id) - 1
            end
        end
    else
        return 0
    end
end



function initDummy(dummy)
    local uuid     = dummy.Dummy.Entity.Uuid.EntityUuid
    -- DPrint(uuid)
    local name     = Dummy:Name(dummy)
    -- DPrint(name)
    local dummyId  = name .. '##' .. uuid
    -- DPrint(dummyId)


    _GLL.DummyVeryOriginalTransforms[uuid] = Ext.Types.Serialize(dummy.Transform.Transform)

    _GLL.DummyNameMap[dummyId] = dummy
    _GLL.DummyNames            = MapToArray(_GLL.DummyNameMap)

    local Options               = _GLL.DummyNames
    local SelectedIndex         =  GetClientControlIndex() or 0
    E.comboDummies.Options       =  Options
    E.cmbBoneDummies.Options    =  Options
    E.comboDummies.SelectedIndex     = SelectedIndex
    E.cmbBoneDummies.SelectedIndex  = SelectedIndex
    selectedCharacter = E.cmbBoneDummies.SelectedIndex + 1
    -- DPrint('initDummy, character: %s', selectedCharacter)


    if Mods.GizmoLib then
        createDummySelectionCheckbox(dummy, dummyId)
    end

    local window = createDummyFloatingWidget(dummy, name)
    PM.DummyWidgets[dummyId] = {Window = window, Size = window.LastSize, Dummy = dummy, Name = name}

    GetGenomeVariablesIndicies(dummy)
    if not boneZoneInit then
        TableBoneValues(dummy)
    end

    ApplySavedTransform(dummy, dummyId)
end



-- local function syncDofDistance()
--     pcall(function()
        -- local distance = Ext.UI.GetRoot():Find("ContentRoot"):Child(21).DataContext.DOFDistance
--         E.dofDistance.Value = {distance, 0, 0, 0}
--     end)
-- end



local function UpdateFloatingWidgets()
    if not E.checkDummiesPop.Checked then return end

    for _, key in ipairs(E.comboDummies.Options) do
        local entry = PM.DummyWidgets[key]
        local x, y, z = table.unpack(entry.Dummy.Visual.Visual.WorldTransform.Translate)
        local target   = {x, y + HEIGHT_OFFSET, z}
        local camPos   = Camera:GetActiveCamera().Transform.Transform.Translate
        local distance = Ext.Math.Distance(target, camPos)

        entry.Window.Visible = distance < MAX_DISTANCE
        AttachWindowToEntity(entry.Window, target, entry.Size)
    end
end



local function OnPhotoModeTick()
    -- syncDofDistance()
    UpdateFloatingWidgets()
end



function OnPhotoModeCreate()
    if gizmoLibError then return end
    DDebug('ENTERED PHOTOMODE')
    DDebug('Current delay: %i', Settings.pmInitDelay[1])
    PM.DummyWidgets = {}
    AssignSoftBody(_C())

    GetHairSprings()
    if E.checkAutoHair  and E.checkAutoHair.Checked  then DisableHairPhysics()  else EnableHairPhysics()  end
    if E.checkAutoTail  and E.checkAutoTail.Checked  then DisableTailPhysics()  else EnableTailPhysics()  end
    if E.checkAutoTent  and E.checkAutoTent.Checked  then DisableTentPhysics()  else EnableTentPhysics()  end
    if E.checkAutoWings and E.checkAutoWings.Checked then DisableWingsPhysics() else EnableWingsPhysics() end
    if E.checkAutoDick  and E.checkAutoDick.Checked  then DisableDickPhysics()  else EnableDickPhysics()  end

    Helpers.Timer:OnTicks(Settings.pmInitDelay[1], function()
        DDebug('PHOTOMODE BS START')
        _GLL.States.inPhotoMode = true
        _GLL.DummyNameMap       = {}

        local Dummies = Dummy:GetAll()
        for _, dummy in pairs(Dummies) do
            initDummy(dummy)
        end

        if Mods.GizmoLib then
            E.grpGizmoDummies:AddText(' | Gizmo selections').SameLine = true
        end

        Utils:SubUnsubToTick('sub', 'PhotoMode', OnPhotoModeTick)

        CharacterLightSetupState(Settings.lightSetupState)
        DarkVisionState(E.checkVision.Checked)
        UpdateCharacterInfo(E.comboDummies.SelectedIndex + 1)

        --- BoneZone
        if boneZoneInit then
            for _, dummy in pairs(Dummies) do
                SetValuesToVars(dummy)
            end
        end
        SetVarValuesToSliders()
        boneZoneInit = true


        --- Gizmo
        if Mods.GizmoLib then
            if Settings.autoOpenToolbar then
            -- _GLL.gizmo:SetActive(false)
                _GLL.gizmo:SetActive(true)
            -- Helpers.Timer:OnTicks(5, function()
                -- Delete the main gizmo, cuz it creates on initialization, a
                -- local globalEditor = GL_GLOBALS.TransformEditor or Mods.GizmoLib.GL_GLOBALS.TransformEditor
                -- if not globalEditor.Gizmo.Guid then
                --     Mods.GizmoLib.NetChannel.ManageGizmo:RequestToServer({Clear = true}, function(response)
                --         globalEditor.Gizmo.Guid = nil
                --         globalEditor.Gizmo.SavedGizmos = {}
                --     end)
                -- end
                -- globalEditor.Gizmo:DeleteItem()
                -- globalEditor.Target = nil
            -- end)
            end
        end

        DDebug('PHOTOMODE BS END')
    end)
end



local function OnPhotoModeDestroy()
    if gizmoLibError then return end
    if E.checkAutoTail.Checked then EnableTailPhysics() end
    -- if E.checkAutoHair.Checked then EnableHairPhysics() end

    _GLL.States.inPhotoMode = false
    _GLL.DummyNameMap       = nil
    _GLL.DummyNames         = nil

    local NotIn = {'Not in Photo Mode'}
    E.comboDummies.Options    = NotIn
    E.cmbBoneDummies.Options = NotIn
    E.comboDummies.SelectedIndex = 0
    E.cmbBoneDummies.SelectedIndex = 0

    UpdateCharacterInfo(nil)
    ResetSliderValue()

    E.checkDummiesPop.Checked = false
    for _, entry in pairs(PM.DummyWidgets) do
        entry.Window:Destroy()
    end

    _GLL.BZHistory      = {}
    _GLL.BZHistoryIndex = {}
    _GLL.BZOldValues    = {}

    DetachAllAttachies()

    if Mods.GizmoLib then
        _GLL.GizmoDummySelections = {}
        GL_GLOBALS.TransformEditor.Target = {}

        Imgui.ClearChildren(E.grpGizmoDummies)

        _GLL.gizmo:SetActive(false)
        _GLL.gizmo:Clear()
    end

    E.checkPause.Checked = false
    _GLL.pauseEntity = nil

    -- JointLoopStop()
    -- DeleteJoint()
end



Ext.Entity.OnCreate('PhotoModeSession',  OnPhotoModeCreate)
Ext.Entity.OnDestroy('PhotoModeSession', OnPhotoModeDestroy)



Ext.Events.ResetCompleted:Subscribe(function()
    Helpers.Timer:OnTicks(10, function()
        if PhotoModeExists() then OnPhotoModeCreate() end
    end)
end)



Ext.Entity.OnChange('CCState', function()
    Helpers.Timer:OnTicks(200, function()
        CharacterLightSetupState(Settings.lightSetupState)
    end)
end)



Ext.Entity.OnCreate('ClientControl', function(entity)
    _GLL.lastClientControlUuid = entity and entity and entity.Uuid and entity.Uuid.EntityUuid
end)



Ch.JumpFollow:SetHandler(function()
    OnTicks(100, function()
        CharacterLightSetupState(Settings.lightSetupState)
    end)
end)


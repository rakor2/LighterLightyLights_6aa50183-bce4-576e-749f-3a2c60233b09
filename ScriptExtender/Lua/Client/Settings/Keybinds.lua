local function xd(xd)
    if xd then
        mw.Open = not mw.Open
    else
        DealingWithNoesis(function()
            local state = Ext.UI:GetRoot():Find('ContentRoot'):Child(21).IsVisible
            mw.Open = not state
        end)
    end

    if Changelog:ShouldShow() then
        Changelog:CreateWindow('Lighty Lights')
    end

    SelectLightingFromCurrentTrigger()
    SelectAtmosphereFromCurrentTrigger()
end

local keybindings = {
    ll_toggle_window      = function() xd(true) end,
    
    ll_toggle_light       = function() toggleLightBtn() end,

    ll_toggle_all_lights  = function() toggleAllLightsBtn() end,

    ll_toggle_marker      = function() ToggleMarker(_GLL.markerUuid) end,

    ll_toggle_all_markers = function() Ch.MarkerHandler:RequestToServer({}, function() end) end,

    ll_duplicate          = function() DuplicateLight() end,

    ll_beam               = function() Ch.MazzleBeam:SendToServer({}) end,

    ll_stick              = function()
        E.checkStick.Checked = not E.checkStick.Checked
        StickToCamera()
    end,

    ll_next               = function() nextOptionBtn() end,

    ll_prev               = function() prevOptionBtn() end,

    ll_selected_popup     = function()
        local lightName = getSelectedLightName() or 'None'
        if lightName then selectedLightNotification.Label = lightName end
        windowNotification.Visible = not windowNotification.Visible
        E.checkSelectedLightNotification.Checked = not E.checkSelectedLightNotification.Checked
    end,

    ll_apply_anl          = function() ApplyParameters() end,

    ll_hide_gobo          = function() hideGobo() end,

    ll_toggle_bz_symm     = function()
        local state = not E.checkSymm.Checked
        _GLL.States.bzSymmetry = state
        E.checkSymm.Checked = state
    end,

    -- ll_save_pose          = function() end,

    ll_pm_prev_dummy      = function()
        UI:PrevOption(E.comboDummies)
        UpdateDummyCombo(E.comboDummies)
    end,

    ll_pm_next_dummy      = function()
        UI:NextOption(E.comboDummies)
        UpdateDummyCombo(E.comboDummies)
    end,

    ll_dummy_popup        = function()
        E.checkDummiesPop.Checked = not E.checkDummiesPop.Checked
        for _, v in pairs(PM.DummyWidgets) do
            v.Window.Visible = not v.Window.Visible
        end
    end,

    ll_bone_undo = function() HistoryUndo() end,

    ll_bone_redo = function() HistoryRedo() end,

    ll_select_item_main = function() SelectItemAsAttachable('Main') end,

    ll_select_item_off = function() SelectItemAsAttachable('Off') end,

    -- ll_select_bone = function() GizmoSelect() end,

    -- ll_cycle_bone_gizmo = function() GizmoCycleMode() end,

    -- ll_add_bone = function() AddBoneToSelection() end,

    ll_hide_window = function() xd() end,

    ll_bz_quicksave = function() BZ.QuickSave() end
}

for key, callback in pairs(keybindings) do
    MCM.SetKeybindingCallback(key, callback)
end

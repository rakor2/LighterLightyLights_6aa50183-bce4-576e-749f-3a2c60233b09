local keybindings = {
    ll_toggle_window      = function() mw.Open = not mw.Open end,
    
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

    ll_save_pose          = function() end,

    ll_pm_prev_dummy      = function()
        UI:PrevOption(E.visTemComob)
        UpdateDummyCombo(E.visTemComob)
    end,

    ll_pm_next_dummy      = function()
        UI:NextOption(E.visTemComob)
        UpdateDummyCombo(E.visTemComob)
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
}

for key, callback in pairs(keybindings) do
    MCM.SetKeybindingCallback(key, callback)
end
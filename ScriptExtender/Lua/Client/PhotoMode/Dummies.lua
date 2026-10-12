function UpdateDummyCombo(e)
    if not _GLL.States.inPhotoMode then return end

    if selectedCharacter then
        PM.DummyWidgets[_GLL.DummyNames[selectedCharacter]].Window:SetColor('WindowBg', Style.Colors.windowBg)
        PM.DummyWidgets[_GLL.DummyNames[selectedCharacter]].Window:SetColor('Text', Style.Colors.textColor)
        selectedCharacter = e.SelectedIndex + 1
        -- DPrint('UpdateDummyCombo, character: %s', selectedCharacter)

        E.comboDummies.SelectedIndex    = e.SelectedIndex
        E.cmbBoneDummies.SelectedIndex = e.SelectedIndex
        SC.SyncSelectedDummuToQSAT(e.SelectedIndex)

        local dummyId = _GLL.DummyNames[selectedCharacter]

        if Mods.GizmoLib and not E.checkPreventGizmo.Checked then
            for k, v in pairs(_GLL.DummyNames) do
                E.checkAddTarget[v].Checked = false
            end

            local selectedUuid = _GLL.DummyNameMap[dummyId].Dummy.Entity.Uuid.EntityUuid
            E.checkAddTarget[dummyId].Checked = true

            -- API.SetActive(false, API._activeEditor)
            _GLL.gizmo:SetActive(true)
            _GLL.gizmo:Select({_GLL.DummyNameMap[dummyId].Dummy.Entity})
        end

        getSourcePositionCl()
        UpdateCharacterInfo(selectedCharacter)
        SetVarValuesToSliders()
        LoadAttachState(getSelectedDummy())

        PM.DummyWidgets[dummyId].Window:SetColor('WindowBg', Style.Colors.special)
        SetHighlightColor(PM.DummyWidgets[dummyId].Window)
    end
end



function GetSelectedDummyOwnerUuid()
    local entity = _GLL.DummyNameMap[E.cmbBoneDummies.Options[selectedCharacter]]
    if entity then
        local characterUuid = entity.Dummy.Entity.Uuid.EntityUuid
        if characterUuid then
            return characterUuid
        end
    end
end



function UpdateCharacterInfo(index)
    Helpers.Timer:OnTicks(5, function ()
        if index and _GLL.DummyNameMap and _GLL.DummyNameMap[E.comboDummies.Options[index]]    and
           _GLL.DummyNameMap[E.comboDummies.Options[index]].Visual                                  and
           _GLL.DummyNameMap[E.comboDummies.Options[index]].Visual.Visual
        then
            local WT = _GLL.DummyNameMap[E.comboDummies.Options[index]].Visual.Visual.WorldTransform
            E.posInput.Value   = {WT.Translate[1], WT.Translate[2], WT.Translate[3], 0}
            E.scaleInput.Value = {WT.Scale[1], WT.Scale[2], WT.Scale[3], 0}
            local deg = Helpers.Math.QuatToEuler(WT.RotationQuat)
            E.rotInput.Value = {deg[1], deg[2], deg[3], 0}
        else
            E.posInput.Value   = {0,0,0,0}
            E.rotInput.Value   = {0,0,0,0}
            E.scaleInput.Value = {0,0,0,0}
        end
    end)
end



function GizmoSelectDummy()
    local selectedId = _GLL.DummyNames[selectedCharacter]
    local entity = _GLL.DummyNameMap[selectedId].Dummy.Entity
    _GLL.gizmo:Select({entity})
end



function ApplyDummyTransform()
    if _GLL.DummyNameMap and _GLL.DummyNameMap[E.comboDummies.Options[selectedCharacter]] then
        local T  = _GLL.DummyNameMap[E.comboDummies.Options[selectedCharacter]].Visual.Visual.WorldTransform
        local T2 = _GLL.DummyNameMap[E.comboDummies.Options[selectedCharacter]].DummyOriginalTransform.Transform
        local Deg  = {E.rotInput.Value[1], E.rotInput.Value[2], E.rotInput.Value[3]}
        local Quats = Math.EulerToQuats(Deg)

        T.RotationQuat = Quats
        T.Scale        = {E.scaleInput.Value[1], E.scaleInput.Value[2], E.scaleInput.Value[3]}
        T.Translate    = {E.posInput.Value[1],   E.posInput.Value[2],   E.posInput.Value[3]}

        T2.RotationQuat = Quats
        T2.Scale        = {E.scaleInput.Value[1], E.scaleInput.Value[2], E.scaleInput.Value[3]}
        T2.Translate    = {E.posInput.Value[1],   E.posInput.Value[2],   E.posInput.Value[3]}
    end
end
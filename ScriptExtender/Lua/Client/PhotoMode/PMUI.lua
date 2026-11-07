function BetterPMDummy(p)
    local sepa2 = p:AddSeparatorText('Dummy controls')

    E.comboDummies = p:AddCombo('')
        UI:Config(E.comboDummies, {
            SelectedIndex = 0,
            Options      = {'Not in Photo Mode'},
            HeightLargest = true,
            SameLine     = false,
            ItemWidth    = COMBO_WIDTH,
            OnChange     = function(e)
                if not _GLL.States.inPhotoMode then return end
                UpdateDummyCombo(e)
            end,
            OnRightClick = function(e)
                if not Mods.GizmoLib then return end

                -- _GLL.GizmoDummySelections = {}
                for k, v in pairs(_GLL.DummyNames) do
                    E.checkAddTarget[v].Checked = false
                end

                local selectedId = _GLL.DummyNames[selectedCharacter]
                local selectedUuid = _GLL.DummyNameMap[selectedId].Dummy.Entity.Uuid.EntityUuid
                -- _GLL.GizmoDummySelections[selectedUuid] = _GLL.DummyNameMap[selectedId].Dummy.Entity
                E.checkAddTarget[selectedId].Checked = true

                GizmoSelectDummy()
            end
        })
    selectedCharacter = E.comboDummies.SelectedIndex + 1



    E.btnDumPrev = p:AddButton('<')
        UI:Config(E.btnDumPrev, {
            SameLine = true,
            OnClick  = function(e)
                UI:PrevOption(E.comboDummies)
                UpdateDummyCombo(E.comboDummies)
            end
        })



    E.btnDumNext = p:AddButton('>')
        UI:Config(E.btnDumNext, {
            SameLine = true,
            OnClick  = function(e)
                UI:NextOption(E.comboDummies)
                UpdateDummyCombo(E.comboDummies)
            end
        })



    local txtDum = p:AddText('Dummies')
        UI:Config(txtDum, {SameLine = true})



    if Mods.GizmoLib then
        p:AddDummy(0,0)
        E.grpGizmoDummies = p:AddGroup('GizmoDummies')

        -- E.btnGizmoActive = p:AddButton([[Make gizmo active again if it does not cycle modes]])
        --     UI:Config(E.btnGizmoActive, {
        --         -- SameLine = true,
        --         OnClick = function()
        --             if _GLL.gizmo then
        --                 _GLL.gizmo:SetActive(true)
        --             end
        --         end,
        --         Tooltip = [[        Makes gizmo active again when you closed and opened the top bar      ]]
        --     })

        p:AddDummy(0,0)
        E.checkPreventGizmo = p:AddCheckbox('Prevent gizmo when selecting in Dummies')
    end



    E.checkDummiesPop = p:AddCheckbox('Dummies popup')
        UI:Config(E.checkDummiesPop, {
            SameLine = false,
            OnChange = function(e)
                if not _GLL.States.inPhotoMode then E.checkDummiesPop.Checked = false return end
                for _, v in pairs(PM.DummyWidgets) do
                    v.Window.Visible = E.checkDummiesPop.Checked
                end
            end,
            Tooltip = [[        Small popups above dummies      ]]
        })



    E.infoCollapse = p:AddCollapsingHeader('Info')
    E.infoCollapse.DefaultOpen = Settings.openByDefaultPMInfo



    E.posInput = E.infoCollapse:AddInputScalar('Position')
        UI:Config(E.posInput, {
            Components = 3,
            Value      = {0, 0, 0, 0}
        })



    E.rotInput = E.infoCollapse:AddInputScalar('Rotation')
        UI:Config(E.rotInput, {
            Components = 3,
            Value      = {0, 0, 0, 0}
        })



    E.scaleInput = E.infoCollapse:AddInputScalar('Scale')
        UI:Config(E.scaleInput, {
            Components = 3,
            Value      = {1, 1, 1, 0}
        })



    E.applyButton = E.infoCollapse:AddButton('Apply')
        UI:Config(E.applyButton, {
            SameLine  = false,
            OnClick   = ApplyDummyTransform
        })


    E.infoCollapse:AddSeparator()



    E.charPosCollapse = p:AddCollapsingHeader("Position")
    E.charPosCollapse.DefaultOpen = Settings.openByDefaultPMPos



    E.stemModSlider = E.charPosCollapse:AddSliderInt("", 0, 1, 10000, 1)
        UI:Config(E.stemModSlider, {
            SameLine    = false,
            Components  = 1,
            Logarithmic = true,
            Value       = {1500, 0, 0, 0},
            OnChange    = function()
                STEP_MOD = E.stemModSlider.Value[1]
            end
        })



    E.resetStemMod = E.charPosCollapse:AddButton('How fast are the sliders')
        UI:Config(E.resetStemMod, {
            SameLine  = true,
            OnClick   = function()
                E.stemModSlider.Value = {1500, 0, 0, 0}
            end
        })



    E.posX = E.charPosCollapse:AddSlider("W/E", 0, -100, 100, 1)
        UI:Config(E.posX, {
            SameLine   = false,
            Components = 1,
            Value      = {0, 0, 0, 0},
            OnChange   = function(e)
                MoveCharacter("x", e.Value[1], STEP_MOD, selectedCharacter)
                E.posX.Value = {0, 0, 0, 0}
            end
        })



    E.posY = E.charPosCollapse:AddSlider("D/U", 0, -100, 100, 1)
        UI:Config(E.posY, {
            SameLine   = false,
            Components = 1,
            Value      = {0, 0, 0, 0},
            OnChange   = function(e)
                MoveCharacter("y", e.Value[1], STEP_MOD, selectedCharacter)
                E.posY.Value = {0, 0, 0, 0}
            end
        })



    E.posZ = E.charPosCollapse:AddSlider("S/N", 0, -100, 100, 1)
        UI:Config(E.posZ, {
            SameLine   = false,
            Components = 1,
            Value      = {0, 0, 0, 0},
            OnChange   = function(e)
                MoveCharacter("z", e.Value[1], STEP_MOD, selectedCharacter)
                E.posZ.Value = {0, 0, 0, 0}
            end
        })



    E.posReset = E.charPosCollapse:AddButton('Reset')
        UI:Config(E.posReset, {
            OnClick = function(e)
                local Translate = _GLL.DummyVeryOriginalTransforms[GetSelectedDummyOwnerUuid()].Translate
                MoveCharacter('reset', Translate, STEP_MOD, selectedCharacter)
            end
        })



    E.charPosCollapse:AddSeparator()



    E.charRotCollapse = p:AddCollapsingHeader("Rotation")
    E.charRotCollapse.DefaultOpen = Settings.openByDefaultPMRot



    E.rotationModSlider = E.charRotCollapse:AddSliderInt("", 0, 1, 10000, 1)
        UI:Config(E.rotationModSlider, {
            Logarithmic = true,
            SameLine    = false,
            Components  = 1,
            Value       = {1500, 0, 0, 0},
            OnChange    = function()
                ROT_MOD = E.rotationModSlider.Value[1]
            end
        })



    E.resetROT_MOD = E.charRotCollapse:AddButton('How fast are the sliders')
        UI:Config(E.resetROT_MOD, {
            SameLine  = true,
            OnClick   = function()
                E.rotationModSlider.Value = {1500, 0, 0, 0}
            end
        })



    E.rotX = E.charRotCollapse:AddSlider("Pitch", 0, -100, 100, 1)
        UI:Config(E.rotX, {
            SameLine   = false,
            Components = 1,
            Value      = {0, 0, 0, 0},
            OnChange   = function()
                local value = E.rotX.Value[1]
                RotateCharacter("x", value, ROT_MOD, selectedCharacter)
                E.rotX.Value = {0, 0, 0, 0}
            end
        })



    E.rotY = E.charRotCollapse:AddSlider("Yaw", 0, -100, 100, 1)
        UI:Config(E.rotY, {
            SameLine   = false,
            Components = 1,
            Value      = {0, 0, 0, 0},
            OnChange   = function()
                local value = E.rotY.Value[1]
                RotateCharacter("y", value, ROT_MOD, selectedCharacter)
                E.rotY.Value = {0, 0, 0, 0}
            end
        })



    E.rotZ = E.charRotCollapse:AddSlider("Roll", 0, -100, 100, 1)
        UI:Config(E.rotZ, {
            SameLine   = false,
            Components = 1,
            Value      = {0, 0, 0, 0},
            OnChange   = function()
                local value = E.rotZ.Value[1]
                RotateCharacter("z", value, ROT_MOD, selectedCharacter)
                E.rotZ.Value = {0, 0, 0, 0}
            end
        })



    E.resetRot = E.charRotCollapse:AddButton("Reset")
        UI:Config(E.resetRot, {
            SameLine  = false,
            OnClick   = function()
                local RotationQuat = _GLL.DummyVeryOriginalTransforms[GetSelectedDummyOwnerUuid()].RotationQuat
                RotateCharacter('reset', RotationQuat, STEP_MOD, selectedCharacter)
            end
        })

    E.charRotCollapse:AddSeparator()



    E.charScaleCollapse = p:AddCollapsingHeader("Scale")
    E.charScaleCollapse.DefaultOpen = Settings.openByDefaultPMScale



    E.scaleModSlider = E.charScaleCollapse:AddSliderInt("", 0, 1, 10000, 1)
        UI:Config(E.scaleModSlider, {
            Logarithmic = true,
            SameLine    = false,
            Components  = 1,
            Value       = {1500, 0, 0, 0},
            OnChange    = function()
                SCALE_MOD = E.scaleModSlider.Value[1]
            end
        })



    E.resetScaMod = E.charScaleCollapse:AddButton('How fast are the sliders')
        UI:Config(E.resetScaMod, {
            SameLine  = true,
            OnClick   = function()
                E.scaleModSlider.Value = {1500, 0, 0, 0}
            end
        })



    E.scaleLenght = E.charScaleCollapse:AddSlider("Length", 0, -100, 100, 1)
        UI:Config(E.scaleLenght, {
            SameLine   = false,
            Components = 1,
            Value      = {0, 0, 0, 0},
            OnChange   = function()
                local value = E.scaleLenght.Value[1]
                ScaleCharacter("x", value, SCALE_MOD, selectedCharacter)
                E.scaleLenght.Value = {0, 0, 0, 0}
            end
        })



    E.scaleWidth = E.charScaleCollapse:AddSlider("Height", 0, -100, 100, 1)
        UI:Config(E.scaleWidth, {
            SameLine   = false,
            Components = 1,
            Value      = {0, 0, 0, 0},
            OnChange   = function()
                local value = E.scaleWidth.Value[1]
                ScaleCharacter("y", value, SCALE_MOD, selectedCharacter)
                E.scaleWidth.Value = {0, 0, 0, 0}
            end
        })



    E.scaleHeight = E.charScaleCollapse:AddSlider("Width", 0, -100, 100, 1)
        UI:Config(E.scaleHeight, {
            SameLine   = false,
            Components = 1,
            Value      = {0, 0, 0, 0},
            OnChange   = function()
                local value = E.scaleHeight.Value[1]
                ScaleCharacter("z", value, SCALE_MOD, selectedCharacter)
                E.scaleHeight.Value = {0, 0, 0, 0}
            end
        })



    E.scaleAll = E.charScaleCollapse:AddSlider("All", 0, -100, 100, 1)
        UI:Config(E.scaleAll, {
            SameLine   = false,
            Components = 1,
            Value      = {0, 0, 0, 0},
            OnChange   = function()
                local value = E.scaleAll.Value[1]
                ScaleCharacter('all', value, SCALE_MOD, selectedCharacter)
                E.scaleAll.Value = {0, 0, 0, 0}
            end
        })



    E.resetScale = E.charScaleCollapse:AddButton("Reset")
        UI:Config(E.resetScale, {
            SameLine  = false,
            OnClick   = function()
                ScaleCharacter('reset', value, SCALE_MOD, selectedCharacter)
            end
        })



    E.charScaleCollapse:AddSeparator()

    E.collapseParts = p:AddCollapsingHeader('Other body parts')



    local ATT_STEP = 5000

    local AttachmentsToMove = {
        'Hair',
        'Horns',
        'Tail',
        'Headwear',
        'Beard',
    }



    E.comboAtts = E.collapseParts:AddCombo('Attachments')
        UI:Config(E.comboAtts, {
            Options       = AttachmentsToMove,
            SelectedIndex = 0,
        })



    local function GetSelectedAttachment()
        return E.comboAtts.Options[E.comboAtts.SelectedIndex + 1]
    end



    E.collapseAttTrans = E.collapseParts:AddTree('Position')
        UI:Config(E.collapseAttTrans, {
            DefaultOpen = false
        })



    E.tposX = E.collapseAttTrans:AddSlider('W/E', 0, -100, 100, 1)
        UI:Config(E.tposX, {
            SameLine   = false,
            Components = 1,
            Value      = {0, 0, 0, 0},
            OnChange   = function()
                Entity:MoveAttachment(getSelectedDummy(), 'x', E.tposX.Value[1], ATT_STEP, GetSelectedAttachment())
                E.tposX.Value = {0, 0, 0, 0}
            end
        })



    E.tposY = E.collapseAttTrans:AddSlider('D/U', 0, -100, 100, 1)
        UI:Config(E.tposY, {
            SameLine   = false,
            Components = 1,
            Value      = {0, 0, 0, 0},
            OnChange   = function()
                Entity:MoveAttachment(getSelectedDummy(), 'y', E.tposY.Value[1], ATT_STEP, GetSelectedAttachment())
                E.tposY.Value = {0, 0, 0, 0}
            end
        })



    E.tposZ = E.collapseAttTrans:AddSlider('S/N', 0, -100, 100, 1)
        UI:Config(E.tposZ, {
            SameLine   = false,
            Components = 1,
            Value      = {0, 0, 0, 0},
            OnChange   = function()
                Entity:MoveAttachment(getSelectedDummy(), 'z', E.tposZ.Value[1], ATT_STEP, GetSelectedAttachment())
                E.tposZ.Value = {0, 0, 0, 0}
            end
        })



    E.resettPos = E.collapseAttTrans:AddButton('Reset')
        UI:Config(E.resettPos, {
            SameLine = false,
            OnClick  = function()
                local dummy = getSelectedDummy()
                local Visuals = Entity:FindAttachment(dummy, GetSelectedAttachment())
                if not Visuals or #Visuals == 0 then return end
                Visuals[1]:SetWorldTranslate(dummy.Visual.Visual.WorldTransform.Translate)
            end
        })



    E.collapseAttTrans:AddSeparator()



    E.collapseAttRot = E.collapseParts:AddTree('Rotation')
        UI:Config(E.collapseAttRot, {
            DefaultOpen = false
        })



    E.trotX = E.collapseAttRot:AddSlider('Pitch', 0, -100, 100, 1)
        UI:Config(E.trotX, {
            SameLine   = false,
            Components = 1,
            Value      = {0, 0, 0, 0},
            OnChange   = function()
                Entity:RotateAttachment(getSelectedDummy(), 'x', E.trotX.Value[1], ATT_STEP, GetSelectedAttachment())
                E.trotX.Value = {0, 0, 0, 0}
            end
        })



    E.trotY = E.collapseAttRot:AddSlider('Yaw', 0, -100, 100, 1)
        UI:Config(E.trotY, {
            SameLine   = false,
            Components = 1,
            Value      = {0, 0, 0, 0},
            OnChange   = function()
                Entity:RotateAttachment(getSelectedDummy(), 'y', E.trotY.Value[1], ATT_STEP, GetSelectedAttachment())
                E.trotY.Value = {0, 0, 0, 0}
            end
        })



    E.trotZ = E.collapseAttRot:AddSlider('Roll', 0, -100, 100, 1)
        UI:Config(E.trotZ, {
            SameLine   = false,
            Components = 1,
            Value      = {0, 0, 0, 0},
            OnChange   = function()
                Entity:RotateAttachment(getSelectedDummy(), 'z', E.trotZ.Value[1], ATT_STEP, GetSelectedAttachment())
                E.trotZ.Value = {0, 0, 0, 0}
            end
        })



    E.resettRot = E.collapseAttRot:AddButton('Reset')
        UI:Config(E.resettRot, {
            SameLine = false,
            OnClick  = function()
                local dummy = getSelectedDummy()
                local Visuals = Entity:FindAttachment(dummy, GetSelectedAttachment())
                if not Visuals or #Visuals == 0 then return end
                Visuals[1]:SetWorldRotate(dummy.Visual.Visual.WorldTransform.RotationQuat)
            end
        })



    E.collapseAttRot:AddSeparator()



    E.collapseAttSc = E.collapseParts:AddTree('Scale')
        UI:Config(E.collapseAttSc, {
            DefaultOpen = false
        })



    E.tsclX = E.collapseAttSc:AddSlider('Length', 0, -100, 100, 1)
        UI:Config(E.tsclX, {
            SameLine   = false,
            Components = 1,
            Value      = {0, 0, 0, 0},
            OnChange   = function()
                Entity:ScaleAttachment(getSelectedDummy(), 'x', E.tsclX.Value[1], ATT_STEP, GetSelectedAttachment())
                E.tsclX.Value = {0, 0, 0, 0}
            end
        })



    E.tsclY = E.collapseAttSc:AddSlider('Height', 0, -100, 100, 1)
        UI:Config(E.tsclY, {
            SameLine   = false,
            Components = 1,
            Value      = {0, 0, 0, 0},
            OnChange   = function()
                Entity:ScaleAttachment(getSelectedDummy(), 'y', E.tsclY.Value[1], ATT_STEP, GetSelectedAttachment())
                E.tsclY.Value = {0, 0, 0, 0}
            end
        })



    E.tsclZ = E.collapseAttSc:AddSlider('Width', 0, -100, 100, 1)
        UI:Config(E.tsclZ, {
            SameLine   = false,
            Components = 1,
            Value      = {0, 0, 0, 0},
            OnChange   = function()
                Entity:ScaleAttachment(getSelectedDummy(), 'z', E.tsclZ.Value[1], ATT_STEP, GetSelectedAttachment())
                E.tsclZ.Value = {0, 0, 0, 0}
            end
        })



    E.tsclAll = E.collapseAttSc:AddSlider('All', 0, -100, 100, 1)
        UI:Config(E.tsclAll, {
            SameLine   = false,
            Components = 1,
            Value      = {0, 0, 0, 0},
            OnChange   = function()
                Entity:ScaleAttachment(getSelectedDummy(), 'all', E.tsclAll.Value[1], ATT_STEP, GetSelectedAttachment())
                E.tsclAll.Value = {0, 0, 0, 0}
            end
        })



    E.resettScl = E.collapseAttSc:AddButton('Reset')
        UI:Config(E.resettScl, {
            SameLine = false,
            OnClick  = function()
                local dummy = getSelectedDummy()
                local Visuals = Entity:FindAttachment(dummy, GetSelectedAttachment())
                if not Visuals or #Visuals == 0 then return end
                Visuals[1]:SetWorldScale(dummy.Visual.Visual.WorldTransform.Scale)
            end
        })



    E.collapseAttSc:AddSeparator()


    E.saveLoadCollapse = p:AddCollapsingHeader('Save/Load postition')
    E.saveLoadCollapse.DefaultOpen = Settings.openByDefaultPMSave


    saveLoadWindow = E.saveLoadCollapse:AddChildWindow('')
    saveLoadWindow.AlwaysAutoResize = false
    saveLoadWindow.Size = {0, 150}



    E.saveButton = E.saveLoadCollapse:AddButton('Save')
        UI:Config(E.saveButton, {
            SameLine  = false,
            OnClick   = function()
                if _GLL.DummyNameMap then
                    SaveDummyTransformAndCreateSelectable()
                end
            end
        })



    E.exportPosButton = E.saveLoadCollapse:AddButton('Export')
        UI:Config(E.exportPosButton, {
            SameLine  = true,
            OnClick   = function()
                if not _GLL.SavedTransforms then return end

                local json = Ext.Json.Stringify(_GLL.SavedTransforms)
                Ext.IO.SaveFile('LightyLights/ExportedPositions.json', json)
            end
        })



    E.importPosButton = E.saveLoadCollapse:AddButton('Import')
        UI:Config(E.importPosButton, {
            SameLine  = true,
            OnClick   = function()
                if not _GLL.DummyNameMap then return end

                local json = Ext.IO.LoadFile('LightyLights/ExportedPositions.json')
                if not json then DPrint('LOL') return end

                local importData = Ext.Json.Parse(json)
                if not importData then DPrint('XD') return end

                local savedIndex = E.comboDummies.SelectedIndex
                for dummyName, T in pairs(importData) do
                    local entity = _GLL.DummyNameMap[dummyName]
                    if entity then
                        entity.Visual.Visual.WorldTransform = T
                        entity.DummyOriginalTransform.Transform = T

                        for i, name in ipairs(E.comboDummies.Options) do
                            if name == dummyName then
                                E.comboDummies.SelectedIndex = i - 1
                                break
                            end
                        end
                        SaveDummyTransformAndCreateSelectable()
                    end
                end

                E.comboDummies.SelectedIndex = savedIndex
                UpdateCharacterInfo(E.comboDummies.SelectedIndex + 1)
            end
        })



    E.checkAutoSave = E.saveLoadCollapse:AddCheckbox('Re-apply saved positions to dummies')
        UI:Config(E.checkAutoSave, {
            SameLine = true,
            Checked = true,
        })


    E.saveLoadCollapse:AddSeparator()
end



function BetterPMTab(p)
    p:AddSeparatorText('Some controls over environment')

    E.checkPause = p:AddCheckbox('Unpause')
        UI:Config(E.checkPause, {
            OnChange = function(e)
                if not _GLL.States.inPhotoMode then E.checkPause.Checked = false return end

                if not _GLL.pauseEntity then
                    _GLL.pauseEntity = Ext.Entity.GetAllEntitiesWithComponent('Pause')[1]
                end

                if _GLL.pauseEntity then
                    if e.Checked then
                        _GLL.pauseEntity:RemoveComponent('Pause')
                    else
                        _GLL.pauseEntity:CreateComponent('Pause')
                    end
                end
            end
        })



    E.btnSeeThr = p:AddButton('Disable SeeThrough walls circle thingy type thing')
        UI:Config(E.btnSeeThr, {
            SameLine = false,
            OnClick = function()
                for _, v in pairs(Ext.Entity.GetAllEntities()) do
                    -- if v.VisualLoadDescription and v.VisualLoadDescription.Flags.IsScenery then
                        if v.Visual and v.Visual.Visual then
                            for _, h in pairs(v.Visual.Visual.ObjectDescs) do
                                if h.Renderable then
                                    local am = h.Renderable.ActiveMaterial
                                    if am then
                                        for _, g in pairs(am.Material.Parameters.ScalarParameters) do
                                            if g.ParameterName == 'SeeThroughEnabled' then
                                                h.Renderable.ActiveMaterial:SetScalar('SeeThroughEnabled', 0)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    -- end
                end
            end,
            Tooltip = [[        Disables this see-though hole when character is behind a wall or something		]]
        })


    local function DistanceSq(a, b)
        local dx = a[1] - b[1]
        local dy = a[2] - b[2]
        local dz = a[3] - b[3]
        return dx*dx + dy*dy + dz*dz
    end


    local function RemoveFadeables()
        -- local BATCH_SIZE = 10
        -- local TICK_INTERVAL = 10
        local Pos = _C().Transform.Transform.Translate
        local Entities = {}
        local tickCnt = 0
        local index = 1

        for _, ent in pairs(Ext.Entity.GetAllEntitiesWithComponent('FadeableObstruction')) do
            if ent.Transform then
                if DistanceSq(Pos, ent.Transform.Transform.Translate) < Settings.fadeableDistance then
                    table.insert(Entities, ent)
                end
            end
        end

        Utils:SubUnsubToTick(1, 'fade', function()
            tickCnt = tickCnt + 1
            if tickCnt % Settings.fadeableTickInterval ~= 0 then return end

            for i = index, math.min(index + Settings.fadeableBatchSize - 1, #Entities) do
                local ent = Entities[i]
                if ent and ent.FadeableObstruction then
                    ent:RemoveComponent('FadeableObstruction')
                end
            end

            index = index + Settings.fadeableBatchSize

            E.progressFade.Value = index / #Entities

            if index > #Entities then
                Utils:SubUnsubToTick(0, 'fade')
                E.progressFade.Value = 0
            end
        end)

    end



    E.btnTaperFade = p:AddButton('Remove fadeable objects')
        UI:Config(E.btnTaperFade, {
            OnClick = RemoveFadeables,
            Tooltip = [[        Removed fadeable objects like roofs and walls		]]
        })


    E.progressFade = p:AddProgressBar('Fade progress')
    E.progressFade.Size = {850, 0}
    E.progressFade.Value = 0
end



function BetterPMCam(p)
    p:AddSeparatorText('Camera controls')

    Ext.Stats.GetStatsManager().ExtraData['PhotoModeCameraMovementSpeed'] = Settings.defaultCameraSpeed

    E.camSpeed = p:AddSlider('Speed [W SPEED]', 0, 0.01, 100)
        UI:Config(E.camSpeed, {
            SameLine    = false,
            Logarithmic = true,
            Value       = {Settings.defaultCameraSpeed, 0, 0, 0},
            OnChange    = function(e)
                Ext.Stats.GetStatsManager().ExtraData['PhotoModeCameraMovementSpeed'] = e.Value[1]
            end
        })


    E.camFov = p:AddSlider('FoV', 1, 0.1, 2)
        UI:Config(E.camFov, {
            SameLine = false,
            OnChange = function(e)
                CameraControlls('FOV', e.Value[1])
            end
        })



    E.slFarPlane = p:AddSlider('Far plane distance', 1000, 0, 5000)
        UI:Config(E.slFarPlane, {
            Logarithmic = true,
            OnChange    = function(e)
                CameraControlls('FarPlane', e.Value[1])
            end,
            Tooltip = [[        How far from the camera an object can be displayed      ]]
        })



    E.slNearPlane = p:AddSlider('Near plane distance', 0.025, 0.001, 0.025)
        UI:Config(E.slNearPlane, {
            Logarithmic = true,
            OnChange    = function(e)
                CameraControlls('NearPlane', e.Value[1])
            end,
            Tooltip = [[        How close to the camera an object can be displayed      ]]
        })


    p:AddDummy(0, 20)
    p:AddSeparatorText('DoF')


    E.dofStrength = p:AddSlider('Strength', 0, 22, 1, 0.001)
        UI:Config(E.dofStrength, {
            SameLine    = false,
            Logarithmic = true,
            Components  = 1,
            Value       = {1, 0, 0, 0},
            OnChange    = function()
                local i = _GLL.Sta
                local s, err = DealingWithNoesis(function()
                    return Ext.UI.GetRoot():Find("ContentRoot"):Child(_GLL.npmi).DataContext.DOFStrength
                end)

                if s then
                    local preciseDofStr = (E.dofStrength.Value[1])
                    Ext.UI.Defer(function ()
                        Ext.UI.GetRoot():Find("ContentRoot"):Child(_GLL.npmi).DataContext.DOFStrength = preciseDofStr
                    end)
                end
            end
        })


    local function DofChange(value)
        local s, r = DealingWithNoesis(function()
            return Ext.UI.GetRoot():Find("ContentRoot"):Child(_GLL.npmi).DataContext.DOFDistance
        end)

        if s then
            Ext.UI.Defer(function ()
                Ext.UI.GetRoot():Find("ContentRoot"):Child(_GLL.npmi).DataContext.DOFDistance = value
            end)
        end
    end



    E.dofDistance = p:AddSlider("", 0, 0, 30, 0.001)
        UI:Config(E.dofDistance, {
            SameLine    = false,
            Logarithmic = true,
            Components  = 1,
            Value       = {1, 0, 0, 0},
            OnChange    = function()
                DofChange(E.dofDistance.Value[1])
            end
        })



    E.btnDofDistanceDec = p:AddButton('<')
        UI:Config(E.btnDofDistanceDec, {
            SameLine = true,
            OnClick  = function()
                DofChange(E.dofDistance.Value[1] + 0.0005)
            end
        })



    E.btnDofDistanceInc = p:AddButton('>')
        UI:Config(E.btnDofDistanceInc, {
            SameLine = true,
            OnClick  = function()
                DofChange(E.dofDistance.Value[1] - 0.0005)
            end
        })



    textDofDistance = p:AddText('Distance')
        UI:Config(textDofDistance, { SameLine = true })


    p:AddDummy(0, 20)
    p:AddSeparatorText('Save/Load position')




    E.btnSavePos = p:AddButton('Save')
        UI:Config(E.btnSavePos, {
            OnClick = CreateSelectableForSavedCameraPos
        })


    E.windowLoadPos = p:AddChildWindow('Load')
    E.windowLoadPos.Size = {0, 100}

end

--- Crashes
--[[
for _, ent in pairs(Ext.Entity.GetAllEntitiesWithComponent('FadeableObstruction')) do
    _D(ent:RemoveComponent('FadeableObstruction'))
end
]]--



--- Doesn't get Constructions
--[[
for _, ent in pairs(Ext.Entity.GetEntitiesAroundPosition(_C().Transform.Transform.Translate, 30)) do
    if ent.FadeableObstruction then
        _D(ent:RemoveComponent('FadeableObstruction'))
    end
end
]]--



--- Doesn't get Constructions
--[[
for _, shape in pairs(Ext.Level.TestSphere(_C().Transform.Transform.Translate, 140, 4, 4096, 16, 1).Shapes) do
    _D(shape.PhysicsObject.Entity:RemoveComponent('FadeableObstruction'))
end
]]--



---Lowkey works
--[[
for _, ent in pairs(Ext.Entity.GetAllEntities()) do
    if ent.FadeableObstruction and ent.Transform then
        if Mods.LL2.DistanceSq(_C().Transform.Transform.Translate, ent.Transform.Transform.Translate) < 100 then
            ent:RemoveComponent('FadeableObstruction')
        end
    end
end
]]--
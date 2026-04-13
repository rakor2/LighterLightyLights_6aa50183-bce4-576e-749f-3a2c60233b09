function BetterPMTab(parent)
    local function getSelectedDummyOwnerUuid()
        local entity = _GLL.DummyNameMap[E.cmbBoneDummies.Options[selectedCharacter]]
        if entity then
            local characterUuid = entity.Dummy.Entity.Uuid.EntityUuid
            if characterUuid then
                return characterUuid
            end
        end
    end


    local camSepa = parent:AddSeparatorText('Camera controls')
    E.checkPause = parent:AddCheckbox('Unpause')
        UI:Config(E.checkPause, {
            OnChange = function(e)
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

    E.btnSeeThr = parent:AddButton('Disable SeeThrough walls circle thingy type thing')
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
            end
        })
    local function DistanceSq(a, b)
        local dx = a[1] - b[1]
        local dy = a[2] - b[2]
        local dz = a[3] - b[3]
        return dx*dx + dy*dy + dz*dz
    end
    local function removeFadeables()
        local BATCH_SIZE = 10
        local TICK_INTERVAL = 10
        local Pos = _C().Transform.Transform.Translate
        local Entities = {}
        local tickCnt = 0
        local index = 1
        local tick
        for _, ent in pairs(Ext.Entity.GetAllEntitiesWithComponent('FadeableObstruction')) do
            if ent.Transform then
                if DistanceSq(Pos, ent.Transform.Transform.Translate) < 10000 then
                    table.insert(Entities, ent)
                end
            end
        end

        tick = Ext.Events.Tick:Subscribe(function()
            tickCnt = tickCnt + 1
            if tickCnt % TICK_INTERVAL ~= 0 then return end

            for i = index, math.min(index + BATCH_SIZE - 1, #Entities) do
                local ent = Entities[i]
                if ent and ent.FadeableObstruction then
                    ent:RemoveComponent('FadeableObstruction')
                end
            end

            index = index + BATCH_SIZE

            E.progressFace.Value = index / #Entities

            if index > #Entities then
                Ext.Events.Tick:Unsubscribe(tick)
                E.progressFace.Value = 0
            end
        end)
    end


    E.btnTaperFade = parent:AddButton('Remove fade objects [SE Devel only]')
        UI:Config(E.btnTaperFade, {
            OnClick = function(e)
                s, err = pcall(removeFadeables)
                if err then DPrint('Remove fade objects available only on Devel version of SE') end
            end
        })


    E.progressFace = parent:AddProgressBar('Fade progress')
    E.progressFace.Size = {850, 0}
    E.progressFace.Value = 0



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


    parent:AddSeparatorText('Camera controls')



    E.camCollapse = parent:AddCollapsingHeader('Parameters')
    E.camCollapse.DefaultOpen = openByDefaultPMCamera



    Ext.Stats.GetStatsManager().ExtraData['PhotoModeCameraMovementSpeed'] = defaultCameraSpeed

    E.camSpeed = E.camCollapse:AddSlider('Speed', 0, 0.01, 100, 0.1)
        UI:Config(E.camSpeed, {
            SameLine   = false,
            Logarithmic = true,
            Components = 1,
            Value      = {defaultCameraSpeed, 0, 0, 0},
            OnChange   = function()
                Ext.Stats.GetStatsManager().ExtraData['PhotoModeCameraMovementSpeed'] = E.camSpeed.Value[1]
            end
        })



    E.slFarPlane = E.camCollapse:AddSlider('Far plane distance', 1000, 0, 5000, 1)
        UI:Config(E.slFarPlane, {
            Logarithmic = true,
            OnChange    = function(e)
                CameraControlls('Far_plane', e.Value[1])
            end
        })



    E.slNearPlane = E.camCollapse:AddSlider('Near plane distance', 0.025, 0.001, 0.025, 1)
        UI:Config(E.slNearPlane, {
            Logarithmic = true,
            OnChange    = function(e)
                CameraControlls('Near_plane', e.Value[1])
            end
        })



    E.dofCollapse = parent:AddCollapsingHeader("DoF")
    E.dofCollapse.DefaultOpen = false



    E.dofStrength = E.dofCollapse:AddSlider("Strength", 0, 22, 1, 0.001)
        UI:Config(E.dofStrength, {
            SameLine    = false,
            Logarithmic = true,
            Components  = 1,
            Value       = {1, 0, 0, 0},
            OnChange    = function()
                local success, result = pcall(function()
                    return Ext.UI.GetRoot():Find("ContentRoot"):Child(21).DataContext.DOFStrength
                end)

                if success and result then
                    local preciseDofStr = (E.dofStrength.Value[1])
                    Ext.UI.GetRoot():Find("ContentRoot"):Child(21).DataContext.DOFStrength = preciseDofStr
                end
            end
        })


    local getDofStrengthSub = Ext.Events.Tick:Subscribe(function()
        local success, result = pcall(function()
            return Ext.UI.GetRoot():Find("ContentRoot"):Child(21).DataContext.DOFStrength
        end)

        if success and result then
            getDofStrength = result
            E.dofStrength.Value = { getDofStrength, 0, 0, 0 }
        end
    end)


    local function dofChange(value)
        local success, result = pcall(function()
            return Ext.UI.GetRoot():Find("ContentRoot"):Child(21).DataContext.DOFDistance
        end)

        if success and result then
            Ext.UI.GetRoot():Find("ContentRoot"):Child(21).DataContext.DOFDistance = value
        end
    end



    E.dofDistance = E.dofCollapse:AddSlider("", 0, 0, 30, 0.001)
        UI:Config(E.dofDistance, {
            SameLine    = false,
            Logarithmic = true,
            Components  = 1,
            Value       = {1, 0, 0, 0},
            OnChange    = function()
                dofChange(E.dofDistance.Value[1])
            end
        })



    E.btnDofDistanceDec = E.dofCollapse:AddButton('<')
        UI:Config(E.btnDofDistanceDec, {
            SameLine = true,
            OnClick  = function()
                dofChange(E.dofDistance.Value[1] + 0.0005)
            end
        })



    E.btnDofDistanceInc = E.dofCollapse:AddButton('>')
        UI:Config(E.btnDofDistanceInc, {
            SameLine = true,
            OnClick  = function()
                dofChange(E.dofDistance.Value[1] - 0.0005)
            end
        })



    textDofDistance = E.dofCollapse:AddText('Distance')
        UI:Config(textDofDistance, { SameLine = true })



    E.collapseSavePos = parent:AddCollapsingHeader('Save/Load position')



    local btnCounter = 0
    local savedButtons = {}

    E.btnSavePos = E.collapseSavePos:AddButton('Save')
        UI:Config(E.btnSavePos, {
            OnClick   = function()
                if not _GLL.States.inPhotoMode then return end

                btnCounter = btnCounter + 1
                local currentIndex = btnCounter
                local size = 0

                CameraSaveLoadPosition(currentIndex)

                E.windowLoadPos.Size = {
                    E.windowLoadPos.Size[1],
                    E.windowLoadPos.Size[2] + size
                }

                local btnDelete = E.windowLoadPos:AddButton('X')
                    UI:Config(btnDelete, { IDContext = 'delete_' .. currentIndex })

                local btnLoad = E.windowLoadPos:AddButton('')
                    UI:Config(btnLoad, {
                        IDContext = 'load_' .. currentIndex,
                        SameLine  = true,
                        Label     = tostring(currentIndex)
                    })

                savedButtons[currentIndex] = {
                    load   = btnLoad,
                    delete = btnDelete
                }

                btnDelete.OnClick = function()
                    if savedButtons[currentIndex] then
                        savedButtons[currentIndex].load:Destroy()
                        savedButtons[currentIndex].delete:Destroy()
                        savedButtons[currentIndex] = nil
                        _GLL.CameraPositions[tostring(currentIndex)] = nil

                        E.windowLoadPos.Size = {
                            E.windowLoadPos.Size[1],
                            E.windowLoadPos.Size[2] - size
                        }
                    end
                end

                btnLoad.OnClick = function()
                    local index = tostring(currentIndex)
                    if _GLL.CameraPositions[index] then
                        local camera = Camera:GetActiveCamera()
                        camera.PhotoModeCameraSavedTransform.Transform.Translate     = _GLL.CameraPositions[index].activeTranslate
                        camera.PhotoModeCameraSavedTransform.Transform.RotationQuat  = _GLL.CameraPositions[index].activeRotationQuat
                        camera.PhotoModeCameraSavedTransform.Transform.Scale         = _GLL.CameraPositions[index].activeScale

                        Helpers.Timer:OnTicks(5, function()
                            Ext.UI.GetRoot():Find("ContentRoot"):Child(21).DataContext.RecallCameraTransform:Execute()
                        end)
                    end
                end
            end
        })


    E.windowLoadPos = E.collapseSavePos:AddChildWindow('Load')
    E.windowLoadPos.Size = {0, 100}

    local sepa2 = parent:AddSeparatorText('Dummy controls')



    function UpdateDummyCombo(e)
        if not _GLL.States.inPhotoMode then return end

        PM.DummyWidgets[_GLL.DummyNames[selectedCharacter]].Window:SetColor('WindowBg', Style.Colors.windowBg)
        PM.DummyWidgets[_GLL.DummyNames[selectedCharacter]].Window:SetColor('Text', Style.Colors.textColor)
        selectedCharacter = e.SelectedIndex + 1

        E.visTemComob.SelectedIndex    = e.SelectedIndex
        E.cmbBoneDummies.SelectedIndex = e.SelectedIndex

        local dummyId = _GLL.DummyNames[selectedCharacter]

        if Mods.GizmoLib and not E.checkPreventGizmo.Checked then

            for k, v in pairs(_GLL.DummyNames) do
                E.checkAddTarget[v].Checked = false
            end

            local selectedUuid = _GLL.DummyNameMap[dummyId].Dummy.Entity.Uuid.EntityUuid
            E.checkAddTarget[dummyId].Checked = true
            _GLL.gizmo:Select({_GLL.DummyNameMap[dummyId].Dummy.Entity})
        end

        UpdateCharacterInfo(selectedCharacter)
        SetVarValuesToSliders()
        LoadAttachState(getSelectedDummy())
        PM.DummyWidgets[selectedId].Window:SetColor('WindowBg', Style.Colors.special)
        SetHighlightColor(PM.DummyWidgets[selectedId].Window)
    end



    function GizmoSelectDummy()
        local selectedId = _GLL.DummyNames[selectedCharacter]
        local entity = _GLL.DummyNameMap[selectedId].Dummy.Entity
        _GLL.gizmo:Select({entity})
    end



    E.visTemComob = parent:AddCombo('')
        UI:Config(E.visTemComob, {
            SelectedIndex = 0,
            Options      = {'Not in Photo Mode'},
            HeightLargest = true,
            SameLine     = false,
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
    selectedCharacter = E.visTemComob.SelectedIndex + 1



    E.btnDumPrev = parent:AddButton('<')
        UI:Config(E.btnDumPrev, {
            SameLine = true,
            OnClick  = function(e)
                UI:PrevOption(E.visTemComob)
                UpdateDummyCombo(E.visTemComob)
            end
        })



    E.btnDumNext = parent:AddButton('>')
        UI:Config(E.btnDumNext, {
            SameLine = true,
            OnClick  = function(e)
                UI:NextOption(E.visTemComob)
                UpdateDummyCombo(E.visTemComob)
            end
        })




    local txtDum = parent:AddText('Dummies')
        UI:Config(txtDum, {SameLine = true})


    if Mods.GizmoLib then
        parent:AddDummy(0,0)
        E.grpGizmoDummies = parent:AddGroup('GizmoDummies')

        parent:AddDummy(0,0)
        E.checkPreventGizmo = parent:AddCheckbox('Prevent gizmo when selecting in Dummies')
    end

    parent:AddDummy(0,0)
    E.checkDummiesPop = parent:AddCheckbox('Dummies popup')
        UI:Config(E.checkDummiesPop, {
            SameLine = true,
            OnChange = function(e)
                if not _GLL.States.inPhotoMode then E.checkDummiesPop.Checked = false return end
                for _, v in pairs(PM.DummyWidgets) do
                    v.Window.Visible = E.checkDummiesPop.Checked
                end
            end
        })


    E.infoCollapse = parent:AddCollapsingHeader('Info')
    E.infoCollapse.DefaultOpen = openByDefaultPMInfo



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
            OnClick   = function()
                if _GLL.DummyNameMap and _GLL.DummyNameMap[E.visTemComob.Options[selectedCharacter]] then

                    local transform  = _GLL.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.WorldTransform
                    local transform2 = _GLL.DummyNameMap[E.visTemComob.Options[selectedCharacter]].DummyOriginalTransform.Transform

                    local deg  = {E.rotInput.Value[1], E.rotInput.Value[2], E.rotInput.Value[3]}
                    local quats = Math.EulerToQuats(deg)

                    transform.RotationQuat = quats
                    transform.Scale        = {E.scaleInput.Value[1], E.scaleInput.Value[2], E.scaleInput.Value[3]}
                    transform.Translate    = {E.posInput.Value[1],   E.posInput.Value[2],   E.posInput.Value[3]}

                    transform2.RotationQuat = quats
                    transform2.Scale        = {E.scaleInput.Value[1], E.scaleInput.Value[2], E.scaleInput.Value[3]}
                    transform2.Translate    = {E.posInput.Value[1],   E.posInput.Value[2],   E.posInput.Value[3]}
                end
            end
        })


    E.infoCollapse:AddSeparator()



    E.charPosCollapse = parent:AddCollapsingHeader("Position")
    E.charPosCollapse.DefaultOpen = openByDefaultPMPos



    E.stemModSlider = E.charPosCollapse:AddSliderInt("", 0, 1, 10000, 1)
        UI:Config(E.stemModSlider, {
            SameLine    = false,
            Components  = 1,
            Logarithmic = true,
            Value       = {1500, 0, 0, 0},
            OnChange    = function()
                stepMod = E.stemModSlider.Value[1]
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
                MoveCharacter("x", e.Value[1], stepMod, selectedCharacter)
                E.posX.Value = {0, 0, 0, 0}
            end
        })



    E.posY = E.charPosCollapse:AddSlider("D/U", 0, -100, 100, 1)
        UI:Config(E.posY, {
            SameLine   = false,
            Components = 1,
            Value      = {0, 0, 0, 0},
            OnChange   = function(e)
                MoveCharacter("y", e.Value[1], stepMod, selectedCharacter)
                E.posY.Value = {0, 0, 0, 0}
            end
        })



    E.posZ = E.charPosCollapse:AddSlider("S/N", 0, -100, 100, 1)
        UI:Config(E.posZ, {
            SameLine   = false,
            Components = 1,
            Value      = {0, 0, 0, 0},
            OnChange   = function(e)
                MoveCharacter("z", e.Value[1], stepMod, selectedCharacter)
                E.posZ.Value = {0, 0, 0, 0}
            end
        })



    E.posReset = E.charPosCollapse:AddButton('Reset')
        UI:Config(E.posReset, {
            OnClick = function(e)
                local x, y, z = table.unpack(_GLL.DummyVeryOriginalTransforms[getSelectedDummyOwnerUuid()].Translate)
                _GLL.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.WorldTransform.Translate = {x, y, z}
                UpdateCharacterInfo(selectedCharacter)
            end
        })


    E.charPosCollapse:AddSeparator()



    E.charRotCollapse = parent:AddCollapsingHeader("Rotation")
    E.charRotCollapse.DefaultOpen = openByDefaultPMRot



    E.rotationModSlider = E.charRotCollapse:AddSliderInt("", 0, 1, 10000, 1)
        UI:Config(E.rotationModSlider, {
            Logarithmic = true,
            SameLine    = false,
            Components  = 1,
            Value       = {1500, 0, 0, 0},
            OnChange    = function()
                rotMod = E.rotationModSlider.Value[1]
            end
        })



    E.resetRotMod = E.charRotCollapse:AddButton('How fast are the sliders')
        UI:Config(E.resetRotMod, {
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
                RotateCharacter("x", value, rotMod, selectedCharacter)
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
                RotateCharacter("y", value, rotMod, selectedCharacter)
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
                RotateCharacter("z", value, rotMod, selectedCharacter)
                E.rotZ.Value = {0, 0, 0, 0}
            end
        })



    E.resetRot = E.charRotCollapse:AddButton("Reset")
        UI:Config(E.resetRot, {
            SameLine  = false,
            OnClick   = function()
                local x, y, z, w = table.unpack(_GLL.DummyVeryOriginalTransforms[getSelectedDummyOwnerUuid()].RotationQuat)
                _GLL.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.WorldTransform.RotationQuat = {x, y, z, w}
                UpdateCharacterInfo(selectedCharacter)
            end
        })

    E.charRotCollapse:AddSeparator()



    E.charScaleCollapse = parent:AddCollapsingHeader("Scale")
    E.charScaleCollapse.DefaultOpen = openByDefaultPMScale



    E.scaleModSlider = E.charScaleCollapse:AddSliderInt("", 0, 1, 10000, 1)
        UI:Config(E.scaleModSlider, {
            Logarithmic = true,
            SameLine    = false,
            Components  = 1,
            Value       = {1500, 0, 0, 0},
            OnChange    = function()
                scaleMod = E.scaleModSlider.Value[1]
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
                ScaleCharacter("x", value, scaleMod, selectedCharacter)
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
                ScaleCharacter("y", value, scaleMod, selectedCharacter)
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
                ScaleCharacter("z", value, scaleMod, selectedCharacter)
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
                ScaleCharacter("all", value, scaleMod, selectedCharacter)
                E.scaleAll.Value = {0, 0, 0, 0}
            end
        })



    E.resetScale = E.charScaleCollapse:AddButton("Reset")
        UI:Config(E.resetScale, {
            SameLine  = false,
            OnClick   = function()
                local x, y, z = table.unpack(_GLL.DummyVeryOriginalTransforms[getSelectedDummyOwnerUuid()].Scale)
                _GLL.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.WorldTransform.Scale = {x, y, z}
                UpdateCharacterInfo(selectedCharacter)
                -- E.scaleInput.Label = string.format('L: %.2f  H: %.2f  W: %.2f', 1, 1, 1)
            end
        })


    E.charScaleCollapse:AddSeparator()



    E.collapseParts = parent:AddCollapsingHeader('Other body parts')

    E.treeTail = E.collapseParts:AddTree('Tail')

    E.tailPosCollapse = E.treeTail:AddTree("Position")
        UI:Config(E.tailPosCollapse, {
            DefaultOpen  = false
        })



    E.tposX = E.tailPosCollapse:AddSlider("W/E", 0, -100, 100, 1)
        UI:Config(E.tposX, {
            SameLine   = false,
            Components = 1,
            Value      = {0, 0, 0, 0},
            OnChange   = function()
                local value = E.tposX.Value[1]
                MoveTail("x", value, 3000, selectedCharacter)
                E.tposX.Value = {0, 0, 0, 0}
            end
        })



    E.tposY = E.tailPosCollapse:AddSlider("D/U", 0, -100, 100, 1)
        UI:Config(E.tposY, {
            SameLine   = false,
            Components = 1,
            Value      = {0, 0, 0, 0},
            OnChange   = function()
                local value = E.tposY.Value[1]
                MoveTail("y", value, 3000, selectedCharacter)
                E.tposY.Value = {0, 0, 0, 0}
            end
        })



    E.tposZ = E.tailPosCollapse:AddSlider("S/N", 0, -100, 100, 1)
        UI:Config(E.tposZ, {
            SameLine   = false,
            Components = 1,
            Value      = {0, 0, 0, 0},
            OnChange   = function()
                local value = E.tposZ.Value[1]
                MoveTail("z", value, 3000, selectedCharacter)
                E.tposZ.Value = {0, 0, 0, 0}
            end
        })



    E.resettPos = E.tailPosCollapse:AddButton("Reset")
        UI:Config(E.resettPos, {
            SameLine  = false,
            OnClick   = function()
                for i = 1, #_GLL.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments do
                    if _GLL.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments[i].Visual.VisualResource.Objects[1].ObjectID:lower():find('tail') then
                        _GLL.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments[i].Visual:SetWorldTranslate(
                            _GLL.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.WorldTransform.Translate)
                        break
                    end
                end
            end
        })



    E.tailPosCollapse:AddSeparator()



    E.tailRotCollapse = E.treeTail:AddTree("Rotation")
        UI:Config(E.tailRotCollapse, {
            DefaultOpen = false
        })



    E.trotX = E.tailRotCollapse:AddSlider("Pitch", 0, -100, 100, 1)
        UI:Config(E.trotX, {
            SameLine   = false,
            Components = 1,
            Value      = {0, 0, 0, 0},
            OnChange   = function()
                local value = E.trotX.Value[1]
                RotateTail("x", value, 3000, selectedCharacter)
                E.trotX.Value = {0, 0, 0, 0}
            end
        })



    E.trotY = E.tailRotCollapse:AddSlider("Yaw", 0, -100, 100, 1)
        UI:Config(E.trotY, {
            SameLine   = false,
            Components = 1,
            Value      = {0, 0, 0, 0},
            OnChange   = function()
                local value = E.trotY.Value[1]
                RotateTail("y", value, 3000, selectedCharacter)
                E.trotY.Value = {0, 0, 0, 0}
            end
        })



    E.trotZ = E.tailRotCollapse:AddSlider("Roll", 0, -100, 100, 1)
        UI:Config(E.trotZ, {
            SameLine   = false,
            Components = 1,
            Value      = {0, 0, 0, 0},
            OnChange   = function()
                local value = E.trotZ.Value[1]
                RotateTail("z", value, 3000, selectedCharacter)
                E.trotZ.Value = {0, 0, 0, 0}
            end
        })



    E.resettRot = E.tailRotCollapse:AddButton("Reset")
        UI:Config(E.resettRot, {
            SameLine  = false,
            OnClick   = function()
                for i = 1, #_GLL.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments do
                    if _GLL.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments[i].Visual.VisualResource.Objects[1].ObjectID:lower():find('tail') then
                        _GLL.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments[i].Visual:SetWorldRotate(
                            _GLL.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.WorldTransform.RotationQuat)
                        break
                    end
                end
            end
        })

    E.tailRotCollapse:AddSeparator()


    E.treeHorns = E.collapseParts:AddTree('Horns')



    E.hornsPosCollapse = E.treeHorns:AddTree("Position")
        UI:Config(E.hornsPosCollapse, {
            DefaultOpen = false
        })



    E.hposX = E.hornsPosCollapse:AddSlider("W/E", 0, -100, 100, 1)
        UI:Config(E.hposX, {
            SameLine   = false,
            Components = 1,
            Value      = {0, 0, 0, 0},
            OnChange   = function()
                local value = E.hposX.Value[1]
                MoveHorns("x", value, 3000, selectedCharacter)
                E.hposX.Value = {0, 0, 0, 0}
            end
        })



    E.hposY = E.hornsPosCollapse:AddSlider("D/U", 0, -100, 100, 1)
        UI:Config(E.hposY, {
            SameLine   = false,
            Components = 1,
            Value      = {0, 0, 0, 0},
            OnChange   = function()
                local value = E.hposY.Value[1]
                MoveHorns("y", value, 3000, selectedCharacter)
                E.hposY.Value = {0, 0, 0, 0}
            end
        })



    E.hposZ = E.hornsPosCollapse:AddSlider("S/N", 0, -100, 100, 1)
        UI:Config(E.hposZ, {
            SameLine   = false,
            Components = 1,
            Value      = {0, 0, 0, 0},
            OnChange   = function()
                local value = E.hposZ.Value[1]
                MoveHorns("z", value, 3000, selectedCharacter)
                E.hposZ.Value = {0, 0, 0, 0}
            end
        })



    E.resethPos = E.hornsPosCollapse:AddButton("Reset")
        UI:Config(E.resethPos, {
            SameLine  = false,
            OnClick   = function()
                for i = 1, #_GLL.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments do
                    if _GLL.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments[i].Visual.VisualResource.Objects[1].ObjectID:lower():find("horns") then
                        _GLL.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments[i].Visual:SetWorldTranslate(
                            _GLL.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.WorldTransform.Translate)
                        break
                    end
                end
            end
        })

    E.hornsPosCollapse:AddSeparator()



    E.hornsRotCollapse = E.treeHorns:AddTree("Rotation")
        UI:Config(E.hornsRotCollapse, {
            DefaultOpen = false
        })



    E.hrotX = E.hornsRotCollapse:AddSlider("Pitch", 0, -100, 100, 1)
        UI:Config(E.hrotX, {
            SameLine   = false,
            Components = 1,
            Value      = {0, 0, 0, 0},
            OnChange   = function()
                local value = E.hrotX.Value[1]
                RotateHorns("x", value, 3000, selectedCharacter)
                E.hrotX.Value = {0, 0, 0, 0}
            end
        })



    E.hrotY = E.hornsRotCollapse:AddSlider("Yaw", 0, -100, 100, 1)
        UI:Config(E.hrotY, {
            SameLine   = false,
            Components = 1,
            Value      = {0, 0, 0, 0},
            OnChange   = function()
                local value = E.hrotY.Value[1]
                RotateHorns("y", value, 3000, selectedCharacter)
                E.hrotY.Value = {0, 0, 0, 0}
            end
        })



    E.hrotZ = E.hornsRotCollapse:AddSlider("Roll", 0, -100, 100, 1)
        UI:Config(E.hrotZ, {
            SameLine   = false,
            Components = 1,
            Value      = {0, 0, 0, 0},
            OnChange   = function()
                local value = E.hrotZ.Value[1]
                RotateHorns("z", value, 3000, selectedCharacter)
                E.hrotZ.Value = {0, 0, 0, 0}
            end
        })



    E.resethRot = E.hornsRotCollapse:AddButton("Reset")
        UI:Config(E.resethRot, {
            SameLine  = false,
            OnClick   = function()
                for i = 1, #_GLL.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments do
                    if _GLL.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments[i].Visual.VisualResource.Objects[1].ObjectID:lower():find("horns") then
                        _GLL.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments[i].Visual:SetWorldRotate(
                            _GLL.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.WorldTransform.RotationQuat)
                        break
                    end
                end
            end
        })

    E.hornsRotCollapse:AddSeparator()


    E.saveLoadCollapse = parent:AddCollapsingHeader('Save/Load postition')
    E.saveLoadCollapse.DefaultOpen = openByDefaultPMSave


    saveLoadWindow = E.saveLoadCollapse:AddChildWindow('')
    saveLoadWindow.AlwaysAutoResize = false
    saveLoadWindow.Size = {0, 1}



    E.saveButton = E.saveLoadCollapse:AddButton("Save")
        UI:Config(E.saveButton, {
            SameLine  = false,
            OnClick   = function()
                if _GLL.DummyNameMap then
                    SaveVisTempCharacterPosition()
                end
            end
        })


    E.saveLoadCollapse:AddSeparator()
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

                local savedIndex = E.visTemComob.SelectedIndex
                for dummyName, saved in pairs(importData) do
                    local entity = _GLL.DummyNameMap[dummyName]
                    if entity then
                        entity.Visual.Visual.WorldTransform.Translate    = {saved.pos[1],   saved.pos[2],   saved.pos[3]}
                        entity.Visual.Visual.WorldTransform.RotationQuat = {saved.rot[1],   saved.rot[2],   saved.rot[3], saved.rot[4]}
                        entity.Visual.Visual.WorldTransform.Scale        = {saved.scale[1], saved.scale[2], saved.scale[3]}
                        entity.DummyOriginalTransform.Transform.Translate    = {saved.pos[1],   saved.pos[2],   saved.pos[3]}
                        entity.DummyOriginalTransform.Transform.RotationQuat = {saved.rot[1],   saved.rot[2],   saved.rot[3], saved.rot[4]}
                        entity.DummyOriginalTransform.Transform.Scale        = {saved.scale[1], saved.scale[2], saved.scale[3]}

                        for i, name in ipairs(E.visTemComob.Options) do
                            if name == dummyName then
                                E.visTemComob.SelectedIndex = i - 1
                                break
                            end
                        end
                        SaveVisTempCharacterPosition()
                    end
                end

                E.visTemComob.SelectedIndex = savedIndex
                UpdateCharacterInfo(E.visTemComob.SelectedIndex + 1)
            end
        })
    E.checkAutoSave = E.saveLoadCollapse:AddCheckbox('Re-apply saved positions to dummies')
        UI:Config(E.checkAutoSave, {
            SameLine = true,
            Checked = true,
        })


    E.saveLoadCollapse:AddSeparator()

end
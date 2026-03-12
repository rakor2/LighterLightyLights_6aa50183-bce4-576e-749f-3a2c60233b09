function BetterPMTab(parent)
    local function getSelectedDummyOwnerUuid()
        local entity = LLGlobals.DummyNameMap[E.cmbBoneDummies.Options[selectedCharacter]]
        if entity then
            local characterUuid = entity.Dummy.Entity.Uuid.EntityUuid
            if characterUuid then
                return characterUuid
            end
        end
    end


    local camSepa = parent:AddSeparatorText('Camera controls')

    E.camCollapse = parent:AddCollapsingHeader('Parameters')
    E.camCollapse.DefaultOpen = openByDefaultPMCamera



    Ext.Stats.GetStatsManager().ExtraData['PhotoModeCameraMovementSpeed'] = defaultCameraSpeed

    E.camSpeed = E.camCollapse:AddSlider('Speed', 0, 0.01, 100, 0.1)
        UI:Config(E.camSpeed, {
            IDContext  = 'slider_UniqueSliderID',
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
            IDContext   = "DofStr",
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
            IDContext   = "DofDist",
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
            IDContext = '238492kjndflkjsdnf',
            OnClick   = function()
                if not LLGlobals.States.inPhotoMode then return end

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
                        LLGlobals.CameraPositions[tostring(currentIndex)] = nil

                        E.windowLoadPos.Size = {
                            E.windowLoadPos.Size[1],
                            E.windowLoadPos.Size[2] - size
                        }
                    end
                end

                btnLoad.OnClick = function()
                    local index = tostring(currentIndex)
                    if LLGlobals.CameraPositions[index] then
                        local camera = Camera:GetActiveCamera()
                        camera.PhotoModeCameraSavedTransform.Transform.Translate     = LLGlobals.CameraPositions[index].activeTranslate
                        camera.PhotoModeCameraSavedTransform.Transform.RotationQuat  = LLGlobals.CameraPositions[index].activeRotationQuat
                        camera.PhotoModeCameraSavedTransform.Transform.Scale         = LLGlobals.CameraPositions[index].activeScale

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


    -- LLGlobals.gizmo = API.CreateManipulator()
    -- LLGlobals.gizmo.Config.IsSelectableEntity = function(info)
    --     return info.Type == "Unknown"
    -- end



    -- API.Events.OnTransformEnd:Subscribe(function(data)
    --     local dummy =  LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]]
    --     local Ser = Ext.Types.Serialize(dummy.Visual.Visual.WorldTransform)
    --     Ext.Types.Unserialize(dummy.DummyOriginalTransform.Transform, Ser)
    --     -- DDump(dummy.Visual.Visual.WorldTransform)
    -- end)



    local function gizmoSelectDummy()
        local ent = LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]]
        LLGlobals.gizmo:Select({ent.Dummy.Entity})
    end



    function UpdatePMDummyCombo(e)
        local e = e or E.visTemComob
        PM.DummyWidgets[LLGlobals.DummyNames[selectedCharacter]].Window:SetColor('WindowBg', Style.Colors.windowBg)
        PM.DummyWidgets[LLGlobals.DummyNames[selectedCharacter]].Window:SetColor('Text', Style.Colors.textColor)

        selectedCharacter = e.SelectedIndex + 1
        E.cmbBoneDummies.SelectedIndex = e.SelectedIndex
        UpdateCharacterInfo(selectedCharacter)
        SetVarValuesToSliders()

        PM.DummyWidgets[LLGlobals.DummyNames[selectedCharacter]].Window:SetColor('WindowBg', Style.Colors.special)
        SetHighlightColor(PM.DummyWidgets[LLGlobals.DummyNames[selectedCharacter]].Window)

        -- DPrint('Selected dummy: %s', LLGlobals.DummyNames[selectedCharacter])
        -- gizmoSelectDummy()
    end



    E.visTemComob = parent:AddCombo('')
        UI:Config(E.visTemComob, {
            IDContext    = 'E.visTemComob123',
            SelectedIndex = 0,
            Options      = {'Not in Photo Mode'},
            HeightLargest = true,
            SameLine     = false,
            OnChange     = function(e)
                if not LLGlobals.States.inPhotoMode then return end
                UpdatePMDummyCombo(e)
            end,
            OnRightClick = function(e)
                gizmoSelectDummy()
            end
        })
    selectedCharacter = E.visTemComob.SelectedIndex + 1



    E.btnDumPrev = parent:AddButton('<')
        UI:Config(E.btnDumPrev, {
            SameLine = true,
            OnClick  = function(e)
                UI:PrevOption(E.visTemComob)
                UpdatePMDummyCombo()
            end
        })



    E.btnDumNext = parent:AddButton('>')
        UI:Config(E.btnDumNext, {
            SameLine = true,
            OnClick  = function(e)
                UI:NextOption(E.visTemComob)
                UpdatePMDummyCombo()
            end
        })



    local txtDum = parent:AddText('Dummies')
        UI:Config(txtDum, { SameLine = true })

    E.checkDummiesPop = parent:AddCheckbox('Dummies popup')
        UI:Config(E.checkDummiesPop, {
            OnChange = function(e)
                if not LLGlobals.States.inPhotoMode then E.checkDummiesPop.Checked = false return end
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
            IDContext = "loadApply",
            SameLine  = false,
            OnClick   = function()
                if LLGlobals.DummyNameMap and LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]] then

                    local transform  = LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.WorldTransform
                    local transform2 = LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]].DummyOriginalTransform.Transform

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
            IDContext   = "modSlider",
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
            IDContext = "modSl1231232323131ider",
            SameLine  = true,
            OnClick   = function()
                E.stemModSlider.Value = {1500, 0, 0, 0}
            end
        })



    E.posX = E.charPosCollapse:AddSlider("W/E", 0, -100, 100, 1)
        UI:Config(E.posX, {
            IDContext  = "sliderX",
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
            IDContext  = "sliderY",
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
            IDContext  = "sliderZ",
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
                local x, y, z = table.unpack(LLGlobals.DummyVeryOriginalTransforms[getSelectedDummyOwnerUuid()].Translate)
                LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.WorldTransform.Translate = {x, y, z}
                UpdateCharacterInfo(selectedCharacter)
            end
        })


    E.charPosCollapse:AddSeparator()



    E.charRotCollapse = parent:AddCollapsingHeader("Rotation")
    E.charRotCollapse.DefaultOpen = openByDefaultPMRot



    E.rotationModSlider = E.charRotCollapse:AddSliderInt("", 0, 1, 10000, 1)
        UI:Config(E.rotationModSlider, {
            IDContext   = "rotModSlider",
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
            IDContext = "modSl1231111123131ider",
            SameLine  = true,
            OnClick   = function()
                E.rotationModSlider.Value = {1500, 0, 0, 0}
            end
        })



    E.rotX = E.charRotCollapse:AddSlider("Pitch", 0, -100, 100, 1)
        UI:Config(E.rotX, {
            IDContext  = "E.rotX",
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
            IDContext  = "E.rotY",
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
            IDContext  = "E.rotZ",
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
            IDContext = "E.resetRot",
            SameLine  = false,
            OnClick   = function()
                local x, y, z, w = table.unpack(LLGlobals.DummyVeryOriginalTransforms[getSelectedDummyOwnerUuid()].RotationQuat)
                LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.WorldTransform.RotationQuat = {x, y, z, w}
                UpdateCharacterInfo(selectedCharacter)
            end
        })

    E.charRotCollapse:AddSeparator()



    E.charScaleCollapse = parent:AddCollapsingHeader("Scale")
    E.charScaleCollapse.DefaultOpen = openByDefaultPMScale



    E.scaleModSlider = E.charScaleCollapse:AddSliderInt("", 0, 1, 10000, 1)
        UI:Config(E.scaleModSlider, {
            IDContext   = "sacleModSlider",
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
            IDContext = "modSl123123131ider",
            SameLine  = true,
            OnClick   = function()
                E.scaleModSlider.Value = {1500, 0, 0, 0}
            end
        })



    E.scaleLenght = E.charScaleCollapse:AddSlider("Length", 0, -100, 100, 1)
        UI:Config(E.scaleLenght, {
            IDContext  = "scaleLenght123",
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
            IDContext  = "scaleWidth232",
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
            IDContext  = "scaleHeight323",
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
            IDContext  = "scalescaleAll323",
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
            IDContext = "E.resetScale",
            SameLine  = false,
            OnClick   = function()
                local x, y, z = table.unpack(LLGlobals.DummyVeryOriginalTransforms[getSelectedDummyOwnerUuid()].Scale)
                LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.WorldTransform.Scale = {x, y, z}
                UpdateCharacterInfo(selectedCharacter)
                -- E.scaleInput.Label = string.format('L: %.2f  H: %.2f  W: %.2f', 1, 1, 1)
            end
        })


    E.charScaleCollapse:AddSeparator()



    E.collapseParts = parent:AddCollapsingHeader('Other body parts')

    E.treeTail = E.collapseParts:AddTree('Tail')

    E.tailPosCollapse = E.treeTail:AddTree("Position")
        UI:Config(E.tailPosCollapse, {
            IDContext    = 'wwwwdwd',
            DefaultOpen  = false
        })



    E.tposX = E.tailPosCollapse:AddSlider("W/E", 0, -100, 100, 1)
        UI:Config(E.tposX, {
            IDContext  = "slide123rX",
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
            IDContext  = "slid123erY",
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
            IDContext  = "slid123123erZ",
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
            IDContext = "resetttrot",
            SameLine  = false,
            OnClick   = function()
                for i = 1, #LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments do
                    if LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments[i].Visual.VisualResource.Objects[1].ObjectID:lower():find('tail') then
                        LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments[i].Visual:SetWorldTranslate(
                            LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.WorldTransform.Translate)
                        break
                    end
                end
            end
        })



    E.tailPosCollapse:AddSeparator()



    E.tailRotCollapse = E.treeTail:AddTree("Rotation")
        UI:Config(E.tailRotCollapse, {
            IDContext   = 'asdasdasdasdasds',
            DefaultOpen = false
        })



    E.trotX = E.tailRotCollapse:AddSlider("Pitch", 0, -100, 100, 1)
        UI:Config(E.trotX, {
            IDContext  = "ro123tX",
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
            IDContext  = "r123otY",
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
            IDContext  = "ro12312tZ",
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
            IDContext = "resetttrot",
            SameLine  = false,
            OnClick   = function()
                for i = 1, #LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments do
                    if LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments[i].Visual.VisualResource.Objects[1].ObjectID:lower():find('tail') then
                        LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments[i].Visual:SetWorldRotate(
                            LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.WorldTransform.RotationQuat)
                        break
                    end
                end
            end
        })

    E.tailRotCollapse:AddSeparator()


    E.treeHorns = E.collapseParts:AddTree('Horns')



    E.hornsPosCollapse = E.treeHorns:AddTree("Position")
        UI:Config(E.hornsPosCollapse, {
            IDContext   = 'as123123da323sdds',
            DefaultOpen = false
        })



    E.hposX = E.hornsPosCollapse:AddSlider("W/E", 0, -100, 100, 1)
        UI:Config(E.hposX, {
            IDContext  = "slid123e123rX",
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
            IDContext  = "slid13123erY",
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
            IDContext  = "sli23d123123erZ",
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
            IDContext = "re11sehhhhpos",
            SameLine  = false,
            OnClick   = function()
                for i = 1, #LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments do
                    if LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments[i].Visual.VisualResource.Objects[1].ObjectID:lower():find("horns") then
                        LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments[i].Visual:SetWorldTranslate(
                            LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.WorldTransform.Translate)
                        break
                    end
                end
            end
        })

    E.hornsPosCollapse:AddSeparator()



    E.hornsRotCollapse = E.treeHorns:AddTree("Rotation")
        UI:Config(E.hornsRotCollapse, {
            IDContext   = 'asdas123123dasdasdasds',
            DefaultOpen = false
        })



    E.hrotX = E.hornsRotCollapse:AddSlider("Pitch", 0, -100, 100, 1)
        UI:Config(E.hrotX, {
            IDContext  = "ro1312323tX",
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
            IDContext  = "r1213otY",
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
            IDContext  = "ro1233312tZ",
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
            IDContext = "rese123hhhrot",
            SameLine  = false,
            OnClick   = function()
                for i = 1, #LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments do
                    if LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments[i].Visual.VisualResource.Objects[1].ObjectID:lower():find("horns") then
                        LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments[i].Visual:SetWorldRotate(
                            LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.WorldTransform.RotationQuat)
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
            IDContext = "saveIdddasdasda",
            SameLine  = false,
            OnClick   = function()
                if LLGlobals.DummyNameMap then
                    SaveVisTempCharacterPosition()
                end
            end
        })


    E.saveLoadCollapse:AddSeparator()


end
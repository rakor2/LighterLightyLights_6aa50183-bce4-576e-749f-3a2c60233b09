LightDropdown = nil
colorPicker = nil
lightTypeCombo = nil
goboLightDropdown = nil
ltnCombo = nil
currentIntensityTextWidget = nil
currentDistanceTextWidget = nil

local OPENQUESTIONMARK = false
IMGUI:AntiStupiditySystem()






-- Function to get list of created lights _ai
function GetLightOptions()
    local options = {}
    if ClientSpawnedLights then
        for i, light in ipairs(ClientSpawnedLights) do
            table.insert(options, light.name)
        end
    end
    return options
end

-- Global ApplyStyle function _ai
function ApplyStyle(window, styleNum)
    if not Styles[styleNum] then
        for i = 1, #StyleDefinitions do
            local funcName = StyleDefinitions[i].funcName
            local windowName = "MainWindow" .. (funcName == "Main" and "" or funcName:sub(5))

            Styles[i] = {
                func = Style[windowName][funcName]
            }
        end
    end

    if Styles[styleNum] then
        Styles[styleNum].func(window)
    end
end







MCM.SetKeybindingCallback('ll_toggle_window', function()
    mw.Open = not mw.Open
end)


MCM.SetKeybindingCallback('ll_toggle_light', function()
    toggleLightBtn()
end)


MCM.SetKeybindingCallback('ll_toggle_all_lights', function()
    toggleAllLightsBtn()
end)


MCM.SetKeybindingCallback('ll_toggle_marker', function()
    ToggleMarker(LLGlobals.markerUuid)
end)


MCM.SetKeybindingCallback('ll_toggle_all_markers', function()
    Channels.MarkerHandler:RequestToServer({}, function (Response)
    end)
end)


MCM.SetKeybindingCallback('ll_duplicate', function()
    DuplicateLight()
end)


MCM.SetKeybindingCallback('ll_beam', function()
    Channels.MazzleBeam:SendToServer({})
end)


MCM.SetKeybindingCallback('ll_stick', function()
    checkStick.Checked = not checkStick.Checked
    stickToCameraCheck()
end)


MCM.SetKeybindingCallback('ll_next', function()
    nextOptionBtn()
end)


MCM.SetKeybindingCallback('ll_prev', function()
    prevOptionBtn()
end)


MCM.SetKeybindingCallback('ll_selected_popup', function()
    

    local lightName = getSelectedLightName() or 'None'
    if lightName then selectedLightNotification.Label = lightName end

    windowNotification.Visible = not windowNotification.Visible 
    checkSelectedLightNotification.Checked = not checkSelectedLightNotification.Checked

end)



MCM.SetKeybindingCallback('ll_apply_anl', function()
    Apply_TheOptimizationIsUnspoken()
end)


-- MCM.SetKeybindingCallback('ll_reset_anl', function()
--     Ext.Net.PostMessageToServer("sunValuesResetAll", "")
--     starsCheckbox.Checked = false
--     castLightCheckbox.Checked = false
-- end)



function MainTab2(mt2)
    if MainTab2 ~= nil then return end
    MainTab2 = mt2

    -- Create window first _ai
    mw = Ext.IMGUI.NewWindow("Lighty Lights")
    mw.Font = 'Font'
    mw.Open = OPENQUESTIONMARK

    mw.Closeable = true
    

    -- if mw then
    --     EnableMCMHotkeys()
    -- end

    -- xdText = mt2:AddText("")


    -- Add open button _ai
    openButton = mt2:AddButton("Open")
    openButton.IDContext = "OpenMainWindowButton"
    openButton.OnClick = function()
        mw.Open = not mw.Open
    end

    -- Add window close handler _ai
    mw.OnClose = function()
        mw.Open = false
        return true
    end

    local styleCombo = mt2:AddCombo("Style")
    styleCombo.IDContext = "StyleSwitchCombo"
    styleCombo.Options = StyleNames
    styleCombo.SelectedIndex = StyleSettings.selectedStyle - 1

    styleCombo.OnChange = function(widget)
        StyleSettings.selectedStyle = widget.SelectedIndex + 1
        ApplyStyle(mw, StyleSettings.selectedStyle)
        
        if windowNotification then
            checkSelectedLightNotification.Checked = false
            windowNotification:Destroy()
            CreateLightNumberNotification()
        end

        SettingsSave()
    end

    ApplyStyle(mw, StyleSettings.selectedStyle)

    MainWindow(mw)
end

function MainWindow(mw)
    ViewportSize = Ext.IMGUI.GetViewportSize()
    mw:SetPos({ViewportSize[1] / 6, ViewportSize[2] / 10})
    if ViewportSize[1] <= 1920 and ViewportSize[2] <= 1080 then
        mw:SetSize({ 525, 750 })
    else
        mw:SetSize({ 720, 1000 })
    end
    mw.AlwaysAutoResize = false
    mw.Scaling = 'Scaled'
    mw.Font = 'Font'



    mw.Visible = true
    mw.Closeable = true

    mainTabBar = mw:AddTabBar('LL')
    
    
    main2 = mainTabBar:AddTabItem('Main')
    MainTab(main2)

    
    anal2Tab = mainTabBar:AddTabItem('AnL')
    Anal2Tab(anal2Tab)
    
    
    betterPM = mainTabBar:AddTabItem('PM')
    BetterPMTab(betterPM)


    origin2PointTab = mainTabBar:AddTabItem('Origin point')
    Origin2PointTab(origin2PointTab)


    goboTab = mainTabBar:AddTabItem('Gobo')
    Gobo2Tab(goboTab)


    -- saverTab = mainTabBar:AddTabItem('Saver')
    -- Saver2Tab(saverTab)


    settingsTab = mainTabBar:AddTabItem('Settings')
    Settings2Tab(settingsTab)

    
    -- dev = mainTabBar:AddTabItem("Dev")
    -- DevTab(dev)
    
    
    
    -- Add AnL tab to the same TabBar _ai
    -- anlTab = mainTabBar:AddTabItem("AnL")
    -- AnLWindowTab(anlTab)
    


    -- mainTab = mainTabBar:AddTabItem("Main_old")
    -- MainWindowTab(mainTab)
    
    -- originPointTab = mainTabBar:AddTabItem("Origin point")
    -- OriginPointTab(originPointTab)
    
    
    
    
    



    -- particles = mainTabBar:AddTabItem("Particles")
    -- PartclesTab(particles)


    StyleV2:RegisterWindow(mw)

    SettingsLoad()
end



--===============-------------------------------------------------------------------------------------------------------------------------------
-----PM TAB------
--===============-------------------------------------------------------------------------------------------------------------------------------

function BetterPMTab(parent)
    local camSepa = parent:AddSeparatorText('Camera settings')

    camCollapse = parent:AddCollapsingHeader("Camera")
    camCollapse.DefaultOpen = openByDefaultPMCamera


    local camSpeed = camCollapse:AddSlider("Speed", 0, 0.01, 100, 0.1) --default, min, max, step
    camSpeed.IDContext = "UniqueSliderID"
    camSpeed.SameLine = false
    camSpeed.Logarithmic = true
    camSpeed.Components = 1
    camSpeed.Value = {Ext.Stats.GetStatsManager().ExtraData["PhotoModeCameraMovementSpeed"],0,0,0}
    camSpeed.OnChange = function()
         Ext.Stats.GetStatsManager().ExtraData["PhotoModeCameraMovementSpeed"] = camSpeed.Value[1]
    end

    local slFarPlane = camCollapse:AddSlider('Far plane distance', 1000, 0, 5000, 1)
    slFarPlane.Logarithmic = true
    slFarPlane.OnChange = function(e)
        CameraControlls('Far_plane', e.Value[1])
    end
    

    local slNearPlane = camCollapse:AddSlider('Near plane distance', 0.025, 0.001, 0.025, 1)
    slNearPlane.Logarithmic = true
    slNearPlane.OnChange = function(e)
        CameraControlls('Near_plane', e.Value[1])
    end


    dofCollapse = parent:AddCollapsingHeader("DoF")
    dofCollapse.DefaultOpen = false

    local dofStrength = dofCollapse:AddSlider("Strength", 0, 22, 1, 0.001)
    dofStrength.IDContext = "DofStr"
    dofStrength.SameLine = false
    dofStrength.Logarithmic = true
    dofStrength.Components = 1
    dofStrength.Value = { 1, 0, 0, 0 }
    dofStrength.OnChange = function()
        local success, result = pcall(function()
            return Ext.UI.GetRoot():Find("ContentRoot"):Child(21).DataContext.DOFStrength
        end)

        if success and result then
            local preciseDofStr = (dofStrength.Value[1])
            Ext.UI.GetRoot():Find("ContentRoot"):Child(21).DataContext.DOFStrength = preciseDofStr
        end
    end

    local getDofStrengthSub = Ext.Events.Tick:Subscribe(function()
        local success, result = pcall(function()
            return Ext.UI.GetRoot():Find("ContentRoot"):Child(21).DataContext.DOFStrength
        end)

        if success and result then
            getDofStrength = result
            dofStrength.Value = { getDofStrength, 0, 0, 0 }
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

    local dofDistance = dofCollapse:AddSlider("", 0, 0, 30, 0.001)
    dofDistance.IDContext = "DofDist"
    dofDistance.SameLine = false
    dofDistance.Logarithmic = true
    dofDistance.Components = 1
    dofDistance.Value = { 1, 0, 0, 0 }
    dofDistance.OnChange = function()
        dofChange(dofDistance.Value[1])
    end


    local btnDofDistanceDec= dofCollapse:AddButton('<')
    btnDofDistanceDec.SameLine = true
    btnDofDistanceDec.OnClick = function ()
        dofChange(dofDistance.Value[1] + 0.0005)
    end
    
    local btnDofDistanceInc = dofCollapse:AddButton('>')
    btnDofDistanceInc.SameLine = true
    btnDofDistanceInc.OnClick = function ()
        dofChange(dofDistance.Value[1] - 0.0005)
    end

    local textDofDistance = dofCollapse:AddText('Distance')
    textDofDistance.SameLine = true

    local getDofDistanceSub = Ext.Events.Tick:Subscribe(function()
        local success, result = pcall(function()
            return Ext.UI.GetRoot():Find("ContentRoot"):Child(21).DataContext.DOFDistance
        end)

        if success and result then
            getDofDistance = result
            dofDistance.Value = { getDofDistance, 0, 0, 0 }
        end
    end)

    --CamPos

    collapseSavePos = parent:AddCollapsingHeader('Save/Load position')


    local btnCounter = 0
    local btnSavePos = collapseSavePos:AddButton('Save')
    btnSavePos.IDContext = '238492kjndflkjsdnf'
    btnSavePos.OnClick = function ()
        
        btnCounter = btnCounter + 1
        local btnLoadPos
        local btnDeleteLoadPos
        local size = 38

        
        CameraSaveLoadPosition(btnCounter)


        GlobalsIMGUI.windowLoadPos.Size = {GlobalsIMGUI.windowLoadPos.Size[1], GlobalsIMGUI.windowLoadPos.Size[2] + size}
        
        btnDeleteLoadPos = GlobalsIMGUI.windowLoadPos:AddButton('X')
        btnDeleteLoadPos.IDContext = Ext.Math.Random(1,10000)
        btnDeleteLoadPos.OnClick = function ()
            btnLoadPos:Destroy()
            btnDeleteLoadPos:Destroy()
            GlobalsIMGUI.windowLoadPos.Size = {GlobalsIMGUI.windowLoadPos.Size[1], GlobalsIMGUI.windowLoadPos.Size[2] - size}
        end


        btnLoadPos = GlobalsIMGUI.windowLoadPos:AddButton('')
        btnLoadPos.IDContext = Ext.Math.Random(1,10000)
        btnLoadPos.SameLine = true
        btnLoadPos.Label = btnCounter
        btnLoadPos.OnClick = function ()
            if LLGlobals.CameraPositions[btnLoadPos.Label] then 
                Camera:SetTranslate(LLGlobals.CameraPositions[btnLoadPos.Label].activeTranslate)
                Camera:SetRotationQuat(LLGlobals.CameraPositions[btnLoadPos.Label].activeRotationQuat)
                Camera:SetScale(LLGlobals.CameraPositions[btnLoadPos.Label].activeScale)
            end
            
            -- Camera:GetActiveCamera().PhotoModeCameraSavedTransform.field_0.Translate = LLGlobals.CameraPositions[btnLoadPos.Label].activeTranslate
            -- Camera:GetActiveCamera().PhotoModeCameraSavedTransform.field_0.RotationQuat = LLGlobals.CameraPositions[btnLoadPos.Label].activeRotationQuat
            -- Camera:GetActiveCamera().PhotoModeCameraSavedTransform.field_0.Scale = LLGlobals.CameraPositions[btnLoadPos.Label].activeScale
        end
    end
    
    GlobalsIMGUI.windowLoadPos = collapseSavePos:AddChildWindow('Load')
    GlobalsIMGUI.windowLoadPos.Size = {0, 1}

    local sepa2 = parent:AddSeparatorText('Dummy controls')



    visTemComob = parent:AddCombo('Character')
    visTemComob.IDContext = 'visTemComob123'
    visTemComob.SelectedIndex = 0
    visTemComob.Options = {'Not in Photo Mode'}
    visTemComob.HeightLargest = true
    visTemComob.SameLine = false
    visTemComob.OnChange = function()
        selectedCharacter = visTemComob.SelectedIndex + 1
        UpdateCharacterInfo(visTemComob.SelectedIndex + 1)
    end
    selectedCharacter = visTemComob.SelectedIndex + 1


    

    local infoCollapse = parent:AddCollapsingHeader('Info')
    infoCollapse.DefaultOpen = openByDefaultPMInfo

    
    posInput = infoCollapse:AddInputScalar('Position')
    posInput.Components = 3
    posInput.Value = {0, 0, 0, 0}



    rotInput = infoCollapse:AddInputScalar('Rotation')
    rotInput.Components = 3
    rotInput.Value = {0, 0, 0, 0}



    scaleInput = infoCollapse:AddInputScalar('Scale')
    scaleInput.Components = 3
    scaleInput.Value = {1, 1, 1, 0}



    local applyButton = infoCollapse:AddButton('Apply')
    applyButton.IDContext = "loadApply"
    applyButton.SameLine = false
    applyButton.OnClick = function()
        if LLGlobals.DummyNameMap and LLGlobals.DummyNameMap[visTemComob.Options[selectedCharacter]] then
            local transform = LLGlobals.DummyNameMap[visTemComob.Options[selectedCharacter]].Visual.Visual.WorldTransform
            transform.Translate = {posInput.Value[1], posInput.Value[2], posInput.Value[3]}
            transform.Scale = {scaleInput.Value[1], scaleInput.Value[2], scaleInput.Value[3]}
            local deg = {rotInput.Value[1], rotInput.Value[2], rotInput.Value[3]}
            local quats = Math:EulerToQuats(deg)
            transform.RotationQuat = quats
            --UpdateCharacterInfo(index)
        end
    end
    


    local charPosCollapse = parent:AddCollapsingHeader("Position")
    charPosCollapse.DefaultOpen = openByDefaultPMPos

    DPrint('charPosCollapse open by def: %s', charPosCollapse.DefaultOpen)




    local stemModSlider = charPosCollapse:AddSliderInt("", 0, 1, 10000, 1) --default, min, max, step
    stemModSlider.IDContext = "modSlider"
    stemModSlider.SameLine = false
    stemModSlider.Components = 1
    stemModSlider.Logarithmic = true
    stemModSlider.Value = { 1500, 0, 0, 0 }
    stemModSlider.OnChange = function()
        stepMod = stemModSlider.Value[1]
    end



    local resetStemMod = charPosCollapse:AddButton('Mod')
    resetStemMod.IDContext = "modSl1231232323131ider"
    resetStemMod.SameLine = true
    resetStemMod.OnClick = function()
        stemModSlider.Value = { 1500, 0, 0, 0 }
    end



    local posX = charPosCollapse:AddSlider("W/E", 0, -100, 100, 1)
    posX.IDContext = "sliderX"
    posX.SameLine = false
    posX.Components = 1
    posX.Value = { 0, 0, 0, 0 }
    posX.OnChange = function()
        local value = posX.Value[1]
        -- DPrint(visTemComob.Options[selectedCharacter])
        MoveCharacter("x", value, stepMod, selectedCharacter)
        posX.Value = { 0, 0, 0, 0 }
    end



    local posY = charPosCollapse:AddSlider("D/U", 0, -100, 100, 1)
    posY.IDContext = "sliderY"
    posY.SameLine = false
    posY.Components = 1
    posY.Value = { 0, 0, 0, 0 }
    posY.OnChange = function()
        local value = posY.Value[1]
        MoveCharacter("y", value, stepMod, selectedCharacter)
        posY.Value = { 0, 0, 0, 0 }
    end



    local posZ = charPosCollapse:AddSlider("S/N", 0, -100, 100, 1)
    posZ.IDContext = "sliderZ"
    posZ.SameLine = false
    posZ.Components = 1
    posZ.Value = { 0, 0, 0, 0 }
    posZ.OnChange = function()
        local value = posZ.Value[1]
        MoveCharacter("z", value, stepMod, selectedCharacter)
        posZ.Value = { 0, 0, 0, 0 }
    end



    local charRotCollapse = parent:AddCollapsingHeader("Rotation")
    charRotCollapse.DefaultOpen = openByDefaultPMRot


    local rotationModSlider = charRotCollapse:AddSliderInt("", 0, 1, 10000, 1)
    rotationModSlider.IDContext = "rotModSlider"
    rotationModSlider.Logarithmic = true
    rotationModSlider.SameLine = false
    rotationModSlider.Components = 1
    rotationModSlider.Value = { 1500, 0, 0, 0 }
    rotationModSlider.OnChange = function()
        rotMod = rotationModSlider.Value[1]
    end



    local resetRotMod = charRotCollapse:AddButton('Mod')
    resetRotMod.IDContext = "modSl1231111123131ider"
    resetRotMod.SameLine = true
    resetRotMod.OnClick = function()
        rotationModSlider.Value = { 1500, 0, 0, 0 }
    end



    local rotX = charRotCollapse:AddSlider("Pitch", 0, -100, 100, 1)
    rotX.IDContext = "rotX"
    rotX.SameLine = false
    rotX.Components = 1
    rotX.Value = { 0, 0, 0, 0 }
    rotX.OnChange = function()
        local value = rotX.Value[1]
        RotateCharacter("x", value, rotMod, selectedCharacter)
        rotX.Value = { 0, 0, 0, 0 }
    end



    local rotY = charRotCollapse:AddSlider("Yaw", 0, -100, 100, 1)
    rotY.IDContext = "rotY"
    rotY.SameLine = false
    rotY.Components = 1
    rotY.Value = { 0, 0, 0, 0 }
    rotY.OnChange = function()
        local value = rotY.Value[1]
        RotateCharacter("y", value, rotMod, selectedCharacter)
        rotY.Value = { 0, 0, 0, 0 }
    end



    local rotZ = charRotCollapse:AddSlider("Roll", 0, -100, 100, 1)
    rotZ.IDContext = "rotZ"
    rotZ.SameLine = false
    rotZ.Components = 1
    rotZ.Value = { 0, 0, 0, 0 }
    rotZ.OnChange = function()
        local value = rotZ.Value[1]
        RotateCharacter("z", value, rotMod, selectedCharacter)
        rotZ.Value = { 0, 0, 0, 0 }
    end



    local resetRot = charRotCollapse:AddButton("Reset")
    resetRot.IDContext = "resetrot"
    resetRot.SameLine = false
    resetRot.OnClick = function()
        LLGlobals.DummyNameMap[visTemComob.Options[selectedCharacter]].Visual.Visual.WorldTransform.RotationQuat =  {0.0, 1.0, 0.0, 0.0}
        UpdateCharacterInfo(selectedCharacter)
    end



    local charScaleCollapse = parent:AddCollapsingHeader("Scale")
    charScaleCollapse.DefaultOpen = openByDefaultPMScale



    local scaleModSlider = charScaleCollapse:AddSliderInt("", 0, 1, 10000, 1)
    scaleModSlider.IDContext = "sacleModSlider"
    scaleModSlider.Logarithmic = true
    scaleModSlider.SameLine = false
    scaleModSlider.Components = 1
    scaleModSlider.Value = { 1500, 0, 0, 0 }
    scaleModSlider.OnChange = function()
        scaleMod = scaleModSlider.Value[1]
    end



    local resetScaMod = charScaleCollapse:AddButton('Mod')
    resetScaMod.IDContext = "modSl123123131ider"
    resetScaMod.SameLine = true
    resetScaMod.OnClick = function()
        scaleModSlider.Value = { 1500, 0, 0, 0 }
    end



    local scaleLenght = charScaleCollapse:AddSlider("Length", 0, -100, 100, 1)
    scaleLenght.IDContext = "scaleLenght123"
    scaleLenght.SameLine = false
    scaleLenght.Components = 1
    scaleLenght.Value = { 0, 0, 0, 0 }
    scaleLenght.OnChange = function()
        local value = scaleLenght.Value[1]
        ScaleCharacter("x", value, scaleMod, selectedCharacter)
        scaleLenght.Value = { 0, 0, 0, 0 }
    end



    local scaleWidth = charScaleCollapse:AddSlider("Height", 0, -100, 100, 1)
    scaleWidth.IDContext = "scaleWidth232"
    scaleWidth.SameLine = false
    scaleWidth.Components = 1
    scaleWidth.Value = { 0, 0, 0, 0 }
    scaleWidth.OnChange = function()
        local value = scaleWidth.Value[1]
        ScaleCharacter("y", value, scaleMod, selectedCharacter)
        scaleWidth.Value = { 0, 0, 0, 0 }
    end



    local scaleHeight = charScaleCollapse:AddSlider("Width", 0, -100, 100, 1)
    scaleHeight.IDContext = "scaleHeight323"
    scaleHeight.SameLine = false
    scaleHeight.Components = 1
    scaleHeight.Value = { 0, 0, 0, 0 }
    scaleHeight.OnChange = function()
        local value = scaleHeight.Value[1]
        ScaleCharacter("z", value, scaleMod, selectedCharacter)
        scaleHeight.Value = { 0, 0, 0, 0 }
    end



    local scaleAll = charScaleCollapse:AddSlider("All", 0, -100, 100, 1)
    scaleAll.IDContext = "scalescaleAll323"
    scaleAll.SameLine = false
    scaleAll.Components = 1
    scaleAll.Value = { 0, 0, 0, 0 }
    scaleAll.OnChange = function()
        local value = scaleAll.Value[1]
        ScaleCharacter("all", value, scaleMod, selectedCharacter)
        scaleAll.Value = { 0, 0, 0, 0 }
    end



    local resetScale = charScaleCollapse:AddButton("Reset")
    resetScale.IDContext = "resetscale"
    resetScale.SameLine = false
    resetScale.OnClick = function()
        LLGlobals.DummyNameMap[visTemComob.Options[selectedCharacter]].Visual.Visual.WorldTransform.Scale = { 1, 1, 1 }
        GlobalsIMGUI.infoScale.Label = string.format('L: %.2f  H: %.2f  W: %.2f', 1, 1, 1)
        UpdateCharacterInfo(selectedCharacter)
    end



    parent:AddSeparatorText('')



    local saveLoadCollapse = parent:AddCollapsingHeader('Save/Load postition')
    saveLoadCollapse.DefaultOpen = openByDefaultPMSave


    saveLoadWindow = saveLoadCollapse:AddChildWindow('')
    saveLoadWindow.AlwaysAutoResize = false
    saveLoadWindow.Size = {0, 1}



    local saveButton = saveLoadCollapse:AddButton("Save")
    saveButton.IDContext = "saveIdddasdasda"
    saveButton.SameLine = false
    saveButton.OnClick = function()
        if LLGlobals.DummyNameMap then
            SaveVisTempCharacterPosition()
        end
    end

    --LookAt

    parent:AddSeparatorText('Look at')



    local collapseLookAt = parent:AddCollapsingHeader("Position")
    collapseLookAt.IDContext = 'wwwswdawdwdwd'
    collapseLookAt.DefaultOpen = openByDefaultPMLook






    
    
    
    local targetPos
    
    local btnMoveToCamLookAt = collapseLookAt:AddButton('Move to cam')
    btnMoveToCamLookAt.SameLine = false
    btnMoveToCamLookAt.OnClick = function ()
        targetPos = Camera:GetActiveCamera().Transform.Transform.Translate
        Ext.Net.PostMessageToServer('LL_MoveLookAtTargetToCam', Ext.Json.Stringify(targetPos))
    end
    


    local btnCreateLookAt = collapseLookAt:AddButton('Marker')
    btnCreateLookAt.SameLine = true
    btnCreateLookAt.OnClick = function ()
        Ext.Net.PostMessageToServer('LL_CreateLookAtTarget', '')
    end
    

    local btnDeleteLookAt = collapseLookAt:AddButton('Delete')
    btnDeleteLookAt.SameLine = true
    btnDeleteLookAt.OnClick = function ()
        Ext.Net.PostMessageToServer('LL_DeleteLookAtTarget', '')
    end
    
    local btnUpdateCamPos = collapseLookAt:AddCheckbox('Disable head follow the camera thing')
    btnUpdateCamPos.SameLine = true
    btnUpdateCamPos.OnChange = function (e)
        
        if not Ext.Entity.GetAllEntitiesWithComponent('PhotoModeCameraTransform')[1] then e.Checked = false return end

        if e.Checked then
            Utils:SubUnsubToTick('sub', 'LL_LookAt', function ()
                if not Ext.Entity.GetAllEntitiesWithComponent('PhotoModeCameraTransform')[1] then
                    Utils:SubUnsubToTick('unsub','LL_LookAt', _)
                    e.Checked = false
                    return
                end  
                targetPos = targetPos or _C().Transform.Transform.Translate
                Ext.Entity.GetAllEntitiesWithComponent('PhotoModeCameraTransform')[1].PhotoModeCameraTransform.Transform.Translate = {targetPos[1],targetPos[2],targetPos[3]}
            end)
        else
            if not Utils.subID and Utils.subID['LL_LookAt'] then
                e.Checked = false
                return
            end
            Utils:SubUnsubToTick('unsub','LL_LookAt', _)
            e.Checked = false
        end
            
    end



    local lookAtSlDefault = 0.1



    local slLookAt = collapseLookAt:AddSlider('X Y Z', 0, -lookAtSlDefault, lookAtSlDefault, 1)
    slLookAt.IDContext = '131231asdad'
    slLookAt.SameLine = false
    slLookAt.Components = 3
    slLookAt.Value = {0, 0, 0, 0}
    slLookAt.OnChange = function()
        targetPos = targetPos or _C().Transform.Transform.Translate
        targetPos[1] = targetPos[1] + slLookAt.Value[1]
        targetPos[2] = targetPos[2] + slLookAt.Value[2]
        targetPos[3] = targetPos[3] + slLookAt.Value[3]
        Ext.Entity.GetAllEntitiesWithComponent('PhotoModeCameraTransform')[1].PhotoModeCameraTransform.Transform.Translate = {targetPos[1],targetPos[2],targetPos[3]}
        local data = {
            x = targetPos[1],
            y = targetPos[2],
            z = targetPos[3],
        }
        Ext.Net.PostMessageToServer('LL_MoveLookAtTarget', Ext.Json.Stringify(data))
        slLookAt.Value = {0, 0, 0, 0}
    end





    -- local SavedTargetPos = {}
    -- local btnSaveCamPos = collapseLookAt:AddButton('Save')
    -- btnSaveCamPos.IDContext = 'awdaoijdna'
    -- btnSaveCamPos.SameLine = true
    -- btnSaveCamPos.OnClick = function (e)
        
    --     SavedTargetPos = targetPos

    -- end


    
    -- local btnSaveCamPos = collapseLookAt:AddButton('Load')
    -- btnSaveCamPos.IDContext = 'awdaoijawdawdna'
    -- btnSaveCamPos.SameLine = true
    -- btnSaveCamPos.OnClick = function (e)
        
    --     Ext.Entity.GetAllEntitiesWithComponent('PhotoModeCameraTransform')[1].PhotoModeCameraTransform.Transform.Translate = {SavedTargetPos[1],SavedTargetPos[2],SavedTargetPos[3]}
    --     local Data = {
    --         x = SaveTargetPos[1],
    --         y = SaveTargetPos[2],
    --         z = SaveTargetPos[3],
    --     }
    --     Ext.Net.PostMessageToServer('LL_MoveLookAtTarget', Ext.Json.Stringify(Data))

    -- end


    parent:AddSeparatorText('Tail')



    local tailPosCollapse = parent:AddCollapsingHeader("Position")
    tailPosCollapse.IDContext = 'wwwwdwd'
    tailPosCollapse.DefaultOpen = false



    local tposX = tailPosCollapse:AddSlider("W/E", 0, -100, 100, 1)
    tposX.IDContext = "slide123rX"
    tposX.SameLine = false
    tposX.Components = 1
    tposX.Value = { 0, 0, 0, 0 }
    tposX.OnChange = function()
        local value = tposX.Value[1]
        -- DPrint(visTemComob.Options[selectedCharacter])
        MoveTail("x", value, 3000, selectedCharacter)

        tposX.Value = { 0, 0, 0, 0 }
    end



    local tposY = tailPosCollapse:AddSlider("D/U", 0, -100, 100, 1)
    tposY.IDContext = "slid123erY"
    tposY.SameLine = false
    tposY.Components = 1
    tposY.Value = { 0, 0, 0, 0 }
    tposY.OnChange = function()
        local value = tposY.Value[1]
        MoveTail("y", value, 3000, selectedCharacter)
        tposY.Value = { 0, 0, 0, 0 }
    end



    local tposZ = tailPosCollapse:AddSlider("S/N", 0, -100, 100, 1)
    tposZ.IDContext = "slid123123erZ"
    tposZ.SameLine = false
    tposZ.Components = 1
    tposZ.Value = { 0, 0, 0, 0 }
    tposZ.OnChange = function()
        local value = tposZ.Value[1]
        MoveTail("z", value, 3000, selectedCharacter)
        tposZ.Value = { 0, 0, 0, 0 }
    end



    local resettPos = tailPosCollapse:AddButton("Reset")
    resettPos.IDContext = "resetttrot"
    resettPos.SameLine = false
    resettPos.OnClick = function()
        for i = 1, #LLGlobals.DummyNameMap[visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments do
            if LLGlobals.DummyNameMap[visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments[i].Visual.VisualResource.Objects[1].ObjectID:lower():find('tail') then
                LLGlobals.DummyNameMap[visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments[i].Visual:SetWorldTranslate(
                    LLGlobals.DummyNameMap[visTemComob.Options[selectedCharacter]].Visual.Visual.WorldTransform.Translate)
                break
            end
        end
    end



    local tailRotCollapse = parent:AddCollapsingHeader("Rotation")
    tailRotCollapse.IDContext = 'asdasdasdasdasds'
    tailRotCollapse.DefaultOpen = false



    local trotX = tailRotCollapse:AddSlider("Pitch", 0, -100, 100, 1)
    trotX.IDContext = "ro123tX"
    trotX.SameLine = false
    trotX.Components = 1
    trotX.Value = { 0, 0, 0, 0 }
    trotX.OnChange = function()
        local value = trotX.Value[1]
        RotateTail("x", value, 3000, selectedCharacter)
        trotX.Value = { 0, 0, 0, 0 }
    end



    local trotY = tailRotCollapse:AddSlider("Yaw", 0, -100, 100, 1)
    trotY.IDContext = "r123otY"
    trotY.SameLine = false
    trotY.Components = 1
    trotY.Value = { 0, 0, 0, 0 }
    trotY.OnChange = function()
        local value = trotY.Value[1]
        RotateTail("y", value, 3000, selectedCharacter)
        trotY.Value = { 0, 0, 0, 0 }
    end



    local trotZ = tailRotCollapse:AddSlider("Roll", 0, -100, 100, 1)
    trotZ.IDContext = "ro12312tZ"
    trotZ.SameLine = false
    trotZ.Components = 1
    trotZ.Value = { 0, 0, 0, 0 }
    trotZ.OnChange = function()
        local value = trotZ.Value[1]
        RotateTail("z", value, 3000, selectedCharacter)
        trotZ.Value = { 0, 0, 0, 0 }
    end



    local resettRot = tailRotCollapse:AddButton("Reset")
    resettRot.IDContext = "resetttrot"
    resettRot.SameLine = false
    resettRot.OnClick = function()
        for i = 1, #LLGlobals.DummyNameMap[visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments do
            if LLGlobals.DummyNameMap[visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments[i].Visual.VisualResource.Objects[1].ObjectID:lower():find('tail') then
                LLGlobals.DummyNameMap[visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments[i].Visual:SetWorldRotate(
                    LLGlobals.DummyNameMap[visTemComob.Options[selectedCharacter]].Visual.Visual.WorldTransform.RotationQuat)
                break
            end
        end
    end



    local sepa5 = parent:AddSeparatorText('Horns')



    local hornsPosCollapse = parent:AddCollapsingHeader("Position")
    hornsPosCollapse.IDContext = 'as123123da323sdds'
    hornsPosCollapse.DefaultOpen = false



    local hposX = hornsPosCollapse:AddSlider("W/E", 0, -100, 100, 1)
    hposX.IDContext = "slid123e123rX"
    hposX.SameLine = false
    hposX.Components = 1
    hposX.Value = { 0, 0, 0, 0 }
    hposX.OnChange = function()
        local value = hposX.Value[1]
        -- DPrint(visTemComob.Options[selectedCharacter])
        MoveHorns("x", value, 3000, selectedCharacter)

        hposX.Value = { 0, 0, 0, 0 }
    end



    local hposY = hornsPosCollapse:AddSlider("D/U", 0, -100, 100, 1)
    hposY.IDContext = "slid13123erY"
    hposY.SameLine = false
    hposY.Components = 1
    hposY.Value = { 0, 0, 0, 0 }
    hposY.OnChange = function()
        local value = hposY.Value[1]
        MoveHorns("y", value, 3000, selectedCharacter)
        hposY.Value = { 0, 0, 0, 0 }
    end



    local hposZ = hornsPosCollapse:AddSlider("S/N", 0, -100, 100, 1)
    hposZ.IDContext = "sli23d123123erZ"
    hposZ.SameLine = false
    hposZ.Components = 1
    hposZ.Value = { 0, 0, 0, 0 }
    hposZ.OnChange = function()
        local value = hposZ.Value[1]
        MoveHorns("z", value, 3000, selectedCharacter)
        hposZ.Value = { 0, 0, 0, 0 }
    end



    local resethPos = hornsPosCollapse:AddButton("Reset")
    resethPos.IDContext = "re11sehhhhpos"
    resethPos.SameLine = false
    resethPos.OnClick = function()
        for i = 1, #LLGlobals.DummyNameMap[visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments do
            if LLGlobals.DummyNameMap[visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments[i].Visual.VisualResource.Objects[1].ObjectID:lower():find("horns") then
                LLGlobals.DummyNameMap[visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments[i].Visual:SetWorldTranslate(
                    LLGlobals.DummyNameMap[visTemComob.Options[selectedCharacter]].Visual.Visual.WorldTransform.Translate)
                break
            end
        end
    end



    local hornsRotCollapse = parent:AddCollapsingHeader("Rotation")
    hornsRotCollapse.IDContext = 'asdas123123dasdasdasds'
    hornsRotCollapse.DefaultOpen = false


    
    local hrotX = hornsRotCollapse:AddSlider("Pitch", 0, -100, 100, 1)
    hrotX.IDContext = "ro1312323tX"
    hrotX.SameLine = false
    hrotX.Components = 1
    hrotX.Value = { 0, 0, 0, 0 }
    hrotX.OnChange = function()
        local value = hrotX.Value[1]
        RotateHorns("x", value, 3000, selectedCharacter)
        hrotX.Value = { 0, 0, 0, 0 }
    end



    local hrotY = hornsRotCollapse:AddSlider("Yaw", 0, -100, 100, 1)
    hrotY.IDContext = "r1213otY"
    hrotY.SameLine = false
    hrotY.Components = 1
    hrotY.Value = { 0, 0, 0, 0 }
    hrotY.OnChange = function()
        local value = hrotY.Value[1]
        RotateHorns("y", value, 3000, selectedCharacter)
        hrotY.Value = { 0, 0, 0, 0 }
    end



    local hrotZ = hornsRotCollapse:AddSlider("Roll", 0, -100, 100, 1)
    hrotZ.IDContext = "ro1233312tZ"
    hrotZ.SameLine = false
    hrotZ.Components = 1
    hrotZ.Value = { 0, 0, 0, 0 }
    hrotZ.OnChange = function()
        local value = hrotZ.Value[1]
        RotateHorns("z", value, 3000, selectedCharacter)
        hrotZ.Value = { 0, 0, 0, 0 }
    end



    local resethRot = hornsRotCollapse:AddButton("Reset")
    resethRot.IDContext = "rese123hhhrot"
    resethRot.SameLine = false
    resethRot.OnClick = function()
        for i = 1, #LLGlobals.DummyNameMap[visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments do
            if LLGlobals.DummyNameMap[visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments[i].Visual.VisualResource.Objects[1].ObjectID:lower():find("horns") then
                LLGlobals.DummyNameMap[visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments[i].Visual:SetWorldRotate(
                    LLGlobals.DummyNameMap[visTemComob.Options[selectedCharacter]].Visual.Visual.WorldTransform.RotationQuat)
                break
            end
        end
    end
end



--===============-------------------------------------------------------------------------------------------------------------------------------
-----ANAL2 TAB------
--===============-------------------------------------------------------------------------------------------------------------------------------





function DevTab(parent)


    
    parent:AddSeparatorText('AnL')
    local getTriggersBtn = parent:AddButton('Update triggers')
    getTriggersBtn.OnClick = function ()
        Channels.GetTriggers:SendToServer({})
    end



end


Mods.BG3MCM.IMGUIAPI:InsertModMenuTab(ModuleUUID, "Lighty Lights", MainTab2)

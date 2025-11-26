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
    E.checkStick.Checked = not E.checkStick.Checked
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
    E.checkSelectedLightNotification.Checked = not E.checkSelectedLightNotification.Checked

end)



MCM.SetKeybindingCallback('ll_apply_anl', function()
    ApplyParameters()
end)

MCM.SetKeybindingCallback('ll_hide_gobo', function()
    hideGobo()
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
            E.checkSelectedLightNotification.Checked = false
            windowNotification:Destroy()
            CreateLightNumberNotification()
        end

        if Mods.Mazzle_Docs then
            initMazzleColors()
            API.Rebuild('LL2', 'Lighty Lights Elucidator')
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
        mw:SetSize({ 571, 750 })
    else
        mw:SetSize({ 766, 1000 })
    end
    mw.AlwaysAutoResize = false
    mw.Scaling = 'Scaled'
    mw.Font = 'Font'



    mw.Visible = true
    mw.Closeable = true

    mainTabBar = mw:AddTabBar('LL')


    E.main2 = mainTabBar:AddTabItem('Main')
    MainTab(E.main2)


    E.anal2Tab = mainTabBar:AddTabItem('AnL')
    Anal2Tab(E.anal2Tab)


    E.betterPM = mainTabBar:AddTabItem('PM')
    BetterPMTab(E.betterPM)


    E.origin2PointTab = mainTabBar:AddTabItem('Origin point')
    Origin2PointTab(E.origin2PointTab)


    E.goboTab = mainTabBar:AddTabItem('Gobo')
    Gobo2Tab(E.goboTab)

    E.utilsTab = mainTabBar:AddTabItem('Utils')
    Utils2Tab(E.utilsTab)


    -- saverTab = mainTabBar:AddTabItem('Saver')
    -- Saver2Tab(saverTab)


    E.settingsTab = mainTabBar:AddTabItem('Settings')
    Settings2Tab(E.settingsTab)


    function buttonSizes()
        for _, element in pairs(ER) do
            element.Size = {180/Style.buttonScale, 39/Style.buttonScale}
        end
    end



    -- function funnyStuff()
    --     local allElements = {}
    --     for _, element in pairs(E) do
    --         table.insert(allElements, element)
    --     end
    --     for _, element in pairs(ER) do
    --         table.insert(allElements, element)
    --     end

    --     for _, element in pairs(allElements) do
    --         element.OnHoverEnter = function(e)
    --             local elementType = tostring(e):match('^(%w+)')

    --             if elementType == 'Button' then
    --                 Imgui.FadeColor(e, 'Button', Style.buttonHovered, Style.button, fadeTime)
    --             elseif elementType == 'Checkbox' then
    --                 Imgui.FadeColor(e, 'FrameBg', Style.frameBgHovered, Style.frameBg, fadeTime)
    --             elseif elementType == 'SliderScalar' or elementType == 'SliderInt' then
    --                 Imgui.FadeColor(e, 'FrameBg', Style.frameBgHovered, Style.frameBg, fadeTime)
    --                 Imgui.FadeColor(e, 'FrameBgHovered', Style.frameBgHovered, Style.frameBgHovered, fadeTime)
    --             elseif elementType == 'InputText' then
    --                 Imgui.FadeColor(e, 'FrameBg', Style.frameBgHovered, Style.frameBg, fadeTime)
    --             elseif elementType == 'ColorEdit' then
    --                 Imgui.FadeColor(e, 'FrameBg', Style.frameBgHovered, Style.frameBg, fadeTime)
    --             elseif elementType == 'Combo' then
    --                 Imgui.FadeColor(e, 'FrameBg', Style.frameBgHovered, Style.frameBg, fadeTime)
    --             elseif elementType == 'TabItem' then
    --                 Imgui.FadeColor(e, 'TabActive', Style.tabHovered, Style.tabActive, fadeTime)
    --                 -- Imgui.FadeColor(e, 'TabHovered', Style.tabHovered, Style.tab, fadeTime)
    --                 Imgui.FadeColor(e, 'Tab', Style.tabHovered, Style.tab, fadeTime)
    --             elseif elementType == 'CollapsingHeader' then
    --                 Imgui.FadeColor(e, 'Header', Style.headerHovered, Style.header, fadeTime)
    --             end
    --         end
    --         element.OnHoverLeave = function(e)
    --             local elementType = tostring(e):match('^(%w+)')

    --             if elementType == 'Button' then
    --                 Imgui.FadeColor(e, 'Button', Style.buttonHovered, Style.button, fadeTime)
    --             elseif elementType == 'Checkbox' then
    --                 Imgui.FadeColor(e, 'FrameBg', Style.frameBgHovered, Style.frameBg, fadeTime)
    --             elseif elementType == 'SliderScalar' or elementType == 'SliderInt' then
    --                 Imgui.FadeColor(e, 'FrameBg', Style.frameBgHovered, Style.frameBg, fadeTime)
    --                 Imgui.FadeColor(e, 'FrameBgHovered', Style.frameBgHovered, Style.frameBgHovered, fadeTime)
    --             elseif elementType == 'InputText' then
    --                 Imgui.FadeColor(e, 'FrameBg', Style.frameBgHovered, Style.frameBg, fadeTime)
    --             elseif elementType == 'ColorEdit' then
    --                 Imgui.FadeColor(e, 'FrameBg', Style.frameBgHovered, Style.frameBg, fadeTime)
    --             elseif elementType == 'Combo' then
    --                 Imgui.FadeColor(e, 'FrameBg', Style.frameBgHovered, Style.frameBg, fadeTime)
    --             elseif elementType == 'TabItem' then
    --                 Imgui.FadeColor(e, 'TabActive', Style.tabHovered, Style.tabActive, fadeTime)
    --                 -- Imgui.FadeColor(e, 'TabHovered', Style.tabHovered, Style.tab, fadeTime)
    --                 Imgui.FadeColor(e, 'Tab', Style.tabHovered, Style.tab, fadeTime)
    --             elseif elementType == 'CollapsingHeader' then
    --                 Imgui.FadeColor(e, 'Header', Style.headerHovered, Style.header, fadeTime)
    --             end
    --         end
    --         -- element.OnClick = function(e)
    --         --     local elementType = tostring(e):match('^(%w+)')

    --         --     if elementType == 'Button' then
    --         --         -- Imgui.FadeColor(e, 'Button', Style.buttonHovered, Style.button, fadeTime)
    --         --         Imgui.FadeColor(e, 'ButtonActive', Style.buttonHovered, Style.buttonActive, fadeTime)
    --         --         -- Imgui.FadeColor(e, 'ButtonHovered', Style.buttonActive, Style.buttonHovered, fadeTime)
    --         --     elseif elementType == 'Checkbox' then
    --         --         Imgui.FadeColor(e, 'FrameBg', Style.frameBgHovered, Style.frameBg, fadeTime)
    --         --     elseif elementType == 'SliderScalar' or elementType == 'SliderInt' then
    --         --         Imgui.FadeColor(e, 'FrameBg', Style.frameBgHovered, Style.frameBg, fadeTime)
    --         --         Imgui.FadeColor(e, 'FrameBgHovered', Style.frameBgActive, Style.frameBgHovered, fadeTime)
    --         --     elseif elementType == 'InputText' then
    --         --         Imgui.FadeColor(e, 'FrameBg', Style.frameBgHovered, Style.frameBg, fadeTime)
    --         --     elseif elementType == 'ColorEdit' then
    --         --         Imgui.FadeColor(e, 'FrameBg', Style.frameBgHovered, Style.frameBg, fadeTime)
    --         --     elseif elementType == 'Combo' then
    --         --         Imgui.FadeColor(e, 'FrameBg', Style.frameBgHovered, Style.frameBg, fadeTime)
    --         --     elseif elementType == 'TabItem' then
    --         --         Imgui.FadeColor(e, 'TabActive', Style.tabHovered, Style.tabActive, fadeTime)
    --         --         -- Imgui.FadeColor(e, 'TabHovered', Style.tabHovered, Style.tab, fadeTime)
    --         --         Imgui.FadeColor(e, 'Tab', Style.tabHovered, Style.tab, fadeTime)
    --         --     elseif elementType == 'CollapsingHeader' then
    --         --         Imgui.FadeColor(e, 'Header', Style.headerHovered, Style.header, fadeTime)
    --         --     end
    --         -- end
    --     end
    -- end
    -- funnyStuff()
    buttonSizes()

    -- dev = mainTabBar:AddTabItem("Dev")
    -- DevTab(dev)



    -- Add AnL tab to the same TabBar _ai
    -- anlTab = mainTabBar:AddTabItem("AnL")
    -- AnLWindowTab(anlTab)



    -- mainTab = mainTabBar:AddTabItem("Main_old")
    -- MainWindowTab(mainTab)

    -- originPointTab = E.mainTabBar:AddTabItem("Origin point")
    -- OriginPointTab(originPointTab)








    -- particles = E.mainTabBar:AddTabItem("Particles")
    -- PartclesTab(particles)


    StyleV2:RegisterWindow(mw)

    SettingsLoad()
end



--===============-------------------------------------------------------------------------------------------------------------------------------
-----PM TAB------
--===============-------------------------------------------------------------------------------------------------------------------------------

function BetterPMTab(parent)
    local camSepa = parent:AddSeparatorText('Camera settings')

    E.camCollapse = parent:AddCollapsingHeader("Camera")
    E.camCollapse.DefaultOpen = openByDefaultPMCamera

    Ext.Stats.GetStatsManager().ExtraData['PhotoModeCameraMovementSpeed'] = defaultCameraSpeed
    E.camSpeed = E.camCollapse:AddSlider('Speed', 0, 0.01, 100, 0.1) --default, min, max, step
    E.camSpeed.IDContext = 'slider_UniqueSliderID'
    E.camSpeed.SameLine = false
    E.camSpeed.Logarithmic = true
    E.camSpeed.Components = 1
    E.camSpeed.Value = {defaultCameraSpeed, 0, 0, 0}
    E.camSpeed.OnChange = function()
         Ext.Stats.GetStatsManager().ExtraData['PhotoModeCameraMovementSpeed'] = E.camSpeed.Value[1]
    end

    E.slFarPlane = E.camCollapse:AddSlider('Far plane distance', 1000, 0, 5000, 1)
    E.slFarPlane.Logarithmic = true
    E.slFarPlane.OnChange = function(e)
        CameraControlls('Far_plane', e.Value[1])
    end


    E.slNearPlane = E.camCollapse:AddSlider('Near plane distance', 0.025, 0.001, 0.025, 1)
    E.slNearPlane.Logarithmic = true
    E.slNearPlane.OnChange = function(e)
        CameraControlls('Near_plane', e.Value[1])
    end


    E.dofCollapse = parent:AddCollapsingHeader("DoF")
    E.dofCollapse.DefaultOpen = false

    E.dofStrength = E.dofCollapse:AddSlider("Strength", 0, 22, 1, 0.001)
    E.dofStrength.IDContext = "DofStr"
    E.dofStrength.SameLine = false
    E.dofStrength.Logarithmic = true
    E.dofStrength.Components = 1
    E.dofStrength.Value = { 1, 0, 0, 0 }
    E.dofStrength.OnChange = function()
        local success, result = pcall(function()
            return Ext.UI.GetRoot():Find("ContentRoot"):Child(21).DataContext.DOFStrength
        end)

        if success and result then
            local preciseDofStr = (E.dofStrength.Value[1])
            Ext.UI.GetRoot():Find("ContentRoot"):Child(21).DataContext.DOFStrength = preciseDofStr
        end
    end

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
    E.dofDistance.IDContext = "DofDist"
    E.dofDistance.SameLine = false
    E.dofDistance.Logarithmic = true
    E.dofDistance.Components = 1
    E.dofDistance.Value = { 1, 0, 0, 0 }
    E.dofDistance.OnChange = function()
        dofChange(E.dofDistance.Value[1])
    end


    E.btnDofDistanceDec= E.dofCollapse:AddButton('<')
    E.btnDofDistanceDec.SameLine = true
    E.btnDofDistanceDec.OnClick = function ()
        dofChange(E.dofDistance.Value[1] + 0.0005)
    end

    E.btnDofDistanceInc = E.dofCollapse:AddButton('>')
    E.btnDofDistanceInc.SameLine = true
    E.btnDofDistanceInc.OnClick = function ()
        dofChange(E.dofDistance.Value[1] - 0.0005)
    end

    textDofDistance = E.dofCollapse:AddText('Distance')
    textDofDistance.SameLine = true

    getDofDistanceSub = Ext.Events.Tick:Subscribe(function()
        local success, result = pcall(function()
            return Ext.UI.GetRoot():Find("ContentRoot"):Child(21).DataContext.DOFDistance
        end)

        if success and result then
            getDofDistance = result
            E.dofDistance.Value = { getDofDistance, 0, 0, 0 }
        end
    end)

    --CamPos

    E.collapseSavePos = parent:AddCollapsingHeader('Save/Load position')


local btnCounter = 0
local savedButtons = {}

E.btnSavePos = E.collapseSavePos:AddButton('Save')
E.btnSavePos.IDContext = '238492kjndflkjsdnf'
E.btnSavePos.OnClick = function ()

    if not LLGlobals.States.inPhotoMode then return end

    btnCounter = btnCounter + 1
    local currentIndex = btnCounter
    local size = 38

    CameraSaveLoadPosition(currentIndex)

    E.windowLoadPos.Size = {
        E.windowLoadPos.Size[1],
        E.windowLoadPos.Size[2] + size
    }

    local btnDelete = E.windowLoadPos:AddButton('X')
    btnDelete.IDContext = 'delete_' .. currentIndex

    local btnLoad = E.windowLoadPos:AddButton('')
    btnLoad.IDContext = 'load_' .. currentIndex
    btnLoad.SameLine = true
    btnLoad.Label = tostring(currentIndex)

    savedButtons[currentIndex] = {
        load = btnLoad,
        delete = btnDelete
    }

    btnDelete.OnClick = function ()
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

    btnLoad.OnClick = function ()
        local index = tostring(currentIndex)
        if LLGlobals.CameraPositions[index] then
            local camera = Camera:GetActiveCamera()
            camera.PhotoModeCameraSavedTransform.field_0.Translate = LLGlobals.CameraPositions[index].activeTranslate
            camera.PhotoModeCameraSavedTransform.field_0.RotationQuat = LLGlobals.CameraPositions[index].activeRotationQuat
            camera.PhotoModeCameraSavedTransform.field_0.Scale = LLGlobals.CameraPositions[index].activeScale

            Helpers.Timer:OnTicks(5, function ()
                Ext.UI.GetRoot():Find("ContentRoot"):Child(21).DataContext.RecallCameraTransform:Execute()
            end)
        end
    end
end


    E.windowLoadPos = E.collapseSavePos:AddChildWindow('Load')
    E.windowLoadPos.Size = {0, 1}

    local sepa2 = parent:AddSeparatorText('Dummy controls')



    E.visTemComob = parent:AddCombo('Character')
    E.visTemComob.IDContext = 'E.visTemComob123'
    E.visTemComob.SelectedIndex = 0
    E.visTemComob.Options = {'Not in Photo Mode'}
    E.visTemComob.HeightLargest = true
    E.visTemComob.SameLine = false
    E.visTemComob.OnChange = function()

        selectedCharacter = E.visTemComob.SelectedIndex + 1

        DPrint('Combo option: %s', E.visTemComob.Options[E.visTemComob.SelectedIndex + 1])
        DPrint('Selected character combo: %s', selectedCharacter)
        UpdateCharacterInfo(E.visTemComob.SelectedIndex + 1)
    end
    selectedCharacter = E.visTemComob.SelectedIndex + 1




    E.infoCollapse = parent:AddCollapsingHeader('Info')
    E.infoCollapse.DefaultOpen = openByDefaultPMInfo


    E.posInput = E.infoCollapse:AddInputScalar('Position')
    E.posInput.Components = 3
    E.posInput.Value = {0, 0, 0, 0}



    E.rotInput = E.infoCollapse:AddInputScalar('Rotation')
    E.rotInput.Components = 3
    E.rotInput.Value = {0, 0, 0, 0}



    E.scaleInput = E.infoCollapse:AddInputScalar('Scale')
    E.scaleInput.Components = 3
    E.scaleInput.Value = {1, 1, 1, 0}



    E.applyButton = E.infoCollapse:AddButton('Apply')
    E.applyButton.IDContext = "loadApply"
    E.applyButton.SameLine = false
    E.applyButton.OnClick = function()
        if LLGlobals.DummyNameMap and LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]] then
            local transform = LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.WorldTransform
            transform.Translate = {E.posInput.Value[1], E.posInput.Value[2], E.posInput.Value[3]}
            transform.Scale = {E.scaleInput.Value[1], E.scaleInput.Value[2], E.scaleInput.Value[3]}
            local deg = {E.rotInput.Value[1], E.rotInput.Value[2], E.rotInput.Value[3]}
            local quats = Math:EulerToQuats(deg)
            transform.RotationQuat = quats
            --UpdateCharacterInfo(index)
        end
    end




    E.charPosCollapse = parent:AddCollapsingHeader("Position")
    E.charPosCollapse.DefaultOpen = openByDefaultPMPos

    -- DPrint('E.charPosCollapse open by def: %s', E.charPosCollapse.DefaultOpen)




    E.stemModSlider = E.charPosCollapse:AddSliderInt("", 0, 1, 10000, 1) --default, min, max, step
    E.stemModSlider.IDContext = "modSlider"
    E.stemModSlider.SameLine = false
    E.stemModSlider.Components = 1
    E.stemModSlider.Logarithmic = true
    E.stemModSlider.Value = { 1500, 0, 0, 0 }
    E.stemModSlider.OnChange = function()
        stepMod = E.stemModSlider.Value[1]
    end



    E.resetStemMod = E.charPosCollapse:AddButton('Mod')
    E.resetStemMod.IDContext = "modSl1231232323131ider"
    E.resetStemMod.SameLine = true
    E.resetStemMod.OnClick = function()
        E.stemModSlider.Value = { 1500, 0, 0, 0 }
    end



    E.posX = E.charPosCollapse:AddSlider("W/E", 0, -100, 100, 1)
    E.posX.IDContext = "sliderX"
    E.posX.SameLine = false
    E.posX.Components = 1
    E.posX.Value = { 0, 0, 0, 0 }
    E.posX.OnChange = function(e)
        -- local value = E.posX.Value[1]

        DPrint('Selected character name selectedCharacter: %s', E.visTemComob.Options[selectedCharacter])
        DPrint('Selected character name Index: %s', E.visTemComob.Options[E.visTemComob.SelectedIndex + 1])
        DPrint('Selected character W/E: %s', selectedCharacter)

        MoveCharacter("x", e.Value[1], stepMod, selectedCharacter)

        DPrint('Pre SliderValue W/E: %s', e.Value[1])
        E.posX.Value = {0, 0, 0, 0}
        DPrint('Post SliderValue W/E: %s', e.Value[1])
    end



    E.posY = E.charPosCollapse:AddSlider("D/U", 0, -100, 100, 1)
    E.posY.IDContext = "sliderY"
    E.posY.SameLine = false
    E.posY.Components = 1
    E.posY.Value = { 0, 0, 0, 0 }
    E.posY.OnChange = function(e)
        -- local value = E.posY.Value[1]

        DPrint('Selected character name selectedCharacter: %s', E.visTemComob.Options[selectedCharacter])
        DPrint('Selected character name Index: %s', E.visTemComob.Options[E.visTemComob.SelectedIndex + 1])
        DPrint('Selected character D/U: %s', selectedCharacter)


        MoveCharacter("y", e.Value[1], stepMod, selectedCharacter)
        DPrint('Pre SliderValue D/U: %s', e.Value[1])
        E.posY.Value = { 0, 0, 0, 0 }
        DPrint('Post SliderValue D/U: %s', e.Value[1])

    end



    E.posZ = E.charPosCollapse:AddSlider("S/N", 0, -100, 100, 1)
    E.posZ.IDContext = "sliderZ"
    E.posZ.SameLine = false
    E.posZ.Components = 1
    E.posZ.Value = { 0, 0, 0, 0 }
    E.posZ.OnChange = function(e)
        -- local value = E.posZ.Value[1]

        DPrint('Selected character name selectedCharacter: %s', E.visTemComob.Options[selectedCharacter])
        DPrint('Selected character name Index: %s', E.visTemComob.Options[E.visTemComob.SelectedIndex + 1])
        DPrint('Selected character S/N: %s', selectedCharacter)


        MoveCharacter("z", e.Value[1], stepMod, selectedCharacter)
        DPrint('Pre SliderValue S/N: %s', e.Value[1])
        E.posZ.Value = { 0, 0, 0, 0 }
        DPrint('Post SliderValue S/N: %s', e.Value[1])

    end



    E.charRotCollapse = parent:AddCollapsingHeader("Rotation")
    E.charRotCollapse.DefaultOpen = openByDefaultPMRot


    E.rotationModSlider = E.charRotCollapse:AddSliderInt("", 0, 1, 10000, 1)
    E.rotationModSlider.IDContext = "rotModSlider"
    E.rotationModSlider.Logarithmic = true
    E.rotationModSlider.SameLine = false
    E.rotationModSlider.Components = 1
    E.rotationModSlider.Value = { 1500, 0, 0, 0 }
    E.rotationModSlider.OnChange = function()
        rotMod = E.rotationModSlider.Value[1]
    end



    E.resetRotMod = E.charRotCollapse:AddButton('Mod')
    E.resetRotMod.IDContext = "modSl1231111123131ider"
    E.resetRotMod.SameLine = true
    E.resetRotMod.OnClick = function()
        E.rotationModSlider.Value = { 1500, 0, 0, 0 }
    end



    E.rotX = E.charRotCollapse:AddSlider("Pitch", 0, -100, 100, 1)
    E.rotX.IDContext = "E.rotX"
    E.rotX.SameLine = false
    E.rotX.Components = 1
    E.rotX.Value = { 0, 0, 0, 0 }
    E.rotX.OnChange = function()
        local value = E.rotX.Value[1]
        RotateCharacter("x", value, rotMod, selectedCharacter)
        E.rotX.Value = { 0, 0, 0, 0 }
    end



    E.rotY = E.charRotCollapse:AddSlider("Yaw", 0, -100, 100, 1)
    E.rotY.IDContext = "E.rotY"
    E.rotY.SameLine = false
    E.rotY.Components = 1
    E.rotY.Value = { 0, 0, 0, 0 }
    E.rotY.OnChange = function()
        local value = E.rotY.Value[1]
        RotateCharacter("y", value, rotMod, selectedCharacter)
        E.rotY.Value = { 0, 0, 0, 0 }
    end



    E.rotZ = E.charRotCollapse:AddSlider("Roll", 0, -100, 100, 1)
    E.rotZ.IDContext = "E.rotZ"
    E.rotZ.SameLine = false
    E.rotZ.Components = 1
    E.rotZ.Value = { 0, 0, 0, 0 }
    E.rotZ.OnChange = function()
        local value = E.rotZ.Value[1]
        RotateCharacter("z", value, rotMod, selectedCharacter)
        E.rotZ.Value = { 0, 0, 0, 0 }
    end



    E.resetRot = E.charRotCollapse:AddButton("Reset")
    E.resetRot.IDContext = "E.resetRot"
    E.resetRot.SameLine = false
    E.resetRot.OnClick = function()
        LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.WorldTransform.RotationQuat =  {0.0, 1.0, 0.0, 0.0}
        UpdateCharacterInfo(selectedCharacter)
    end



    E.charScaleCollapse = parent:AddCollapsingHeader("Scale")
    E.charScaleCollapse.DefaultOpen = openByDefaultPMScale



    E.scaleModSlider = E.charScaleCollapse:AddSliderInt("", 0, 1, 10000, 1)
    E.scaleModSlider.IDContext = "sacleModSlider"
    E.scaleModSlider.Logarithmic = true
    E.scaleModSlider.SameLine = false
    E.scaleModSlider.Components = 1
    E.scaleModSlider.Value = { 1500, 0, 0, 0 }
    E.scaleModSlider.OnChange = function()
        scaleMod = E.scaleModSlider.Value[1]
    end



    E.resetScaMod = E.charScaleCollapse:AddButton('Mod')
    E.resetScaMod.IDContext = "modSl123123131ider"
    E.resetScaMod.SameLine = true
    E.resetScaMod.OnClick = function()
        E.scaleModSlider.Value = { 1500, 0, 0, 0 }
    end



    E.scaleLenght = E.charScaleCollapse:AddSlider("Length", 0, -100, 100, 1)
    E.scaleLenght.IDContext = "scaleLenght123"
    E.scaleLenght.SameLine = false
    E.scaleLenght.Components = 1
    E.scaleLenght.Value = { 0, 0, 0, 0 }
    E.scaleLenght.OnChange = function()
        local value = E.scaleLenght.Value[1]
        ScaleCharacter("x", value, scaleMod, selectedCharacter)
        E.scaleLenght.Value = { 0, 0, 0, 0 }
    end



    E.scaleWidth = E.charScaleCollapse:AddSlider("Height", 0, -100, 100, 1)
    E.scaleWidth.IDContext = "scaleWidth232"
    E.scaleWidth.SameLine = false
    E.scaleWidth.Components = 1
    E.scaleWidth.Value = { 0, 0, 0, 0 }
    E.scaleWidth.OnChange = function()
        local value = E.scaleWidth.Value[1]
        ScaleCharacter("y", value, scaleMod, selectedCharacter)
        E.scaleWidth.Value = { 0, 0, 0, 0 }
    end



    E.scaleHeight = E.charScaleCollapse:AddSlider("Width", 0, -100, 100, 1)
    E.scaleHeight.IDContext = "scaleHeight323"
    E.scaleHeight.SameLine = false
    E.scaleHeight.Components = 1
    E.scaleHeight.Value = { 0, 0, 0, 0 }
    E.scaleHeight.OnChange = function()
        local value = E.scaleHeight.Value[1]
        ScaleCharacter("z", value, scaleMod, selectedCharacter)
        E.scaleHeight.Value = { 0, 0, 0, 0 }
    end



    E.scaleAll = E.charScaleCollapse:AddSlider("All", 0, -100, 100, 1)
    E.scaleAll.IDContext = "scalescaleAll323"
    E.scaleAll.SameLine = false
    E.scaleAll.Components = 1
    E.scaleAll.Value = { 0, 0, 0, 0 }
    E.scaleAll.OnChange = function()
        local value = E.scaleAll.Value[1]
        ScaleCharacter("all", value, scaleMod, selectedCharacter)
        E.scaleAll.Value = { 0, 0, 0, 0 }
    end



    E.resetScale = E.charScaleCollapse:AddButton("Reset")
    E.resetScale.IDContext = "E.resetScale"
    E.resetScale.SameLine = false
    E.resetScale.OnClick = function()
        LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.WorldTransform.Scale = { 1, 1, 1 }
        E.infoScale.Label = string.format('L: %.2f  H: %.2f  W: %.2f', 1, 1, 1)
        UpdateCharacterInfo(selectedCharacter)
    end




    E.collapseParts = parent:AddCollapsingHeader('Other body parts')

    E.treeTail = E.collapseParts:AddTree('Tail')

    E.tailPosCollapse = E.treeTail:AddTree("Position")
    E.tailPosCollapse.IDContext = 'wwwwdwd'
    E.tailPosCollapse.DefaultOpen = false



    E.tposX = E.tailPosCollapse:AddSlider("W/E", 0, -100, 100, 1)
    E.tposX.IDContext = "slide123rX"
    E.tposX.SameLine = false
    E.tposX.Components = 1
    E.tposX.Value = { 0, 0, 0, 0 }
    E.tposX.OnChange = function()
        local value = E.tposX.Value[1]
        -- DPrint(E.visTemComob.Options[selectedCharacter])
        MoveTail("x", value, 3000, selectedCharacter)

        E.tposX.Value = { 0, 0, 0, 0 }
    end



    E.tposY = E.tailPosCollapse:AddSlider("D/U", 0, -100, 100, 1)
    E.tposY.IDContext = "slid123erY"
    E.tposY.SameLine = false
    E.tposY.Components = 1
    E.tposY.Value = { 0, 0, 0, 0 }
    E.tposY.OnChange = function()
        local value = E.tposY.Value[1]
        MoveTail("y", value, 3000, selectedCharacter)
        E.tposY.Value = { 0, 0, 0, 0 }
    end



    E.tposZ = E.tailPosCollapse:AddSlider("S/N", 0, -100, 100, 1)
    E.tposZ.IDContext = "slid123123erZ"
    E.tposZ.SameLine = false
    E.tposZ.Components = 1
    E.tposZ.Value = { 0, 0, 0, 0 }
    E.tposZ.OnChange = function()
        local value = E.tposZ.Value[1]
        MoveTail("z", value, 3000, selectedCharacter)
        E.tposZ.Value = { 0, 0, 0, 0 }
    end



    E.resettPos = E.tailPosCollapse:AddButton("Reset")
    E.resettPos.IDContext = "resetttrot"
    E.resettPos.SameLine = false
    E.resettPos.OnClick = function()
        for i = 1, #LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments do
            if LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments[i].Visual.VisualResource.Objects[1].ObjectID:lower():find('tail') then
                LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments[i].Visual:SetWorldTranslate(
                    LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.WorldTransform.Translate)
                break
            end
        end
    end



    E.tailRotCollapse = E.treeTail:AddTree("Rotation")
    E.tailRotCollapse.IDContext = 'asdasdasdasdasds'
    E.tailRotCollapse.DefaultOpen = false



    E.trotX = E.tailRotCollapse:AddSlider("Pitch", 0, -100, 100, 1)
    E.trotX.IDContext = "ro123tX"
    E.trotX.SameLine = false
    E.trotX.Components = 1
    E.trotX.Value = { 0, 0, 0, 0 }
    E.trotX.OnChange = function()
        local value = E.trotX.Value[1]
        RotateTail("x", value, 3000, selectedCharacter)
        E.trotX.Value = { 0, 0, 0, 0 }
    end



    E.trotY = E.tailRotCollapse:AddSlider("Yaw", 0, -100, 100, 1)
    E.trotY.IDContext = "r123otY"
    E.trotY.SameLine = false
    E.trotY.Components = 1
    E.trotY.Value = { 0, 0, 0, 0 }
    E.trotY.OnChange = function()
        local value = E.trotY.Value[1]
        RotateTail("y", value, 3000, selectedCharacter)
        E.trotY.Value = { 0, 0, 0, 0 }
    end



    E.trotZ = E.tailRotCollapse:AddSlider("Roll", 0, -100, 100, 1)
    E.trotZ.IDContext = "ro12312tZ"
    E.trotZ.SameLine = false
    E.trotZ.Components = 1
    E.trotZ.Value = { 0, 0, 0, 0 }
    E.trotZ.OnChange = function()
        local value = E.trotZ.Value[1]
        RotateTail("z", value, 3000, selectedCharacter)
        E.trotZ.Value = { 0, 0, 0, 0 }
    end



    E.resettRot = E.tailRotCollapse:AddButton("Reset")
    E.resettRot.IDContext = "resetttrot"
    E.resettRot.SameLine = false
    E.resettRot.OnClick = function()
        for i = 1, #LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments do
            if LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments[i].Visual.VisualResource.Objects[1].ObjectID:lower():find('tail') then
                LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments[i].Visual:SetWorldRotate(
                    LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.WorldTransform.RotationQuat)
                break
            end
        end
    end



    E.treeHorns = E.collapseParts:AddTree('Horns')



    E.hornsPosCollapse = E.treeHorns:AddTree("Position")
    E.hornsPosCollapse.IDContext = 'as123123da323sdds'
    E.hornsPosCollapse.DefaultOpen = false



    E.hposX = E.hornsPosCollapse:AddSlider("W/E", 0, -100, 100, 1)
    E.hposX.IDContext = "slid123e123rX"
    E.hposX.SameLine = false
    E.hposX.Components = 1
    E.hposX.Value = { 0, 0, 0, 0 }
    E.hposX.OnChange = function()
        local value = E.hposX.Value[1]
        -- DPrint(E.visTemComob.Options[selectedCharacter])
        MoveHorns("x", value, 3000, selectedCharacter)

        E.hposX.Value = { 0, 0, 0, 0 }
    end



    E.hposY = E.hornsPosCollapse:AddSlider("D/U", 0, -100, 100, 1)
    E.hposY.IDContext = "slid13123erY"
    E.hposY.SameLine = false
    E.hposY.Components = 1
    E.hposY.Value = { 0, 0, 0, 0 }
    E.hposY.OnChange = function()
        local value = E.hposY.Value[1]
        MoveHorns("y", value, 3000, selectedCharacter)
        E.hposY.Value = { 0, 0, 0, 0 }
    end



    E.hposZ = E.hornsPosCollapse:AddSlider("S/N", 0, -100, 100, 1)
    E.hposZ.IDContext = "sli23d123123erZ"
    E.hposZ.SameLine = false
    E.hposZ.Components = 1
    E.hposZ.Value = { 0, 0, 0, 0 }
    E.hposZ.OnChange = function()
        local value = E.hposZ.Value[1]
        MoveHorns("z", value, 3000, selectedCharacter)
        E.hposZ.Value = { 0, 0, 0, 0 }
    end



    E.resethPos = E.hornsPosCollapse:AddButton("Reset")
    E.resethPos.IDContext = "re11sehhhhpos"
    E.resethPos.SameLine = false
    E.resethPos.OnClick = function()
        for i = 1, #LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments do
            if LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments[i].Visual.VisualResource.Objects[1].ObjectID:lower():find("horns") then
                LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments[i].Visual:SetWorldTranslate(
                    LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.WorldTransform.Translate)
                break
            end
        end
    end



    E.hornsRotCollapse = E.treeHorns:AddTree("Rotation")
    E.hornsRotCollapse.IDContext = 'asdas123123dasdasdasds'
    E.hornsRotCollapse.DefaultOpen = false



    E.hrotX = E.hornsRotCollapse:AddSlider("Pitch", 0, -100, 100, 1)
    E.hrotX.IDContext = "ro1312323tX"
    E.hrotX.SameLine = false
    E.hrotX.Components = 1
    E.hrotX.Value = { 0, 0, 0, 0 }
    E.hrotX.OnChange = function()
        local value = E.hrotX.Value[1]
        RotateHorns("x", value, 3000, selectedCharacter)
        E.hrotX.Value = { 0, 0, 0, 0 }
    end



    E.hrotY = E.hornsRotCollapse:AddSlider("Yaw", 0, -100, 100, 1)
    E.hrotY.IDContext = "r1213otY"
    E.hrotY.SameLine = false
    E.hrotY.Components = 1
    E.hrotY.Value = { 0, 0, 0, 0 }
    E.hrotY.OnChange = function()
        local value = E.hrotY.Value[1]
        RotateHorns("y", value, 3000, selectedCharacter)
        E.hrotY.Value = { 0, 0, 0, 0 }
    end



    E.hrotZ = E.hornsRotCollapse:AddSlider("Roll", 0, -100, 100, 1)
    E.hrotZ.IDContext = "ro1233312tZ"
    E.hrotZ.SameLine = false
    E.hrotZ.Components = 1
    E.hrotZ.Value = { 0, 0, 0, 0 }
    E.hrotZ.OnChange = function()
        local value = E.hrotZ.Value[1]
        RotateHorns("z", value, 3000, selectedCharacter)
        E.hrotZ.Value = { 0, 0, 0, 0 }
    end



    E.resethRot = E.hornsRotCollapse:AddButton("Reset")
    E.resethRot.IDContext = "rese123hhhrot"
    E.resethRot.SameLine = false
    E.resethRot.OnClick = function()
        for i = 1, #LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments do
            if LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments[i].Visual.VisualResource.Objects[1].ObjectID:lower():find("horns") then
                LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments[i].Visual:SetWorldRotate(
                    LLGlobals.DummyNameMap[E.visTemComob.Options[selectedCharacter]].Visual.Visual.WorldTransform.RotationQuat)
                break
            end
        end
    end



    parent:AddSeparatorText('')



    E.saveLoadCollapse = parent:AddCollapsingHeader('Save/Load postition')
    E.saveLoadCollapse.DefaultOpen = openByDefaultPMSave


    saveLoadWindow = E.saveLoadCollapse:AddChildWindow('')
    saveLoadWindow.AlwaysAutoResize = false
    saveLoadWindow.Size = {0, 1}



    E.saveButton = E.saveLoadCollapse:AddButton("Save")
    E.saveButton.IDContext = "saveIdddasdasda"
    E.saveButton.SameLine = false
    E.saveButton.OnClick = function()
        if LLGlobals.DummyNameMap then
            SaveVisTempCharacterPosition()
        end
    end

    --LookAt

    parent:AddSeparatorText('Look at')



    E.collapseLookAt = parent:AddCollapsingHeader("Position")
    E.collapseLookAt.IDContext = 'wwwswdawdwdwd'
    E.collapseLookAt.DefaultOpen = openByDefaultPMLook









    local targetPos

    E.btnMoveToCamLookAt = E.collapseLookAt:AddButton('Move to cam')
    E.btnMoveToCamLookAt.SameLine = false
    E.btnMoveToCamLookAt.OnClick = function ()
        targetPos = Camera:GetActiveCamera().Transform.Transform.Translate
        Ext.Net.PostMessageToServer('LL_MoveLookAtTargetToCam', Ext.Json.Stringify(targetPos))
    end



    E.btnCreateLookAt = E.collapseLookAt:AddButton('Marker')
    E.btnCreateLookAt.SameLine = true
    E.btnCreateLookAt.OnClick = function ()
        Ext.Net.PostMessageToServer('LL_CreateLookAtTarget', '')
    end


    E.btnDeleteLookAt = E.collapseLookAt:AddButton('Delete')
    E.btnDeleteLookAt.SameLine = true
    E.btnDeleteLookAt.OnClick = function ()
        Ext.Net.PostMessageToServer('LL_DeleteLookAtTarget', '')
    end

    E.btnUpdateCamPos = E.collapseLookAt:AddCheckbox('Disable head follow the camera thing')
    E.btnUpdateCamPos.SameLine = true
    E.btnUpdateCamPos.OnChange = function (e)

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



    E.slLookAt = E.collapseLookAt:AddSlider('X Y Z', 0, -lookAtSlDefault, lookAtSlDefault, 1)
    E.slLookAt.IDContext = '1312sss31asdad'
    E.slLookAt.SameLine = false
    E.slLookAt.Components = 3
    E.slLookAt.Value = {0, 0, 0, 0}
    E.slLookAt.OnChange = function()
        targetPos = targetPos or _C().Transform.Transform.Translate
        targetPos[1] = targetPos[1] + E.slLookAt.Value[1]
        targetPos[2] = targetPos[2] + E.slLookAt.Value[2]
        targetPos[3] = targetPos[3] + E.slLookAt.Value[3]
        Ext.Entity.GetAllEntitiesWithComponent('PhotoModeCameraTransform')[1].PhotoModeCameraTransform.Transform.Translate = {targetPos[1],targetPos[2],targetPos[3]}
        local data = {
            x = targetPos[1],
            y = targetPos[2],
            z = targetPos[3],
        }
        Ext.Net.PostMessageToServer('LL_MoveLookAtTarget', Ext.Json.Stringify(data))
        E.slLookAt.Value = {0, 0, 0, 0}
    end
end



--===============-------------------------------------------------------------------------------------------------------------------------------
-----ANAL2 TAB------
--===============-------------------------------------------------------------------------------------------------------------------------------





function DevTab(parent)



    parent:AddSeparatorText('AnL')
    E.getTriggersBtn = parent:AddButton('Update triggers')
    E.getTriggersBtn.OnClick = function ()
        Channels.GetTriggers:SendToServer({})
    end



end

MCM.InsertModMenuTab('Lighty Lights', MainTab2, ModuleUUID)


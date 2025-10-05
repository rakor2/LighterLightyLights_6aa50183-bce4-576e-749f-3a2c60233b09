LightDropdown = nil
colorPicker = nil
lightTypeCombo = nil
goboLightDropdown = nil
ltnCombo = nil
currentIntensityTextWidget = nil
currentDistanceTextWidget = nil

local OPENQUESTIONMARK = true
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
    ToggleLight()
end)

MCM.SetKeybindingCallback('ll_toggle_all_lights', function()
    ToggleLights()
end)

MCM.SetKeybindingCallback('ll_toggle_marker', function()
    ToggleMarker()
end)

MCM.SetKeybindingCallback('ll_toggle_all_markers', function()
    ToggleAllMarkers()
end)

MCM.SetKeybindingCallback('ll_duplicate', function()
    DuplicateLight()
end)

MCM.SetKeybindingCallback('ll_stick', function()
    if CheckBoxCF.Checked == false then
        CheckBoxCF.Checked = true
        CameraStick()
    else
        CheckBoxCF.Checked = false
        CameraStick()
    end
end)


MCM.SetKeybindingCallback('ll_window_scroll_down', function()
    mw:SetScroll({0, 100000000})
end)

MCM.SetKeybindingCallback('ll_window_scroll_up', function()
    mw:SetScroll({0, 0})
end)


MCM.SetKeybindingCallback('ll_apply_anl', function()
    Ext.Net.PostMessageToServer("valuesApply", "")
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

    -- Add style switch combo _ai
    local styleCombo = mt2:AddCombo("Style")
    styleCombo.IDContext = "StyleSwitchCombo"
    styleCombo.Options = StyleNames
    styleCombo.SelectedIndex = StyleSettings.selectedStyle - 1 or 0

    styleCombo.OnChange = function(widget)
        StyleSettings.selectedStyle = widget.SelectedIndex + 1
        ApplyStyle(mw, StyleSettings.selectedStyle)
        SettingsSave()
    end


    GlobalsIMGUI.checkPickerSize = mt2:AddCheckbox('Smaller color picker')
    GlobalsIMGUI.checkPickerSize.Checked = pickerSize or false
    GlobalsIMGUI.checkPickerSize.OnChange = function ()
        ChangeColorPickerSize()
        pickerSize = GlobalsIMGUI.checkPickerSize.Checked
        SettingsSave()
    end
    
    ---TBD: temp
    -- function Style.SetFont2(font, value)
    --     local font = font or '__QuadraatOffcPro.ttf'
    --     local size = 35
    --     if value == 3 then size = 35 Style.buttonScale = 1
    --     elseif value == 2 then size = 30 Style.buttonScale = 1.14
    --     elseif value == 1 then size = 25 Style.buttonScale = 1.305
    --     end
    --     Ext.IMGUI.LoadFont('FontLL', 'Mods/' .. Ext.Mod.GetMod(ModuleUUID).Info.Directory .. '/ScriptExtender/Lua/Shared/LibLib/ImGui/' .. font .. '/', size)
    -- end


    -- GlobalsIMGUI.uidScale = mt2:AddSliderInt('UI scale', 3, 1, 3, 1)
    -- GlobalsIMGUI.uidScale.OnChange = function (e)
    --     Utils:AntiSpam(500, function ()
    --         Style.SetFont2(nil, e.Value[1])
    --         buttonSizes()
    --     end)
    -- end



    -- local ifuckedupbtn = mt2:AddButton('Delete stuck lights and markers')
    -- ifuckedupbtn.OnClick = function()
    --     IFuckedUp:GatherLightsAndMarkers()
    -- end
    -- ApplyStyle(mw, StyleSettings.selectedStyle)

    MainWindow(mw)
end

function MainWindow(mw)
    Style.MainWindow.Main(mw)
    ViewportSize = Ext.IMGUI.GetViewportSize()
    mw:SetPos({ViewportSize[1] / 6, ViewportSize[2] / 10})
    if ViewportSize[1] <= 1920 and ViewportSize[2] <= 1080 then
        mw:SetSize({ 525, 750 })
    else
        mw:SetSize({ 700, 1000 })
    end
    mw.AlwaysAutoResize = false
    mw.Scaling = 'Scaled'
    mw.Font = 'Font'



    mw.Visible = true
    mw.Closeable = true

    -- Create one TabBar for all tabs _ai
    mainTabBar = mw:AddTabBar("LL")

    -- Add Main tab _ai
    mainTab = mainTabBar:AddTabItem("Main")
    MainWindowTab(mainTab)



    -- Add AnL tab to the same TabBar _ai
    -- anlTab = mainTabBar:AddTabItem("AnL")
    -- AnLWindowTab(anlTab)

    anal2Tab = mainTabBar:AddTabItem("AnL")
    Anal2Tab(anal2Tab)


    betterPM = mainTabBar:AddTabItem("PM")
    BetterPMTab(betterPM)

    originPointTab = mainTabBar:AddTabItem("Origin point")
    OriginPointTab(originPointTab)

    goboTab = mainTabBar:AddTabItem("Gobo")
    GoboWindowTab(goboTab)


    dev = mainTabBar:AddTabItem("Dev")
    DevTab(dev)


    main2 = mainTabBar:AddTabItem("Main2")
    MainTab(main2)



    -- particles = mainTabBar:AddTabItem("Particles")
    -- PartclesTab(particles)
    -- settingsTab = mainTabBar:AddTabItem("Settings")
    -- SettingsTab(settingsTab)


    StyleV2:RegisterWindow(mw)

    SettingsLoad()
end

--===============-------------------------------------------------------------------------------------------------------------------------------
-----MAIN TAB------
--===============-------------------------------------------------------------------------------------------------------------------------------

function MainWindowTab(parent)
    parent:AddSeparatorText("Management")

    -- Add light type combo box _ai
    lightTypeCombo = parent:AddCombo("")
    lightTypeCombo.IDContext = "LightTypeCombo"
    lightTypeCombo.HeightLargest = true
    lightTypeCombo.Options = lightTypeNames
    lightTypeCombo.SelectedIndex = 0
    lightTypeCombo.OnChange = function(combo)
        LightTypeChange(combo)
    end

    -- Add create button _ai
    local createButton = parent:AddButton("Create")
    createButton.IDContext = "CreateLightButton"
    Style.buttonSize.default(createButton)
    createButton.SameLine = true
    createButton.OnClick = function()
        CreateLightClick()
    end

    -- local createButton = parent:AddButton("D")
    -- createButton.IDContext = "CreateLightButton"
    -- createButton.SameLine = true
    -- createButton.OnClick = function()
    --     mw:SetScroll({ 0, 1000000 })
    -- end

    -- Add spawned lights combo directly to mt _ai
    LightDropdown = parent:AddCombo("Created lights")
    LightDropdown.IDContext = "LightDropdown"
    LightDropdown.HeightLargest = true

    -- Add handler for dropdown selection change _ai
    LightDropdown.OnChange = function(dropdown)
        LightDropdownChange(dropdown)
    end

    -- Add rename input and button directly to mt _ai
    local renameInput = parent:AddInputText("")
    renameInput.IDContext = "RenameLightInput"

    local renameButton = parent:AddButton("Rename")
    renameButton.IDContext = "RenameLightButton"
    Style.buttonSize.default(renameButton)
    renameButton.SameLine = true
    renameButton.OnClick = function()
        RenameLightClick(renameInput)
    end

    -- Add delete button _ai
    local deleteButton = parent:AddButton("Delete")
    deleteButton.IDContext = "DeleteLightButton"
    Style.buttonSize.default(deleteButton)
    deleteButton.OnClick = function()
        DeleteLight()
    end

    -- Add delete all button with confirmation _ai
    local deleteAllButton = parent:AddButton("Delete all")
    deleteAllButton.IDContext = "DeleteAllLightButton"
    Style.buttonSize.default(deleteAllButton)
    deleteAllButton.SameLine = true

    -- Add confirm button (initially hidden) _ai
    local confirmDeleteAllButton = parent:AddButton("Confirm")
    confirmDeleteAllButton.IDContext = "ConfirmDeleteAllButton"
    Style.buttonConfirm.default(confirmDeleteAllButton)
    confirmDeleteAllButton.SameLine = true
    confirmDeleteAllButton.Visible = false

    -- Add handlers for delete all functionality _ai
    deleteAllButton.OnClick = function()
        DeleteAllClick(deleteAllButton, confirmDeleteAllButton)
    end

    confirmDeleteAllButton.OnClick = function()
        ConfirmDeleteAllClick(deleteAllButton, confirmDeleteAllButton)
    end

    -- Add duplicate button _ai
    local duplicateButton = parent:AddButton("Duplicate")
    duplicateButton.IDContext = "DuplicateLightButton"
    duplicateButton.SameLine = true
    Style.buttonSize.default(duplicateButton)
    duplicateButton.OnClick = function()
        DuplicateLight()
    end

    -- Add replace button _ai
    local replaceButton = parent:AddButton("Replace")
    replaceButton.IDContext = "ReplaceLightButton"
    replaceButton.SameLine = true
    Style.buttonSize.default(replaceButton)
    replaceButton.OnClick = function()
        ReplaceLight()
    end

    local separatorPosSource = parent:AddSeparatorText("Character's position source")


    -- Add position source checkbox _ai
    local useOriginPoint = parent:AddCheckbox("Origin point")
    local tlDummyCheckbox = parent:AddCheckbox("Cutscene")
    local posSourceCheckbox = parent:AddCheckbox("Client-side")
    local CollapsingHeaderOrbit

    posSourceCheckbox.IDContext = "PosSourceCheckbox"
    posSourceCheckbox.SameLine = true
    posSourceCheckbox.OnChange = function(checkbox)
        if checkbox.Checked then
            useOriginPoint.Checked = false
            tlDummyCheckbox.Checked = false
            ToggleOriginPoint(false)
            CollapsingHeaderOrbit.Label = "Character relative"
        end
        PositionSourceChange(checkbox.Checked)
    end

    useOriginPoint.IDContext = "UseOriginPointCheckbox"
    useOriginPoint.SameLine = false
    useOriginPoint.OnChange = function(checkbox)
        if checkbox.Checked then
            posSourceCheckbox.Checked = false
            tlDummyCheckbox.Checked = false
            PositionSourceChange(false)
            CollapsingHeaderOrbit.Label = "Origin point relative"
        else
            if not posSourceCheckbox.Checked then
                CollapsingHeaderOrbit.Label = "Character relative"
            end
        end
        ToggleOriginPoint(checkbox.Checked)
    end


    tlDummyCheckbox.IDContext = "CutsceneCheckbox"
    tlDummyCheckbox.Checked = false
    tlDummyCheckbox.SameLine = true
    tlDummyCheckbox.OnChange = function(checkbox)
        if tlDummyCheckbox.Checked then
            useOriginPoint.Checked = false
            ToggleOriginPoint(false)
            posSourceCheckbox.Checked = false
            CollapsingHeaderOrbit.Label = "Character relative"
        end
        PositionSourceCutscene(checkbox.Checked)
    end

    local separator = parent:AddSeparatorText("Parameters")

    
    local toggleLightButton = parent:AddButton("Toggle light")
    toggleLightButton.IDContext = "ToggleLightButton"
    toggleLightButton.OnClick = function()
        ToggleLight()
    end

    local toggleLightsButton = parent:AddButton("Toggle all")
    toggleLightsButton.IDContext = "ToggleLightsButton"
    Style.buttonSize.default(toggleLightsButton)
    toggleLightsButton.SameLine = true
    toggleLightsButton.OnClick = function()
        ToggleLights()
    end

    local toggleMarkerButton = parent:AddButton("Toggle marker")
    toggleMarkerButton.SameLine = true
    toggleMarkerButton.IDContext = "ToggleMarkerButton"
    toggleMarkerButton.OnClick = function()
        ToggleMarker()
    end

    local toggleAllMarkersButton = parent:AddButton("Toggle all")
    toggleAllMarkersButton.SameLine = true
    Style.buttonSize.default(toggleAllMarkersButton)
    toggleAllMarkersButton.IDContext = "ToggleAllMarkersButton"
    toggleAllMarkersButton.SameLine = true
    toggleAllMarkersButton.OnClick = function()
        ToggleAllMarkers()
    end

    collapsingHeader = parent:AddCollapsingHeader("Color/Temperature/Power/Distance")

    local colorGroup = collapsingHeader:AddGroup('')

    --temporary
    function ChangeColorPickerSize()
        colorPicker:Destroy()
        if GlobalsIMGUI.checkPickerSize.Checked then
            colorPicker = colorGroup:AddColorEdit("Picker")
            colorPicker.IDContext = "LightColorPicker"
            colorPicker.NoAlpha = true
            colorPicker.Float = false
            colorPicker.InputRGB = true
            colorPicker.DisplayHex = true
            colorPicker.OnChange = function(picker)
                ColorPickerChange(picker)
            end
        else
            colorPicker = colorGroup:AddColorPicker("xd")
            colorPicker.IDContext = "LightColorPicker"
            colorPicker.NoAlpha = true
            colorPicker.Float = false
            colorPicker.InputRGB = true
            colorPicker.DisplayHex = true
            colorPicker.OnChange = function(picker)
                ColorPickerChange(picker)
            end
        end
    end

    if pickerSize == true then
        colorPicker = colorGroup:AddColorEdit("Picker")
        colorPicker.IDContext = "LightColorPicker"
        colorPicker.NoAlpha = true
        colorPicker.Float = false
        colorPicker.InputRGB = true
        colorPicker.DisplayHex = true
        colorPicker.OnChange = function(picker)
            ColorPickerChange(picker)
        end
    else
        colorPicker = colorGroup:AddColorPicker("xd")
        colorPicker.IDContext = "LightColorPicker"
        colorPicker.NoAlpha = true
        colorPicker.Float = false
        colorPicker.InputRGB = true
        colorPicker.DisplayHex = true
        colorPicker.OnChange = function(picker)
            ColorPickerChange(picker)
        end
    end

    -- Add temperature slider _ai
    temperatureSlider = collapsingHeader:AddSlider("Temperature", 1000, 1000, 40000, 1)
    temperatureSlider.IDContext = "LightTemperatureSlider"
    temperatureSlider.Logarithmic = true
    temperatureSlider.OnChange = function(slider)
        TemperatureSliderChange(slider)
    end

    intensitySlider = collapsingHeader:AddSlider("", 0, -2000, 2000, 0.001)
    intensitySlider.IDContext = "LightIntensitySlider"
    intensitySlider.Logarithmic = true
    intensitySlider.Value = { 1, 0, 0, 0 }
    intensitySliderValue = intensitySlider
    intensitySlider.OnChange = function(slider)
        IntensitySliderChange(slider)
    end

    -- Add text widgets for displaying current values _ai
    -- local currentIntensityText = collapsingHeader:AddText(string.format("Power: %.3f", 0.0))
    local currentIntensityText = collapsingHeader:AddText("Power")
    -- currentIntensityTextWidget = currentIntensityText
    currentIntensityText.SameLine = true

    -- local resetIntensityButton = collapsingHeader:AddButton("r")
    -- resetIntensityButton.SameLine = true
    -- resetIntensityButton.IDContext = "ResetIntensityButton"
    -- resetIntensityButton.OnClick = function()
    --     intensitySlider.Value = { 1, 0, 0, 0 }
    --     ResetIntensityClick()
    -- end

    local radiusSlider = collapsingHeader:AddSlider("", 0, 0, 60, 0.001)
    radiusSlider.IDContext = "LightRadiusSlider"
    radiusSlider.Logarithmic = true
    radiusSlider.Value = { 1, 0, 0, 0 }
    radiusSliderValue = radiusSlider
    radiusSlider.OnChange = function(slider)
        RadiusSliderChange(slider)
    end


    -- local currentDistanceText = collapsingHeader:AddText(string.format("Distance: %.3f", 0.0))
    local currentDistanceText = collapsingHeader:AddText("Distance")
    -- currentDistanceTextWidget = currentDistanceText
    currentDistanceText.SameLine = true

    -- local resetRadiusButton = collapsingHeader:AddButton("r")
    -- resetRadiusButton.IDContext = "ResetRadiusButton"
    -- resetRadiusButton.SameLine = true
    -- resetRadiusButton.OnClick = function()
    --     radiusSlider.Value = { 1, 0, 0, 0 }
    --     ResetRadiusClick()
    -- end


    -- Add position controls separator _ai
    local Separator = parent:AddSeparatorText("Positioning")



    local resetAllPositionButton = parent:AddButton("Reset position")
    resetAllPositionButton.SameLine = false
    resetAllPositionButton.IDContext = "ResetAllPositionButton"
    resetAllPositionButton.OnClick = function()
        ResetLightPosition("all")
    end
   

    local resetAllRotationButton = parent:AddButton("Reset rotation")
    resetAllRotationButton.SameLine = true
    resetAllRotationButton.IDContext = "ResetAllRotationButton"
    resetAllRotationButton.OnClick = function()
        ResetLightRotation("all")
    end


    CheckBoxCF = parent:AddCheckbox("Stick light to camera")
    CheckBoxCF.OnChange = function()
        CameraStick()
    end

    CollapsingHeaderOrbit = parent:AddCollapsingHeader("Character relative")
    CollapsingHeaderOrbit.Visible = true

    local angleSlider = CollapsingHeaderOrbit:AddSlider("", 0, -1000, 1000, 0.001)
    angleSlider.IDContext = "AngleSlider"
    angleSlider.OnChange = function(value)
        OrbitSliderChange(value, "angle", -0.002)
    end

    -- Angle orbit buttons _ai
    local angleLeftButton = CollapsingHeaderOrbit:AddButton("<")
    angleLeftButton.SameLine = true
    angleLeftButton.OnClick = function()
        OrbitButtonClick("angle", buttonStep * 10)
    end

    local angleRightButton = CollapsingHeaderOrbit:AddButton(">")
    angleRightButton.SameLine = true
    angleRightButton.OnClick = function()
        OrbitButtonClick("angle", -buttonStep * 10)
    end

    local addtext = CollapsingHeaderOrbit:AddText("Ccw/Cw")
    addtext.SameLine = true
    

        local heightSlider = CollapsingHeaderOrbit:AddSlider("", 0, -1000, 1000, 0.001)
    heightSlider.IDContext = "HeightSlider"
    heightSlider.OnChange = function(value)
        OrbitSliderChange(value, "height", 0.0001)
    end

    -- Height orbit buttons _ai
    local heightDownButton = CollapsingHeaderOrbit:AddButton("<")
    heightDownButton.IDContext = "HeightDownButton"
    heightDownButton.SameLine = true
    heightDownButton.OnClick = function()
        OrbitButtonClick("height", -buttonStep)
    end

    local heightUpButton = CollapsingHeaderOrbit:AddButton(">")
    heightUpButton.IDContext = "HeightUpButton"
    heightUpButton.SameLine = true
    heightUpButton.OnClick = function()
        OrbitButtonClick("height", buttonStep)
    end

    local addtext = CollapsingHeaderOrbit:AddText("Down/Up")
    addtext.SameLine = true

    local radiusSlider = CollapsingHeaderOrbit:AddSlider("", 0, -1000, 1000, 0.001)
    radiusSlider.IDContext = "RadiusSlider"
    radiusSlider.OnChange = function(value)
        OrbitSliderChange(value, "radius", 0.0001)
    end

    -- Radius orbit buttons _ai
    local radiusInButton = CollapsingHeaderOrbit:AddButton("<")
    radiusInButton.IDContext = "RadiusInButton"
    radiusInButton.SameLine = true
    radiusInButton.OnClick = function()
        OrbitButtonClick("radius", -buttonStep)
    end

    local radiusOutButton = CollapsingHeaderOrbit:AddButton(">")
    radiusOutButton.IDContext = "RadiusOutButton"
    radiusOutButton.SameLine = true
    radiusOutButton.OnClick = function()
        OrbitButtonClick("radius", buttonStep)
    end

    local addtext = CollapsingHeaderOrbit:AddText("Close/Far")
    addtext.SameLine = true





    -- Collapsing header _ai
    local CollapsingHeaderDm = parent:AddCollapsingHeader("World relative")

    local forwardBackSlider = CollapsingHeaderDm:AddSlider("", 0, -1000, 1000, 0.001)
    forwardBackSlider.IDContext = "ForwardBackSlider"
    forwardBackSlider.OnChange = function(value)
        SliderChange(value, MoveLightForwardBack, stepMultiplier)
    end

    -- Forward/Back movement _ai
    local forwardBackButton = CollapsingHeaderDm:AddButton("<")
    forwardBackButton.SameLine = true
    forwardBackButton.IDContext = "MoveBackButton"
    forwardBackButton.OnClick = function()
        MoveLightForwardBack(-buttonStep)
    end

    local forwardButton = CollapsingHeaderDm:AddButton(">")
    forwardButton.IDContext = "MoveForwardButton"
    forwardButton.SameLine = true
    forwardButton.OnClick = function()
        MoveLightForwardBack(buttonStep)
    end

    local addtext = CollapsingHeaderDm:AddText("South/North")   
    addtext.SameLine = true
                         
    
    local upDownSlider = CollapsingHeaderDm:AddSlider("", 0, -1000, 1000, 0.001)
    upDownSlider.IDContext = "UpDownSlider"
    upDownSlider.OnChange = function(value)
        SliderChange(value, MoveLightUpDown, stepMultiplier)
    end
    -- Up/Down movement _ai
    local downButton = CollapsingHeaderDm:AddButton("<")
    downButton.SameLine = true
    downButton.IDContext = "MoveDownButton"
    downButton.OnClick = function()
        MoveLightUpDown(-buttonStep)
    end

    local upButton = CollapsingHeaderDm:AddButton(">")
    upButton.IDContext = "MoveUpButton"
    upButton.SameLine = true
    upButton.OnClick = function()
        MoveLightUpDown(buttonStep)
    end

    local addtext = CollapsingHeaderDm:AddText("Down/Up")
    addtext.SameLine = true

    
    local leftRightSlider = CollapsingHeaderDm:AddSlider("", 0, -1000, 1000, 0.001)
    leftRightSlider.IDContext = "LeftRightSlider"
    leftRightSlider.OnChange = function(value)
        SliderChange(value, MoveLightLeftRight, stepMultiplier)
    end

    -- Left/Right movement _ai
    local leftButton = CollapsingHeaderDm:AddButton("<")
    leftButton.SameLine = true
    leftButton.IDContext = "MoveLeftButton"
    leftButton.OnClick = function()
        MoveLightLeftRight(-buttonStep)
    end

    local rightButton = CollapsingHeaderDm:AddButton(">")

    rightButton.IDContext = "MoveRightButton"
    rightButton.SameLine = true
    rightButton.OnClick = function()
        MoveLightLeftRight(buttonStep)
    end

    local addtext = CollapsingHeaderDm:AddText("West/East")
    addtext.SameLine = true



    --  -- Collapsing header _ai
    -- local CollapsingHeaderCameraRelative = parent:AddCollapsingHeader("Camera relative")

    -- local forwardCRSlider = CollapsingHeaderCameraRelative:AddSlider("", 0, -1000, 1000, 0.001)
    -- forwardCRSlider.IDContext = "ForwardCRSlider"
    -- forwardCRSlider.OnChange = function(value)
    --     local currentValue = tonumber(value.Value[1])
    --     if currentValue and currentValue ~= 0 then
    --         MoveLightCameraRelative("forward", currentValue * stepMultiplier)
    --         forwardCRSlider.Value = {0, 0, 0, 0}
    --     end
    -- end

    -- -- Forward/Back movement _ai
    -- local forwardCRButton = CollapsingHeaderCameraRelative:AddButton("<")
    -- forwardCRButton.SameLine = true
    -- forwardCRButton.IDContext = "MoveForwardCRButton"
    -- forwardCRButton.OnClick = function()
    --     MoveLightCameraRelative("forward", -buttonStep)
    -- end

    -- local backwardCRButton = CollapsingHeaderCameraRelative:AddButton(">")
    -- backwardCRButton.IDContext = "MoveBackwardCRButton"
    -- backwardCRButton.SameLine = true
    -- backwardCRButton.OnClick = function()
    --     MoveLightCameraRelative("forward", buttonStep)
    -- end


    -- local addtext = CollapsingHeaderCameraRelative:AddText("Back/Forward")
    -- addtext.SameLine = true

    -- local rightleftCRSlider = CollapsingHeaderCameraRelative:AddSlider("", 0, -1000, 1000, 0.001)
    -- rightleftCRSlider.IDContext = "RightLeftCRSlider"
    -- rightleftCRSlider.OnChange = function(value)
    --     local currentValue = tonumber(value.Value[1])
    --     if currentValue and currentValue ~= 0 then
    --         MoveLightCameraRelative("right", currentValue * stepMultiplier)
    --         rightleftCRSlider.Value = {0, 0, 0, 0}
    --     end
    -- end

    -- -- Left/Right movement _ai
    -- local leftCRButton = CollapsingHeaderCameraRelative:AddButton("<")
    -- leftCRButton.SameLine = true
    -- leftCRButton.IDContext = "MoveLeftCRButton"
    -- leftCRButton.OnClick = function()
    --     MoveLightCameraRelative("right", -buttonStep)
    -- end

    -- local rightCRButton = CollapsingHeaderCameraRelative:AddButton(">")
    -- rightCRButton.IDContext = "MoveRightCRButton"
    -- rightCRButton.SameLine = true
    -- rightCRButton.OnClick = function()
    --     MoveLightCameraRelative("right", buttonStep)
    -- end

    -- local addtext = CollapsingHeaderCameraRelative:AddText("Left/Right")
    -- addtext.SameLine = true

    -- local upDownCRSlider = CollapsingHeaderCameraRelative:AddSlider("", 0, -1000, 1000, 0.001)
    -- upDownCRSlider.IDContext = "UpDownCRSlider"
    -- upDownCRSlider.OnChange = function(value)
    --     local currentValue = tonumber(value.Value[1])
    --     if currentValue and currentValue ~= 0 then
    --         MoveLightCameraRelative("up", currentValue * stepMultiplier)
    --         upDownCRSlider.Value = {0, 0, 0, 0}
    --     end
    -- end

    -- -- Up/Down movement _ai
    -- local downCRButton = CollapsingHeaderCameraRelative:AddButton("<")
    -- downCRButton.SameLine = true
    -- downCRButton.IDContext = "MoveDownCRButton"
    -- downCRButton.OnClick = function()
    --     MoveLightCameraRelative("up", -buttonStep)
    -- end

    -- local upCRButton = CollapsingHeaderCameraRelative:AddButton(">")
    -- upCRButton.IDContext = "MoveUpCRButton"
    -- upCRButton.SameLine = true
    -- upCRButton.OnClick = function()
    --     MoveLightCameraRelative("up", buttonStep)
    -- end

    -- local addtext = CollapsingHeaderCameraRelative:AddText("Down/Up")
    -- addtext.SameLine = true


    local CollapsingHeaderRotation = parent:AddCollapsingHeader("Rotation")


    local tiltSlider = CollapsingHeaderRotation:AddSlider("", 0, -50, 50, 0.001)
    tiltSlider.OnChange = function(value)
        RotateLightTilt(tiltSlider.Value[1])
        tiltSlider.Value = { 0, 0, 0, 0 }
    end

    -- Tilt rotation _ai
    local tiltLeftButton = CollapsingHeaderRotation:AddButton("<")
    tiltLeftButton.SameLine = true
    tiltLeftButton.OnClick = function()
        RotateLightTilt(-rotationStep)
    end


    local tiltRightButton = CollapsingHeaderRotation:AddButton(">")
    tiltRightButton.SameLine = true
    tiltRightButton.OnClick = function()
        RotateLightTilt(rotationStep)
    end

    local addtext = CollapsingHeaderRotation:AddText("Up/Down")
    addtext.SameLine = true

    local yawSlider = CollapsingHeaderRotation:AddSlider("", 0, -50, 50, 0.001)
    yawSlider.OnChange = function()
        RotateLightYaw(yawSlider.Value[1])
        yawSlider.Value = { 0, 0, 0, 0 }
    end

    -- Yaw rotation _ai
    local yawLeftButton = CollapsingHeaderRotation:AddButton("<")
    yawLeftButton.IDContext = '123123333'
    yawLeftButton.SameLine = true
    yawLeftButton.OnClick = function()
        RotateLightYaw(-rotationStep)
    end

    local yawRightButton = CollapsingHeaderRotation:AddButton(">")
    yawRightButton.IDContext = '123123'
    yawRightButton.SameLine = true
    yawRightButton.OnClick = function()
        RotateLightYaw(rotationStep)
    end

    local addtext = CollapsingHeaderRotation:AddText("Left/Right")
    addtext.SameLine = true


 
    --#region

    -- -- Tilt rotation reset button _ai
    -- local resetTiltButton = parent:AddButton("Tilt reset")
    -- Style.buttonSize.default(resetTiltButton)
    -- resetTiltButton.IDContext = "ResetTiltButton"
    -- resetTiltButton.OnClick = function()
    --     ResetLightRotation("tilt")
    -- end

    -- -- Yaw rotation reset button _ai
    -- local resetYawButton = parent:AddButton("Yaw reset")
    -- Style.buttonSize.default(resetYawButton)
    -- resetYawButton.SameLine = true
    -- resetYawButton.OnClick = function()
    --     ResetLightRotation("yaw")
    -- end

    -- -- Roll rotation reset button _ai
    -- local resetRollButton = parent:AddButton("Roll reset")
    -- Style.buttonSize.default(resetRollButton)
    -- resetRollButton.IDContext = "ResetRollButton"
    -- resetRollButton.SameLine = true
    -- resetRollButton.OnClick = function()
    --     ResetLightRotation("roll")
    -- end

    
    
    -- Forward/Back reset button _ai
    -- local resetForwardBackButton = parent:AddButton("X reset")
    -- Style.buttonSize.default(resetForwardBackButton)
    -- resetForwardBackButton.IDContext = "ResetForwardBackButton"
    -- resetForwardBackButton.OnClick = function()
    --     ResetLightPosition("z")
    -- end

    -- -- Left/Right reset button _ai
    -- local resetLeftRightButton = parent:AddButton("Y reset")
    -- Style.buttonSize.default(resetLeftRightButton)
    -- resetLeftRightButton.IDContext = "ResetLeftRightButton"
    -- resetLeftRightButton.SameLine = true
    -- resetLeftRightButton.OnClick = function()
    --     ResetLightPosition("x")
    -- end

    -- -- Up/Down reset button _ai
    -- local resetUpDownButton = parent:AddButton("Z reset")
    -- Style.buttonSize.default(resetUpDownButton)
    -- resetUpDownButton.IDContext = "ResetUpDownButton"
    -- resetUpDownButton.SameLine = true
    -- resetUpDownButton.OnClick = function()
    --     ResetLightPosition("y")
    -- end

    
    --#endregion


    
    local savePositionButton = parent:AddButton("Save")
    savePositionButton.IDContext = "SavePositionButton"
    Style.buttonSize.default(savePositionButton)
    savePositionButton.OnClick = function()
        SaveLightPosition()
    end

    local loadPositionButton = parent:AddButton("Load")
    loadPositionButton.IDContext = "LoadPositionButton"
    Style.buttonSize.default(loadPositionButton)
    loadPositionButton.SameLine = true
    loadPositionButton.OnClick = function()
        LoadLightPosition()
    end





    -- Add position controls separator _ai
    local Separator = parent:AddSeparatorText("Utilities")

    -- Add step control sliders _ai
    local movementStepSlider = parent:AddSlider("Position mod", buttonStep, 0.001, 2, 0.001)
    movementStepSlider.IDContext = "MovementStepSlider"
    movementStepSlider.OnChange = function(widget)
        buttonStep = widget.Value[1]
    end

    local rotationStepSlider = parent:AddSlider("Rotation mod", rotationStep, 0.001, 2, 0.001)
    rotationStepSlider.IDContext = "RotationStepSlider"
    rotationStepSlider.OnChange = function(widget)
        rotationStep = widget.Value[1]
    end

    -- Add VFX control checkbox _ai
    local vfxControlCheckbox = parent:AddCheckbox("Disable VFX blur and shake")
    vfxControlCheckbox.OnChange = function(widget)
        DisableVFXEffects(widget.Checked)
    end

    local dummyUP = parent:AddDummy(229, 0)
    dummyUP.IDContext = "dummyUP"
    dummyUP.SameLine = true


    -- local createButton = parent:AddButton("U")
    -- createButton.IDContext = "CreateLightButton"
    -- createButton.SameLine = true
    -- createButton.OnClick = function()
    --     mw:SetScroll({ 0, 0 })
    -- end
end

--===============-------------------------------------------------------------------------------------------------------------------------------
-----ORIGIN POINT TAB------
--===============-------------------------------------------------------------------------------------------------------------------------------

function OriginPointTab(parent)
    parent:AddSeparatorText("Management")

    -- Create origin point button _ai
    local createButton = parent:AddButton("Create")
    createButton.IDContext = "CreateOriginPointButton"
    Style.buttonSize.default(createButton)
    createButton.OnClick = function()
        CreateOriginPoint()
    end

    -- Move origin point to camera position button _ai
    local moveToCameraButton = parent:AddButton("Move to cam")
    moveToCameraButton.IDContext = "MoveToCameraButton"
    -- Style.buttonSize.default(moveToCameraButton)
    moveToCameraButton.SameLine = true
    moveToCameraButton.OnClick = function()
        MoveOriginPointToCameraPos()
    end

    -- Reset position button _ai
    local resetButton = parent:AddButton("Reset")
    resetButton.IDContext = "ResetOriginPointButton"
    Style.buttonSize.default(resetButton)
    resetButton.SameLine = true
    resetButton.OnClick = function()
        ResetOriginPoint()
    end


    -- Delete origin point button _ai
    local deleteButton = parent:AddButton("Delete")
    deleteButton.IDContext = "DeleteOriginPointButton"
    Style.buttonSize.default(deleteButton)
    deleteButton.SameLine = true


    local hideOriginPointCheckbox = parent:AddCheckbox("Hide origin point")
    hideOriginPointCheckbox.IDContext = "HideOriginPointCheckbox"
    hideOriginPointCheckbox.OnChange = function(widget)
        ScaleOriginPoint(widget.Checked)
    end

    deleteButton.OnClick = function()
        DeleteOriginPoint()
        hideOriginPointCheckbox.Checked = false
    end

    parent:AddSeparatorText("Position")

    local zSlider = parent:AddSlider("", 0, -1000, 1000, 0.001)
    zSlider.OnChange = function(value)
        OriginPointSliderChange(value, "z", stepMultiplier)
    end

    -- Z axis buttons _ai
    local zLeftButton = parent:AddButton("<")
    zLeftButton.SameLine = true
    zLeftButton.IDContext = "ZLeftButton"
    zLeftButton.OnClick = function()
        MoveOriginPoint("z", -buttonStep)
    end

    local zRightButton = parent:AddButton(">")
    zRightButton.SameLine = true
    zRightButton.IDContext = "ZRightButton"
    zRightButton.OnClick = function()
        MoveOriginPoint("z", buttonStep)
    end

    local addtext = parent:AddText("South/North")
    addtext.SameLine = true


    
    local ySlider = parent:AddSlider("", 0, -1000, 1000, 0.001)
    ySlider.OnChange = function(value)
        OriginPointSliderChange(value, "y", stepMultiplier)
    end

    -- Y axis buttons _ai
    local yLeftButton = parent:AddButton("<")
    yLeftButton.SameLine = true
    yLeftButton.IDContext = "YLeftButton"
    yLeftButton.OnClick = function()
        MoveOriginPoint("y", -buttonStep)
    end

    local yRightButton = parent:AddButton(">")
    yRightButton.SameLine = true
    yRightButton.IDContext = "YRightButton"
    yRightButton.OnClick = function()
        MoveOriginPoint("y", buttonStep)
    end

    local addtext = parent:AddText("Down/Up")
    addtext.SameLine = true

    -- Add sliders for position adjustment _ai
    local xSlider = parent:AddSlider("", 0, -1000, 1000, 0.001)
    xSlider.IDContext = "XSlider"
    xSlider.OnChange = function(value)
        OriginPointSliderChange(value, "x", stepMultiplier)
    end

    -- X axis buttons _ai
    local xLeftButton = parent:AddButton("<")
    xLeftButton.SameLine = true
    xLeftButton.IDContext = "XLeftButton"
    xLeftButton.OnClick = function()
        MoveOriginPoint("x", -buttonStep)
    end

    local xRightButton = parent:AddButton(">")
    xRightButton.SameLine = true
    xRightButton.IDContext = "XRightButton"
    xRightButton.OnClick = function()
        MoveOriginPoint("x", buttonStep)
    end

    local addtext = parent:AddText("West/East")
    addtext.SameLine = true

end

--===============-------------------------------------------------------------------------------------------------------------------------------
-----ANAL TAB------
--===============-------------------------------------------------------------------------------------------------------------------------------

function AnLWindowTab(parent)
    parent:AddSeparatorText("Management")

    -- Add LTN controls _ai
    local ltnSearchInput = parent:AddInputText("Search LTN", "")

    local dummyUP = parent:AddDummy(27, 0)
    dummyUP.IDContext = "dummyUP"
    dummyUP.SameLine = true


    local createButton = parent:AddButton("D")
    createButton.IDContext = "CreateLightButton"
    createButton.SameLine = true
    createButton.OnClick = function()
        mw:SetScroll({ 0, 1000000 })
    end

    ltnCombo = parent:AddCombo("", "")

    -- Initialize LTN combo _ai
    ltnCombo.Options = GetTemplateOptions(ltn_templates)
    ltnCombo.SelectedIndex = 0

    local ltnLeftButton = parent:AddButton("<")
    ltnLeftButton.SameLine = true
    ltnLeftButton.IDContext = "LTNLeftButton"
    ltnLeftButton.OnClick = function()
        LTNButtonClick("left", ltnCombo.SelectedIndex, ltnCombo)
    end

    local ltnRightButton = parent:AddButton(">")
    ltnRightButton.SameLine = true
    ltnRightButton.IDContext = "LTNRightButton"
    ltnRightButton.OnClick = function()
        LTNButtonClick("right", ltnCombo.SelectedIndex, ltnCombo)
    end


    -- Then add Fav button _ai
    local addToLTNFavButton = parent:AddButton("Add to favs")
    addToLTNFavButton.SameLine = true
    addToLTNFavButton.IDContext = "AddToLTNFavoritesButton"
    addToLTNFavButton.OnClick = function()
        AddLTNFavorite(ltnCombo, ltnFavCombo)
    end

    -- Add LTN favorites section _ai
    ltnFavCombo = parent:AddCombo("")
    local ltnFavOptions = {}
    for _, fav in ipairs(LTNFavoritesList) do
        table.insert(ltnFavOptions, fav.name)
    end
    ltnFavCombo.Options = ltnFavOptions
    ltnFavCombo.OnChange = function(widget)
        LTNFavComboChange(widget)
    end

    -- Add LTN favorites navigation _ai
    local ltnFavLeftButton = parent:AddButton("<")
    ltnFavLeftButton.SameLine = true
    ltnFavLeftButton.IDContext = "LTNFavLeftButton"
    ltnFavLeftButton.OnClick = function()
        LTNFavButtonClick("left", ltnFavCombo)
    end

    local ltnFavRightButton = parent:AddButton(">")
    ltnFavRightButton.SameLine = true
    ltnFavRightButton.IDContext = "LTNFavRightButton"
    ltnFavRightButton.OnClick = function()
        LTNFavButtonClick("right", ltnFavCombo)
    end

    local ltnFavText = parent:AddText("Favorites")
    ltnFavText.SameLine = true

    ltnSearchInput.OnChange = function(widget)
        LTNSearchInputChange(widget, ltnCombo)
    end

    ltnCombo.OnChange = function(widget)
        LTNComboBoxChange(widget)
    end

    -- local separator = parent:AddSeparator()
    -- separator:SetColor("Separator", {0.5, 0.5, 0.5, 0})

    local dummySeparator = parent:AddDummy(1, 1)
    dummySeparator.IDContext = "ddummySeparator"


    -- Add ATM controls _ai
    local atmSearchInput = parent:AddInputText("Search ATM", "")
    local atmCombo = parent:AddCombo("", "")

    -- Initialize ATM combo _ai
    atmCombo.Options = GetTemplateOptions(atm_templates)
    atmCombo.SelectedIndex = 0

    local atmLeftButton = parent:AddButton("<")
    atmLeftButton.SameLine = true
    atmLeftButton.IDContext = "ATMLeftButton"
    atmLeftButton.OnClick = function()
        ATMButtonClick("left", atmCombo.SelectedIndex, atmCombo)
    end

    local atmRightButton = parent:AddButton(">")
    atmRightButton.SameLine = true
    atmRightButton.IDContext = "ATMRightButton"
    atmRightButton.OnClick = function()
        ATMButtonClick("right", atmCombo.SelectedIndex, atmCombo)
    end


    -- Then add Fav button _ai
    local addToATMFavButton = parent:AddButton("Add to favs")
    addToATMFavButton.SameLine = true
    addToATMFavButton.IDContext = "ATMFavButton"
    addToATMFavButton.OnClick = function()
        AddATMFavorite(atmCombo, atmFavCombo)
    end

    -- Add ATM favorites section _ai
    atmFavCombo = parent:AddCombo("")
    local atmFavOptions = {}
    for _, fav in ipairs(ATMFavoritesList) do
        table.insert(atmFavOptions, fav.name)
    end
    atmFavCombo.Options = atmFavOptions
    atmFavCombo.OnChange = function(widget)
        ATMFavComboChange(widget)
    end

    -- Add ATM favorites navigation _ai
    local atmFavLeftButton = parent:AddButton("<")
    atmFavLeftButton.SameLine = true
    atmFavLeftButton.IDContext = "ATMFavLeftButton"
    atmFavLeftButton.OnClick = function()
        ATMFavButtonClick("left", atmFavCombo)
    end

    local atmFavRightButton = parent:AddButton(">")
    atmFavRightButton.SameLine = true
    atmFavRightButton.IDContext = "ATMFavRightButton"
    atmFavRightButton.OnClick = function()
        ATMFavButtonClick("right", atmFavCombo)
    end

    local atmFavText = parent:AddText("Favorites")
    atmFavText.SameLine = true

    atmSearchInput.OnChange = function(widget)
        ATMSearchInputChange(widget, atmCombo)
    end

    atmCombo.OnChange = function(widget)
        ATMComboBoxChange(widget)
    end

    -- Add reset ATM button _ai
    local resetATMButton = parent:AddButton("Reset ATM")
    resetATMButton.IDContext = "ResetAllATMButton"
    resetATMButton.OnClick = function()
        ResetAllATM()
    end

    -- Add reset LTN button _ai
    local resetLTNButton = parent:AddButton("Reset LTN")
    resetLTNButton.IDContext = "ResetAllLTNButton"
    resetLTNButton.SameLine = true
    resetLTNButton.OnClick = function()
        ResetAllLTN()
    end
end



--===============-------------------------------------------------------------------------------------------------------------------------------
-----PM TAB------
--===============-------------------------------------------------------------------------------------------------------------------------------

function BetterPMTab(parent)
    local camSepa = parent:AddSeparatorText('Camera settings')

    camCollapse = parent:AddCollapsingHeader("Camera")
    camCollapse.DefaultOpen = false


    local camSpeed = camCollapse:AddSlider("Speed", 0, 0.01, 100, 0.1) --default, min, max, step
    camSpeed.IDContext = "UniqueSliderID"
    camSpeed.SameLine = false
    camSpeed.Logarithmic = true
    camSpeed.Components = 1
    camSpeed.Value = {Ext.Stats.GetStatsManager().ExtraData["PhotoModeCameraMovementSpeed"],0,0,0}
    camSpeed.OnChange = function()
         Ext.Stats.GetStatsManager().ExtraData["PhotoModeCameraMovementSpeed"] = camSpeed.Value[1]
    end

    local farPlane = camCollapse:AddSlider('Far plane distance', 1000, 0, 5000, 1)
    farPlane.Logarithmic = true
    farPlane.OnChange = function()
        CameraControlls('Far_plane', farPlane.Value[1])
    end

    local nearPlane = camCollapse:AddCheckbox('Disable near plane')
    nearPlane.OnChange = function()
        local camera = Camera:GetActiveCamera()
        if camera then
            if nearPlane.Checked then
                camera.Camera.Controller.NearPlane = 0.01
            else
                camera.Camera.Controller.NearPlane = 0.099999
            end
        end
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
            --DDump(Globals.CameraPositions[btnLoadPos.Label])
            if Globals.CameraPositions[btnLoadPos.Label] then 
                Camera:SetTranslate(Globals.CameraPositions[btnLoadPos.Label].activeTranslate)
                Camera:SetRotationQuat(Globals.CameraPositions[btnLoadPos.Label].activeRotationQuat)
                Camera:SetScale(Globals.CameraPositions[btnLoadPos.Label].activeScale)
            end
            
            -- Camera:GetActiveCamera().PhotoModeCameraSavedTransform.field_0.Translate = Globals.CameraPositions[btnLoadPos.Label].activeTranslate
            -- Camera:GetActiveCamera().PhotoModeCameraSavedTransform.field_0.RotationQuat = Globals.CameraPositions[btnLoadPos.Label].activeRotationQuat
            -- Camera:GetActiveCamera().PhotoModeCameraSavedTransform.field_0.Scale = Globals.CameraPositions[btnLoadPos.Label].activeScale
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
        --getSelectedFillCharacter()
        selectedCharacter = visTemComob.SelectedIndex + 1
        UpdateCharacterInfo(visTemComob.SelectedIndex + 1)
    end
    selectedCharacter = visTemComob.SelectedIndex + 1


    

    local infoCollapse = parent:AddCollapsingHeader('Info')
    

    
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
        if Globals.DummyNameMap and Globals.DummyNameMap[visTemComob.Options[selectedCharacter]] then
            local transform = Globals.DummyNameMap[visTemComob.Options[selectedCharacter]].Visual.Visual.WorldTransform
            transform.Translate = {posInput.Value[1], posInput.Value[2], posInput.Value[3]}
            transform.Scale = {scaleInput.Value[1], scaleInput.Value[2], scaleInput.Value[3]}
            local deg = {rotInput.Value[1], rotInput.Value[2], rotInput.Value[3]}
            local quats = Math:EulerToQuats(deg)
            transform.RotationQuat = quats
            --UpdateCharacterInfo(index)
        end
    end
    


    local charPosCollapse = parent:AddCollapsingHeader("Position")
    charPosCollapse.DefaultOpen = false



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
    charRotCollapse.DefaultOpen = false



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
        Globals.DummyNameMap[visTemComob.Options[selectedCharacter]].Visual.Visual.WorldTransform.RotationQuat =  {0.0, 1.0, 0.0, 0.0}
        UpdateCharacterInfo(selectedCharacter)
    end



    local charScaleCollapse = parent:AddCollapsingHeader("Scale")
    charScaleCollapse.DefaultOpen = false



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
        Globals.DummyNameMap[visTemComob.Options[selectedCharacter]].Visual.Visual.WorldTransform.Scale = { 1, 1, 1 }
        GlobalsIMGUI.infoScale.Label = string.format('L: %.2f  H: %.2f  W: %.2f', 1, 1, 1)
        UpdateCharacterInfo(selectedCharacter)
    end



    parent:AddSeparatorText('')



    local saveLoadCollapse = parent:AddCollapsingHeader('Save/Load postition')



    saveLoadWindow = saveLoadCollapse:AddChildWindow('')
    saveLoadWindow.AlwaysAutoResize = false
    saveLoadWindow.Size = {0, 1}



    local saveButton = saveLoadCollapse:AddButton("Save")
    saveButton.IDContext = "saveIdddasdasda"
    saveButton.SameLine = false
    saveButton.OnClick = function()
        if Globals.DummyNameMap then
            SaveVisTempCharacterPosition()
        end
    end

    --LookAt

    parent:AddSeparatorText('Look at')



    local collapseLookAt = parent:AddCollapsingHeader("Position")
    collapseLookAt.IDContext = 'wwwswdawdwdwd'
    collapseLookAt.DefaultOpen = false


    
    local btnCreateLookAt = collapseLookAt:AddButton('Marker')
    btnCreateLookAt.OnClick = function ()
        Ext.Net.PostMessageToServer('LL_CreateLookAtTarget', '')
    end
    


    local targetPos



    local btnMoveToCamLookAt = collapseLookAt:AddButton('Move to cam')
    btnMoveToCamLookAt.SameLine = true
    btnMoveToCamLookAt.OnClick = function ()
        targetPos = Camera:GetActiveCamera().Transform.Transform.Translate
        Ext.Net.PostMessageToServer('LL_MoveLookAtTargetToCam', Ext.Json.Stringify(targetPos))
    end


    local btnDeleteLookAt = collapseLookAt:AddButton('Delete')
    btnDeleteLookAt.SameLine = true
    btnDeleteLookAt.OnClick = function ()
        Ext.Net.PostMessageToServer('LL_DeleteLookAtTarget', '')
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
        for i = 1, #Globals.DummyNameMap[visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments do
            if Globals.DummyNameMap[visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments[i].Visual.VisualResource.Objects[1].ObjectID:lower():find('tail') then
                Globals.DummyNameMap[visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments[i].Visual:SetWorldTranslate(
                    Globals.DummyNameMap[visTemComob.Options[selectedCharacter]].Visual.Visual.WorldTransform.Translate)
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
        for i = 1, #Globals.DummyNameMap[visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments do
            if Globals.DummyNameMap[visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments[i].Visual.VisualResource.Objects[1].ObjectID:lower():find('tail') then
                Globals.DummyNameMap[visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments[i].Visual:SetWorldRotate(
                    Globals.DummyNameMap[visTemComob.Options[selectedCharacter]].Visual.Visual.WorldTransform.RotationQuat)
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
        for i = 1, #Globals.DummyNameMap[visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments do
            if Globals.DummyNameMap[visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments[i].Visual.VisualResource.Objects[1].ObjectID:lower():find("horns") then
                Globals.DummyNameMap[visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments[i].Visual:SetWorldTranslate(
                    Globals.DummyNameMap[visTemComob.Options[selectedCharacter]].Visual.Visual.WorldTransform.Translate)
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
        for i = 1, #Globals.DummyNameMap[visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments do
            if Globals.DummyNameMap[visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments[i].Visual.VisualResource.Objects[1].ObjectID:lower():find("horns") then
                Globals.DummyNameMap[visTemComob.Options[selectedCharacter]].Visual.Visual.Attachments[i].Visual:SetWorldRotate(
                    Globals.DummyNameMap[visTemComob.Options[selectedCharacter]].Visual.Visual.WorldTransform.RotationQuat)
                break
            end
        end
    end
end

--===============-------------------------------------------------------------------------------------------------------------------------------
-----PARTICLES TAB------
--===============-------------------------------------------------------------------------------------------------------------------------------

function PartclesTab(parent)
    local partText = parent:AddText('Under construction')

    local uuidInput = parent:AddInputText('')
    uuidInput.OnChange = function()
        -- DPrint(uuidInput.Text)
        -- uuid = uuidInput.Text
    end

    local particlesDrop = parent:AddCombo('a')
    particlesDrop.Options = { '1', '2' }
    particlesDrop.SelectedIndex = 0
    particlesDrop.OnChange = function()
        table.insert(createdParticles, particlesDrop.SelectedIndex + 1)
        -- DPrint(particlesDrop.Options)
    end

    createdParticles = {}

    local particlesCreatedDrop = parent:AddCombo('c')
    particlesCreatedDrop.Options = createdParticles
    particlesCreatedDrop.OnChange = function()
        -- DPrint(particlesCreatedDrop.Options)
    end

    local particleSlider = parent:AddSlider("W/E", 0, -100, 100, 0.1)
    particleSlider.OnChange = function()
        local uuid = '0a6559ae-9d79-4d3c-be88-c84644e4062e'
        -- EntControls:Position(uuid, 'x', particleSlider.Value[1], 0.01, 'posSlider', 'OnClient')
        EntControls:Position(uuid, 'x', particleSlider.Value[1], 0.01, 'posSlider', 'OnClientToServer')
        particleSlider.Value = { 0, 0, 0, 0 }
    end


    local particleSlider = parent:AddSlider("U/D", 0, -100, 100, 0.1)
    particleSlider.OnChange = function()
        local uuid = '0a6559ae-9d79-4d3c-be88-c84644e4062e'
        -- EntControls:Position(uuid, 'y', particleSlider.Value[1], 0.01, 'posSlider', 'OnClient')
        EntControls:Position(uuid, 'y', particleSlider.Value[1], 0.01, 'posSlider', 'OnClientToServer')
        particleSlider.Value = { 0, 0, 0, 0 }
    end


    local particleSlider = parent:AddSlider("N/S", 0, -100, 100, 0.1)
    particleSlider.OnChange = function()
        local uuid = '0a6559ae-9d79-4d3c-be88-c84644e4062e'
        -- EntControls:Position(uuid, 'z', particleSlider.Value[1], 0.01, 'posSlider', 'OnClient')
        EntControls:Position(uuid, 'z', particleSlider.Value[1], 0.01, 'posSlider', 'OnClientToServer')
        particleSlider.Value = { 0, 0, 0, 0 }
    end
end



--===============-------------------------------------------------------------------------------------------------------------------------------
-----GOBO TAB----
--===============-------------------------------------------------------------------------------------------------------------------------------

function GoboWindowTab(parent)
    parent:AddSeparatorText("Management")

    local goboGUIDs = {
        Tree = gobo_window_tree,
        Figures = gobo_figures,
        Window = gobo_window
    }

    -- Use existing LightDropdown for light selection _ai
    goboLightDropdown = parent:AddCombo("Created lights")
    goboLightDropdown.IDContext = "GoboLightDropdown"
    goboLightDropdown.HeightLargest = true
    goboLightDropdown.Options = LightDropdown.Options
    goboLightDropdown.SelectedIndex = LightDropdown.SelectedIndex

    -- List of available gobo masks _ai
    local goboList = parent:AddCombo("Masks")
    goboList.IDContext = "GoboMasksList"
    goboList.HeightLargest = true
    goboList.Options = { "Tree", "Figures", "Window" }
    goboList.SelectedIndex = 0

    -- Add distance slider for gobo _ai
    local goboDistanceSlider = parent:AddSlider("Distance", 1.0, 0.1, 4.0, 0.01)
    goboDistanceSlider.IDContext = "GoboDistanceSlider"
    goboDistanceSlider.OnChange = function(widget)
        GoboDistanceSliderChange(widget, goboLightDropdown)
    end


    -- local goboRotationHeader = parent:AddSeparatorText("Rotation")


    -- local goboRotationXSlider = parent:AddSlider("", 0, 0, 360.0, 1.0)
    -- goboRotationXSlider.IDContext = "GoboRotationXSlider"
    -- goboRotationXSlider.OnChange = function(widget)
    --     GoboRotationAxisSlider(widget, goboLightDropdown, "x")
    -- end

    -- local resetGoboRotationXButton = parent:AddButton("Reset tilt")
    -- resetGoboRotationXButton.IDContext = "ResetGoboRotationXButton"
    -- resetGoboRotationXButton.SameLine = true
    -- resetGoboRotationXButton.OnClick = function()
    --     ResetGoboRotation(goboLightDropdown, "x")
    --     goboRotationXSlider.Value = {0, 0, 0, 0}
    -- end

    -- local goboRotationYSlider = parent:AddSlider("", 0, 0, 360.0, 1.0)
    -- goboRotationYSlider.IDContext = "GoboRotationYSlider"
    -- goboRotationYSlider.OnChange = function(widget)
    --     GoboRotationAxisSlider(widget, goboLightDropdown, "y")
    -- end

    -- local resetGoboRotationYButton = parent:AddButton("Reset yaw")
    -- resetGoboRotationYButton.IDContext = "ResetGoboRotationYButton"
    -- resetGoboRotationYButton.SameLine = true
    -- resetGoboRotationYButton.OnClick = function()
    --     ResetGoboRotation(goboLightDropdown, "y")
    --     goboRotationYSlider.Value = {0, 0, 0, 0}
    -- end

    -- local goboRotationZSlider = parent:AddSlider("", 0, 0, 360.0, 1.0)
    -- goboRotationZSlider.IDContext = "GoboRotationZSlider"
    -- goboRotationZSlider.OnChange = function(widget)
    --     GoboRotationAxisSlider(widget, goboLightDropdown, "z")
    -- end

    -- local resetGoboRotationZButton = parent:AddButton("Reset roll")
    -- resetGoboRotationZButton.IDContext = "ResetGoboRotationZButton"
    -- resetGoboRotationZButton.SameLine = true
    -- resetGoboRotationZButton.OnClick = function()
    --     ResetGoboRotation(goboLightDropdown, "z")
    --     goboRotationZSlider.Value = {0, 0, 0, 0}
    -- end

    -- local resetAllGoboRotationButton = parent:AddButton("Reset all")
    -- resetAllGoboRotationButton.IDContext = "ResetAllGoboRotationButton"
    -- resetAllGoboRotationButton.OnClick = function()
    --     ResetGoboRotation(goboLightDropdown, "all")
    --     goboRotationXSlider.Value = {0, 0, 0, 0}
    --     goboRotationYSlider.Value = {0, 0, 0, 0}
    --     goboRotationZSlider.Value = {0, 0, 0, 0}
    -- end

    -- Add create gobo button _ai
    local createGoboButton = parent:AddButton("Create gobo")
    createGoboButton.IDContext = "CreateGoboButton"
    createGoboButton.OnClick = function()
        CreateGoboClick(goboLightDropdown, goboList, goboGUIDs)
    end


    local deleteGoboButton = parent:AddButton("Delete gobo")
    deleteGoboButton.IDContext = "DeleteGoboButton"
    deleteGoboButton.SameLine = true
    deleteGoboButton.OnClick = function()
        DeleteGoboClick(goboLightDropdown)
    end
end

--===============-------------------------------------------------------------------------------------------------------------------------------
-----MAIN2 TAB------
--===============-------------------------------------------------------------------------------------------------------------------------------
--[[
function  MainWindowTab2(parent)
    parent:AddText('Main2')

    
    Globals.LightEntities = {}
    Globals.selectedLight = tostring(1) --yes
    hard = '7279c199-1f14-4bce-8740-98866d9878be'

    local btnCreateLight = parent:AddButton('Create')
    btnCreateLight.OnClick = function ()
        local availableLightGuid = hard
        local data = {
            lightGuid = availableLightGuid
        }
        Ext.Net.PostMessageToServer('LL_CreateLight', Ext.Json.Stringify(data))
    end
    
    local btnReCreateLight = parent:AddButton('ReCreate')
    btnReCreateLight.OnClick = function ()

        local data = {
            lightEntityUuid = Globals.LightEntities[Globals.selectedLight]
        }
        Ext.Net.PostMessageToServer('LL_RecreateLight', Ext.Json.Stringify(data))
    end

    local lightRT_lightLight_Map = {
        ['7279c199-1f14-4bce-8740-98866d9878be'] = 'aca228c3-f0c5-41e0-bc00-d11ddee12ed0'
    }
    
    Globals.selectedLightAngle = Ext.Template.GetRootTemplate(lightRT_lightLight_Map[hard]).Angle[2]
    Ext.Template.GetRootTemplate(lightRT_lightLight_Map[hard]).LightType = 1
    
    Ext.RegisterNetListener('LL_LightEntitiesTable', function (channel, payload, user)
        Globals.LightEntities = Ext.Json.Parse(payload)
        DDump(Globals.LightEntities)
    end)
    
    local function RecreateLight()
        Utils:AntiSpam(0, function ()
            local data = {
                lightEntityUuid = Globals.LightEntities[Globals.selectedLight]
            }
            Ext.Net.PostMessageToServer('LL_RecreateLight', Ext.Json.Stringify(data))
        end)
    end

    local btnOuterAngleDec = parent:AddButton('<')
    btnOuterAngleDec.IDContext = 's;alkf122mnef'
    btnOuterAngleDec.OnClick = function ()
        Utils:AntiSpam(50, function ()
            local lightLight = Ext.Template.GetRootTemplate(lightRT_lightLight_Map[hard])
            lightLight.Angle = {1, Globals.selectedLightAngle - 1}
            RecreateLight()
        end)
    end

    local btnOuterAngleInc = parent:AddButton('>')
    btnOuterAngleInc.IDContext = 's;alkfjas;oefijnweimnef'
    btnOuterAngleInc.OnClick = function ()
        Utils:AntiSpam(50, function ()
            local lightLight = Ext.Template.GetRootTemplate(lightRT_lightLight_Map[hard])
            lightLight.Angle = {1, Globals.selectedLightAngle + 1}
            RecreateLight()
        end)
    end
    


    local slOuterAngle = parent:AddSliderInt('Outer angle', 10, 1, 179, 1)
    slOuterAngle.OnChange = function ()
        -- local lightRT = Ext.Template.GetRootTemplate('7279c199-1f14-4bce-8740-98866d9878be')
        -- local lightResource = Ext.Resource.Get(lightRT.VisualTemplate, 'Effect')
        -- local lightGuid = lightResource.Constructor.EffectComponents[1].Properties['Appearance.Light UUID'].Value
        local lightLight = Ext.Template.GetRootTemplate(lightRT_lightLight_Map[hard])
        lightLight.Angle = {1, slOuterAngle.Value[1]}
        RecreateLight()
    end
end
]]

--===============-------------------------------------------------------------------------------------------------------------------------------
-----ANAL2 TAB------
--===============-------------------------------------------------------------------------------------------------------------------------------


function Anal2Tab(parent)

    
    local CHILD_WIN_SIZE = {554, 200}
    local winLtnFav
    local winAtmFav


    -- local valuesApplyButton = parent:AddButton("Apply 2")
    -- valuesApplyButton.IDContext = "sunValuesDayLoad"
    -- valuesApplyButton.SameLine = false
    -- valuesApplyButton.OnClick = function()
    --     Ext.Net.PostMessageToServer("valuesApplyDay", "")
    -- end



    parent:AddSeparatorText('Lighting')

    

    Globals.FilteredLTNOptions = Globals.LtnComboOptions


    
    local inpSearchLighting = parent:AddInputText('')
    inpSearchLighting.IDContext = 'o9irtqjwno9485839c'
    inpSearchLighting.OnChange = function()
        Globals.FilteredLTNOptions = UI:FilterOptions(inpSearchLighting.Text, Globals.LtnComboOptions)
        GlobalsIMGUI.comboLighting.Options = Globals.FilteredLTNOptions
        GlobalsIMGUI.comboLighting.SelectedIndex = 0
    end



    local btnClearSearch = parent:AddButton('Search')
    btnClearSearch.SameLine = true
    btnClearSearch.OnClick = function ()
        inpSearchLighting.Text = ''
        Globals.FilteredLTNOptions = Globals.LtnComboOptions
        GlobalsIMGUI.comboLighting.Options = Globals.LtnComboOptions
    end
    


    GlobalsIMGUI.comboLighting = parent:AddCombo('')
    GlobalsIMGUI.comboLighting.IDContext = ';oeirj4eiouh'
    GlobalsIMGUI.comboLighting.Options = Globals.LtnComboOptions or {}
    GlobalsIMGUI.comboLighting.SelectedIndex = 0
    GlobalsIMGUI.comboLighting.OnChange = function ()
        Ext.Net.PostMessageToServer('LL_LightingApply', UI:SelectedOpt(GlobalsIMGUI.comboLighting))
        ChangeLTNValues()
    end

    
    
    local btnPrevLtn = parent:AddButton('<')
    btnPrevLtn.IDContext = ';olsikefnlieurhn'
    btnPrevLtn.SameLine = true
    btnPrevLtn.OnClick = function ()
        UI:PrevOption(GlobalsIMGUI.comboLighting)
        Ext.Net.PostMessageToServer('LL_LightingApply', UI:SelectedOpt(GlobalsIMGUI.comboLighting))
        ChangeLTNValues()
    end



    local btnNextLtn = parent:AddButton('>')
    btnNextLtn.IDContext = ';olsikefnlieur3402934u20934uhn'
    btnNextLtn.SameLine = true
    btnNextLtn.OnClick = function ()
        UI:NextOption(GlobalsIMGUI.comboLighting)
        Ext.Net.PostMessageToServer('LL_LightingApply', UI:SelectedOpt(GlobalsIMGUI.comboLighting))
        ChangeLTNValues()
    end



    local btnAddToFav = parent:AddButton('Add')
    btnAddToFav.IDContext = 'oiurfhaieowurhi4wh5iu'
    btnAddToFav.SameLine = true
    btnAddToFav.OnClick = function ()
        if Globals.FavLighting[UI:SelectedOpt(GlobalsIMGUI.comboLighting)] == UI:SelectedOpt(GlobalsIMGUI.comboLighting) then
            return
        else
            CreateSelectable(winLtnFav, Globals.FavLighting, Globals.FilteredLTNOptions[GlobalsIMGUI.comboLighting.SelectedIndex + 1], 'FavoriteLighting', 'LL_LightingApply')
        end
    end



    local colFav = parent:AddCollapsingHeader('Favorites')
    colFav.IDContext = 'iaeuhkbnkwbriyuwg34iy'
    


    winLtnFav = colFav:AddChildWindow('')
    winLtnFav.Size = CHILD_WIN_SIZE



    if Ext.IO.LoadFile('LightyLights/FavoriteLighting.json') then
        Globals.FavLighting = Ext.Json.Parse(Ext.IO.LoadFile('LightyLights/FavoriteLighting.json'))
        PopulateLTNFavorites(winLtnFav, Globals.FavLighting)
    else
        Globals.FavLighting = {}
    end



    parent:AddSeparatorText('Atmosphere')



    Globals.FilteredATMOptions = Globals.AtmComboOptions



    local inpSearchAtmosphere = parent:AddInputText('')
    inpSearchAtmosphere.IDContext = 'pfkjawpo3i4rho83hr'
    inpSearchAtmosphere.OnChange = function()
        Globals.FilteredATMOptions = UI:FilterOptions(inpSearchAtmosphere.Text, Globals.AtmComboOptions)
        GlobalsIMGUI.comboAtmosphere.Options = Globals.FilteredATMOptions
        GlobalsIMGUI.comboAtmosphere.SelectedIndex = 0
    end



    local btnClearSearchAtm = parent:AddButton('Search')
    btnClearSearchAtm.IDContext = 'oweifjw3oiufhn'
    btnClearSearchAtm.SameLine = true
    btnClearSearchAtm.OnClick = function ()
        inpSearchAtmosphere.Text = ''
        Globals.FilteredATMOptions = Globals.AtmComboOptions
        GlobalsIMGUI.comboAtmosphere.Options = Globals.AtmComboOptions
    end



    GlobalsIMGUI.comboAtmosphere = parent:AddCombo('')
    GlobalsIMGUI.comboAtmosphere.IDContext = ';o342342etm'
    GlobalsIMGUI.comboAtmosphere.Options = Globals.AtmComboOptions or {}
    GlobalsIMGUI.comboAtmosphere.SelectedIndex = 0
    GlobalsIMGUI.comboAtmosphere.OnChange = function ()
        Ext.Net.PostMessageToServer('LL_AtmosphereApply', UI:SelectedOpt(GlobalsIMGUI.comboAtmosphere))
    end



    local btnPrevAtm = parent:AddButton('<')
    btnPrevAtm.IDContext = ';olsikefnli4444444eurhnatm'
    btnPrevAtm.SameLine = true
    btnPrevAtm.OnClick = function ()
        UI:PrevOption(GlobalsIMGUI.comboAtmosphere)
        Ext.Net.PostMessageToServer('LL_AtmosphereApply', UI:SelectedOpt(GlobalsIMGUI.comboAtmosphere))
    end



    local btnNextAtm = parent:AddButton('>')
    btnNextAtm.IDContext = ';ol123123sik34uhnatm'
    btnNextAtm.SameLine = true
    btnNextAtm.OnClick = function ()
        UI:NextOption(GlobalsIMGUI.comboAtmosphere)
        Ext.Net.PostMessageToServer('LL_AtmosphereApply', UI:SelectedOpt(GlobalsIMGUI.comboAtmosphere))
    end



    local btnAddToFavAtm = parent:AddButton('Add')
    btnAddToFavAtm.IDContext = 'oiu12312354125m'
    btnAddToFavAtm.SameLine = true
    btnAddToFavAtm.OnClick = function ()
        if Globals.FavAtmosphere[UI:SelectedOpt(GlobalsIMGUI.comboAtmosphere)] == UI:SelectedOpt(GlobalsIMGUI.comboAtmosphere) then
            return
        else
            CreateSelectable(winAtmFav, Globals.FavAtmosphere, Globals.FilteredATMOptions[GlobalsIMGUI.comboAtmosphere.SelectedIndex + 1], 'FavoriteAtmosphere', 'LL_AtmosphereApply')
        end
    end



    local colFavAtm = parent:AddCollapsingHeader('Favorites')
    colFavAtm.IDContext = 'iae1231231235156646hgdtm'

    winAtmFav = colFavAtm:AddChildWindow('')
    winAtmFav.Size = CHILD_WIN_SIZE



    if Ext.IO.LoadFile('LightyLights/FavoriteAtmosphere.json') then
        Globals.FavAtmosphere = Ext.Json.Parse(Ext.IO.LoadFile('LightyLights/FavoriteAtmosphere.json'))
        PopulateATMFavorites(winAtmFav, Globals.FavAtmosphere)
    else
        Globals.FavAtmosphere = {}
    end



    local aepasdaw = parent:AddSeparatorText('Reset')



    local resetLtnBtn = parent:AddButton('Lighting')
    resetLtnBtn.OnClick = function ()
        ResetAllLTN()
    end
    


    local resetAtmBtn = parent:AddButton('Atmosphere')
    resetAtmBtn.SameLine = true
    resetAtmBtn.OnClick = function ()
        ResetAllATM()
    end


    


    --#region TBD: refactor
    parent:AddSeparatorText('Parameters')

    local valuesApplyButton = parent:AddButton("Apply")
    valuesApplyButton.IDContext = "sunValuesNightLoad"
    valuesApplyButton.OnClick = function()
        Ext.Net.PostMessageToServer("valuesApply", "")
    end


    local sunValuesLoadButton = parent:AddButton("Reset all")
    sunValuesLoadButton.IDContext = "sunValuesLoad"
    sunValuesLoadButton.SameLine = true
    sunValuesLoadButton.OnClick = function()
        Ext.Net.PostMessageToServer("sunValuesResetAll", "")
        starsCheckbox.Checked = false
        castLightCheckbox.Checked = false
    end

    parent:AddText('I advise you to set a hotkey for Apply').SameLine = true

    local collapsingHeaderSun = parent:AddCollapsingHeader("Sun")

    sunYaw = collapsingHeaderSun:AddSlider("Yaw", 0, 0, 360, 0.01)
    sunYaw.IDContext = "sunYaw"
    sunYaw.SameLine = false
    sunYaw.Value = { 0, 0, 0, 0 }
    sunYaw.OnChange = function(value)
        -- DPrint(sunYaw.Value[1])
        UpdateValue("SunYaw", "value1", value)
    end

    sunPitch = collapsingHeaderSun:AddSlider("Pitch", 0, 0, 360, 0.01)
    sunPitch.IDContext = "sunPitch"
    sunPitch.SameLine = false
    sunPitch.OnChange = function(value)
        --DPrint(sunPitch.Value[1])
        UpdateValue("SunPitch", "value1", value)
    end

    sunIntensity = collapsingHeaderSun:AddSlider("Intensity", 0, 0, 1000000, 0.01)
    sunIntensity.IDContext = "sunIntensity"
    sunIntensity.SameLine = false
    sunIntensity.Logarithmic = true
    sunIntensity.OnChange = function(value)
        --DPrint(sunIntensity.Value[1])
        UpdateValue("SunInt", "value1", value)
    end

    sunColor = collapsingHeaderSun:AddColorEdit("Sun color")
    sunColor.IDContext = "colorSun"
    sunColor.Color = { 1.0, 1.0, 1.0, 1.0 }
    sunColor.NoAlpha = true
    sunColor.Float = true
    sunColor.PickerHueWheel = false
    sunColor.InputRGB = true
    sunColor.DisplayHex = true
    sunColor.OnChange = function(value)
        UpdateValue("SunColor", "value4", value)
        -- Color change code here
    end


    -- local moonSeparator = parent:AddSeparatorText("Moon")

    local collapsingHeaderMoon = parent:AddCollapsingHeader("Moon")


    moonEnabledCheckbox = collapsingHeaderMoon:AddCheckbox("Enabled")
    moonEnabledCheckbox.IDContext = "moonEnabledCheckbox"
    moonEnabledCheckbox.Checked = false
    moonEnabledCheckbox.SameLine = false
    moonEnabledCheckbox.OnChange = function()
        UpdateValue("MoonEnabled", "value", moonEnabledCheckbox.Checked)
    end

    castLightCheckbox = collapsingHeaderMoon:AddCheckbox("Cast light")
    castLightCheckbox.IDContext = "castLightCheckbox"
    castLightCheckbox.Checked = false
    castLightCheckbox.SameLine = true
    castLightCheckbox.OnChange = function(value)
        if castLightCheckbox.Checked then
            --DPrint(castLightCheckbox.Checked)
            UpdateValue("CastLight", "value", true)
        else
            --DPrint(castLightCheckbox.Checked)
            UpdateValue("CastLight", "value", false)
        end
    end

    moonYaw = collapsingHeaderMoon:AddSlider("Yaw", 0, 0, 360, 0.01)
    moonYaw.IDContext = "moonYaw"
    moonYaw.SameLine = false
    moonYaw.OnChange = function(value)
        --DPrint(moonYaw.Value[1])
        UpdateValue("MoonYaw", "value1", value)
    end

    moonPitch = collapsingHeaderMoon:AddSlider("Pitch", 0, 0, 360, 0.01)
    moonPitch.IDContext = "moonPitch"
    moonPitch.SameLine = false
    moonPitch.OnChange = function(value)
        --DPrint(moonPitch.Value[1])
        UpdateValue("MoonPitch", "value1", value)
    end

    moonIntensity = collapsingHeaderMoon:AddSlider("Intensity", 0, 0, 100000, 0.01)
    moonIntensity.IDContext = "moonIntensity"
    moonIntensity.SameLine = false
    moonIntensity.Logarithmic = true
    moonIntensity.OnChange = function(value)
        --DPrint(moonIntensity.Value[1])
        UpdateValue("MoonInt", "value1", value)
    end

    moonEarthshine = collapsingHeaderMoon:AddSlider("Earthshine", 0, 0, 1, 0.01)
    moonEarthshine.IDContext = "moonEarthshine"
    moonEarthshine.SameLine = false
    moonEarthshine.OnChange = function(value)
        UpdateValue("MoonEarthshine", "value1", value)
    end

    moonGlare = collapsingHeaderMoon:AddSlider("Glare", 0, 0, 10, 0.01)
    moonGlare.IDContext = "moonGlare"
    moonGlare.SameLine = false
    moonGlare.OnChange = function(value)
        UpdateValue("MoonGlare", "value1", value)
    end

    moonRadius = collapsingHeaderMoon:AddSlider("Radius", 0, 0, 100000, 0.01)
    moonRadius.IDContext = "moonRadius"
    moonRadius.SameLine = false
    moonRadius.Logarithmic = true
    moonRadius.OnChange = function(value)
        --DPrint(moonRadius.Value[1])
        UpdateValue("MoonRadius", "value1", value)
    end


    moonDistance = collapsingHeaderMoon:AddSlider("Distance", 0, 0, 1000000, 1)
    moonDistance.IDContext = "moonDistance"
    moonDistance.SameLine = false
    moonDistance.Logarithmic = true
    moonDistance.OnChange = function(value)
        UpdateValue("MoonDistance", "value1", value)
    end



    -- tearsRotate = collapsingHeaderMoonExtended:AddSlider("Tears Rotate", 0, 0, 360, 0.01)
    -- tearsRotate.IDContext = "tearsRotate"
    -- tearsRotate.SameLine = false
    -- tearsRotate.OnChange = function(value)
    --     UpdateValue("TearsRotate", "value1", value)
    -- end

    -- tearsScale = collapsingHeaderMoonExtended:AddSlider("Tears Scale", 0, 0, 10, 0.01)
    -- tearsScale.IDContext = "tearsScale"
    -- tearsScale.SameLine = false
    -- tearsScale.OnChange = function(value)
    --     UpdateValue("TearsScale", "value1", value)
    -- end


    moonColor = collapsingHeaderMoon:AddColorEdit("Moon color")
    moonColor.IDContext = "colorMoon"
    moonColor.Color = { 1.0, 1.0, 1.0, 1.0 }
    moonColor.NoAlpha = true
    moonColor.Float = true
    moonColor.PickerHueWheel = false
    moonColor.InputRGB = true
    moonColor.DisplayHex = true
    moonColor.OnChange = function(value)
        UpdateValue("MoonColor", "value4", value)
        -- Color change code here
    end

    -- local starsSeparator = parent:AddSeparatorText("Stars")

    local collapsingHeaderStars = parent:AddCollapsingHeader("Stars")

    starsCheckbox = collapsingHeaderStars:AddCheckbox("Stars")
    starsCheckbox.IDContext = "starsCheckbox"
    starsCheckbox.Checked = false
    starsCheckbox.SameLine = false
    starsCheckbox.OnChange = function()
        if starsCheckbox.Checked then
            --DPrint(starsCheckbox.Checked)
            -- UpdateStarsState(1)
            -- Checked code
            UpdateValue("StarsState", "value", true)
        else
            --DPrint(starsCheckbox.Checked)
            -- UpdateStarsState(0)
            -- Unchecked code
            UpdateValue("StarsState", "value", false)
        end
    end

    starsAmount = collapsingHeaderStars:AddSlider("Amount", 0, 0, 50, 0.01)
    starsAmount.IDContext = "starsAmount"
    starsAmount.SameLine = false
    starsAmount.OnChange = function(value)
        --DPrint(starsAmount.Value[1])
        UpdateValue("StarsAmount", "value1", value)
    end

    starsIntensity = collapsingHeaderStars:AddSlider("Intensity", 0, 0, 100000, 0.01)
    starsIntensity.IDContext = "starsIntensity"
    starsIntensity.SameLine = false
    starsIntensity.Logarithmic = true
    starsIntensity.OnChange = function(value)
        --DPrint(starsIntensity.Value[1])
        UpdateValue("StarsInt", "value1", value)
    end

    starsSaturation1 = collapsingHeaderStars:AddSlider("Saturation 1", 0, 0, 1, 0.01)
    starsSaturation1.IDContext = "starsSaturation1"
    starsSaturation1.SameLine = false
    starsSaturation1.OnChange = function(value)
        --DPrint(starsSaturation1.Value[1])
        UpdateValue("StarsSaturation1", "value1", value)
    end

    starsSaturation2 = collapsingHeaderStars:AddSlider("Saturation 2", 0, 0, 1, 0.01)
    starsSaturation2.IDContext = "starsSaturation2"
    starsSaturation2.SameLine = false
    starsSaturation2.OnChange = function(value)
        --DPrint(starsSaturation2.Value[1])
        UpdateValue("StarsSaturation2", "value1", value)
    end

    starsShimmer = collapsingHeaderStars:AddSlider("Shimmer", 0, 0, 10, 0.01)
    starsShimmer.IDContext = "starsShimmer"
    starsShimmer.SameLine = false
    starsShimmer.OnChange = function(value)
        --DPrint(starsShimmer.Value[1])
        UpdateValue("StarsShimmer", "value1", value)
    end



    local collapsingHeaderShadows = parent:AddCollapsingHeader("Shadows")


    shadowEnabledCheckbox = collapsingHeaderShadows:AddCheckbox("Shadow enabled")
    shadowEnabledCheckbox.IDContext = "shadowEnabled"
    shadowEnabledCheckbox.Checked = false
    shadowEnabledCheckbox.SameLine = false
    shadowEnabledCheckbox.OnChange = function()
        UpdateValue("ShadowEnabled", "value", shadowEnabledCheckbox.Checked)
    end

    cascadeSpeed = collapsingHeaderShadows:AddSlider("Cascade speed", 0, 0, 1, 0.01)
    cascadeSpeed.IDContext = "cascadeSpeed"
    cascadeSpeed.SameLine = false
    cascadeSpeed.OnChange = function(value)
        --DPrint(cascadeSpeed.Value[1])
        UpdateValue("CascadeSpeed", "value1", value)
    end

    lightSize = collapsingHeaderShadows:AddSlider("Light size", 0, 0, 30, 0.01)
    lightSize.IDContext = "lightSize"
    lightSize.SameLine = false
    lightSize.OnChange = function(value)
        --DPrint(lightSize.Value[1])
        UpdateValue("LightSize", "value1", value)
    end

    cascadeCountSlider = collapsingHeaderShadows:AddSlider("Cascade count", 0, 0, 10, 1)
    cascadeCountSlider.IDContext = "cascadeCount"
    cascadeCountSlider.SameLine = false
    cascadeCountSlider.OnChange = function()
        UpdateValue("CascadeCount", "value1", cascadeCountSlider)
    end

    shadowBiasSlider = collapsingHeaderShadows:AddSlider("Shadow bias", 0, 0, 1, 0.001)
    shadowBiasSlider.IDContext = "shadowBias"
    shadowBiasSlider.SameLine = false
    shadowBiasSlider.OnChange = function(value)
        UpdateValue("ShadowBias", "value1", value)
    end

    shadowFadeSlider = collapsingHeaderShadows:AddSlider("Shadow fade", 0, 0, 1, 0.01)
    shadowFadeSlider.IDContext = "shadowFade"
    shadowFadeSlider.SameLine = false
    shadowFadeSlider.OnChange = function(value)
        UpdateValue("ShadowFade", "value1", value)
    end

    shadowFarPlaneSlider = collapsingHeaderShadows:AddSlider("Shadow far plane", 0, 0, 100000, 1)
    shadowFarPlaneSlider.IDContext = "shadowFarPlane"
    shadowFarPlaneSlider.SameLine = false
    shadowFarPlaneSlider.Logarithmic = true
    shadowFarPlaneSlider.OnChange = function(value)
        UpdateValue("ShadowFarPlane", "value1", value)
    end

    shadowNearPlaneSlider = collapsingHeaderShadows:AddSlider("Shadow near plane", 0, 0, 1000, 0.1)
    shadowNearPlaneSlider.IDContext = "Bias"
    shadowNearPlaneSlider.SameLine = false
    shadowNearPlaneSlider.OnChange = function(value)
        UpdateValue("ShadowFarPlane", "value1", value)
    end

    -- local collapsingHeaderSSAO = parent:AddCollapsingHeader("Ya naSSAO etoy igre v rot")

    -- ssaoBias = collapsingHeaderSSAO:AddSlider("Bias", 0, 0, 10, 1)
    -- ssaoBias.IDContext = "Bias"
    -- ssaoBias.SameLine = false
    -- ssaoBias.Logarithmic = true
    -- ssaoBias.OnChange = function(value)
    --     UpdateValue("SSAOBias", "value1", value)
    -- end

    -- ssaoDirectLightInfluence = collapsingHeaderSSAO:AddSlider("DirectLightInfluence", 0, -10000000000000000, 10, 1)
    -- ssaoDirectLightInfluence.IDContext = "saasDirectLightInfluence"
    -- ssaoDirectLightInfluence.SameLine = false
    -- ssaoDirectLightInfluence.Logarithmic = true
    -- ssaoDirectLightInfluence.OnChange = function(value)
    --     UpdateValue("SSAODirectLightInfluence", "value1", value)
    -- end


    -- ssaoEnabled = collapsingHeaderSSAO:AddCheckbox("Enabled")
    -- ssaoEnabled.IDContext = "SSAOeewe"
    -- ssaoEnabled.Checked = false
    -- ssaoEnabled.SameLine = false
    -- ssaoEnabled.OnChange = function()
    --     UpdateValue("SSAOEnabled", "value", ssaoEnabled.Checked)
    -- end

    -- ssaoIntensity = collapsingHeaderSSAO:AddSlider("Intensity", 0, 0, 10, 1)
    -- ssaoIntensity.IDContext = "saasIntensity"
    -- ssaoIntensity.SameLine = false
    -- ssaoIntensity.Logarithmic = true
    -- ssaoIntensity.OnChange = function(value)
    --     UpdateValue("SSAOIntensity", "value1", value)
    -- end

    -- ssaoRadius = collapsingHeaderSSAO:AddSlider("Radius", 0, 0, 10, 1)
    -- ssaoRadius.IDContext = "saasIntensity"
    -- ssaoRadius.SameLine = false
    -- ssaoRadius.Logarithmic = true
    -- ssaoRadius.OnChange = function(value)
    --     UpdateValue("SSAORadius", "value1", value)
    -- end


    local collapsingHeaderFogLayer = parent:AddCollapsingHeader("Fog")
    local collapsingHeaderFogGeneral = collapsingHeaderFogLayer:AddTree("Fog general")



    fogPhase = collapsingHeaderFogGeneral:AddSlider("Phase", 0, 0, 1, 0.01)
    fogPhase.IDContext = "fogPhase"
    fogPhase.SameLine = false
    fogPhase.OnChange = function(value)
        UpdateValue("FogPhase", "value1", value)
    end

    fogRenderDistance = collapsingHeaderFogGeneral:AddSlider("Render distance", 0, 0, 10000, 1)
    fogRenderDistance.IDContext = "fogRenderDistance"
    fogRenderDistance.SameLine = false
    fogRenderDistance.OnChange = function(value)
        UpdateValue("FogRenderDistance", "value1", value)
    end


    local collapsingHeaderFogLayer1 = collapsingHeaderFogLayer:AddTree("Fog layer 1")

    fogLayer1EnabledCheckbox = collapsingHeaderFogLayer1:AddCheckbox("Enabled")
    fogLayer1EnabledCheckbox.IDContext = "fogLayer1EnabledCheckbox"
    fogLayer1EnabledCheckbox.Checked = false
    fogLayer1EnabledCheckbox.SameLine = false
    fogLayer1EnabledCheckbox.OnChange = function()
        UpdateValue("FogLayer1Enabled", "value", fogLayer1EnabledCheckbox.Checked)
    end

    fogLayer1Density0 = collapsingHeaderFogLayer1:AddSlider("Density 0", 0, 0, 1, 0.01)
    fogLayer1Density0.IDContext = "fogLayer1Density0"
    fogLayer1Density0.SameLine = false
    fogLayer1Density0.OnChange = function(value)
        UpdateValue("FogLayer1Density0", "value1", value)
    end

    fogLayer1Density1 = collapsingHeaderFogLayer1:AddSlider("Density 1", 0, 0, 1, 0.01)
    fogLayer1Density1.IDContext = "fogLayer1Density1"
    fogLayer1Density1.SameLine = false
    fogLayer1Density1.OnChange = function(value)
        UpdateValue("FogLayer1Density1", "value1", value)
    end

    fogLayer1Height0 = collapsingHeaderFogLayer1:AddSlider("Height 0", 0, -100, 100, 1)
    fogLayer1Height0.IDContext = "fogLayer1Height0"
    fogLayer1Height0.Logarithmic = true
    fogLayer1Height0.SameLine = false
    fogLayer1Height0.OnChange = function(value)
        UpdateValue("FogLayer1Height0", "value1", value)
    end

    fogLayer1Height1 = collapsingHeaderFogLayer1:AddSlider("Height 1", 0, -100, 100, 1)
    fogLayer1Height1.IDContext = "fogLayer1Height1"
    fogLayer1Height1.Logarithmic = true
    fogLayer1Height1.SameLine = false
    fogLayer1Height1.OnChange = function(value)
        UpdateValue("FogLayer1Height1", "value1", value)
    end

    fogLayer1NoiseCoverage = collapsingHeaderFogLayer1:AddSlider("Noise coverage", 0, 0, 1, 0.01)
    fogLayer1NoiseCoverage.IDContext = "fogLayer1NoiseCoverage"
    fogLayer1NoiseCoverage.SameLine = false
    fogLayer1NoiseCoverage.OnChange = function(value)
        UpdateValue("FogLayer1NoiseCoverage", "value1", value)
    end

    fogLayer1Albedo = collapsingHeaderFogLayer1:AddColorEdit("Albedo color")
    fogLayer1Albedo.IDContext = "fogLayer1Albedo"
    fogLayer1Albedo.Color = { 1.0, 1.0, 1.0, 1.0 }
    fogLayer1Albedo.NoAlpha = true
    fogLayer1Albedo.Float = true
    fogLayer1Albedo.PickerHueWheel = false
    fogLayer1Albedo.InputRGB = true
    fogLayer1Albedo.DisplayHex = true
    fogLayer1Albedo.OnChange = function(value)
        UpdateValue("FogLayer1Albedo", "value4", value)
    end

    local collapsingHeaderFogLayer0 = collapsingHeaderFogLayer:AddTree("Fog layer 0")

    fogLayer0EnabledCheckbox = collapsingHeaderFogLayer0:AddCheckbox("Enabled")
    fogLayer0EnabledCheckbox.IDContext = "fogLayer0EnabledCheckbox"
    fogLayer0EnabledCheckbox.Checked = false
    fogLayer0EnabledCheckbox.SameLine = false
    fogLayer0EnabledCheckbox.OnChange = function()
        UpdateValue("FogLayer0Enabled", "value", fogLayer0EnabledCheckbox.Checked)
    end

    fogLayer0Density0 = collapsingHeaderFogLayer0:AddSlider("Density 0", 0, 0, 1, 0.01)
    fogLayer0Density0.IDContext = "fogLayer0Density0"
    fogLayer0Density0.SameLine = false
    fogLayer0Density0.OnChange = function(value)
        UpdateValue("FogLayer0Density0", "value1", value)
    end

    fogLayer0Density1 = collapsingHeaderFogLayer0:AddSlider("Density 1", 0, 0, 1, 0.01)
    fogLayer0Density1.IDContext = "fogLayer0Density1"
    fogLayer0Density1.SameLine = false
    fogLayer0Density1.OnChange = function(value)
        UpdateValue("FogLayer0Density1", "value1", value)
    end

    fogLayer0Height0 = collapsingHeaderFogLayer0:AddSlider("Height 0", 0, -100, 100, 1)
    fogLayer0Height0.IDContext = "fogLayer0Height0"
    fogLayer0Height0.Logarithmic = true
    fogLayer0Height0.SameLine = false
    fogLayer0Height0.OnChange = function(value)
        UpdateValue("FogLayer0Height0", "value1", value)
    end

    fogLayer0Height1 = collapsingHeaderFogLayer0:AddSlider("Height 1", 0, -100, 100, 1)
    fogLayer0Height1.IDContext = "fogLayer0Height1"
    fogLayer0Height1.Logarithmic = true
    fogLayer0Height1.SameLine = false              
    fogLayer0Height1.OnChange = function(value)
        UpdateValue("FogLayer0Height1", "value1", value)
    end

    fogLayer0NoiseCoverage = collapsingHeaderFogLayer0:AddSlider("Noise coverage", 0, 0, 1, 0.01)
    fogLayer0NoiseCoverage.IDContext = "fogLayer0NoiseCoverage"
    fogLayer0NoiseCoverage.SameLine = false
    fogLayer0NoiseCoverage.OnChange = function(value)
        UpdateValue("FogLayer0NoiseCoverage", "value1", value)
    end

    fogLayer0Albedo = collapsingHeaderFogLayer0:AddColorEdit("Albedo color")
    fogLayer0Albedo.IDContext = "fogLayer0Albedo"
    fogLayer0Albedo.Color = { 1.0, 1.0, 1.0, 1.0 }
    fogLayer0Albedo.NoAlpha = true
    fogLayer0Albedo.Float = true
    fogLayer0Albedo.PickerHueWheel = false
    fogLayer0Albedo.InputRGB = true
    fogLayer0Albedo.DisplayHex = true
    fogLayer0Albedo.OnChange = function(value)
        UpdateValue("FogLayer0Albedo", "value4", value)
    end


    local collapsingHeaderSkyLight = parent:AddCollapsingHeader("Sky light")



    cirrusCloudsEnabledCheckbox = collapsingHeaderSkyLight:AddCheckbox("Cirrus clouds enabled")
    cirrusCloudsEnabledCheckbox.IDContext = "cirrusCloudsEnabled"
    cirrusCloudsEnabledCheckbox.Checked = false
    cirrusCloudsEnabledCheckbox.SameLine = false
    cirrusCloudsEnabledCheckbox.OnChange = function()
        UpdateValue("CirrusCloudsEnabled", "value", cirrusCloudsEnabledCheckbox.Checked)
    end


    cirrusCloudsIntensitySlider = collapsingHeaderSkyLight:AddSlider("Cirrus clouds intensity", 0, 0, 100, 0.01)
    cirrusCloudsIntensitySlider.IDContext = "cirrusCloudsIntensity"
    cirrusCloudsIntensitySlider.SameLine = false
    cirrusCloudsIntensitySlider.OnChange = function(value)
        UpdateValue("CirrusCloudsIntensity", "value1", value)
    end

    cirrusCloudsAmountSlider = collapsingHeaderSkyLight:AddSlider("Cirrus clouds amount", 0, 0, 1, 0.01)
    cirrusCloudsAmountSlider.IDContext = "cirrusCloudsAmount"
    cirrusCloudsAmountSlider.SameLine = false
    cirrusCloudsAmountSlider.OnChange = function(value)
        UpdateValue("CirrusCloudsAmount", "value1", value)
    end

    cirrusCloudsColor = collapsingHeaderSkyLight:AddColorEdit("Cirrus clouds color")
    cirrusCloudsColor.IDContext = "cirrusCloudsColor"
    cirrusCloudsColor.Color = { 1.0, 1.0, 1.0, 1.0 }
    cirrusCloudsColor.NoAlpha = true
    cirrusCloudsColor.Float = true
    cirrusCloudsColor.PickerHueWheel = false
    cirrusCloudsColor.InputRGB = true
    cirrusCloudsColor.DisplayHex = true
    cirrusCloudsColor.OnChange = function(value)
        UpdateValue("CirrusCloudsColor", "value4", value)
    end

    rotateSkydomeEnabledCheckbox = collapsingHeaderSkyLight:AddCheckbox("Rotate skydome")
    rotateSkydomeEnabledCheckbox.IDContext = "rotateSkydomeEnabled"
    rotateSkydomeEnabledCheckbox.Checked = false
    rotateSkydomeEnabledCheckbox.SameLine = false
    rotateSkydomeEnabledCheckbox.OnChange = function()
        UpdateValue("RotateSkydomeEnabled", "value", rotateSkydomeEnabledCheckbox.Checked)
    end

    scatteringEnabledCheckbox = collapsingHeaderSkyLight:AddCheckbox("Scattering enabled")
    scatteringEnabledCheckbox.IDContext = "scatteringEnabled"
    scatteringEnabledCheckbox.Checked = false
    scatteringEnabledCheckbox.SameLine = false
    scatteringEnabledCheckbox.OnChange = function()
        UpdateValue("ScatteringEnabled", "value", scatteringEnabledCheckbox.Checked)
    end

    scatteringIntensitySlider = collapsingHeaderSkyLight:AddSlider("Scattering intensity", 0, 0, 10, 0.01)
    scatteringIntensitySlider.IDContext = "scatteringIntensity"
    scatteringIntensitySlider.SameLine = false
    scatteringIntensitySlider.OnChange = function(value)
        UpdateValue("ScatteringIntensity", "value1", value)
    end

    scatteringSunColor = collapsingHeaderSkyLight:AddColorEdit("Scattering sun color")
    scatteringSunColor.IDContext = "scatteringSunColor"
    scatteringSunColor.Color = { 1.0, 1.0, 1.0, 1.0 }
    scatteringSunColor.NoAlpha = true
    scatteringSunColor.Float = true
    scatteringSunColor.PickerHueWheel = false
    scatteringSunColor.InputRGB = true
    scatteringSunColor.DisplayHex = true
    scatteringSunColor.OnChange = function(value)
        UpdateValue("ScatteringSunColor", "value4", value)
    end

    scatteringSunIntensitySlider = collapsingHeaderSkyLight:AddSlider("Scattering sun intensity", 0, 0, 100, 0.01)
    scatteringSunIntensitySlider.IDContext = "scatteringSunIntensity"
    scatteringSunIntensitySlider.SameLine = false
    scatteringSunIntensitySlider.OnChange = function(value)
        UpdateValue("ScatteringSunIntensity", "value1", value)
    end

    skydomeEnabledCheckbox = collapsingHeaderSkyLight:AddCheckbox("Skydome enabled")
    skydomeEnabledCheckbox.IDContext = "skydomeEnabled"
    skydomeEnabledCheckbox.Checked = false
    skydomeEnabledCheckbox.SameLine = false
    skydomeEnabledCheckbox.OnChange = function()
        UpdateValue("SkydomeEnabled", "value", skydomeEnabledCheckbox.Checked)
    end


    scatteringIntensityScaleSlider = collapsingHeaderSkyLight:AddSlider("Scattering intensity scale", 0, 0, 10, 0.01)
    scatteringIntensityScaleSlider.IDContext = "scatteringIntensityScale"
    scatteringIntensityScaleSlider.SameLine = false
    scatteringIntensityScaleSlider.OnChange = function(value)
        UpdateValue("ScatteringIntensityScale", "value1", value)
    end




    local collapsingHeaderVolumetricCloud = parent:AddCollapsingHeader("Volumetric clouds")



    cloudEnabledCheckbox = collapsingHeaderVolumetricCloud:AddCheckbox("Enabled")
    cloudEnabledCheckbox.IDContext = "cloudEnabled"
    cloudEnabledCheckbox.Checked = false
    cloudEnabledCheckbox.SameLine = false
    cloudEnabledCheckbox.OnChange = function()
        UpdateValue("CloudEnabled", "value", cloudEnabledCheckbox.Checked)
    end

    cloudIntensitySlider = collapsingHeaderVolumetricCloud:AddSlider("Intensity", 0, 0, 100000, 0.01)
    cloudIntensitySlider.IDContext = "cloudIntensity"
    cloudIntensitySlider.SameLine = false
    cloudIntensitySlider.OnChange = function(value)
        UpdateValue("CloudIntensity", "value1", value)
    end

    cloudStartHeightSlider = collapsingHeaderVolumetricCloud:AddSlider("Start height", 0, 0, 10000, 1)
    cloudStartHeightSlider.IDContext = "cloudStartHeight"
    cloudStartHeightSlider.SameLine = false
    cloudStartHeightSlider.OnChange = function(value)
        UpdateValue("CloudStartHeight", "value1", value)
    end

    cloudEndHeightSlider = collapsingHeaderVolumetricCloud:AddSlider("End height", 0, 0, 20000, 1)
    cloudEndHeightSlider.IDContext = "cloudEndHeight"
    cloudEndHeightSlider.SameLine = false
    cloudEndHeightSlider.OnChange = function(value)
        UpdateValue("CloudEndHeight", "value1", value)
    end

    cloudHorizonDistanceSlider = collapsingHeaderVolumetricCloud:AddSlider("Horizon distance", 0, 0, 100000, 1)
    cloudHorizonDistanceSlider.IDContext = "cloudHorizonDistance"
    cloudHorizonDistanceSlider.SameLine = false
    cloudHorizonDistanceSlider.OnChange = function(value)
        UpdateValue("CloudHorizonDistance", "value1", value)
    end


    cloudCoverageStartDistanceSlider = collapsingHeaderVolumetricCloud:AddSlider("Coverage start distance", 0, 0, 100000,
        1)
    cloudCoverageStartDistanceSlider.IDContext = "cloudCoverageStartDistance"
    cloudCoverageStartDistanceSlider.SameLine = false
    cloudCoverageStartDistanceSlider.OnChange = function(value)
        UpdateValue("CloudCoverageStartDistance", "value1", value)
    end

    cloudCoverageWindSpeedSlider = collapsingHeaderVolumetricCloud:AddSlider("Coverage wind speed", 0, 0, 100, 0.01)
    cloudCoverageWindSpeedSlider.IDContext = "cloudCoverageWindSpeed"
    cloudCoverageWindSpeedSlider.SameLine = false
    cloudCoverageWindSpeedSlider.OnChange = function(value)
        UpdateValue("CloudCoverageWindSpeed", "value1", value)
    end

    cloudDetailScaleSlider = collapsingHeaderVolumetricCloud:AddSlider("Detail scale", 0, 0, 10, 0.01)
    cloudDetailScaleSlider.IDContext = "cloudDetailScale"
    cloudDetailScaleSlider.SameLine = false
    cloudDetailScaleSlider.OnChange = function(value)
        UpdateValue("CloudDetailScale", "value1", value)
    end


    cloudShadowFactorSlider = collapsingHeaderVolumetricCloud:AddSlider("Shadow factor", 0, 0, 1, 0.01)
    cloudShadowFactorSlider.IDContext = "cloudShadowFactor"
    cloudShadowFactorSlider.SameLine = false
    cloudShadowFactorSlider.OnChange = function(value)
        UpdateValue("CloudShadowFactor", "value1", value)
    end

    cloudSunLightFactorSlider = collapsingHeaderVolumetricCloud:AddSlider("Sun light factor", 0, 0, 10, 0.01)
    cloudSunLightFactorSlider.IDContext = "cloudSunLightFactor"
    cloudSunLightFactorSlider.SameLine = false
    cloudSunLightFactorSlider.OnChange = function(value)
        UpdateValue("CloudSunLightFactor", "value1", value)
    end

    cloudAmbientLightFactorSlider = collapsingHeaderVolumetricCloud:AddSlider("Ambient light factor", 0, 0, 10, 0.01)
    cloudAmbientLightFactorSlider.IDContext = "cloudAmbientLightFactor"
    cloudAmbientLightFactorSlider.SameLine = false
    cloudAmbientLightFactorSlider.OnChange = function(value)
        UpdateValue("CloudAmbientLightFactor", "value1", value)
    end


    cloudSunRayLengthSlider = collapsingHeaderVolumetricCloud:AddSlider("Sun ray length", 0, 0, 1, 0.01)
    cloudSunRayLengthSlider.IDContext = "cloudSunRayLength"
    cloudSunRayLengthSlider.SameLine = false
    cloudSunRayLengthSlider.OnChange = function(value)
        UpdateValue("CloudSunRayLength", "value1", value)
    end

    cloudBaseColor = collapsingHeaderVolumetricCloud:AddColorEdit("Base color")
    cloudBaseColor.IDContext = "cloudBaseColor"
    cloudBaseColor.Color = { 1.0, 1.0, 1.0, 1.0 }
    cloudBaseColor.NoAlpha = true
    cloudBaseColor.Float = true
    cloudBaseColor.PickerHueWheel = false
    cloudBaseColor.InputRGB = true
    cloudBaseColor.DisplayHex = true
    cloudBaseColor.OnChange = function(value)
        UpdateValue("CloudBaseColor", "value4", value)
    end

    cloudTopColor = collapsingHeaderVolumetricCloud:AddColorEdit("Top color")
    cloudTopColor.IDContext = "cloudTopColor"
    cloudTopColor.Color = { 1.0, 1.0, 1.0, 1.0 }
    cloudTopColor.NoAlpha = true
    cloudTopColor.Float = true
    cloudTopColor.PickerHueWheel = false
    cloudTopColor.InputRGB = true
    cloudTopColor.DisplayHex = true
    cloudTopColor.OnChange = function(value)
        UpdateValue("CloudTopColor", "value4", value)
    end

    --#endregion






    -- local applyParamBtn = parent:AddButton('Apply')

    -- local resetParamBtn = parent:AddButton('Reset')
    -- resetParamBtn.SameLine = true

    

    

end


function DevTab(parent)


    
    parent:AddSeparatorText('AnL')
    local getTriggersBtn = parent:AddButton('Update triggers')
    getTriggersBtn.OnClick = function ()
        Ext.Net.PostMessageToServer('LL_GetLTNTriggers', '')
        Ext.Net.PostMessageToServer('LL_GetATMTriggers', '')
    end



end


Mods.BG3MCM.IMGUIAPI:InsertModMenuTab(ModuleUUID, "Lighty Lights", MainTab2)

--[[
PREC DIS POWE
ADD RECENT COLORS
]]



LLGlobals.CreatedLightsClient = {} --UNUSED


LLGlobals.LightsUuidNameMap = {}
LLGlobals.LightsNames = {}
LLGlobals.LightParametersClient = {}


LLGlobals.States = LLGlobals.States or {}
LLGlobals.States.allowLightCreation = {}


---@class Settings
Settings = Settings or {}

---@type string EntityUuid
LLGlobals.selectedUuid = nil

---@type EntityHandle
LLGlobals.selectedEntity = nil

---@type LightComponent
LLGlobals.selectedLightEntity = nil


DEFAULT_MARKER_SCALE = 0.699999988079071

nameIndex = 0

LLGlobals.syncedSelectedIndex = 0

---@class Elements
E = {
    slIntLightType,
    pickerLightColor,
    slLightIntensity,
    slLightTemp,
    slLightRadius,
    slLightOuterAngle,
    slLightInnerAngle,
    checkLightFill,
    checkLightChannel,
    slLightScattering,
    slLightEdgeSharp,
}

---@class ElementsForResize
ER = {
    btnLightIntensityReset,
    btnLightTempReset,
    btnLightRadiusReset,
    btnLightOuterReset,
    btnLightInnerReset,
    btnLightScatterReset,
    btnLightSharpReset,
}



local OPENQUESTIONMARK = false
IMGUI:AntiStupiditySystem()






function LLMCM(mt2)
    -- if LLMCM ~= nil then return end
    LLMCM = mt2

    local rngMax = #ModName
    mw = Ext.IMGUI.NewWindow(ModName[Ext.Math.Random(1, rngMax)])
    mw.Font = 'Font'
    mw.Open = OPENQUESTIONMARK

    mw.Closeable = true


    openButton = mt2:AddButton('Open')
    openButton.IDContext = 'OpenMainWindowButton'
    openButton.OnClick = function()
        mw.Open = not mw.Open
    end

    mw.OnClose = function()
        mw.Open = false
        return true
    end

    local styleCombo = mt2:AddCombo('Style')
    styleCombo.IDContext = 'StyleSwitchCombo'
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


    E.utilsTab = mainTabBar:AddTabItem('Useful')
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


--#region FunnyStuff
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
--#endregion

    buttonSizes()

    StyleV2:RegisterWindow(mw)

    SettingsLoad()
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




function MainTab(p)

    --local btn = p:AddButton('xddd')


    local rngMax = #QOTD
    p:AddSeparatorText(QOTD[Ext.Math.Random(1, rngMax)])
    --

    E.checkTypePoint = p:AddCheckbox('Point')
    E.checkTypePoint.Checked = defaultLightType == 'Point'
    E.checkTypePoint.OnChange = function ()

        lightType = 'Point' -- 0

        E.checkTypeSpot.Checked = false
        E.checkTypeDir.Checked = false

    end


    E.checkTypeSpot = p:AddCheckbox('Spotlight')
    E.checkTypeSpot.Checked = defaultLightType == 'Spotlight'
    E.checkTypeSpot.SameLine = true
    E.checkTypeSpot.OnChange = function ()

        lightType = 'Spotlight' -- 1

        E.checkTypePoint.Checked = false
        E.checkTypeDir.Checked = false

    end


    E.checkTypeDir = p:AddCheckbox('Directional')
    E.checkTypeDir.Checked = defaultLightType == 'Directional'
    E.checkTypeDir.SameLine = true
    E.checkTypeDir.OnChange = function ()

        lightType = 'Directional' -- 2

        E.checkTypePoint.Checked = false
        E.checkTypeSpot.Checked = false

    end



    E.btnCreate2 = p:AddButton('Create')
    E.btnCreate2.SameLine = true
    E.btnCreate2.OnClick = function ()
        CreateLight()
    end



    E.comboIHateCombos = p:AddCombo('')
    E.comboIHateCombos.Options = LLGlobals.LightsNames
    E.comboIHateCombos.SelectedIndex = LLGlobals.syncedSelectedIndex
    E.comboIHateCombos.OnChange = function (e)
        LLGlobals.syncedSelectedIndex = E.comboIHateCombos.SelectedIndex
        E.comboIHateCombos2.SelectedIndex = LLGlobals.syncedSelectedIndex
        SelectLight()
    end



    --- for keybind
    function prevOptionBtn()
        local element = E.comboIHateCombos
        if element.SelectedIndex < 1 then
            element.SelectedIndex = #element.Options - 1
        else
            element.SelectedIndex = element.SelectedIndex - 1
        end
        LLGlobals.syncedSelectedIndex = element.SelectedIndex
        E.comboIHateCombos2.SelectedIndex = LLGlobals.syncedSelectedIndex
        SelectLight()
    end



    E.btnOptionsPrev = p:AddButton('<')
    E.btnOptionsPrev.IDContext = 'adawd'
    E.btnOptionsPrev.SameLine = true
    E.btnOptionsPrev.OnClick = function (e)
        if not LLGlobals.selectedUuid then return end
        prevOptionBtn()
    end



    --- for keybind
    function nextOptionBtn()
        local element = E.comboIHateCombos
        if element.SelectedIndex > #element.Options - 2 then
            element.SelectedIndex = 0
        else
            element.SelectedIndex = element.SelectedIndex + 1
        end
        LLGlobals.syncedSelectedIndex = element.SelectedIndex
        E.comboIHateCombos2.SelectedIndex = LLGlobals.syncedSelectedIndex
        SelectLight()
    end



    E.btnOptionsNext = p:AddButton('>')
    E.btnOptionsNext.IDContext = 'adadwwd'
    E.btnOptionsNext.SameLine = true
    E.btnOptionsNext.OnClick = function (e)
        if not LLGlobals.selectedUuid then return end
        nextOptionBtn()
    end



    txtCreateLight = p:AddText('Created lights')
    txtCreateLight.SameLine = true



    E.inputRename = p:AddInputText('')
    E.inputRename.IDContext = 'adawdawdawdawd'
    E.inputRename.Disabled = false



    E.btnRenameLight = p:AddButton('Rename')
    E.btnRenameLight.SameLine = true
    E.btnRenameLight.Disabled = false
    E.btnRenameLight.OnClick = function ()
        if not LLGlobals.selectedUuid then return end
        local lightEntity = getSelectedLightEntity()


        for k, light in pairs(LLGlobals.LightsUuidNameMap) do
            if light.name == E.comboIHateCombos.Options[E.comboIHateCombos.SelectedIndex + 1] then
                local index = light.nameIndex
                --- TBD: temporary
                local type = getSelectedLightType()
                if lightEntity.LightChannelFlag == 255 then
                    light.name = '+' .. ' ' ..  '#' .. index .. ' ' .. type .. ' ' .. E.inputRename.Text
                else
                    lightEntity.LightChannelFlag = 0
                    light.name = '-' .. ' ' ..  '#' .. index .. ' ' .. type .. ' ' .. E.inputRename.Text
                end

            end
        end

        E.inputRename.Text = ''

        UpdateCreatedLightsCombo()

    end





ER.btnDelete = p:AddButton('Delete')
ER.btnDelete.OnClick = function()

    if not LLGlobals.selectedUuid then return end

    local uuidToDelete = LLGlobals.selectedUuid
    local selectedName = getSelectedLightName()

    Channels.DeleteGobo:SendToServer('Single')

    LLGlobals.CreatedLightsServer[uuidToDelete] = nil
    LLGlobals.LightParametersClient[uuidToDelete] = nil

    for k, light in pairs(LLGlobals.LightsUuidNameMap) do
        if light.name == selectedName then
           table.remove(LLGlobals.LightsUuidNameMap, k)
        end
    end

    for k, light in pairs(LLGlobals.LightsNames) do
        if light == selectedName then
            LLGlobals.LightsNames[k] = nil
        end
    end

    UpdateCreatedLightsCombo()

    E.comboIHateCombos.SelectedIndex = E.comboIHateCombos.SelectedIndex - 1
    if E.comboIHateCombos.SelectedIndex < 0 then
        E.comboIHateCombos.SelectedIndex = 0
    end

    if E.comboIHateCombos.Options and #E.comboIHateCombos.Options > 0 then
        local uuid = getSelectedUuid()
        if uuid then
            SelectLight()
        else
            LLGlobals.selectedUuid = nil
            LLGlobals.selectedEntity = nil
            LLGlobals.markerUuid = nil
            LLGlobals.markerEntity = nil
        end
    else
        LLGlobals.selectedUuid = nil
        LLGlobals.selectedEntity = nil
        LLGlobals.markerUuid = nil
        LLGlobals.markerEntity = nil
        nameIndex = 0
        UpdateTranformInfo(0, 0, 0, 0, 0, 0)
    end


    Channels.DeleteLight:SendToServer(uuidToDelete)

    Channels.SelectedLight:SendToServer(LLGlobals.selectedUuid)

end





    ER.btnDeleteAll = p:AddButton('Delete all')
    ER.btnDeleteAll.SameLine = true
    ER.btnDeleteAll.OnClick = function ()

        ER.btnDeleteAll.Visible = false
        ER.btnConfirmDeleteAll.Visible = true

        confirmTimer = Ext.Timer.WaitFor(1000, function()
            ER.btnConfirmDeleteAll.Visible = false
            ER.btnDeleteAll.Visible = true
        end)
    end


    ER.btnConfirmDeleteAll = p:AddButton('Confirm')
    ER.btnConfirmDeleteAll.Visible = false
    ER.btnConfirmDeleteAll.SameLine = true
    Style.buttonConfirm.default(ER.btnConfirmDeleteAll)
    ER.btnConfirmDeleteAll.OnClick = function ()

        E.checkStick.Checked = false

        Channels.DeleteGobo:SendToServer('All')

        Channels.DeleteLight:SendToServer('All')

        LLGlobals.CreatedLightsServer = {}
        LLGlobals.LightsUuidNameMap = {}
        LLGlobals.LightsNames = {}
        LLGlobals.LightParametersClient = {}
        LLGlobals.selectedUuid = nil
        LLGlobals.selectedEntity = nil
        LLGlobals.markerUuid = {}
        LLGlobals.markerEntity = nil
        nameIndex = 0

        Channels.CurrentEntityTransform:SendToServer(nil)

        UpdateCreatedLightsCombo()
        UpdateTranformInfo(0, 0, 0, 0, 0, 0)
        textFunc.Label = 'Attenuation'

        GatherLightsAndMarkers()

        Ext.Timer.Cancel(confirmTimer)

        ER.btnDeleteAll.Visible = true
        ER.btnConfirmDeleteAll.Visible = false

    end



    ER.btnDuplicate = p:AddButton('Duplicate')
    ER.btnDuplicate.SameLine = true
    ER.btnDuplicate.Disabled = false
    ER.btnDuplicate.OnClick = function ()
        if not LLGlobals.selectedUuid then return end
        DuplicateLight()
    end


    E.checkSelectedLightNotification = p:AddCheckbox('Selected light popup')
    E.checkSelectedLightNotification.SameLine = true
    E.checkSelectedLightNotification.OnChange = function (e)
        windowNotification.Visible = E.checkSelectedLightNotification.Checked
    end







    --- for keybind
    function toggleLightBtn()
        local lightEntity = getSelectedLightEntity()
        local selectedUuid = getSelectedUuid()

        if lightEntity then



            local flag = lightEntity.LightChannelFlag ~= 0
            local flag2 = not flag

            local scattering = lightEntity.ScatteringIntensityScale ~= 0
            local scattering2 = not scattering


            if flag2 then
                local savedFlag = LLGlobals.LightParametersClient[selectedUuid].LightChannelFlag
                lightEntity.LightChannelFlag = (savedFlag ~= nil) and savedFlag or 255
            else
                lightEntity.LightChannelFlag = 0
            end

            if scattering2 and LLGlobals.LightParametersClient[selectedUuid].ScatteringIntensityScale then
                local value = LLGlobals.LightParametersClient[selectedUuid].ScatteringIntensityScale
                lightEntity.ScatteringIntensityScale = value
            else
                lightEntity.ScatteringIntensityScale = 0
            end

            UpdateVisibilityStateToNames(getSelectedLightName(), flag2)

        end
    end



    E.toggleLightButton = p:AddButton('Toggle light')
    E.toggleLightButton.IDContext = 'awdaw'
    E.toggleLightButton.OnClick = function()
        if not LLGlobals.selectedUuid then return end
        toggleLightBtn()
    end



    function toggleAllLightsBtn()
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then

            all = not all

            for _, uuid in pairs(LLGlobals.CreatedLightsServer) do
                local lightEntity = getLightEntity(uuid)

                if all then
                    lightEntity.LightChannelFlag = 0
                    lightEntity.ScatteringIntensityScale = 0
                else
                    local savedFlag = LLGlobals.LightParametersClient[uuid].LightChannelFlag
                    lightEntity.LightChannelFlag = (savedFlag ~= nil) and savedFlag or 255

                    if LLGlobals.LightParametersClient[uuid].ScatteringIntensityScale then
                        local value = LLGlobals.LightParametersClient[uuid].ScatteringIntensityScale
                        lightEntity.ScatteringIntensityScale = value
                    end
                end

                for _, name in pairs(LLGlobals.LightsNames) do
                    UpdateVisibilityStateToNames(name, not all)
                end

            end
        end
    end



    local all = false
    E.toggleLightsButton = p:AddButton('Toggle all')
    E.toggleLightsButton.IDContext = 'awdfdgdfg'
    E.toggleLightsButton.SameLine = true
    E.toggleLightsButton.OnClick = function()
        if not LLGlobals.selectedUuid then return end

        toggleAllLightsBtn()
    end



    E.toggleMarkerButton = p:AddButton('Toggle marker')
    E.toggleMarkerButton.SameLine = true
    E.toggleMarkerButton.IDContext = 'jhjkgyyutr'
    E.toggleMarkerButton.OnClick = function()

        ToggleMarker(LLGlobals.markerUuid)

    end



    E.toggleAllMarkersButton = p:AddButton('Toggle all')
    E.toggleAllMarkersButton.SameLine = true
    E.toggleAllMarkersButton.IDContext = '456456'
    E.toggleAllMarkersButton.SameLine = true
    E.toggleAllMarkersButton.OnClick = function()

        Channels.MarkerHandler:RequestToServer({}, function (Response)
        end)

    end



    E.btnMazzleBeam = p:AddButton('Mazzle beam')
    E.btnMazzleBeam.SameLine = true
    E.btnMazzleBeam.OnClick = function ()
        if not LLGlobals.selectedUuid then return end

        Channels.MazzleBeam:SendToServer({})
    end



    ---------------------------------------------------------
    p:AddSeparatorText('Parameters')
    ---------------------------------------------------------



    E.collapseParameters = p:AddCollapsingHeader('Main parameters')
    E.collapseParameters.DefaultOpen = true
    -- E.collapseParameters = E.collapseParameters:AddGroup('Parameters1')



    E.treeGen = E.collapseParameters:AddTree('General')
    E.treeGen.DefaultOpen = openByDefaultMainGen



    -- TYPE



    E.slIntLightType = E.treeGen:AddSliderInt('', 0,0,2,1)
    E.slIntLightType.IDContext = 'aojwdnakwol;n'
    E.slIntLightType.OnChange = function (e)
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then
            SetLightType(e.Value[1])


            -- TBD: temporary
            local selectedName = getSelectedLightName()
            if selectedName and (selectedName:find('Point') or selectedName:find('Spotlight') or selectedName:find('Directional')) then
                if e.Value[1] == 0 then localLightType = 'Point' end
                if e.Value[1] == 1 then localLightType = 'Spotlight' end
                if e.Value[1] == 2 then localLightType = 'Directional'
                    E.slRotRollSlider.Disabled = false
                    E.btnRot_Rp.Disabled = false
                    E.btnRot_Rm.Disabled = false
                else
                    E.slRotRollSlider.Disabled = true
                    E.btnRot_Rp.Disabled = true
                    E.btnRot_Rm.Disabled = true
                end

                local lightEntity = getSelectedLightEntity()

                if not lightEntity then return end

                if lightEntity.LightChannelFlag == 255 then
                    local newName = LLGlobals.LightsUuidNameMap[E.comboIHateCombos.SelectedIndex + 1].name
                    newName = newName:gsub('Point', localLightType):gsub('Spotlight', localLightType):gsub('Directional', localLightType)
                    LLGlobals.LightsUuidNameMap[E.comboIHateCombos.SelectedIndex + 1].name = newName
                else
                    lightEntity.LightChannelFlag = 0
                    local newName = LLGlobals.LightsUuidNameMap[E.comboIHateCombos.SelectedIndex + 1].name
                    newName = newName:gsub('Point', localLightType):gsub('Spotlight', localLightType):gsub('Directional', localLightType)
                    LLGlobals.LightsUuidNameMap[E.comboIHateCombos.SelectedIndex + 1].name = newName
                end

                UpdateCreatedLightsCombo()

            end
        end
    end



    textLightType = E.treeGen:AddText('Type')
    textLightType.SameLine = true



    -- COLOR



    if biggerPicker then
        E.pickerLightColor = E.treeGen:AddColorPicker('')
        textPicker = E.treeGen:AddText('xd')
        textPicker.SameLine = true
    else
        E.pickerLightColor = E.treeGen:AddColorEdit('')
        textPicker = E.treeGen:AddText('Color (click me)')
        textPicker.SameLine = true
    end




    E.pickerLightColor.IDContext = 'aowidnawoidn'
    E.pickerLightColor.NoAlpha = true
    E.pickerLightColor.Float = false
    E.pickerLightColor.InputRGB = true
    E.pickerLightColor.DisplayHex = true
    E.pickerLightColor.OnChange = function (e)
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then
            SetLightColor({e.Color[1], e.Color[2], e.Color[3]})
        end
    end


    -- INTENSITY



    E.slLightIntensity = E.treeGen:AddSlider('', 1, 0, 60, 1)
    E.slLightIntensity.IDContext = 'lkjanerfliuaern'
    E.slLightIntensity.Logarithmic = true
    E.slLightIntensity.OnChange = function (e)
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then
            SetLightIntensity(e.Value[1])
        end
    end



    ER.btnLightIntensityReset = E.treeGen:AddButton('Power')
    ER.btnLightIntensityReset.SameLine = true
    ER.btnLightIntensityReset.OnClick = function ()
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then
            E.slLightIntensity.Value = {1, 0, 0, 0}
            SetLightIntensity(E.slLightIntensity.Value[1])
        end
    end



    -- TEMPERATURE



    E.slLightTemp = E.treeGen:AddSlider('', 5600, 1000, 40000, 1)
    E.slLightTemp.IDContext = 'wlekjfnlkm'
    E.slLightTemp.Logarithmic = true
    E.slLightTemp.OnChange = function (e)
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then
            local Color = Math:KelvinToRGB(e.Value[1])
            SetLightColor({Color[1], Color[2], Color[3]})
            E.pickerLightColor.Color = {Color[1], Color[2], Color[3], 0}
            LLGlobals.LightParametersClient[LLGlobals.selectedUuid].Temperature = e.Value[1] --This is just for the slidere
        end
    end



    ER.btnLightTempReset = E.treeGen:AddButton('Temperature')
    ER.btnLightTempReset.SameLine = true
    ER.btnLightTempReset.OnClick = function ()
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then
            E.slLightTemp.Value = {5600, 0, 0, 0}
            LLGlobals.LightParametersClient[LLGlobals.selectedUuid].Temperature = 5600
            SetLightColor({1,0.93,0.88})
        end
    end



    -- RADIUS



    E.slLightRadius = E.treeGen:AddSlider('', 1, 0, 60, 1)
    E.slLightRadius.IDContext = 'adwadqw3d'
    E.slLightRadius.Logarithmic = true
    E.slLightRadius.OnChange = function (e)
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then
            SetLightRadius(e.Value[1])
        end
    end



    ER.btnLightRadiusReset = E.treeGen:AddButton('Distance')
    ER.btnLightRadiusReset.SameLine = true
    ER.btnLightRadiusReset.OnClick = function ()
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then
            E.slLightRadius.Value = {1, 0, 0, 0}
            SetLightRadius(E.slLightRadius.Value[1])
        end
    end



    E.checkLightChannel = E.treeGen:AddSliderInt('', 1, 1, 3, 1)
    E.checkLightChannel.IDContext = 'dojandoajwind'
    E.checkLightChannel.OnChange = function (e)
        SetLightChannel(e.Value[1])
    end



    textChannel = E.treeGen:AddText('Light channel')
    textChannel.SameLine = true



    E.slLightScattering = E.treeGen:AddSlider('', 0, 0, 100, 1)
    E.slLightScattering.IDContext = 'esrgsrengsrg'
    E.slLightScattering.Logarithmic = true
    E.slLightScattering.OnChange = function (e)
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then
            SetLightScattering(e.Value[1])
        end
    end



    ER.btnLightScatterReset = E.treeGen:AddButton('Scattering')
    ER.btnLightScatterReset.SameLine = true
    ER.btnLightScatterReset.OnClick = function ()
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then
            E.slLightScattering.Value = {0, 0, 0, 0}
            SetLightScattering(E.slLightScattering.Value[1])
        end
    end



    E.checkLightFill = E.treeGen:AddCheckbox('Scattering fill-light')
    E.checkLightFill.Checked = true
    E.checkLightFill.OnChange = function ()
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then
            SetLightFill(E.checkLightFill.Checked and 184 or 56)
        end
    end



    E.treeGen:AddSeparator('')



    E.treePoint = E.collapseParameters:AddTree('Point')
    E.treePoint.IDContext = 'soawdawddkfn'
    E.treePoint.DefaultOpen = openByDefaultMainPoint



    function SetLightEdgeSharp(value)
        local lightEntity = getSelectedLightEntity()
        if lightEntity and value then
            lightEntity.EdgeSharpening = value
            LLGlobals.LightParametersClient[LLGlobals.selectedUuid].EdgeSharpening = value
        end
    end



    E.slLightEdgeSharp = E.treePoint:AddSlider('', 0, 0, 1, 1)
    E.slLightEdgeSharp.IDContext = 'sdfwerw34'
    E.slLightEdgeSharp.Logarithmic = false
    E.slLightEdgeSharp.OnChange = function (e)
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then
            SetLightEdgeSharp(e.Value[1])
        end
    end



    ER.btnLightSharpReset = E.treePoint:AddButton('Sharpening')
    ER.btnLightSharpReset.SameLine = true
    ER.btnLightSharpReset.OnClick = function ()
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then
            E.slLightEdgeSharp.Value = {0, 0, 0, 0}
            SetLightEdgeSharp(E.slLightEdgeSharp.Value[1])
        end
    end



    -- OUTER ANGLE



    E.treeSpot = E.collapseParameters:AddTree('Spotlight')
    E.treeSpot.IDContext = 'sodkfn'
    E.treeSpot.DefaultOpen = openByDefaultMainSpot



    E.slLightOuterAngle = E.treeSpot:AddSlider('', 45, 0, 179, 1)
    E.slLightOuterAngle.IDContext = '123dwfsefa'
    E.slLightOuterAngle.OnChange = function (e)
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then
            SetLightOuterAngle(e.Value[1])
        end

    end



    ER.btnLightOuterReset = E.treeSpot:AddButton('Outer angle')
    ER.btnLightOuterReset.SameLine = true
    ER.btnLightOuterReset.OnClick = function ()
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then
            E.slLightOuterAngle.Value = {45, 0, 0, 0}
            SetLightOuterAngle(E.slLightOuterAngle.Value[1])
        end
    end



    -- INNER ANGLE



    E.slLightInnerAngle = E.treeSpot:AddSlider('', 1, 0, 179, 1)
    E.slLightInnerAngle.IDContext = 'rfgrtynj5r6'
    E.slLightInnerAngle.OnChange = function (e)
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then
            SetLightInnerAngle(e.Value[1])
        end
    end



    ER.btnLightInnerReset = E.treeSpot:AddButton('Inner angle')
    ER.btnLightInnerReset.SameLine = true
    ER.btnLightInnerReset.OnClick = function ()
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then
            E.slLightInnerAngle.Value = {1, 0, 0, 0}
            SetLightInnerAngle(E.slLightInnerAngle.Value[1])
        end
    end



    E.treeSpot:AddSeparator('')



    local sepaTreeDir
    local spepaPreAdd
    E.treeDir = E.collapseParameters:AddTree('Directional')
    E.treeDir.IDContext = 'sodsdfkfn'
    E.treeDir.DefaultOpen = openByDefaultMainDir



    E.slLightDirEnd = E.treeDir:AddSlider('Falloff front', 0, 0, 20, 1)
    E.slLightDirEnd.IDContext = 'olkjsdeafoiuzsrenbf'
    E.slLightDirEnd.OnChange = function (e)
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then
            SetLightDirectionalParameters('DirectionLightAttenuationEnd', e.Value[1])
        end
    end



    E.slLightDirSide = E.treeDir:AddSlider('Falloff back', 0, 0, 20, 1)
    E.slLightDirSide.IDContext = 'o12312'
    E.slLightDirSide.OnChange = function (e)
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then
            SetLightDirectionalParameters('DirectionLightAttenuationSide', e.Value[1])
        end
    end



    E.slLightDirSide2 = E.treeDir:AddSlider('Falloff sides', 0, 0, 10, 1)
    E.slLightDirSide2.IDContext = 'asdaw'
    E.slLightDirSide2.OnChange = function (e)
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then
            SetLightDirectionalParameters('DirectionLightAttenuationSide2', e.Value[1])
        end
    end



    E.slIntLightDirFunc = E.treeDir:AddSliderInt('', 0, 0, 3, 1)
    E.slIntLightDirFunc.IDContext = 'olkjsdsseafoiuzsrenbf'
    E.slIntLightDirFunc.OnChange = function (e)
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then
            SetLightDirectionalParameters('DirectionLightAttenuationFunction', e.Value[1])
        end
    end



    textFunc = E.treeDir:AddText('Attenuation')
    textFunc.SameLine = true



    E.slLightDirDim = E.treeDir:AddSlider('Wid/Hei/Len', 0, 0, 100, 1)
    E.slLightDirDim.IDContext = 'lkasenfaolkejfn'
    E.slLightDirDim.Components = 3
    E.slLightDirDim.Logarithmic = true
    E.slLightDirDim.OnChange = function (e)
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then
            SetLightDirectionalParameters('DirectionLightDimensions', {e.Value[1], e.Value[2],e.Value[3]})
        end
    end



    ---------------------------------------------------------
    p:AddSeparatorText('Positioning')
    ---------------------------------------------------------



    ER.btnSavePos = p:AddButton('Save')
    ER.btnSavePos.OnClick = function (e)

        if not LLGlobals.selectedUuid then return end

        Channels.SaveLoadLightPos:SendToServer('Save')
    end



    ER.btnLoadPos = p:AddButton('Load')
    ER.btnLoadPos.SameLine = true
    ER.btnLoadPos.OnClick = function (e)

        if not LLGlobals.selectedUuid then return end

        Channels.SaveLoadLightPos:SendToServer('Load')
    end



    local modPosDefault = 8000
    local modPos = 50000
    local modRot = 5000
    local modRotDefault = 1000



    ER.posReset = p:AddButton('Reset position')
    ER.posReset.IDContext = 'resetPos'
    ER.posReset.SameLine = true
    ER.posReset.OnClick = function ()
        MoveEntity(LLGlobals.selectedEntity, nil, 0, 0, 'World', 'Light')
    end



    ER.rotReset = p:AddButton('Reset rotation')
    ER.rotReset.IDContext = 'resetRos'
    ER.rotReset.SameLine = true
    ER.rotReset.OnClick = function ()
        RotateEntity(LLGlobals.selectedEntity, nil, 0, 0, 'Light')
    end



    E.checkStick = p:AddCheckbox('Stick to camera')
    E.checkStick.OnChange = function (e)
        if not LLGlobals.selectedUuid then e.Checked = false return end
        stickToCameraCheck()
    end



    E.worldTree = p:AddCollapsingHeader('World relative')
    E.worldTree.DefaultOpen = openByDefaultMainWorld



    E.slPosZSlider = E.worldTree:AddSlider('', 0, -1000, 1000, 0.1)
    E.slPosZSlider.IDContext = 'NS'
    E.slPosZSlider.Value = {0,0,0,0}
    E.slPosZSlider.OnChange = function()
        MoveEntity(LLGlobals.selectedEntity, 'z', E.slPosZSlider.Value[1], E.modPosSlider.Value[1], 'World', 'Light')
        E.slPosZSlider.Value = {0,0,0,0}
    end



    E.btnPosZ_S = E.worldTree:AddButton('<')
    E.btnPosZ_S.IDContext = ' safj;woeifmn'
    E.btnPosZ_S.SameLine = true
    E.btnPosZ_S.OnClick = function (e)
        MoveEntity(LLGlobals.selectedEntity, 'z', -100, E.modPosSlider.Value[1], 'World', 'Light')
    end



    E.btnPosZ_N = E.worldTree:AddButton('>')
    E.btnPosZ_N.IDContext = ' safj;awdawdwoeifmn'
    E.btnPosZ_N.SameLine = true
    E.btnPosZ_N.OnClick = function (e)
        MoveEntity(LLGlobals.selectedEntity, 'z', 100, E.modPosSlider.Value[1], 'World', 'Light')
    end



    textZ = E.worldTree:AddText('South/North')
    textZ.IDContext = 'awdadwdawdawdawda'
    textZ.SameLine = true



    E.slPosYSlider = E.worldTree:AddSlider('', 0, -1000, 1000, 0.1)
    E.slPosYSlider.IDContext = 'DU'
    E.slPosYSlider.Value = {0,0,0,0}
    E.slPosYSlider.OnChange = function()
        MoveEntity(LLGlobals.selectedEntity, 'y', E.slPosYSlider.Value[1], E.modPosSlider.Value[1], 'World', 'Light')
        E.slPosYSlider.Value = {0,0,0,0}
    end



    E.btnPosY_D = E.worldTree:AddButton('<')
    E.btnPosY_D.IDContext = ' safj;awffdawoeifmn'
    E.btnPosY_D.SameLine = true
    E.btnPosY_D.OnClick = function (e)
        MoveEntity(LLGlobals.selectedEntity, 'y', -100, E.modPosSlider.Value[1], 'World', 'Light')
    end



    E.btnPosY_U = E.worldTree:AddButton('>')
    E.btnPosY_U.IDContext = ' safj;awdffaawdawwdwoeifmn'
    E.btnPosY_U.SameLine = true
    E.btnPosY_U.OnClick = function (e)
        MoveEntity(LLGlobals.selectedEntity, 'y', 100, E.modPosSlider.Value[1], 'World', 'Light')
    end



    textY = E.worldTree:AddText('Down/Up')
    textY.IDContext = 'awdadwdawdawdawda'
    textY.SameLine = true



    E.slPosXSlider = E.worldTree:AddSlider('', 0, -1000, 1000, 0)
    E.slPosXSlider.IDContext = 'WE'
    E.slPosXSlider.Value = {0,0,0,0}
    E.slPosXSlider.OnChange = function()
        MoveEntity(LLGlobals.selectedEntity, 'x', E.slPosXSlider.Value[1], E.modPosSlider.Value[1], 'World', 'Light')
        E.slPosXSlider.Value = {0,0,0,0}
    end



    E.btnPosX_W = E.worldTree:AddButton('<')
    E.btnPosX_W.IDContext = ' safj;awdawoeifmn'
    E.btnPosX_W.SameLine = true
    E.btnPosX_W.OnClick = function (e)
        MoveEntity(LLGlobals.selectedEntity, 'x', -100, E.modPosSlider.Value[1], 'World', 'Light')
    end



    E.btnPosX_E = E.worldTree:AddButton('>')
    E.btnPosX_E.IDContext = ' safj;awdaawdawwdwoeifmn'
    E.btnPosX_E.SameLine = true
    E.btnPosX_E.OnClick = function (e)
        MoveEntity(LLGlobals.selectedEntity, 'x', 100, E.modPosSlider.Value[1], 'World', 'Light')
    end



    textX = E.worldTree:AddText('West/East')
    textX.IDContext = 'awdawdawda'
    textX.SameLine = true



    E.worldTree:AddSeparator('')



    E.orbitTree = p:AddCollapsingHeader('Character relative')
    E.orbitTree.DefaultOpen = openByDefaultMainChar



    E.slPosOrbX = E.orbitTree:AddSlider('', 0, -1000, 1000, 0.1)
    E.slPosOrbX.IDContext = 'NawdawwwdS'
    E.slPosOrbX.Value = {0,0,0,0}
    E.slPosOrbX.OnChange = function()
        MoveEntity(LLGlobals.selectedEntity, 'x', E.slPosOrbX.Value[1], E.modPosSlider.Value[1], 'Orbit', 'Light')
        E.slPosOrbX.Value = {0,0,0,0}
    end



    E.btnPosX_CW = E.orbitTree:AddButton('<')
    E.btnPosX_CW.IDContext = ' safj;awffdahwoeifmn'
    E.btnPosX_CW.SameLine = true
    E.btnPosX_CW.OnClick = function (e)

        for k, v in pairs(LLGlobals.LightParametersClient) do
            DPrint(k)
            local entity = Ext.Entity.Get(k)
            MoveEntity(entity, 'x', -100, E.modPosSlider.Value[1], 'Orbit', 'Light')
        end

    end



    E.btnPosX_CCW = E.orbitTree:AddButton('>')
    E.btnPosX_CCW.IDContext = ' safj;awdffaawdqawwdwoeifmn'
    E.btnPosX_CCW.SameLine = true
    E.btnPosX_CCW.OnClick = function (e)
        MoveEntity(LLGlobals.selectedEntity, 'x', 100, E.modPosSlider.Value[1], 'Orbit', 'Light')
    end



    textCCW = E.orbitTree:AddText('Cw/Ccw')
    textCCW.SameLine = true



    E.slPosOrbY = E.orbitTree:AddSlider('', 0, -1000, 1000, 0.1)
    E.slPosOrbY.IDContext = 'NawawdwdawdS'
    E.slPosOrbY.Value = {0,0,0,0}
    E.slPosOrbY.OnChange = function()
        MoveEntity(LLGlobals.selectedEntity, 'y', E.slPosOrbY.Value[1], E.modPosSlider.Value[1], 'Orbit', 'Light')
        E.slPosOrbY.Value = {0,0,0,0}
    end



    E.btnPosY_D2 = E.orbitTree:AddButton('<')
    E.btnPosY_D2.IDContext = ' safj;awffdqeawwoeifmn'
    E.btnPosY_D2.SameLine = true
    E.btnPosY_D2.OnClick = function (e)
        MoveEntity(LLGlobals.selectedEntity, 'y', -100, E.modPosSlider.Value[1], 'Orbit', 'Light')
    end



    E.btnPosY_U2 = E.orbitTree:AddButton('>')
    E.btnPosY_U2.IDContext = ' safj;awdfefawqawdawwdwoeifmn'
    E.btnPosY_U2.SameLine = true
    E.btnPosY_U2.OnClick = function (e)
        MoveEntity(LLGlobals.selectedEntity, 'y', 100, E.modPosSlider.Value[1], 'Orbit', 'Light')
    end



    textDU = E.orbitTree:AddText('Down/Up')
    textDU.SameLine = true



    E.slPosOrbZ = E.orbitTree:AddSlider('', 0, -1000, 1000, 0.1)
    E.slPosOrbZ.IDContext = 'NawdasdawdS'
    E.slPosOrbZ.Value = {0,0,0,0}
    E.slPosOrbZ.OnChange = function()
        MoveEntity(LLGlobals.selectedEntity, 'z', E.slPosOrbZ.Value[1], E.modPosSlider.Value[1], 'Orbit', 'Light')
        E.slPosOrbZ.Value = {0,0,0,0}
    end



    E.btnPosZ_C = E.orbitTree:AddButton('<')
    E.btnPosZ_C.IDContext = ' safj;awffdawwoeifmn'
    E.btnPosZ_C.SameLine = true
    E.btnPosZ_C.OnClick = function (e)
        MoveEntity(LLGlobals.selectedEntity, 'z', -100, E.modPosSlider.Value[1], 'Orbit', 'Light')
    end



    E.btnPosZ_F = E.orbitTree:AddButton('>')
    E.btnPosZ_F.IDContext = ' safj;awdfefaawdawwdwoeifmn'
    E.btnPosZ_F.SameLine = true
    E.btnPosZ_F.OnClick = function (e)
        MoveEntity(LLGlobals.selectedEntity, 'z', 100, E.modPosSlider.Value[1], 'Orbit', 'Light')
    end



    textCF = E.orbitTree:AddText('Close/Far')
    textCF.SameLine = true



    E.orbitTree:AddSeparator('')



    E.collapsRot = p:AddCollapsingHeader('Rotation')
    E.collapsRot.DefaultOpen = openByDefaultMainRot



    E.slRotTiltSlider = E.collapsRot:AddSlider('', 0, -1000, 1000, 0.1)
    E.slRotTiltSlider.IDContext = 'Pitch'
    E.slRotTiltSlider.Value = {0,0,0,0}
    E.slRotTiltSlider.OnChange = function(e)
        RotateEntity(LLGlobals.selectedEntity, 'x', e.Value[1], E.modRotSlider.Value[1], 'Light')
        E.slRotTiltSlider.Value = {0,0,0,0}
    end
    E.slRotTiltSlider.OnRightClick = function (e)
        RotateEntity(LLGlobals.selectedEntity, 'x', 90, 1, 'Light')
    end



    E.btnRot_Pp = E.collapsRot:AddButton('<')
    E.btnRot_Pp.IDContext = 'adawdawd'
    E.btnRot_Pp.SameLine = true
    E.btnRot_Pp.OnClick = function (e)
        RotateEntity(LLGlobals.selectedEntity, 'x', -100, E.modRotSlider.Value[1], 'Light')
    end



    E.btnRot_Pm = E.collapsRot:AddButton('>')
    E.btnRot_Pm.IDContext = 'awdawdawd'
    E.btnRot_Pm.SameLine = true
    E.btnRot_Pm.OnClick = function (e)
        RotateEntity(LLGlobals.selectedEntity, 'x', 100, E.modRotSlider.Value[1], 'Light')
    end



    rotTiltReset = E.collapsRot:AddText('Pitch')
    rotTiltReset.IDContext = 'resetPitch'
    rotTiltReset.SameLine = true



    E.slRotRollSlider = E.collapsRot:AddSlider('', 0, -1000, 1000, 0.1)
    E.slRotRollSlider.IDContext = 'roll'
    E.slRotRollSlider.Disabled = true
    E.slRotRollSlider.Value = {0,0,0,0}
    E.slRotRollSlider.OnChange = function(e)
        RotateEntity(LLGlobals.selectedEntity, 'z', e.Value[1], E.modRotSlider.Value[1], 'Light')
        E.slRotRollSlider.Value = {0,0,0,0}
    end

    E.slRotRollSlider.OnRightClick = function (e)
        RotateEntity(LLGlobals.selectedEntity, 'z', 90, 1, 'Light')
    end



    E.btnRot_Rp = E.collapsRot:AddButton('<')
    E.btnRot_Rp.IDContext = 'adwdawdawdawd'
    E.btnRot_Rp.Disabled = true
    E.btnRot_Rp.SameLine = true
    E.btnRot_Rp.OnClick = function (e)
        RotateEntity(LLGlobals.selectedEntity, 'z', -100, E.modRotSlider.Value[1], 'Light')
    end



    E.btnRot_Rm = E.collapsRot:AddButton('>')
    E.btnRot_Rm.IDContext = 'awdddddawdawd'
    E.btnRot_Rm.Disabled = true
    E.btnRot_Rm.SameLine = true
    E.btnRot_Rm.OnClick = function (e)
        RotateEntity(LLGlobals.selectedEntity, 'z', 100, E.modRotSlider.Value[1], 'Light')
    end



    rotRollReset = E.collapsRot:AddText('Roll')
    rotRollReset.IDContext = 'resetROll'
    rotRollReset.SameLine = true



    E.slRotYawSlider = E.collapsRot:AddSlider('', 0, -1000, 1000, 0.1)
    E.slRotYawSlider.IDContext = 'yaw'
    E.slRotYawSlider.Value = {0,0,0,0}
    E.slRotYawSlider.OnChange = function(e)
        RotateEntity(LLGlobals.selectedEntity, 'y', e.Value[1], E.modRotSlider.Value[1], 'Light')
        E.slRotYawSlider.Value = {0,0,0,0}
    end

    E.slRotYawSlider.OnRightClick = function (e)
        RotateEntity(LLGlobals.selectedEntity, 'y', 90, 1, 'Light')
    end



    E.btnRot_Yp = E.collapsRot:AddButton('<')
    E.btnRot_Yp.IDContext = 'adwdawddddawdawd'
    E.btnRot_Yp.SameLine = true
    E.btnRot_Yp.OnClick = function (e)
        RotateEntity(LLGlobals.selectedEntity, 'y', -100, E.modRotSlider.Value[1], 'Light')
    end



    E.btnRot_Ym = E.collapsRot:AddButton('>')
    E.btnRot_Ym.IDContext = 'awdddddddddawdawd'
    E.btnRot_Ym.SameLine = true
    E.btnRot_Ym.OnClick = function (e)
        RotateEntity(LLGlobals.selectedEntity, 'y', 100, E.modRotSlider.Value[1], 'Light')
    end



    rotYawReset = E.collapsRot:AddText('Yaw')
    rotYawReset.IDContext = 'resetYaw'
    rotYawReset.SameLine = true



    -- E.bulletLock = E.collapsRot:AddBulletText('Gimbal-lock is real monkaS')



    E.collapsRot:AddSeparator('')



    textPositionInfo = p:AddText('')
    textPositionInfo.Label = string.format('x: %.2f, y: %.2f, z: %.2f', 0, 0, 0)



    textRotationInfo = p:AddText('')
    textRotationInfo.Label = string.format('pitch: %.2f, roll: %.2f, yaw: %.2f', 0, 0, 0)



    ---------------------------------------------------------
    p:AddSeparatorText([[Position source]])
    ---------------------------------------------------------



    E.checkOriginSrc = p:AddCheckbox('Origin point')
    E.checkOriginSrc.Disabled = false
    E.checkOriginSrc.OnChange = function (e)
        SourcePoint(e.Checked)
    end



    E.checkCutsceneSrc = p:AddCheckbox('Cutscene')
    E.checkCutsceneSrc.SameLine = true
    E.checkCutsceneSrc.Disabled = false
    E.checkCutsceneSrc.OnChange = function (e)
        SourceCutscene(e.Checked)
    end



    E.checkPMSrc = p:AddCheckbox('PhotoMode')
    E.checkPMSrc.SameLine = true
    E.checkPMSrc.Disabled = false
    E.checkPMSrc.OnChange = function (e)
        SourcePhotoMode(e.Checked)
    end



    E.checkClientSrc = p:AddCheckbox('Client-side')
    E.checkClientSrc.SameLine = true
    E.checkClientSrc.Disabled = false
    E.checkClientSrc.OnChange = function (e)
        SourceClient(e.Checked)
    end



    ---------------------------------------------------------
    p:AddSeparatorText('Slider settings')
    ---------------------------------------------------------



    E.modPosSlider = p:AddSlider('', modPosDefault, 0.1, modPos, 0)
    E.modPosSlider.Value = {modPosDefault,0,0,0}
    E.modPosSlider.IDContext = 'ModID'
    E.modPosSlider.Logarithmic = true



    ER.modPosReset = p:AddButton('Pos modifier')
    ER.modPosReset.IDContext = 'MOdd'
    ER.modPosReset.SameLine = true
    ER.modPosReset.OnClick = function ()
        E.modPosSlider.Value = {modPosDefault,0,0,0}
    end



    E.modRotSlider = p:AddSlider('', modRotDefault, 0.1, modRot, 0)
    E.modRotSlider.IDContext = 'RotMiodID'
    E.modRotSlider.Value = {modRotDefault,0,0,0}
    E.modRotSlider.Logarithmic = true



    ER.modRotReset = p:AddButton('Rot modifier')
    ER.modRotReset.IDContext = 'MOddRot'
    ER.modRotReset.SameLine = true
    ER.modRotReset.OnClick = function ()
        E.modRotSlider.Value = {modRotDefault,0,0,0}
    end

end



MCM.InsertModMenuTab('Lighty Lights', LLMCM, ModuleUUID)




Ext.RegisterConsoleCommand('lld', function (cmd, ...)

    DPrint('LightParametersClient-----------------------------')
    DDump(LLGlobals.LightParametersClient)

end)




Ext.RegisterConsoleCommand('lldg', function (cmd, ...)

    DPrint('Globals-----------------------------')
    DDump(LLGlobals)

end)



Ext.RegisterConsoleCommand('lldumpall', function (cmd, ...)
    DPrint('CreatedLightsServer ------------------------------')
    DDump(LLGlobals.CreatedLightsServer)
    DPrint('LightsUuidNameMap --------------------------------')
    DDump(LLGlobals.LightsUuidNameMap)
    DPrint('LightsNames --------------------------------------')
    DDump(LLGlobals.LightsNames)
    DPrint('LightParametersClient ----------------------------')
    DDump(LLGlobals.LightParametersClient)
    DPrint('selectedUuid -------------------------------------')
    DDump(LLGlobals.selectedUuid)
    DPrint('selectedEntity -----------------------------------')
    DDump(LLGlobals.selectedEntity)
    DPrint('markerUuid ---------------------------------------')
    DDump(LLGlobals.markerUuid)
    DPrint('nameIndex ----------------------------------------')
    DDump(nameIndex)
end)




--[[
local rate = 10
local count = 300
for _, ent in pairs(Ext.Entity.GetAllEntitiesWithComponent('GameObjectVisual')) do
    if ent.Effect and ent.Effect.EffectName == 'VFX_Environment_Leaves_Sussur_01_NonGlow' then

        if ent.Effect.Timeline then
            _P(ent.Effect.Timeline.Components[5].MaximumParticleCount)
        ent.Effect.Timeline.Components[5].MaximumParticleCount = count
            _P(ent.Effect.Timeline.Components[6].MaximumParticleCount)
            ent.Effect.Timeline.Components[6].MaximumParticleCount = count
        end


        for k, v in pairs(ent.Effect.EffectResource.Constructor.EffectComponents) do

            if v.Properties['Emitter.Behavior.Emit Rate Modifier'] then
                _D(v.Properties['Emitter.Behavior.Emit Rate Modifier'].Value)

                _P('Count')
                v.MaximumParticleCount = count

                v.Properties['Emitter.Behavior.Emit Rate Modifier'].Value = rate
                v.Properties['Emitter.Behavior.Maximum Particle Count'].Value = count

                for g, z in pairs (v.Properties['Emitter.Behavior.Emit Rate'].KeyFrames[1].Frames) do
                    _D(v.Properties['Emitter.Behavior.Emit Rate'].KeyFrames[1])
                    z.Value = rate
                end
            end
        end
    end
end
]]--


--[[
for _, ent in pairs(Ext.Entity.GetAllEntitiesWithComponent('GameObjectVisual')) do
    if ent.Effect and ent.Effect.EffectName == 'VFX_Environment_Leaves_Sussur_01_NonGlow' then
        _D(ent:GetAllComponents())
        return
    end
end
]]--


--[[
for _, ent in pairs(Ext.Entity.GetAllEntitiesWithComponent('GameObjectVisual')) do
    if ent.Effect and ent.Effect.EffectName == 'VFX_Actions_Cast_Cleave_Cast_Root_Textkey_03' then
        if ent.Effect.Timeline then
            Mods.LL2.Utils:Dump(ent, 'r_VFX', true)
            vfx = ent
        end
    end
end
]]--

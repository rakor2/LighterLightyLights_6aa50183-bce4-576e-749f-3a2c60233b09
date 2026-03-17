--[[
Light Setup on level change
]]
_GLL.CreatedLightsClient = {} --UNUSED

_GLL.LightsUuidNameMap = {}
_GLL.LightsNames = {}
_GLL.LightParametersClient = {}

_GLL.States = _GLL.States or {}
_GLL.States.allowLightCreation = {}

---@class Settings
Settings = Settings or {}

---@type string EntityUuid
_GLL.selectedUuid = nil

---@type EntityHandle
_GLL.selectedEntity = nil

---@type LightComponent
_GLL.selectedLightEntity = nil


DEFAULT_MARKER_SCALE = 0.699999988079071

nameIndex = 0

_GLL.syncedSelectedIndex = 0

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
    LLMCM = mt2

    local version = table.concat(Ext.Mod.GetMod(ModuleUUID).Info.ModVersion, ".")
    local rngMax = #ModName
    mw = Ext.IMGUI.NewWindow(ModName[Ext.Math.Random(1, rngMax)] .. ' ' .. '[' .. version .. ']')
    mw.Font = 'Font'
    mw.Open = OPENQUESTIONMARK
    mw.Closeable = true

    openButton = mt2:AddButton('Open')
        UI:Config(openButton, {
            IDContext = 'OpenMainWindowButton',
            OnClick   = function()
                mw.Open = not mw.Open
            end
        })

    mw.OnClose = function()
        mw.Open = false
        return true
    end

    local styleCombo = mt2:AddCombo('Style')
        UI:Config(styleCombo, {
            IDContext     = 'StyleSwitchCombo',
            Options       = StyleNames,
            SelectedIndex = StyleSettings.selectedStyle - 1,
            OnChange      = function(widget)
                StyleSettings.selectedStyle = widget.SelectedIndex + 1
                ApplyStyle(mw, StyleSettings.selectedStyle)
                ResetBoneZoneColors()

                if windowNotification then
                    E.checkSelectedLightNotification.Checked = false
                    windowNotification:Destroy()
                    CreateLightNumberNotification()
                end

                if Mods.Mazzle_Docs then
                    initMazzleColors()
                    API.Rebuild('LL2', 'Lighty Lights Elucidator')
                end

                if Mods.GizmoLib then
                    initGizmoLibColors()
                end

                SettingsSave()
            end
        })


    if Mods.GizmoLib then
        initGizmoLibColors()
    end


    ApplyStyle(mw, StyleSettings.selectedStyle)
    MainWindow(mw)
end



function MainWindow(mw)
    ViewportSize = Ext.IMGUI.GetViewportSize()
    mw:SetPos({ViewportSize[1] / 6, ViewportSize[2] / 10})
    if ViewportSize[1] <= 1920 and ViewportSize[2] <= 1080 then
        mw:SetSize({670, 710})
    else
        mw:SetSize({860, 1000})
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

    E.boneZone = mainTabBar:AddTabItem('BoneZone')
    BoneZoneTab(E.boneZone)

    E.origin2PointTab = mainTabBar:AddTabItem('OriginPoint')
    Origin2PointTab(E.origin2PointTab)

    E.goboTab = mainTabBar:AddTabItem('Gobo')
    Gobo2Tab(E.goboTab)

    E.utilsTab = mainTabBar:AddTabItem('Useful')
    Utils2Tab(E.utilsTab)

    saverTab = mainTabBar:AddTabItem('Saver')
    Saver2Tab(saverTab)

    E.settingsTab = mainTabBar:AddTabItem('Settings')
    Settings2Tab(E.settingsTab)

    E.docsTab = mainTabBar:AddTabItem('Docs')
    Docs2Tab(E.docsTab)

    function buttonSizes()
        for _, element in pairs(ER) do
            element.Size = {180/Style.buttonScale, 39/Style.buttonScale}
        end
    end


--#region FunnyStuff
    function funnyStuff()
        local allElements = {}
        -- local allButtons = {}

        for _, element in pairs(E) do
            table.insert(allElements, element)
        end

        for _, element in pairs(ER) do
            table.insert(allElements, element)
        end
        --#region
        -- for _, element in pairs(ER) do
        --     table.insert(allButtons, element)
        -- end

        -- for _, element in pairs(allButtons) do
        --     element.OnClick = function(e)
        --         local elementType = tostring(e):match('^(%w+)')

        --         if elementType == 'Button' then
        --             -- Imgui.FadeColor(e, 'Button', Style.Colors.buttonHovered, Style.Colors.button, fadeTime)
        --             -- Imgui.FadeColor(e, 'ButtonActive', Style.Colors.buttonHovered, Style.Colors.buttonActive, fadeTime)
        --             -- Imgui.FadeColor(e, 'ButtonHovered', Style.Colors.buttonActive, Style.Colors.buttonHovered, fadeTime)
        --         elseif elementType == 'Checkbox' then
        --             Imgui.FadeColor(e, 'FrameBg', Style.Colors.frameBgHovered, Style.Colors.frameBg, fadeTime)
        --         elseif elementType == 'SliderScalar' or elementType == 'SliderInt' then
        --             Imgui.FadeColor(e, 'FrameBg', Style.Colors.frameBgHovered, Style.Colors.frameBg, fadeTime)
        --             Imgui.FadeColor(e, 'FrameBgHovered', Style.Colors.frameBgActive, Style.Colors.frameBgHovered, fadeTime)
        --         elseif elementType == 'InputText' then
        --             Imgui.FadeColor(e, 'FrameBg', Style.Colors.frameBgHovered, Style.Colors.frameBg, fadeTime)
        --         elseif elementType == 'ColorEdit' then
        --             Imgui.FadeColor(e, 'FrameBg', Style.Colors.frameBgHovered, Style.Colors.frameBg, fadeTime)
        --         elseif elementType == 'Combo' then
        --             Imgui.FadeColor(e, 'FrameBg', Style.Colors.frameBgHovered, Style.Colors.frameBg, fadeTime)
        --         elseif elementType == 'TabItem' then
        --             Imgui.FadeColor(e, 'TabActive', Style.Colors.tabHovered, Style.Colors.tabActive, fadeTime)
        --             -- Imgui.FadeColor(e, 'TabHovered', Style.Colors.tabHovered, Style.Colors.tab, fadeTime)
        --             Imgui.FadeColor(e, 'Tab', Style.Colors.tabHovered, Style.Colors.tab, fadeTime)
        --         elseif elementType == 'CollapsingHeader' then
        --             Imgui.FadeColor(e, 'Header', Style.Colors.headerHovered, Style.Colors.header, fadeTime)
        --         end
        --     end
        -- end
        --#endregion
        for _, element in pairs(allElements) do
            element.OnHoverEnter = function(e)
                local elementType = tostring(e):match('^(%w+)')
                if elementType == 'Button' then
                    Imgui.FadeColor(e, 'Button', Style.Colors.buttonHovered, Style.Colors.button, fadeTime)
                elseif elementType == 'Checkbox' then
                    Imgui.FadeColor(e, 'FrameBg', Style.Colors.frameBgHovered, Style.Colors.frameBg, fadeTime)
                elseif elementType == 'SliderScalar' or elementType == 'SliderInt' then
                    Imgui.FadeColor(e, 'FrameBg', Style.Colors.frameBgHovered, Style.Colors.frameBg, fadeTime)
                    Imgui.FadeColor(e, 'FrameBgHovered', Style.Colors.frameBgHovered, Style.Colors.frameBgHovered, fadeTime)
                elseif elementType == 'InputText' then
                    Imgui.FadeColor(e, 'FrameBg', Style.Colors.frameBgHovered, Style.Colors.frameBg, fadeTime)
                elseif elementType == 'ColorEdit' then
                    Imgui.FadeColor(e, 'FrameBg', Style.Colors.frameBgHovered, Style.Colors.frameBg, fadeTime)
                elseif elementType == 'Combo' then
                    Imgui.FadeColor(e, 'FrameBg', Style.Colors.frameBgHovered, Style.Colors.frameBg, fadeTime)
                elseif elementType == 'TabItem' then
                    Imgui.FadeColor(e, 'TabActive', Style.Colors.tabHovered, Style.Colors.tabActive, fadeTime)
                    -- Imgui.FadeColor(e, 'TabHovered', Style.Colors.tabHovered, Style.Colors.tab, fadeTime)
                    Imgui.FadeColor(e, 'Tab', Style.Colors.tabHovered, Style.Colors.tab, fadeTime)
                elseif elementType == 'CollapsingHeader' then
                    Imgui.FadeColor(e, 'Header', Style.Colors.headerHovered, Style.Colors.header, fadeTime)
                end
            end
            --#region
            --     element.OnHoverLeave = function(e)
            --         local elementType = tostring(e):match('^(%w+)')

            --         if elementType == 'Button' then
            --             Imgui.FadeColor(e, 'Button', Style.Colors.buttonHovered, Style.Colors.button, fadeTime)
            --         elseif elementType == 'Checkbox' then
            --             Imgui.FadeColor(e, 'FrameBg', Style.Colors.frameBgHovered, Style.Colors.frameBg, fadeTime)
            --         elseif elementType == 'SliderScalar' or elementType == 'SliderInt' then
            --             Imgui.FadeColor(e, 'FrameBg', Style.Colors.frameBgHovered, Style.Colors.frameBg, fadeTime)
            --             Imgui.FadeColor(e, 'FrameBgHovered', Style.Colors.frameBgHovered, Style.Colors.frameBgHovered, fadeTime)
            --         elseif elementType == 'InputText' then
            --             Imgui.FadeColor(e, 'FrameBg', Style.Colors.frameBgHovered, Style.Colors.frameBg, fadeTime)
            --         elseif elementType == 'ColorEdit' then
            --             Imgui.FadeColor(e, 'FrameBg', Style.Colors.frameBgHovered, Style.Colors.frameBg, fadeTime)
            --         elseif elementType == 'Combo' then
            --             Imgui.FadeColor(e, 'FrameBg', Style.Colors.frameBgHovered, Style.Colors.frameBg, fadeTime)
            --         elseif elementType == 'TabItem' then
            --             Imgui.FadeColor(e, 'TabActive', Style.Colors.tabHovered, Style.Colors.tabActive, fadeTime)
            --             -- Imgui.FadeColor(e, 'TabHovered', Style.Colors.tabHovered, Style.Colors.tab, fadeTime)
            --             Imgui.FadeColor(e, 'Tab', Style.Colors.tabHovered, Style.Colors.tab, fadeTime)
            --         elseif elementType == 'CollapsingHeader' then
            --             Imgui.FadeColor(e, 'Header', Style.Colors.headerHovered, Style.Colors.header, fadeTime)
            --         end
            --     end
            -- end
            --#endregion
        end
    end
    funnyStuff()
--#endregion

    buttonSizes()
    SettingsLoad()
end



function MainTab(p)
    local rngMax = #MOTD
    p:AddSeparatorText(MOTD[Ext.Math.Random(1, rngMax)])

    E.checkTypePoint = p:AddCheckbox('Point')
        UI:Config(E.checkTypePoint, {
            Checked  = defaultLightType == 'Point',
            OnChange = function()
                lightType = 'Point' -- 0
                E.checkTypeSpot.Checked = false
                E.checkTypeDir.Checked  = false
            end
        })



    E.checkTypeSpot = p:AddCheckbox('Spotlight')
        UI:Config(E.checkTypeSpot, {
            Checked  = defaultLightType == 'Spotlight',
            SameLine = true,
            OnChange = function()
                lightType = 'Spotlight' -- 1
                E.checkTypePoint.Checked = false
                E.checkTypeDir.Checked   = false
            end
        })



    E.checkTypeDir = p:AddCheckbox('Directional')
        UI:Config(E.checkTypeDir, {
            Checked  = defaultLightType == 'Directional',
            SameLine = true,
            OnChange = function()
                lightType = 'Directional' -- 2
                E.checkTypePoint.Checked = false
                E.checkTypeSpot.Checked  = false
            end
        })



    E.btnCreate2 = p:AddButton('Create')
        UI:Config(E.btnCreate2, {
            SameLine = true,
            OnClick  = function()
                local lt = 'Point'
                if lightType == 'Spotlight'   then lt = 'Spot' end
                if lightType == 'Directional' then lt = 'Direction' end
                Ext.Template.GetRootTemplate('aca228c3-f0c5-41e0-bc00-d11ddee12ed0').LightType = lt
                Ext.Template.GetRootTemplate('aca228c3-f0c5-41e0-bc00-d11ddee12ed0').Color = {1,1,1}
                Ext.Template.GetRootTemplate('aca228c3-f0c5-41e0-bc00-d11ddee12ed0').Radius = 6
                CreateLight()
                E.checkGroup.Checked = false
            end
        })



    E.comboIHateCombos = p:AddCombo('')
        UI:Config(E.comboIHateCombos, {
            Options       = _GLL.LightsNames,
            SelectedIndex = _GLL.syncedSelectedIndex,
            OnChange      = function(e)
                _GLL.syncedSelectedIndex = E.comboIHateCombos.SelectedIndex
                E.comboIHateCombos2.SelectedIndex = _GLL.syncedSelectedIndex
                E.checkGroup.Checked = _GLL.LightsToInclude[getSelectedUuid()] or false
                SelectLight()
            end
        })



    --- for keybind
    function prevOptionBtn()
        local element = E.comboIHateCombos
        if element.SelectedIndex < 1 then
            element.SelectedIndex = #element.Options - 1
        else
            element.SelectedIndex = element.SelectedIndex - 1
        end
        _GLL.syncedSelectedIndex = element.SelectedIndex
        E.comboIHateCombos2.SelectedIndex = _GLL.syncedSelectedIndex
        E.checkGroup.Checked = _GLL.LightsToInclude[getSelectedUuid()] or false
        SelectLight()
    end



    E.btnOptionsPrev = p:AddButton('<')
        UI:Config(E.btnOptionsPrev, {
            IDContext = 'adawd',
            SameLine  = true,
            OnClick   = function(e)
                if not _GLL.selectedUuid then return end
                prevOptionBtn()
            end
        })



    --- for keybind
    function nextOptionBtn()
        local element = E.comboIHateCombos
        if element.SelectedIndex > #element.Options - 2 then
            element.SelectedIndex = 0
        else
            element.SelectedIndex = element.SelectedIndex + 1
        end
        _GLL.syncedSelectedIndex = element.SelectedIndex
        E.comboIHateCombos2.SelectedIndex = _GLL.syncedSelectedIndex
        E.checkGroup.Checked = _GLL.LightsToInclude[getSelectedUuid()] or false
        SelectLight()
    end



    E.btnOptionsNext = p:AddButton('>')
        UI:Config(E.btnOptionsNext, {
            IDContext = 'adadwwd',
            SameLine  = true,
            OnClick   = function(e)
                if not _GLL.selectedUuid then return end
                nextOptionBtn()
            end
        })



    txtCreateLight = p:AddText('Created lights')
        UI:Config(txtCreateLight, { SameLine = true })



    E.inputRename = p:AddInputText('')
        UI:Config(E.inputRename, {
            IDContext = 'adawdawdawdawd',
            Disabled  = false
        })



    E.btnRenameLight = p:AddButton('Rename')
        UI:Config(E.btnRenameLight, {
            SameLine = true,
            Disabled = false,
            OnClick  = function()
                if not _GLL.selectedUuid then return end

                local lightEntity = getSelectedLightEntity()

                for k, light in pairs(_GLL.LightsUuidNameMap) do
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
        })



    ER.btnDelete = p:AddButton('Delete')
        UI:Config(ER.btnDelete, {
            OnClick = function()
                if not _GLL.selectedUuid then return end

                local uuidToDelete = _GLL.selectedUuid
                local selectedName = getSelectedLightName()

                Ch.DeleteGobo:SendToServer('Single')
                _GLL.CreatedLightsServer[uuidToDelete]    = nil
                _GLL.LightParametersClient[uuidToDelete]  = nil

                for k, light in pairs(_GLL.LightsUuidNameMap) do
                    if light.name == selectedName then
                        table.remove(_GLL.LightsUuidNameMap, k)
                    end
                end

                for k, light in pairs(_GLL.LightsNames) do
                    if light == selectedName then
                        _GLL.LightsNames[k] = nil
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
                        _GLL.selectedUuid   = nil
                        _GLL.selectedEntity = nil
                        _GLL.markerUuid     = nil
                        _GLL.markerEntity   = nil
                    end
                else
                    _GLL.selectedUuid   = nil
                    _GLL.selectedEntity = nil
                    _GLL.markerUuid     = nil
                    _GLL.markerEntity   = nil
                    nameIndex = 0
                    UpdateTranformInfo(0, 0, 0, 0, 0, 0)
                end

                Ch.DeleteLight:SendToServer(uuidToDelete)
                Ch.SelectedLight:SendToServer(_GLL.selectedUuid)
            end
        })


    local confirmTimer
    ER.btnDeleteAll = p:AddButton('Delete all')
        UI:Config(ER.btnDeleteAll, {
            SameLine = true,
            OnClick  = function()
                ER.btnDeleteAll.Visible = false
                ER.btnConfirmDeleteAll.Visible = true

                confirmTimer = Ext.Timer.WaitFor(1000, function()
                    ER.btnConfirmDeleteAll.Visible = false
                    ER.btnDeleteAll.Visible = true
                end)
            end
        })


    ER.btnConfirmDeleteAll = p:AddButton('Confirm')
    ER.btnConfirmDeleteAll.Visible = false
        UI:Config(ER.btnConfirmDeleteAll, {
            SameLine = true,
            OnClick  = function()
                E.checkStick.Checked = false

                Ch.DeleteGobo:SendToServer('All')
                Ch.DeleteLight:SendToServer('All')

                _GLL.CreatedLightsServer  = {}
                _GLL.LightsUuidNameMap    = {}
                _GLL.LightsNames          = {}
                _GLL.LightParametersClient = {}
                _GLL.selectedUuid         = nil
                _GLL.selectedEntity       = nil
                _GLL.markerUuid           = {}
                _GLL.markerEntity         = nil
                nameIndex = 0

                Ch.CurrentEntityTransform:SendToServer(nil)

                UpdateCreatedLightsCombo()
                UpdateTranformInfo(0, 0, 0, 0, 0, 0)
                textFunc.Label = 'Attenuation'

                GatherLightsAndMarkers()

                Ext.Timer.Cancel(confirmTimer)

                ER.btnDeleteAll.Visible        = true
                ER.btnConfirmDeleteAll.Visible = false
            end
        })
    Style.buttonConfirm.default(ER.btnConfirmDeleteAll)



    ER.btnDuplicate = p:AddButton('Duplicate')
        UI:Config(ER.btnDuplicate, {
            SameLine = true,
            Disabled = false,
            OnClick  = function()
                if not _GLL.selectedUuid then return end
                DuplicateLight()
                E.checkGroup.Checked = false
            end
        })


    E.checkSelectedLightNotification = p:AddCheckbox('Selected light popup')
        UI:Config(E.checkSelectedLightNotification, {
            SameLine = true,
            OnChange = function(e)
                windowNotification.Visible = E.checkSelectedLightNotification.Checked
            end
        })



    --- for keybind
    function toggleLightBtn()
        local lightEntity  = getSelectedLightEntity()
        local selectedUuid = getSelectedUuid()

        if lightEntity then
            local flag        = lightEntity.LightChannelFlag ~= 0
            local flag2       = not flag
            local scattering  = lightEntity.ScatteringIntensityScale ~= 0
            local scattering2 = not scattering

            if flag2 then
                local savedFlag = _GLL.LightParametersClient[selectedUuid].LightChannelFlag
                lightEntity.LightChannelFlag = (savedFlag ~= nil) and savedFlag or 255
            else
                lightEntity.LightChannelFlag = 0
            end

            if scattering2 and _GLL.LightParametersClient[selectedUuid].ScatteringIntensityScale then
                local value = _GLL.LightParametersClient[selectedUuid].ScatteringIntensityScale
                lightEntity.ScatteringIntensityScale = value
            else
                lightEntity.ScatteringIntensityScale = 0
            end

            UpdateVisibilityStateToNames(getSelectedLightName(), flag2)
        end
    end



    E.toggleLightButton = p:AddButton('Toggle light')
        UI:Config(E.toggleLightButton, {
            IDContext = 'awdaw',
            OnClick   = function()
                if not _GLL.selectedUuid then return end
                toggleLightBtn()
            end
        })


    local all = false
    function toggleAllLightsBtn()
        if _GLL.selectedUuid and _GLL.LightParametersClient[_GLL.selectedUuid] then
            all = not all

            for uuid, _ in pairs(_GLL.CreatedLightsServer) do
                local lightEntity = getLightEntity(uuid)

                if all then
                    lightEntity.LightChannelFlag         = 0
                    lightEntity.ScatteringIntensityScale = 0
                else
                    local savedFlag = _GLL.LightParametersClient[uuid].LightChannelFlag
                    lightEntity.LightChannelFlag = (savedFlag ~= nil) and savedFlag or 255

                    if _GLL.LightParametersClient[uuid].ScatteringIntensityScale then
                        local value = _GLL.LightParametersClient[uuid].ScatteringIntensityScale
                        lightEntity.ScatteringIntensityScale = value
                    end
                end

                for _, name in pairs(_GLL.LightsNames) do
                    UpdateVisibilityStateToNames(name, not all)
                end
            end
        end
    end



    local all = false
    E.toggleLightsButton = p:AddButton('Toggle all')
        UI:Config(E.toggleLightsButton, {
            IDContext = 'awdfdgdfg',
            SameLine  = true,
            OnClick   = function()
                if not _GLL.selectedUuid then return end
                toggleAllLightsBtn()
            end
        })



    E.toggleMarkerButton = p:AddButton('Toggle marker')
        UI:Config(E.toggleMarkerButton, {
            SameLine  = true,
            IDContext = 'jhjkgyyutr',
            OnClick   = function()
                ToggleMarker(_GLL.markerUuid)
            end
        })



    E.toggleAllMarkersButton = p:AddButton('Toggle all')
        UI:Config(E.toggleAllMarkersButton, {
            SameLine  = true,
            IDContext = '456456',
            OnClick   = function()
                Ch.MarkerHandler:RequestToServer({}, function(Response)
                end)
            end
        })



    E.btnMazzleBeam = p:AddButton('Mazzle beam')
        UI:Config(E.btnMazzleBeam, {
            SameLine = true,
            OnClick  = function()
                if not _GLL.selectedUuid then return end
                Ch.MazzleBeam:SendToServer({})
            end
        })



    ---------------------------------------------------------
    p:AddSeparatorText('Parameters')
    ---------------------------------------------------------



    E.collapseParameters = p:AddCollapsingHeader('Main parameters')
    E.collapseParameters.DefaultOpen = true



    E.treeGen = E.collapseParameters:AddTree('General')
    E.treeGen.DefaultOpen = openByDefaultMainGen



    E.slIntLightType = E.treeGen:AddSliderInt('', 0, 0, 2, 1)
        UI:Config(E.slIntLightType, {
            IDContext = 'aojwdnakwol;n',
            OnChange  = function(e)
                if _GLL.selectedUuid and _GLL.LightParametersClient[_GLL.selectedUuid] then
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
                            local newName = _GLL.LightsUuidNameMap[E.comboIHateCombos.SelectedIndex + 1].name
                            newName = newName:gsub('Point', localLightType):gsub('Spotlight', localLightType):gsub('Directional', localLightType)
                            _GLL.LightsUuidNameMap[E.comboIHateCombos.SelectedIndex + 1].name = newName
                        else
                            lightEntity.LightChannelFlag = 0
                            local newName = _GLL.LightsUuidNameMap[E.comboIHateCombos.SelectedIndex + 1].name
                            newName = newName:gsub('Point', localLightType):gsub('Spotlight', localLightType):gsub('Directional', localLightType)
                            _GLL.LightsUuidNameMap[E.comboIHateCombos.SelectedIndex + 1].name = newName
                        end
                        UpdateCreatedLightsCombo()
                    end
                end
            end
        })



    textLightType = E.treeGen:AddText('Type')
        UI:Config(textLightType, { SameLine = true })



    if biggerPicker then
        E.pickerLightColor = E.treeGen:AddColorPicker('')
        textPicker = E.treeGen:AddText('Icon')
            UI:Config(textPicker, { SameLine = true })
    else
        E.pickerLightColor = E.treeGen:AddColorEdit('')
        textPicker = E.treeGen:AddText('Color (lick me)')
            UI:Config(textPicker, { SameLine = true })
    end


    RecentColors = RecentColors or {}
    E.recentPickers = {}

    for i = 1, 12 do
        local picker = E.treeGen:AddColorEdit('')
            UI:Config(picker, {
                NoAlpha    = true,
                Float      = false,
                InputRGB   = true,
                DisplayHex = true,
                NoInputs   = true,
                SameLine   = i > 1,
                Color      = RecentColors[tostring(i)] or {0, 0, 0, 1},
                OnChange   = function(e)
                    RecentColors[tostring(i)] = {e.Color[1], e.Color[2], e.Color[3], 1}
                    SettingsSave()
                end
            })

        E.recentPickers[i] = picker
    end


    E.txtSaveColor = E.treeGen:AddText('Saved colors')
        UI:Config(E.txtSaveColor, { SameLine = true })

    E.pickerLightColor.IDContext   = 'aowidnawoidn'
    E.pickerLightColor.NoAlpha     = true
    E.pickerLightColor.Float       = false
    E.pickerLightColor.InputRGB    = true
    E.pickerLightColor.DisplayHex  = true
    E.pickerLightColor.OnChange    = function(e)
        if _GLL.selectedUuid and _GLL.LightParametersClient[_GLL.selectedUuid] then
            SetLightColor({e.Color[1], e.Color[2], e.Color[3]})
        end
    end



    E.slLightIntensity = E.treeGen:AddSlider('', 1, 0, 60, 1)
        UI:Config(E.slLightIntensity, {
            IDContext   = 'lkjanerfliuaern',
            Logarithmic = true,
            OnChange    = function(e)
                if _GLL.selectedUuid and _GLL.LightParametersClient[_GLL.selectedUuid] then
                    SetLightIntensity(e.Value[1])
                end
            end
        })



    ER.btnLightIntensityReset = E.treeGen:AddButton('Power')
        UI:Config(ER.btnLightIntensityReset, {
            SameLine = true,
            OnClick  = function()
                if _GLL.selectedUuid and _GLL.LightParametersClient[_GLL.selectedUuid] then
                    E.slLightIntensity.Value = {1, 0, 0, 0}
                    SetLightIntensity(E.slLightIntensity.Value[1])
                end
            end
        })



    E.slLightTemp = E.treeGen:AddSlider('', 5600, 1000, 40000, 1)
        UI:Config(E.slLightTemp, {
            IDContext   = 'wlekjfnlkm',
            Logarithmic = true,
            OnChange    = function(e)
                if _GLL.selectedUuid and _GLL.LightParametersClient[_GLL.selectedUuid] then
                    local Color = Math.KelvinToRGB(e.Value[1])
                    SetLightColor({Color[1], Color[2], Color[3]})
                    E.pickerLightColor.Color = {Color[1], Color[2], Color[3], 0}
                    _GLL.LightParametersClient[_GLL.selectedUuid].Temperature = e.Value[1] --This is just for the slider
                end
            end
        })



    ER.btnLightTempReset = E.treeGen:AddButton('Temperature')
        UI:Config(ER.btnLightTempReset, {
            SameLine = true,
            OnClick  = function()
                if _GLL.selectedUuid and _GLL.LightParametersClient[_GLL.selectedUuid] then
                    E.slLightTemp.Value = {5600, 0, 0, 0}
                    _GLL.LightParametersClient[_GLL.selectedUuid].Temperature = 5600
                    SetLightColor({1, 0.93, 0.88})
                end
            end
        })



    E.slLightRadius = E.treeGen:AddSlider('', 1, 0, 60, 1)
        UI:Config(E.slLightRadius, {
            IDContext   = 'adwadqw3d',
            Logarithmic = true,
            OnChange    = function(e)
                if _GLL.selectedUuid and _GLL.LightParametersClient[_GLL.selectedUuid] then
                    SetLightRadius(e.Value[1])
                end
            end
        })



    ER.btnLightRadiusReset = E.treeGen:AddButton('Distance')
        UI:Config(ER.btnLightRadiusReset, {
            SameLine = true,
            OnClick  = function()
                if _GLL.selectedUuid and _GLL.LightParametersClient[_GLL.selectedUuid] then
                    E.slLightRadius.Value = {1, 0, 0, 0}
                    SetLightRadius(E.slLightRadius.Value[1])
                end
            end
        })



    E.checkLightChannel = E.treeGen:AddSliderInt('', 1, 1, 3, 1)
        UI:Config(E.checkLightChannel, {
            IDContext = 'dojandoajwind',
            OnChange  = function(e)
                SetLightChannel(e.Value[1])
            end
        })



    textChannel = E.treeGen:AddText('Light channel')
        UI:Config(textChannel, { SameLine = true })



    E.slLightScattering = E.treeGen:AddSlider('', 0, 0, 100, 1)
        UI:Config(E.slLightScattering, {
            IDContext   = 'esrgsrengsrg',
            Logarithmic = true,
            OnChange    = function(e)
                if _GLL.selectedUuid and _GLL.LightParametersClient[_GLL.selectedUuid] then
                    SetLightScattering(e.Value[1])
                end
            end
        })



    ER.btnLightScatterReset = E.treeGen:AddButton('Scattering')
        UI:Config(ER.btnLightScatterReset, {
            SameLine = true,
            OnClick  = function()
                if _GLL.selectedUuid and _GLL.LightParametersClient[_GLL.selectedUuid] then
                    E.slLightScattering.Value = {0, 0, 0, 0}
                    SetLightScattering(E.slLightScattering.Value[1])
                end
            end
        })



    E.checkLightFill = E.treeGen:AddCheckbox('Scattering fill-light')
        UI:Config(E.checkLightFill, {
            Checked  = true,
            OnChange = function()
                if _GLL.selectedUuid and _GLL.LightParametersClient[_GLL.selectedUuid] then
                    SetLightFill(E.checkLightFill.Checked and 184 or 56)
                end
            end
        })



    E.treeGen:AddSeparator('')



    E.treePoint = E.collapseParameters:AddTree('Point')
        UI:Config(E.treePoint, {
            IDContext   = 'soawdawddkfn',
            DefaultOpen = openByDefaultMainPoint
        })



    function SetLightEdgeSharp(value)
        local lightEntity = getSelectedLightEntity()
        if lightEntity and value then
            lightEntity.EdgeSharpening = value
            _GLL.LightParametersClient[_GLL.selectedUuid].EdgeSharpening = value
        end
    end



    E.slLightEdgeSharp = E.treePoint:AddSlider('', 0, 0, 1, 1)
        UI:Config(E.slLightEdgeSharp, {
            IDContext   = 'sdfwerw34',
            Logarithmic = false,
            OnChange    = function(e)
                if _GLL.selectedUuid and _GLL.LightParametersClient[_GLL.selectedUuid] then
                    SetLightEdgeSharp(e.Value[1])
                end
            end
        })



    ER.btnLightSharpReset = E.treePoint:AddButton('Sharpening')
        UI:Config(ER.btnLightSharpReset, {
            SameLine = true,
            OnClick  = function()
                if _GLL.selectedUuid and _GLL.LightParametersClient[_GLL.selectedUuid] then
                    E.slLightEdgeSharp.Value = {0, 0, 0, 0}
                    SetLightEdgeSharp(E.slLightEdgeSharp.Value[1])
                end
            end
        })



    E.treeSpot = E.collapseParameters:AddTree('Spotlight')
        UI:Config(E.treeSpot, {
            IDContext   = 'sodkfn',
            DefaultOpen = openByDefaultMainSpot
        })



    E.slLightOuterAngle = E.treeSpot:AddSlider('', 45, 0, 179, 1)
        UI:Config(E.slLightOuterAngle, {
            IDContext = '123dwfsefa',
            OnChange  = function(e)
                if _GLL.selectedUuid and _GLL.LightParametersClient[_GLL.selectedUuid] then
                    SetLightOuterAngle(e.Value[1])
                end
            end
        })



    ER.btnLightOuterReset = E.treeSpot:AddButton('Outer angle')
        UI:Config(ER.btnLightOuterReset, {
            SameLine = true,
            OnClick  = function()
                if _GLL.selectedUuid and _GLL.LightParametersClient[_GLL.selectedUuid] then
                    E.slLightOuterAngle.Value = {45, 0, 0, 0}
                    SetLightOuterAngle(E.slLightOuterAngle.Value[1])
                end
            end
        })



    E.slLightInnerAngle = E.treeSpot:AddSlider('', 1, 0, 179, 1)
        UI:Config(E.slLightInnerAngle, {
            IDContext = 'rfgrtynj5r6',
            OnChange  = function(e)
                if _GLL.selectedUuid and _GLL.LightParametersClient[_GLL.selectedUuid] then
                    SetLightInnerAngle(e.Value[1])
                end
            end
        })



    ER.btnLightInnerReset = E.treeSpot:AddButton('Inner angle')
        UI:Config(ER.btnLightInnerReset, {
            SameLine = true,
            OnClick  = function()
                if _GLL.selectedUuid and _GLL.LightParametersClient[_GLL.selectedUuid] then
                    E.slLightInnerAngle.Value = {1, 0, 0, 0}
                    SetLightInnerAngle(E.slLightInnerAngle.Value[1])
                end
            end
        })



    E.treeSpot:AddSeparator('')



    E.treeDir = E.collapseParameters:AddTree('Directional')
        UI:Config(E.treeDir, {
            IDContext   = 'sodsdfkfn',
            DefaultOpen = openByDefaultMainDir
        })



    E.slLightDirEnd = E.treeDir:AddSlider('Falloff front', 0, 0, 20, 1)
        UI:Config(E.slLightDirEnd, {
            IDContext = 'olkjsdeafoiuzsrenbf',
            OnChange  = function(e)
                if _GLL.selectedUuid and _GLL.LightParametersClient[_GLL.selectedUuid] then
                    SetLightDirectionalParameters('DirectionLightAttenuationEnd', e.Value[1])
                end
            end
        })



    E.slLightDirSide = E.treeDir:AddSlider('Falloff back', 0, 0, 20, 1)
        UI:Config(E.slLightDirSide, {
            IDContext = 'o12312',
            OnChange  = function(e)
                if _GLL.selectedUuid and _GLL.LightParametersClient[_GLL.selectedUuid] then
                    SetLightDirectionalParameters('DirectionLightAttenuationSide', e.Value[1])
                end
            end
        })



    E.slLightDirSide2 = E.treeDir:AddSlider('Falloff sides', 0, 0, 10, 1)
        UI:Config(E.slLightDirSide2, {
            IDContext = 'asdaw',
            OnChange  = function(e)
                if _GLL.selectedUuid and _GLL.LightParametersClient[_GLL.selectedUuid] then
                    SetLightDirectionalParameters('DirectionLightAttenuationSide2', e.Value[1])
                end
            end
        })



    E.slIntLightDirFunc = E.treeDir:AddSliderInt('', 0, 0, 3, 1)
        UI:Config(E.slIntLightDirFunc, {
            IDContext = 'olkjsdsseafoiuzsrenbf',
            OnChange  = function(e)
                if _GLL.selectedUuid and _GLL.LightParametersClient[_GLL.selectedUuid] then
                    SetLightDirectionalParameters('DirectionLightAttenuationFunction', e.Value[1])
                end
            end
        })



    textFunc = E.treeDir:AddText('Attenuation')
        UI:Config(textFunc, { SameLine = true })



    E.slLightDirDim = E.treeDir:AddSlider('Width/Height/Length', 0, 0, 100, 1)
        UI:Config(E.slLightDirDim, {
            IDContext   = 'lkasenfaolkejfn',
            Components  = 3,
            Value       = {5, 5, 15, 0},
            Logarithmic = true,
            OnChange    = function(e)
                if _GLL.selectedUuid and _GLL.LightParametersClient[_GLL.selectedUuid] then
                    SetLightDirectionalParameters('DirectionLightDimensions', {e.Value[1], e.Value[2], e.Value[3]})
                end
            end
        })



    ---------------------------------------------------------
    p:AddSeparatorText('Positioning')
    ---------------------------------------------------------



    ER.btnSavePos = p:AddButton('Save')
        UI:Config(ER.btnSavePos, {
            OnClick = function(e)
                if not _GLL.selectedUuid then return end
                Ch.SaveLoadLightPos:SendToServer('Save')
            end
        })



    ER.btnLoadPos = p:AddButton('Load')
        UI:Config(ER.btnLoadPos, {
            SameLine = true,
            OnClick  = function(e)
                if not _GLL.selectedUuid then return end
                Ch.SaveLoadLightPos:SendToServer('Load')
            end
        })



    ER.posReset = p:AddButton('Reset position')
        UI:Config(ER.posReset, {
            IDContext = 'resetPos',
            SameLine  = true,
            OnClick   = function()
                MoveEntity(_GLL.selectedEntity, nil, 0, 0, 'World', 'Light')
            end
        })



    ER.rotReset = p:AddButton('Reset rotation')
        UI:Config(ER.rotReset, {
            IDContext = 'resetRos',
            SameLine  = true,
            OnClick   = function()
                RotateEntity(_GLL.selectedEntity, nil, 0, 0, 'Light')
            end
        })



    E.checkStick = p:AddCheckbox('Stick to camera')
        UI:Config(E.checkStick, {
            OnChange = function(e)
                if not _GLL.selectedUuid then e.Checked = false return end
                StickToCamera()
            end
        })



    E.worldTree = p:AddCollapsingHeader('World relative')
    E.worldTree.DefaultOpen = openByDefaultMainWorld



    E.slPosZSlider = E.worldTree:AddSlider('', 0, -1000, 1000, 0.1)
        UI:Config(E.slPosZSlider, {
            IDContext = 'NS',
            Value     = {0, 0, 0, 0},
            OnChange  = function()
                MoveEntity(_GLL.selectedEntity, 'z', E.slPosZSlider.Value[1], E.modPosSlider.Value[1], 'World', 'Light')
                E.slPosZSlider.Value = {0, 0, 0, 0}
            end
        })



    E.btnPosZ_S = E.worldTree:AddButton('<')
        UI:Config(E.btnPosZ_S, {
            IDContext = ' safj;woeifmn',
            SameLine  = true,
            OnClick   = function(e)
                MoveEntity(_GLL.selectedEntity, 'z', -100, E.modPosSlider.Value[1], 'World', 'Light')
            end
        })



    E.btnPosZ_N = E.worldTree:AddButton('>')
        UI:Config(E.btnPosZ_N, {
            IDContext = ' safj;awdawdwoeifmn',
            SameLine  = true,
            OnClick   = function(e)
                MoveEntity(_GLL.selectedEntity, 'z', 100, E.modPosSlider.Value[1], 'World', 'Light')
            end
        })



    local textZ = E.worldTree:AddText('South/North')
        UI:Config(textZ, {
            IDContext = 'awdadwdawdawdawda',
            SameLine  = true
        })



    E.slPosYSlider = E.worldTree:AddSlider('', 0, -1000, 1000, 0.1)
        UI:Config(E.slPosYSlider, {
            IDContext = 'DU',
            Value     = {0, 0, 0, 0},
            OnChange  = function()
                MoveEntity(_GLL.selectedEntity, 'y', E.slPosYSlider.Value[1], E.modPosSlider.Value[1], 'World', 'Light')
                E.slPosYSlider.Value = {0, 0, 0, 0}
            end
        })



    E.btnPosY_D = E.worldTree:AddButton('<')
        UI:Config(E.btnPosY_D, {
            IDContext = ' safj;awffdawoeifmn',
            SameLine  = true,
            OnClick   = function(e)
                MoveEntity(_GLL.selectedEntity, 'y', -100, E.modPosSlider.Value[1], 'World', 'Light')
            end
        })



    E.btnPosY_U = E.worldTree:AddButton('>')
        UI:Config(E.btnPosY_U, {
            IDContext = ' safj;awdffaawdawwdwoeifmn',
            SameLine  = true,
            OnClick   = function(e)
                MoveEntity(_GLL.selectedEntity, 'y', 100, E.modPosSlider.Value[1], 'World', 'Light')
            end
        })



    local textY = E.worldTree:AddText('Down/Up')
        UI:Config(textY, {
            IDContext = 'awdadwdawdawdawda',
            SameLine  = true
        })



    E.slPosXSlider = E.worldTree:AddSlider('', 0, -1000, 1000)
        UI:Config(E.slPosXSlider, {
            IDContext = 'WE',
            Value     = {0, 0, 0, 0},
            OnChange  = function()
                MoveEntity(_GLL.selectedEntity, 'x', E.slPosXSlider.Value[1], E.modPosSlider.Value[1], 'World', 'Light')
                E.slPosXSlider.Value = {0, 0, 0, 0}
            end
        })



    E.btnPosX_W = E.worldTree:AddButton('<')
        UI:Config(E.btnPosX_W, {
            IDContext = ' safj;awdawoeifmn',
            SameLine  = true,
            OnClick   = function(e)
                MoveEntity(_GLL.selectedEntity, 'x', -100, E.modPosSlider.Value[1], 'World', 'Light')
            end
        })



    E.btnPosX_E = E.worldTree:AddButton('>')
        UI:Config(E.btnPosX_E, {
            IDContext = ' safj;awdaawdawwdwoeifmn',
            SameLine  = true,
            OnClick   = function(e)
                MoveEntity(_GLL.selectedEntity, 'x', 100, E.modPosSlider.Value[1], 'World', 'Light')
            end
        })



    local textX = E.worldTree:AddText('West/East')
        UI:Config(textX, {
            IDContext = 'awdawdawda',
            SameLine  = true
        })



    E.worldTree:AddSeparator('')



    E.orbitTree = p:AddCollapsingHeader('Character relative')
    E.orbitTree.DefaultOpen = openByDefaultMainChar




    E.slPosOrbX = E.orbitTree:AddDrag('', 0, 0, 360)
        UI:Config(E.slPosOrbX, {
            WrapAround = true,
            Value     = {0, 0, 0, 0},
            OnChange  = function(e)
                MoveEntity(_GLL.selectedEntity, 'x', e.Value[1], E.modPosSlider.Value[1], 'Orbit', 'Light')
                _GLL.OrbitDragValues[getSelectedUuid()] = {E.slPosOrbX.Value[1], E.slPosOrbY.Value[1], E.slPosOrbZ.Value[1]}
            end
        })



    local textCCW = E.orbitTree:AddText('Ccw/Cw')
        UI:Config(textCCW, { SameLine = true })



    E.slPosOrbY = E.orbitTree:AddDrag('', 0, -30000, 30000)
        UI:Config(E.slPosOrbY, {
            Value     = {200, 0, 0, 0},
            OnChange  = function(e)
                MoveEntity(_GLL.selectedEntity, 'y', e.Value[1], E.modPosSlider.Value[1], 'Orbit', 'Light')
                _GLL.OrbitDragValues[getSelectedUuid()] = {E.slPosOrbX.Value[1], E.slPosOrbY.Value[1], E.slPosOrbZ.Value[1]}
            end
        })



    local textDU = E.orbitTree:AddText('Down/Up')
        UI:Config(textDU, { SameLine = true })



    E.slPosOrbZ = E.orbitTree:AddDrag('', 0, -30000, 30000)
        UI:Config(E.slPosOrbZ, {
            IDContext = 'NawdasdawdS',
            Value     = {200, 0, 0, 0},
            OnChange  = function(e)
                MoveEntity(_GLL.selectedEntity, 'z', e.Value[1], E.modPosSlider.Value[1], 'Orbit', 'Light')
                _GLL.OrbitDragValues[getSelectedUuid()] = {E.slPosOrbX.Value[1], E.slPosOrbY.Value[1], E.slPosOrbZ.Value[1]}
            end
        })



    local textCF = E.orbitTree:AddText('Close/Far')
        UI:Config(textCF, { SameLine = true })



    local treexD = E.orbitTree:AddTree('Grouped')



    _GLL.LightsToInclude = {}



    E.checkGroup = treexD:AddCheckbox('Include selected light to the group')
        UI:Config(E.checkGroup, {
            OnChange = function(e)
                if not _GLL.selectedUuid then return end
                _GLL.LightsToInclude[getSelectedUuid()] = e.Checked
            end
        })



    local function MoveGrouped(axis, value)
        for lightUuid, _ in pairs(_GLL.CreatedLightsServer) do
            if _GLL.LightsToInclude[lightUuid] then
                local lightEntity = Ext.Entity.Get(lightUuid)
                MoveEntity(lightEntity, axis, value, E.modPosSlider.Value[1], 'Orbit', 'Light')
            end
        end
    end



    E.slGroupX = treexD:AddSlider('', 0, -1000, 1000)
        UI:Config(E.slGroupX, {
            OnChange = function(e)
                if not _GLL.selectedUuid then return end
                MoveGrouped('x', e.Value[1])
                e.Value = {0, 0, 0, 0}
            end
        })



    E.btnGropuPosX_CW = treexD:AddButton('<')
        UI:Config(E.btnGropuPosX_CW, {
            SameLine = true,
            OnClick  = function(e)
                MoveGrouped('x', -100)
            end
        })



    E.btnGropuPosX_CCW = treexD:AddButton('>')
        UI:Config(E.btnGropuPosX_CCW, {
            SameLine = true,
            OnClick  = function(e)
                MoveGrouped('x', 100)
            end
        })



    local textCWCCW = treexD:AddText('Cw/Ccw')
        UI:Config(textCWCCW, { SameLine = true })



    E.slGroupZ = treexD:AddSlider('', 0, -1000, 1000)
        UI:Config(E.slGroupZ, {
            OnChange = function(e)
                MoveGrouped('z', e.Value[1])
                e.Value = {0, 0, 0, 0}
            end
        })



    E.btnGropuPosX_Down = treexD:AddButton('<')
        UI:Config(E.btnGropuPosX_Down, {
            SameLine = true,
            OnClick  = function(e)
                MoveGrouped('y', -100)
            end
        })



    E.btnGropuPosX_Up = treexD:AddButton('>')
        UI:Config(E.btnGropuPosX_Up, {
            SameLine = true,
            OnClick  = function(e)
                MoveGrouped('y', 100)
            end
        })



    local textDU = treexD:AddText('Down/Up')
        UI:Config(textDU, { SameLine = true })



    E.slGroupY = treexD:AddSlider('', 0, -1000, 1000, 0.1)
        UI:Config(E.slGroupY, {
            OnChange = function(e)
                MoveGrouped('y', e.Value[1])
                e.Value = {0, 0, 0, 0}
            end
        })



    E.btnGropuPosX_F = treexD:AddButton('<')
        UI:Config(E.btnGropuPosX_F, {
            SameLine = true,
            OnClick  = function(e)
                MoveGrouped('z', -100)
            end
        })



    E.btnGropuPosX_C = treexD:AddButton('>')
        UI:Config(E.btnGropuPosX_C, {
            SameLine = true,
            OnClick  = function(e)
                MoveGrouped('z', 100)
            end
        })


    local textCCF = treexD:AddText('Close/Far')
        UI:Config(textCCF, { SameLine = true })


    E.orbitTree:AddSeparator('')



    E.collapsRot = p:AddCollapsingHeader('Rotation')
    E.collapsRot.DefaultOpen = openByDefaultMainRot



    E.slRotTiltSlider = E.collapsRot:AddSlider('', 0, -1000, 1000, 0.1)
        UI:Config(E.slRotTiltSlider, {
            IDContext    = 'Pitch',
            Value        = {0, 0, 0, 0},
            OnChange     = function(e)
                RotateEntity(_GLL.selectedEntity, 'x', e.Value[1], E.modRotSlider.Value[1], 'Light')
                E.slRotTiltSlider.Value = {0, 0, 0, 0}
            end,
            OnRightClick = function(e)
                RotateEntity(_GLL.selectedEntity, 'x', 90, 1, 'Light')
            end
        })



    E.btnRot_Pp = E.collapsRot:AddButton('<')
        UI:Config(E.btnRot_Pp, {
            IDContext = 'adawdawd',
            SameLine  = true,
            OnClick   = function(e)
                RotateEntity(_GLL.selectedEntity, 'x', -100, E.modRotSlider.Value[1], 'Light')
            end
        })



    E.btnRot_Pm = E.collapsRot:AddButton('>')
        UI:Config(E.btnRot_Pm, {
            IDContext = 'awdawdawd',
            SameLine  = true,
            OnClick   = function(e)
                RotateEntity(_GLL.selectedEntity, 'x', 100, E.modRotSlider.Value[1], 'Light')
            end
        })



    rotTiltReset = E.collapsRot:AddText('Pitch')
        UI:Config(rotTiltReset, {
            IDContext = 'resetPitch',
            SameLine  = true
        })



    E.slRotRollSlider = E.collapsRot:AddSlider('', 0, -1000, 1000, 0.1)
        UI:Config(E.slRotRollSlider, {
            IDContext    = 'roll',
            Disabled     = true,
            Value        = {0, 0, 0, 0},
            OnChange     = function(e)
                RotateEntity(_GLL.selectedEntity, 'z', e.Value[1], E.modRotSlider.Value[1], 'Light')
                E.slRotRollSlider.Value = {0, 0, 0, 0}
            end,
            OnRightClick = function(e)
                RotateEntity(_GLL.selectedEntity, 'z', 90, 1, 'Light')
            end
        })



    E.btnRot_Rp = E.collapsRot:AddButton('<')
        UI:Config(E.btnRot_Rp, {
            IDContext = 'adwdawdawdawd',
            Disabled  = true,
            SameLine  = true,
            OnClick   = function(e)
                RotateEntity(_GLL.selectedEntity, 'z', -100, E.modRotSlider.Value[1], 'Light')
            end
        })



    E.btnRot_Rm = E.collapsRot:AddButton('>')
        UI:Config(E.btnRot_Rm, {
            IDContext = 'awdddddawdawd',
            Disabled  = true,
            SameLine  = true,
            OnClick   = function(e)
                RotateEntity(_GLL.selectedEntity, 'z', 100, E.modRotSlider.Value[1], 'Light')
            end
        })



    rotRollReset = E.collapsRot:AddText('Roll')
        UI:Config(rotRollReset, {
            IDContext = 'resetROll',
            SameLine  = true
        })



    E.slRotYawSlider = E.collapsRot:AddSlider('', 0, -1000, 1000, 0.1)
        UI:Config(E.slRotYawSlider, {
            IDContext    = 'yaw',
            Value        = {0, 0, 0, 0},
            OnChange     = function(e)
                RotateEntity(_GLL.selectedEntity, 'y', e.Value[1], E.modRotSlider.Value[1], 'Light')
                E.slRotYawSlider.Value = {0, 0, 0, 0}
            end,
            OnRightClick = function(e)
                RotateEntity(_GLL.selectedEntity, 'y', 90, 1, 'Light')
            end
        })



    E.btnRot_Yp = E.collapsRot:AddButton('<')
        UI:Config(E.btnRot_Yp, {
            IDContext = 'adwdawddddawdawd',
            SameLine  = true,
            OnClick   = function(e)
                RotateEntity(_GLL.selectedEntity, 'y', -100, E.modRotSlider.Value[1], 'Light')
            end
        })



    E.btnRot_Ym = E.collapsRot:AddButton('>')
        UI:Config(E.btnRot_Ym, {
            IDContext = 'awdddddddddawdawd',
            SameLine  = true,
            OnClick   = function(e)
                RotateEntity(_GLL.selectedEntity, 'y', 100, E.modRotSlider.Value[1], 'Light')
            end
        })



    rotYawReset = E.collapsRot:AddText('Yaw')
        UI:Config(rotYawReset, {
            IDContext = 'resetYaw',
            SameLine  = true
        })



    E.collapsRot:AddSeparator('')

    textPositionInfo = p:AddText('')
    textPositionInfo.Label = string.format('x: %.2f, y: %.2f, z: %.2f', 0, 0, 0)



    textRotationInfo = p:AddText('')
    textRotationInfo.Label = string.format('pitch: %.2f, roll: %.2f, yaw: %.2f', 0, 0, 0)



    ---------------------------------------------------------
    p:AddSeparatorText([[Position source]])
    ---------------------------------------------------------



    E.checkOriginSrc = p:AddCheckbox('Origin point')
        UI:Config(E.checkOriginSrc, {
            Disabled = false,
            OnChange = function(e)
                SourcePoint(e.Checked)
            end
        })



    E.checkCutsceneSrc = p:AddCheckbox('Cutscene')
        UI:Config(E.checkCutsceneSrc, {
            SameLine = true,
            Disabled = false,
            OnChange = function(e)
                SourceCutscene(e.Checked)
            end
        })



    E.checkPMSrc = p:AddCheckbox('PhotoMode')
        UI:Config(E.checkPMSrc, {
            SameLine = true,
            Disabled = false,
            OnChange = function(e)
                SourcePhotoMode(e.Checked)
            end
        })



    E.checkClientSrc = p:AddCheckbox('Client-side')
        UI:Config(E.checkClientSrc, {
            SameLine = true,
            Disabled = false,
            OnChange = function(e)
                SourceClient(e.Checked)
            end
        })



    ---------------------------------------------------------
    p:AddSeparatorText('Slider settings')
    ---------------------------------------------------------

    local modPosDefault = 8000
    local modPos        = 50000
    local modRot        = 5000
    local modRotDefault = 1000

    E.modPosSlider = p:AddSlider('', modPosDefault, 0.1, modPos, 0)
        UI:Config(E.modPosSlider, {
            IDContext   = 'ModID',
            Value       = {modPosDefault, 0, 0, 0},
            Logarithmic = true
        })



    E.modPosReset = p:AddButton('How fast pos sliders')
        UI:Config(E.modPosReset, {
            IDContext = 'MOdd',
            SameLine  = true,
            OnClick   = function()
                E.modPosSlider.Value = {modPosDefault, 0, 0, 0}
            end
        })



    E.modRotSlider = p:AddSlider('', modRotDefault, 0.1, modRot, 0)
        UI:Config(E.modRotSlider, {
            IDContext   = 'RotMiodID',
            Value       = {modRotDefault, 0, 0, 0},
            Logarithmic = true
        })



    E.modRotReset = p:AddButton('How fast rot sliders')
        UI:Config(E.modRotReset, {
            IDContext = 'MOddRot',
            SameLine  = true,
            OnClick   = function()
                E.modRotSlider.Value = {modRotDefault, 0, 0, 0}
            end
        })
end



MCM.InsertModMenuTab('Lighty Lights', LLMCM, ModuleUUID)



Ext.RegisterConsoleCommand('lld', function (cmd, ...)
    DPrint('LightParametersClient-----------------------------')
    DDump(_GLL.LightParametersClient)
end)



Ext.RegisterConsoleCommand('lldg', function (cmd, ...)
    DPrint('Globals-----------------------------')
    DDump(LLGlobals)
end)



Ext.RegisterConsoleCommand('lldumpall', function (cmd, ...)
    DPrint('CreatedLightsServer ------------------------------')
    DDump(_GLL.CreatedLightsServer)
    DPrint('LightsUuidNameMap --------------------------------')
    DDump(_GLL.LightsUuidNameMap)
    DPrint('LightsNames --------------------------------------')
    DDump(_GLL.LightsNames)
    DPrint('LightParametersClient ----------------------------')
    DDump(_GLL.LightParametersClient)
    DPrint('selectedUuid -------------------------------------')
    DDump(_GLL.selectedUuid)
    DPrint('selectedEntity -----------------------------------')
    DDump(_GLL.selectedEntity)
    DPrint('markerUuid ---------------------------------------')
    DDump(_GLL.markerUuid)
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


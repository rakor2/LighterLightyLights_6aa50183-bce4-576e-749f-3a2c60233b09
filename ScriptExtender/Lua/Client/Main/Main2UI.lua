
--[[


Is it possible to have the new implemented square colour open/close (which most people will likely prefer) and something more like what we have in the current version of LL? It's annoying to have to keep clicking (or a keybind to open it would be great in lieu of a open/closable colour selection).


]]




LLGlobals.CreatedLightsClient = {} --UNUSED


LLGlobals.LightsUuidNameMap = {}
LLGlobals.LightsNames = {}
LLGlobals.LightParametersClient = {}


LLGlobals.States = {}
LLGlobals.States.allowLightCreation = {}


---@class Settings
Settings = Settings or {}
-- Settings.checkPrePlaced = Settings.checkPrePlaced or nil


---@type string EntityUuid
LLGlobals.selectedUuid = nil

---@type EntityHandle 
LLGlobals.selectedEntity = nil

---@type LightComponent
LLGlobals.selectedLightEntity = nil



MARKER_SCALE = 0.699999988079071



nameIndex = 0



-- local checkPrePlaced
-- local textPrePlacedNote



LLGlobals.syncedSelectedIndex = 0
E = {
    slIntLightType,
    pickerLightColor,
    slLightIntensity,
    slLightTemp,
    slLightRadius,
    slLightOuterAngle,
    slLightInnerAngle,
    checkLightFill,
    slLightScattering,
    slLightEdgeSharp,
}

ER = {
    btnLightIntensityReset,
    btnLightTempReset,
    btnLightRadiusReset,
    btnLightOuterReset,
    btnLightInnerReset,
    btnLightScatterReset,
    btnLightSharpReset,
}





function MainTab(p)

    --local btn = p:AddButton('xddd')
    

    local rngMax = #QOTD
    p:AddSeparatorText(QOTD[Ext.Math.Random(1, rngMax)])
    -- 

    checkTypePoint = p:AddCheckbox('Point')
    checkTypePoint.Checked = defaultLightType == 'Point'
    checkTypePoint.OnChange = function ()

        lightType = 'Point' -- 0

        checkTypeSpot.Checked = false
        checkTypeDir.Checked = false

    end
    
    
    checkTypeSpot = p:AddCheckbox('Spotlight')
    checkTypeSpot.Checked = defaultLightType == 'Spotlight'
    checkTypeSpot.SameLine = true
    checkTypeSpot.OnChange = function ()

        lightType = 'Spotlight' -- 1

        checkTypePoint.Checked = false
        checkTypeDir.Checked = false
        
    end
    

    checkTypeDir = p:AddCheckbox('Directional')
    checkTypeDir.Checked = defaultLightType == 'Directional'
    checkTypeDir.SameLine = true
    checkTypeDir.OnChange = function ()

        lightType = 'Directional' -- 3

        checkTypePoint.Checked = false
        checkTypeSpot.Checked = false
    
    end

    
    
    btnCreate2 = p:AddButton('Create')
    btnCreate2.SameLine = true
    btnCreate2.OnClick = function ()
        CreateLight()
    end



    comboIHateCombos = p:AddCombo('')
    comboIHateCombos.Options = LLGlobals.LightsNames
    comboIHateCombos.SelectedIndex = LLGlobals.syncedSelectedIndex
    comboIHateCombos.OnChange = function (e)
        LLGlobals.syncedSelectedIndex = comboIHateCombos.SelectedIndex
        comboIHateCombos2.SelectedIndex = LLGlobals.syncedSelectedIndex
        SelectLight()
    end



    --- for keybind
    function prevOptionBtn()
        local element = comboIHateCombos
        if element.SelectedIndex < 1 then
            element.SelectedIndex = #element.Options - 1
        else
            element.SelectedIndex = element.SelectedIndex - 1
        end
        LLGlobals.syncedSelectedIndex = element.SelectedIndex
        comboIHateCombos2.SelectedIndex = LLGlobals.syncedSelectedIndex
        SelectLight()
    end



    local btnOptionsPrev = p:AddButton('<')
    btnOptionsPrev.IDContext = 'adawd'
    btnOptionsPrev.SameLine = true
    btnOptionsPrev.OnClick = function (e)
        if not LLGlobals.selectedUuid then return end
        prevOptionBtn()
    end
        
    

    --- for keybind
    function nextOptionBtn()
        local element = comboIHateCombos
        if element.SelectedIndex > #element.Options - 2 then
            element.SelectedIndex = 0
        else
            element.SelectedIndex = element.SelectedIndex + 1
        end
        LLGlobals.syncedSelectedIndex = element.SelectedIndex
        comboIHateCombos2.SelectedIndex = LLGlobals.syncedSelectedIndex
        SelectLight()
    end


    local btnOptionsNext = p:AddButton('>')
    btnOptionsNext.IDContext = 'adadwwd'
    btnOptionsNext.SameLine = true
    btnOptionsNext.OnClick = function (e)
        if not LLGlobals.selectedUuid then return end
        nextOptionBtn()
    end




    
    local txtCreateLight = p:AddText('Created lights')
    txtCreateLight.SameLine = true

    

    inputRename = p:AddInputText('')
    inputRename.IDContext = 'adawdawdawdawd'
    inputRename.Disabled = false
    inputRename.OnChange = function ()
        
    end


    local btnRenameLight = p:AddButton('Rename')
    btnRenameLight.SameLine = true
    btnRenameLight.Disabled = false
    btnRenameLight.OnClick = function ()
        if not LLGlobals.selectedUuid then return end
        local lightEntity = getSelectedLightEntity()

        
        for k, light in pairs(LLGlobals.LightsUuidNameMap) do
            if light.name == comboIHateCombos.Options[comboIHateCombos.SelectedIndex + 1] then
                local index = light.nameIndex
                --- TBD: temporary
                local type = getSelectedLightType()
                if lightEntity.LightChannelFlag == 255 then
                    light.name = '+' .. ' ' ..  '#' .. index .. ' ' .. type .. ' ' .. inputRename.Text
                else
                    lightEntity.LightChannelFlag = 0
                    light.name = '-' .. ' ' ..  '#' .. index .. ' ' .. type .. ' ' .. inputRename.Text
                end

            end
        end

        inputRename.Text = ''

        UpdateCreatedLightsCombo()

    end





local btnDelete = p:AddButton('Delete')
btnDelete.OnClick = function()

    if not LLGlobals.selectedUuid then return end

    local uuidToDelete = LLGlobals.selectedUuid
    local selectedName = getSelectedLightName()

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

    comboIHateCombos.SelectedIndex = comboIHateCombos.SelectedIndex - 1
    if comboIHateCombos.SelectedIndex < 0 then
        comboIHateCombos.SelectedIndex = 0
    end

    if comboIHateCombos.Options and #comboIHateCombos.Options > 0 then
        local uuid = getSelectedUuid()
        if uuid then
            SelectLight()
        else
            LLGlobals.selectedUuid = nil
            LLGlobals.selectedEntity = nil
        end
    else
        LLGlobals.selectedUuid = nil
        LLGlobals.selectedEntity = nil
        nameIndex = 0
        UpdateTranformInfo(0, 0, 0, 0, 0, 0)
    end
    
    -- DDump(LLGlobals.LightsUuidNameMap)


    Channels.DeleteLight:SendToServer(uuidToDelete)

    Channels.SelectedLight:SendToServer(LLGlobals.selectedUuid)
    
end





    local btnDeleteAll = p:AddButton('Delete all')
    btnDeleteAll.SameLine = true
    btnDeleteAll.OnClick = function ()

        btnDeleteAll.Visible = false
        btnConfirmDeleteAll.Visible = true
        
        confirmTimer = Ext.Timer.WaitFor(1000, function()
            btnConfirmDeleteAll.Visible = false
            btnDeleteAll.Visible = true
        end)
    end

    
    btnConfirmDeleteAll = p:AddButton('Confirm')
    btnConfirmDeleteAll.Visible = false
    btnConfirmDeleteAll.SameLine = true
    Style.buttonConfirm.default(btnConfirmDeleteAll)
    btnConfirmDeleteAll.OnClick = function ()
        
        checkStick.Checked = false

        Channels.DeleteLight:SendToServer('All')

        LLGlobals.CreatedLightsServer = {}
        LLGlobals.LightsUuidNameMap = {}
        LLGlobals.LightsNames = {}
        LLGlobals.LightParametersClient = {}
        LLGlobals.selectedUuid = nil
        LLGlobals.selectedEntity = nil
        LLGlobals.markerUuid = {}
        nameIndex = 0
        
        Channels.CurrentEntityTransform:SendToServer(nil)

        UpdateCreatedLightsCombo()
        UpdateTranformInfo(0, 0, 0, 0, 0, 0)
        textFunc.Label = 'Attenuation'

        GatherLightsAndMarkers()

        Ext.Timer.Cancel(confirmTimer)
        
        btnDeleteAll.Visible = true
        btnConfirmDeleteAll.Visible = false

    end

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
    


    
    local btnDuplicate = p:AddButton('Duplicate')
    btnDuplicate.SameLine = true
    btnDuplicate.Disabled = false
    btnDuplicate.OnClick = function ()
        if not LLGlobals.selectedUuid then return end
        DuplicateLight()
    end
    

    checkSelectedLightNotification = p:AddCheckbox('Selected light popup')
    checkSelectedLightNotification.SameLine = true
    checkSelectedLightNotification.OnChange = function (e)
        windowNotification.Visible = checkSelectedLightNotification.Checked
    end


    
    ---------------------------------------------------------
    p:AddSeparatorText('Parameters')
    ---------------------------------------------------------
    



    -- textLightVisibility = p:AddText('No light selected ')

    --- for keybind
    function toggleLightBtn()
        local lightEntity = getSelectedLightEntity()
        local selectedUuid = getSelectedUuid()

        if lightEntity then

            local flag = lightEntity.LightChannelFlag ~= 0
            local flag2 = not flag

            local scattering = lightEntity.ScatteringIntensityScale ~= 0
            scattering2 = not scattering


            if flag2 then
                lightEntity.LightChannelFlag = 255
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
            -- LightVisibilty()
        end
    end


    local toggleLightButton = p:AddButton('Toggle light')
    toggleLightButton.IDContext = 'awdaw'
    toggleLightButton.OnClick = function()
        if not LLGlobals.selectedUuid then return end
        toggleLightBtn()
    end

    -- local LightChannelFlagCount = 0 
    -- local LightChannelFlagCount = -1
    -- local btnLightChanneg = p:AddButton('LightChannel')
    -- btnLightChanneg.OnClick = function ()
    --     local lightEntity = getSelectedLightEntity()
    --     DPrint(LightChannelFlagCount)
    --     lightEntity.LightChannelFlag = LightChannelFlagCount
    --     LightChannelFlagCount = LightChannelFlagCount + 8
    -- end

    
    function toggleAllLightsBtn()
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then

            all = not all
            
            for _, uuid in pairs(LLGlobals.CreatedLightsServer) do
                local lightEntity = getLightEntity(uuid)

                if all then
                    lightEntity.LightChannelFlag = 0
                    lightEntity.ScatteringIntensityScale = 0
                else
                    lightEntity.LightChannelFlag = 255
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
    local toggleLightsButton = p:AddButton('Toggle all')
    toggleLightsButton.IDContext = 'awdfdgdfg'
    toggleLightsButton.SameLine = true
    toggleLightsButton.OnClick = function()
        if not LLGlobals.selectedUuid then return end

        toggleAllLightsBtn()
    end


    local toggleMarkerButton = p:AddButton('Toggle marker')
    toggleMarkerButton.SameLine = true
    toggleMarkerButton.IDContext = 'jhjkgyyutr'
    toggleMarkerButton.OnClick = function()
        
        ToggleMarker(LLGlobals.markerUuid)

    end

    local toggleAllMarkersButton = p:AddButton('Toggle all')
    toggleAllMarkersButton.SameLine = true
    toggleAllMarkersButton.IDContext = '456456'
    toggleAllMarkersButton.SameLine = true
    toggleAllMarkersButton.OnClick = function()
        
        Channels.MarkerHandler:RequestToServer({}, function (Response)
        end)

    end



    local btnMazzleBeam = p:AddButton('Mazzle beam')
    btnMazzleBeam.SameLine = true
    btnMazzleBeam.OnClick = function ()
        if not LLGlobals.selectedUuid then return end

        Channels.MazzleBeam:SendToServer({})
    end


    local collapseParameters = p:AddCollapsingHeader('Main parameters')
    collapseParameters.DefaultOpen = true
    local gp = collapseParameters:AddGroup('Parameters1')
    
    
    local treeGen = gp:AddTree('General')
    treeGen.DefaultOpen = openByDefaultMainGen





    
    -- TYPE

    


    
    E.slIntLightType = treeGen:AddSliderInt('Type', 0,0,2,1)
    E.slIntLightType.OnChange = function (e)

        


        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then 
            SetLightType(e.Value[1])
            
            
            -- TBD: temporary
            local selectedName = getSelectedLightName()
            if selectedName and (selectedName:find('Point') or selectedName:find('Spotlight') or selectedName:find('Directional')) then
                if e.Value[1] == 0 then localLightType = 'Point' end
                if e.Value[1] == 1 then localLightType = 'Spotlight' end
                if e.Value[1] == 2 then localLightType = 'Directional' end
                
                local lightEntity = getSelectedLightEntity()

                if not lightEntity then return end
                
                if lightEntity.LightChannelFlag == 255 then
                    local newName = LLGlobals.LightsUuidNameMap[comboIHateCombos.SelectedIndex + 1].name
                    newName = newName:gsub('Point', localLightType):gsub('Spotlight', localLightType):gsub('Directional', localLightType)
                    LLGlobals.LightsUuidNameMap[comboIHateCombos.SelectedIndex + 1].name = newName
                else
                    lightEntity.LightChannelFlag = 0
                    local newName = LLGlobals.LightsUuidNameMap[comboIHateCombos.SelectedIndex + 1].name
                    newName = newName:gsub('Point', localLightType):gsub('Spotlight', localLightType):gsub('Directional', localLightType)
                    LLGlobals.LightsUuidNameMap[comboIHateCombos.SelectedIndex + 1].name = newName
                end

                UpdateCreatedLightsCombo()

            end
        end
    end
    





    -- COLOR





    if biggerPicker then
        E.pickerLightColor = treeGen:AddColorPicker('xd')
    else
        E.pickerLightColor = treeGen:AddColorEdit('Color (click me)')
    end

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

    

    
    
    E.slLightIntensity = treeGen:AddSlider('', 1, 0, 60, 1)
    E.slLightIntensity.IDContext = 'lkjanerfliuaern'
    E.slLightIntensity.Logarithmic = true
    E.slLightIntensity.OnChange = function (e)
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then 
            SetLightIntensity(e.Value[1])
        end
    end
    
    
    ER.btnLightIntensityReset = treeGen:AddButton('Power')
    ER.btnLightIntensityReset.SameLine = true
    ER.btnLightIntensityReset.OnClick = function ()
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then 
            E.slLightIntensity.Value = {1, 0, 0, 0}
            SetLightIntensity(E.slLightIntensity.Value[1])
        end
    end
    
    



    
    -- TEMPERATURE
    
    
    



    E.slLightTemp = treeGen:AddSlider('', 5600, 1000, 40000, 1)
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
    
    
    ER.btnLightTempReset = treeGen:AddButton('Temperature')
    ER.btnLightTempReset.SameLine = true
    ER.btnLightTempReset.OnClick = function ()
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then 
            E.slLightTemp.Value = {5600, 0, 0, 0}
            LLGlobals.LightParametersClient[LLGlobals.selectedUuid].Temperature = 5600
            SetLightColor({1,0.93,0.88})
        end
    end
    



    
    
    -- RADIUS
    
    


    

    E.slLightRadius = treeGen:AddSlider('', 1, 0, 60, 1)
    E.slLightRadius.IDContext = 'adwadqw3d'
    E.slLightRadius.Logarithmic = true
    E.slLightRadius.OnChange = function (e)
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then 
            SetLightRadius(e.Value[1])
        end
    end
    
    
    ER.btnLightRadiusReset = treeGen:AddButton('Distance')
    ER.btnLightRadiusReset.SameLine = true
    ER.btnLightRadiusReset.OnClick = function ()
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then 
            E.slLightRadius.Value = {1, 0, 0, 0}
            SetLightRadius(E.slLightRadius.Value[1])
        end
    end

    
    
    E.slLightScattering = treeGen:AddSlider('', 0, 0, 100, 1)
    E.slLightScattering.IDContext = 'esrgsrengsrg'
    E.slLightScattering.Logarithmic = true
    E.slLightScattering.OnChange = function (e)
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then 
            SetLightScattering(e.Value[1])
        end
    end
    
    
    ER.btnLightScatterReset = treeGen:AddButton('Scattering')
    ER.btnLightScatterReset.SameLine = true
    ER.btnLightScatterReset.OnClick = function ()
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then 
            E.slLightScattering.Value = {0, 0, 0, 0}
            SetLightScattering(E.slLightScattering.Value[1])
        end
    end
    
    E.checkLightFill = treeGen:AddCheckbox('Scattering fill-light')
    E.checkLightFill.Checked = true
    E.checkLightFill.OnChange = function ()
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then 
            SetLightFill(E.checkLightFill.Checked and 184 or 56)
        end
    end
    
    
    treeGen:AddSeparator('')



    local treePoint = gp:AddTree('Point')
    treePoint.IDContext = 'soawdawddkfn' 
    treePoint.DefaultOpen = openByDefaultMainPoint


    
    function SetLightEdgeSharp(value)
        local lightEntity = getSelectedLightEntity()
        if lightEntity and value then
            lightEntity.EdgeSharpening = value
            LLGlobals.LightParametersClient[LLGlobals.selectedUuid].EdgeSharpening = value
        end
    end


    E.slLightEdgeSharp = treePoint:AddSlider('', 0, 0, 1, 1)
    E.slLightEdgeSharp.IDContext = 'sdfwerw34'
    E.slLightEdgeSharp.Logarithmic = false
    E.slLightEdgeSharp.OnChange = function (e)
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then 
            SetLightEdgeSharp(e.Value[1])
        end
    end
    

    
    ER.btnLightSharpReset = treePoint:AddButton('Sharpening')
    ER.btnLightSharpReset.SameLine = true
    ER.btnLightSharpReset.OnClick = function ()
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then 
            E.slLightEdgeSharp.Value = {0, 0, 0, 0}
            SetLightEdgeSharp(E.slLightEdgeSharp.Value[1])
        end
    end
    
    
    -- OUTER ANGLE


    local treeSpot = gp:AddTree('Spotlight')
    treeSpot.IDContext = 'sodkfn'
    treeSpot.DefaultOpen = openByDefaultMainSpot



    E.slLightOuterAngle = treeSpot:AddSlider('', 45, 0, 179, 1)
    E.slLightOuterAngle.IDContext = '123dwfsefa'
    E.slLightOuterAngle.OnChange = function (e)
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then 
            SetLightOuterAngle(e.Value[1])
        end
        
    end
    
    
    ER.btnLightOuterReset = treeSpot:AddButton('Outer angle')
    ER.btnLightOuterReset.SameLine = true
    ER.btnLightOuterReset.OnClick = function ()
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then 
            E.slLightOuterAngle.Value = {45, 0, 0, 0}
            SetLightOuterAngle(E.slLightOuterAngle.Value[1])
        end
    end






    -- INNER ANGLE



    
    
    
    E.slLightInnerAngle = treeSpot:AddSlider('', 1, 0, 179, 1)
    E.slLightInnerAngle.IDContext = 'rfgrtynj5r6'
    E.slLightInnerAngle.OnChange = function (e)
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then 
            SetLightInnerAngle(e.Value[1])
        end
    end
    
    
    ER.btnLightInnerReset = treeSpot:AddButton('Inner angle')
    ER.btnLightInnerReset.SameLine = true
    ER.btnLightInnerReset.OnClick = function ()
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then 
            E.slLightInnerAngle.Value = {1, 0, 0, 0}
            SetLightInnerAngle(E.slLightInnerAngle.Value[1])
        end
    end
    




    treeSpot:AddSeparator('')

    local sepaTreeDir
    local spepaPreAdd
    local treeDir = gp:AddTree('Directional')
    treeDir.IDContext = 'sodsdfkfn'
    treeDir.DefaultOpen = openByDefaultMainDir

    
    
    
    E.slLightDirEnd = treeDir:AddSlider('Falloff front', 0, 0, 20, 1)
    E.slLightDirEnd.IDContext = 'olkjsdeafoiuzsrenbf'
    E.slLightDirEnd.OnChange = function (e)
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then 
            SetLightDirectionalParameters('DirectionLightAttenuationEnd', e.Value[1])
        end
    end

    
    
    E.slLightDirSide = treeDir:AddSlider('Falloff back', 0, 0, 20, 1)
    E.slLightDirSide.IDContext = 'o12312'
    E.slLightDirSide.OnChange = function (e)
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then 
            SetLightDirectionalParameters('DirectionLightAttenuationSide', e.Value[1])
        end
    end
    
    
    E.slLightDirSide2 = treeDir:AddSlider('Falloff sides', 0, 0, 10, 1)
    E.slLightDirSide2.IDContext = 'asdaw'
    E.slLightDirSide2.OnChange = function (e)
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then 
            SetLightDirectionalParameters('DirectionLightAttenuationSide2', e.Value[1])
        end
    end
    

    E.slIntLightDirFunc = treeDir:AddSliderInt('', 0, 0, 3, 1)
    E.slIntLightDirFunc.IDContext = 'olkjsdsseafoiuzsrenbf'
    E.slIntLightDirFunc.OnChange = function (e)
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then
            SetLightDirectionalParameters('DirectionLightAttenuationFunction', e.Value[1])
        end
    end


    textFunc = treeDir:AddText('Attenuation')
    textFunc.SameLine = true
        

    E.slLightDirDim = treeDir:AddSlider('Wid/Hei/Len', 0, 0, 100, 1)
    E.slLightDirDim.IDContext = 'lkasenfaolkejfn'
    E.slLightDirDim.Components = 3
    E.slLightDirDim.Logarithmic = true
    E.slLightDirDim.OnChange = function (e)
        if LLGlobals.selectedUuid and LLGlobals.LightParametersClient[LLGlobals.selectedUuid] then 
            SetLightDirectionalParameters('DirectionLightDimensions', {e.Value[1], e.Value[2],e.Value[3]})
        end
    end

    

    -- collapseParameters:AddSeparator('')



    -- local collapseAddParameters = p:AddCollapsingHeader('Additional parameters')
    -- collapseAddParameters.DefaultOpen = openByDefaultMainAdd


    -- local gap = collapseAddParameters:AddGroup('AddParameters')







    -- FILL
    
    -- 1 Render shadows



    

    



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




    checkStick = p:AddCheckbox('Stick to camera')
    checkStick.OnChange = function (e)
        if not LLGlobals.selectedUuid then e.Checked = false return end

        stickToCameraCheck()
    end
    

    
    
    local worldTree = p:AddCollapsingHeader('World relative')
    worldTree.DefaultOpen = openByDefaultMainWorld




    local slPosZSlider = worldTree:AddSlider('', 0, -1000, 1000, 0.1)
    slPosZSlider.IDContext = 'NS'
    slPosZSlider.Value = {0,0,0,0}
    slPosZSlider.OnChange = function()
        MoveEntity(LLGlobals.selectedEntity, 'z', slPosZSlider.Value[1], modPosSlider.Value[1], 'World', 'Light')
        slPosZSlider.Value = {0,0,0,0}
    end
    


    
    local btnPosZ_S = worldTree:AddButton('<')
    btnPosZ_S.IDContext = ' safj;woeifmn'     
    btnPosZ_S.SameLine = true
    btnPosZ_S.OnClick = function (e)
        MoveEntity(LLGlobals.selectedEntity, 'z', -100, modPosSlider.Value[1], 'World', 'Light')
    end



    
    local btnPosZ_N = worldTree:AddButton('>')
    btnPosZ_N.IDContext = ' safj;awdawdwoeifmn'
    btnPosZ_N.SameLine = true
    btnPosZ_N.OnClick = function (e)
        MoveEntity(LLGlobals.selectedEntity, 'z', 100, modPosSlider.Value[1], 'World', 'Light')
    end



    local textZ = worldTree:AddText('South/North')
    textZ.IDContext = 'awdadwdawdawdawda'
    textZ.SameLine = true



    local slPosYSlider = worldTree:AddSlider('', 0, -1000, 1000, 0.1)
    slPosYSlider.IDContext = 'DU'
    slPosYSlider.Value = {0,0,0,0}
    slPosYSlider.OnChange = function()
        MoveEntity(LLGlobals.selectedEntity, 'y', slPosYSlider.Value[1], modPosSlider.Value[1], 'World', 'Light')
        slPosYSlider.Value = {0,0,0,0}
    end



    
    local btnPosY_D = worldTree:AddButton('<')
    btnPosY_D.IDContext = ' safj;awffdawoeifmn'     
    btnPosY_D.SameLine = true
    btnPosY_D.OnClick = function (e)
        MoveEntity(LLGlobals.selectedEntity, 'y', -100, modPosSlider.Value[1], 'World', 'Light')
    end
    


    local btnPosY_U = worldTree:AddButton('>')
    btnPosY_U.IDContext = ' safj;awdffaawdawwdwoeifmn'
    btnPosY_U.SameLine = true
    btnPosY_U.OnClick = function (e)
        MoveEntity(LLGlobals.selectedEntity, 'y', 100, modPosSlider.Value[1], 'World', 'Light')
    end



    local textY = worldTree:AddText('Down/Up')
    textY.IDContext = 'awdadwdawdawdawda'
    textY.SameLine = true



    local slPosXSlider = worldTree:AddSlider('', 0, -1000, 1000, 0)
    slPosXSlider.IDContext = 'WE'
    slPosXSlider.Value = {0,0,0,0}
    slPosXSlider.OnChange = function()
        MoveEntity(LLGlobals.selectedEntity, 'x', slPosXSlider.Value[1], modPosSlider.Value[1], 'World', 'Light')
        slPosXSlider.Value = {0,0,0,0}
    end


    
    local btnPosX_W = worldTree:AddButton('<')
    btnPosX_W.IDContext = ' safj;awdawoeifmn'     
    btnPosX_W.SameLine = true
    btnPosX_W.OnClick = function (e)
        MoveEntity(LLGlobals.selectedEntity, 'x', -100, modPosSlider.Value[1], 'World', 'Light')
    end
    


    local btnPosX_E = worldTree:AddButton('>')
    btnPosX_E.IDContext = ' safj;awdaawdawwdwoeifmn'
    btnPosX_E.SameLine = true
    btnPosX_E.OnClick = function (e)
        MoveEntity(LLGlobals.selectedEntity, 'x', 100, modPosSlider.Value[1], 'World', 'Light')
    end




    local textX = worldTree:AddText('West/East')
    textX.IDContext = 'awdawdawda'
    textX.SameLine = true





    worldTree:AddSeparator('')
    
    
    
    
    local orbitTree = p:AddCollapsingHeader('Character relative')
    orbitTree.DefaultOpen = openByDefaultMainChar
    
    
    
    local slPosOrbX = orbitTree:AddSlider('', 0, -1000, 1000, 0.1)
    slPosOrbX.IDContext = 'NawdawwwdS'
    slPosOrbX.Value = {0,0,0,0}
    slPosOrbX.OnChange = function()
        MoveEntity(LLGlobals.selectedEntity, 'x', slPosOrbX.Value[1], modPosSlider.Value[1], 'Orbit', 'Light')
        slPosOrbX.Value = {0,0,0,0}
    end
    


    local btnPosX_CW = orbitTree:AddButton('<')
    btnPosX_CW.IDContext = ' safj;awffdahwoeifmn'     
    btnPosX_CW.SameLine = true
    btnPosX_CW.OnClick = function (e)
        MoveEntity(LLGlobals.selectedEntity, 'x', -100, modPosSlider.Value[1], 'Orbit', 'Light')
    end
    


    local btnPosX_CCW = orbitTree:AddButton('>')
    btnPosX_CCW.IDContext = ' safj;awdffaawdqawwdwoeifmn'
    btnPosX_CCW.SameLine = true
    btnPosX_CCW.OnClick = function (e)
        MoveEntity(LLGlobals.selectedEntity, 'x', 100, modPosSlider.Value[1], 'Orbit', 'Light')
    end
    


    local textCCW = orbitTree:AddText('Cw/Ccw')
    textCCW.SameLine = true
    
    
    
    
    
    
    local slPosOrbY = orbitTree:AddSlider('', 0, -1000, 1000, 0.1)
    slPosOrbY.IDContext = 'NawawdwdawdS'
    slPosOrbY.Value = {0,0,0,0}
    slPosOrbY.OnChange = function()
        MoveEntity(LLGlobals.selectedEntity, 'y', slPosOrbY.Value[1], modPosSlider.Value[1], 'Orbit', 'Light')
        slPosOrbY.Value = {0,0,0,0}
    end
    

    
    local btnPosY_D2 = orbitTree:AddButton('<')
    btnPosY_D2.IDContext = ' safj;awffdqeawwoeifmn'     
    btnPosY_D2.SameLine = true
    btnPosY_D2.OnClick = function (e)
        MoveEntity(LLGlobals.selectedEntity, 'y', -100, modPosSlider.Value[1], 'Orbit', 'Light')
    end
    
    
    
    local btnPosY_U2 = orbitTree:AddButton('>')
    btnPosY_U2.IDContext = ' safj;awdfefawqawdawwdwoeifmn'
    btnPosY_U2.SameLine = true
    btnPosY_U2.OnClick = function (e)
        MoveEntity(LLGlobals.selectedEntity, 'y', 100, modPosSlider.Value[1], 'Orbit', 'Light')
    end
    
    
    local textDU = orbitTree:AddText('Down/Up')
    textDU.SameLine = true
    

    
    
    local slPosOrbZ = orbitTree:AddSlider('', 0, -1000, 1000, 0.1)
    slPosOrbZ.IDContext = 'NawdasdawdS'
    slPosOrbZ.Value = {0,0,0,0}
    slPosOrbZ.OnChange = function()
        MoveEntity(LLGlobals.selectedEntity, 'z', slPosOrbZ.Value[1], modPosSlider.Value[1], 'Orbit', 'Light')
        slPosOrbZ.Value = {0,0,0,0}
    end

    
    
    local btnPosZ_C = orbitTree:AddButton('<')
    btnPosZ_C.IDContext = ' safj;awffdawwoeifmn'     
    btnPosZ_C.SameLine = true
    btnPosZ_C.OnClick = function (e)
        MoveEntity(LLGlobals.selectedEntity, 'z', -100, modPosSlider.Value[1], 'Orbit', 'Light')
    end
    
    
    
    local btnPosZ_F = orbitTree:AddButton('>')
    btnPosZ_F.IDContext = ' safj;awdfefaawdawwdwoeifmn'
    btnPosZ_F.SameLine = true
    btnPosZ_F.OnClick = function (e)
        MoveEntity(LLGlobals.selectedEntity, 'z', 100, modPosSlider.Value[1], 'Orbit', 'Light')
    end
    
    
    local textCF = orbitTree:AddText('Close/Far')
    textCF.SameLine = true
    
    
    orbitTree:AddSeparator('')




    local collapsRot = p:AddCollapsingHeader('Rotation')
    collapsRot.DefaultOpen = openByDefaultMainRot
    
    
    
    local slRotTiltSlider = collapsRot:AddSlider('', 0, -1000, 1000, 0.1)
    slRotTiltSlider.IDContext = 'Pitch'
    slRotTiltSlider.Value = {0,0,0,0}
    slRotTiltSlider.OnChange = function(e)
        RotateEntity(LLGlobals.selectedEntity, 'x', e.Value[1], modRotSlider.Value[1], 'Light')
        slRotTiltSlider.Value = {0,0,0,0}
    end
    slRotTiltSlider.OnRightClick = function (e)
        RotateEntity(LLGlobals.selectedEntity, 'x', 90, 1, 'Light')
    end

    local btnRot_Pp = collapsRot:AddButton('<')
    btnRot_Pp.IDContext = 'adawdawd'
    btnRot_Pp.SameLine = true
    btnRot_Pp.OnClick = function (e)
        RotateEntity(LLGlobals.selectedEntity, 'x', -100, modRotSlider.Value[1], 'Light')
    end
    
    
    
    local btnRot_Pm = collapsRot:AddButton('>')
    btnRot_Pm.IDContext = 'awdawdawd'
    btnRot_Pm.SameLine = true
    btnRot_Pm.OnClick = function (e)
        RotateEntity(LLGlobals.selectedEntity, 'x', 100, modRotSlider.Value[1], 'Light')
    end


    local rotTiltReset = collapsRot:AddText('Pitch')
    rotTiltReset.IDContext = 'resetPitch'
    rotTiltReset.SameLine = true



    local slRotRollSlider = collapsRot:AddSlider('', 0, -1000, 1000, 0.1)
    slRotRollSlider.IDContext = 'Yaw'
    slRotRollSlider.Value = {0,0,0,0}
    slRotRollSlider.OnChange = function(e)
        RotateEntity(LLGlobals.selectedEntity, 'z', e.Value[1], modRotSlider.Value[1], 'Light')
        slRotRollSlider.Value = {0,0,0,0}
    end
    slRotRollSlider.OnRightClick = function (e)
        RotateEntity(LLGlobals.selectedEntity, 'z', 90, 1, 'Light')
    end

    local btnRot_Rp = collapsRot:AddButton('<')
    btnRot_Rp.IDContext = 'adwdawdawdawd'
    btnRot_Rp.SameLine = true
    btnRot_Rp.OnClick = function (e)
        RotateEntity(LLGlobals.selectedEntity, 'z', -100, modRotSlider.Value[1], 'Light')
    end
    
    
    
    local btnRot_Rm = collapsRot:AddButton('>')
    btnRot_Rm.IDContext = 'awdddddawdawd'
    btnRot_Rm.SameLine = true
    btnRot_Rm.OnClick = function (e)
        RotateEntity(LLGlobals.selectedEntity, 'z', 100, modRotSlider.Value[1], 'Light')
    end


    local rotRollReset = collapsRot:AddText('Roll')
    rotRollReset.IDContext = 'resetROll'
    rotRollReset.SameLine = true

    
    
    local slRotYawSlider = collapsRot:AddSlider('', 0, -1000, 1000, 0.1)
    slRotYawSlider.IDContext = 'Roll'
    slRotYawSlider.Value = {0,0,0,0}
    slRotYawSlider.OnChange = function(e)
        RotateEntity(LLGlobals.selectedEntity, 'y', e.Value[1], modRotSlider.Value[1], 'Light')
        slRotYawSlider.Value = {0,0,0,0}
    end
    slRotYawSlider.OnRightClick = function (e)
        RotateEntity(LLGlobals.selectedEntity, 'y', 90, 1, 'Light')
    end


    local btnRot_Yp = collapsRot:AddButton('<')
    btnRot_Yp.IDContext = 'adwdawddddawdawd'
    btnRot_Yp.SameLine = true
    btnRot_Yp.OnClick = function (e)
        RotateEntity(LLGlobals.selectedEntity, 'y', -100, modRotSlider.Value[1], 'Light')
    end
    
    
    
    local btnRot_Ym = collapsRot:AddButton('>')
    btnRot_Ym.IDContext = 'awdddddddddawdawd'
    btnRot_Ym.SameLine = true
    btnRot_Ym.OnClick = function (e)
        RotateEntity(LLGlobals.selectedEntity, 'y', 100, modRotSlider.Value[1], 'Light')
    end

    local rotYawReset = collapsRot:AddText('Yaw')
    rotYawReset.IDContext = 'resetYaw'
    rotYawReset.SameLine = true




    collapsRot:AddSeparator('')



    textPositionInfo = p:AddText('')
    textPositionInfo.Label = string.format('x: %.2f, y: %.2f, z: %.2f', 0, 0, 0)



    textRotationInfo = p:AddText('')
    textRotationInfo.Label = string.format('pitch: %.2f, roll: %.2f, yaw: %.2f', 0, 0, 0)







    ---------------------------------------------------------
    p:AddSeparatorText([[Position source]])
    ---------------------------------------------------------
    
    


    
    
    checkOriginSrc = p:AddCheckbox('Origin point')
    checkOriginSrc.Disabled = false
    checkOriginSrc.OnChange = function (e)
        SourcePoint(e.Checked)
    end


    checkCutsceneSrc = p:AddCheckbox('Cutscene')
    checkCutsceneSrc.SameLine = true
    checkCutsceneSrc.Disabled = false
    checkCutsceneSrc.OnChange = function (e)
        SourceCutscene(e.Checked)
    end



    checkPMSrc = p:AddCheckbox('PhotoMode')
    checkPMSrc.SameLine = true
    checkPMSrc.Disabled = false
    checkPMSrc.OnChange = function (e)
        SourcePhotoMode(e.Checked)
    end
    


    checkClientSrc = p:AddCheckbox('Client-side')
    checkClientSrc.SameLine = true
    checkClientSrc.Disabled = false
    checkClientSrc.OnChange = function (e)
        SourceClient(e.Checked)
    end
    



    
    
    ---------------------------------------------------------
    p:AddSeparatorText('Utilities')
    ---------------------------------------------------------
    




    
    modPosSlider = p:AddSlider('', modPosDefault, 0.1, modPos, 0)
    modPosSlider.Value = {modPosDefault,0,0,0}
    modPosSlider.IDContext = 'ModID'
    modPosSlider.Logarithmic = true
    
    
    
    ER.modPosReset = p:AddButton('Mod pos')
    ER.modPosReset.IDContext = 'MOdd'
    ER.modPosReset.SameLine = true
    ER.modPosReset.OnClick = function ()
        modPosSlider.Value = {modPosDefault,0,0,0}
    end
    
    
    
    modRotSlider = p:AddSlider('', modRotDefault, 0.1, modRot, 0)
    modRotSlider.IDContext = 'RotMiodID'    
    modRotSlider.Value = {modRotDefault,0,0,0}
    modRotSlider.Logarithmic = true
    

    
    ER.modRotReset = p:AddButton('Mod rot')
    ER.modRotReset.IDContext = 'MOddRot'
    ER.modRotReset.SameLine = true
    ER.modRotReset.OnClick = function ()
        modRotSlider.Value = {modRotDefault,0,0,0}
    end


    local btnPreplaced = p:AddButton('Disable pre-placed lights')
    btnPreplaced.OnClick = function (e)
        for _, lightEnt in pairs(Ext.Entity.GetAllEntitiesWithComponent('Light')) do
            if lightEnt.Light.Template then
                lightEnt.Light.Template.Enabled = false
            end
        end
        textPreplace.Visible = true
        
        Helpers.Timer:OnTicks(300, function ()
            textPreplace.Visible = false
        end)

    end

    textPreplace = p:AddText([[Don't forget to save/load or load]])
    textPreplace.SameLine = true
    textPreplace.Visible = false


    local btnDisableVFX = p:AddCheckbox('Disable VFX shake and blur')
    btnDisableVFX.OnChange = function (e)

    Utils:SubUnsubToTick('sub', 'LL_VFX', function()
        if not e.Checked then Utils:SubUnsubToTick('unsub', 'LL_VFX',_) return end
        local effects = Ext.Entity.GetAllEntitiesWithComponent('Effect')
        for _, entity in ipairs(effects) do
            if entity.Effect and string.find(entity.Effect.EffectName, 'VFX_') then
                local components = entity.Effect.Timeline.Components
                if components then
                    for _, component in ipairs(components) do
                        for property, values in pairs(component.Properties) do
                            if values.FullName == 'Radial Blur.Opacity' then
                                for _, keyFrame in ipairs(values.KeyFrames) do
                                    if keyFrame.Frames then
                                        for _, frame in ipairs(keyFrame.Frames) do
                                            if frame then
                                                local success, value = pcall(function() return frame.Value end)
                                                if success then
                                                    frame.Value = 0
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            if values.FullName == 'Falloff Start-End' then
                                values.Min = 0
                                values.Max = 0
                            end
                        end
                    end
                end
            end
        end
    end)
    end

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

    function buttonSizes()
        for _, element in pairs(ER) do
            element.Size = {180/Style.buttonScale, 39/Style.buttonScale}
        end
    end
    buttonSizes()

    
end



Ext.RegisterNetListener('LL_SendLookAtTargetUuid', function(channel, payload)
    LLGlobals.tragetUuid = payload
    Helpers.Timer:OnTicks(3, function ()
        LLGlobals.tragetEntity = Ext.Entity.Get(LLGlobals.tragetUuid)
    end)
end)


Ext.RegisterConsoleCommand('lld', function (cmd, ...)

    DPrint('LightParametersClient-----------------------------')
    DDump(LLGlobals.LightParametersClient)

end)


Ext.RegisterConsoleCommand('lldg', function (cmd, ...)

    DPrint('Globals-----------------------------')
    DDump(LLGlobals)

end)



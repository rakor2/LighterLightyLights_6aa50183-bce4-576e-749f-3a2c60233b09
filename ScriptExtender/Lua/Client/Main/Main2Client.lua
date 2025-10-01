Globals.CreatedLightsClient = {}
Globals.LightsNameUuidMap = {}
Globals.LightsNames = {}
Globals.LightParameters = {}

---@type string EntityUuid
Globals.selectedUuid = nil

Globals.selectedEntity = nil

---@type LightComponent
Globals.selectedLightEntity = nil


local nameIndex = 0

local comboIHateCombos

local function getSourceTranslate()
    local SourceTranslate = _C().Transform.Transform.Translate
    return SourceTranslate
end

local function UpdateCreatedLightsCombo()
    Globals.LightsNames = Utils:MapToArray(Globals.LightsNameUuidMap)
    comboIHateCombos.Options = Globals.LightsNames
end

local function getSelectedUuid()
    if  Globals.LightsNameUuidMap       and
        comboIHateCombos.SelectedIndex  and
        comboIHateCombos.Options[comboIHateCombos.SelectedIndex + 1]
    then
        return Globals.LightsNameUuidMap[comboIHateCombos.Options[comboIHateCombos.SelectedIndex + 1]]
    end
end

local function getSelectedEntity()
    if getSelectedUuid() then return Ext.Entity.Get(getSelectedUuid()) end
end

local function getSelectedLightEntity()
    if getSelectedEntity() then return getSelectedEntity().Effect.Timeline.Components[2].LightEntity.Light end
end

local function getSelectedLightName()
    return comboIHateCombos.Options[comboIHateCombos.SelectedIndex + 1]
end


local function sanitySelectedLight()
    for name, uuid in pairs(Globals.LightsNameUuidMap) do
        if uuid == Globals.selectedUuid then
            DPrint('Sanity selected light: %s, %s', name, Globals.selectedUuid)
        end
    end
end

function MainTab(p)
    
    local checkTypePoint
    local checkTypeSpot
    local checkTypeDir
    
    --local btn = p:AddButton('xddd')

    
    checkTypePoint = p:AddCheckbox('Point')
    checkTypePoint.OnChange = function ()

        checkTypeSpot.Checked = false
        checkTypeDir.Checked = false

    end
    
    
    checkTypeSpot = p:AddCheckbox('Spotlight')
    checkTypeSpot.SameLine = true                     
    checkTypeSpot.OnChange = function ()

        checkTypePoint.Checked = false
        checkTypeDir.Checked = false
        
    end
    

    checkTypeDir = p:AddCheckbox('Directional')
    checkTypeDir.SameLine = true
    checkTypeDir.Disabled = true
    checkTypeDir.OnChange = function ()

        checkTypePoint.Checked = false
        checkTypeSpot.Checked = false
    
    end
    
    local btnCreate2 = p:AddButton('Create')
    btnCreate2.SameLine = true
    btnCreate2.OnClick = function ()
        

        local Position = getSourceTranslate()


        local Data = {
            type = type or 0,
            Position = Position
        }

        Channels.CreateLight:RequestToServer(Data, function (Response)


            Globals.CreatedLightsServer = Response[1]
            Globals.selectedUuid = Response[2]
            
            -- DPrint('Globals.CreatedLightsServer:')
            -- DDump(Globals.CreatedLightsServer)
            
            Helpers.Timer:OnTicks(10, function () --back to tick abuse Gladge
                
                Globals.selectedEntity = Ext.Entity.Get(Globals.selectedUuid)

                Helpers.Timer:OnTicks(5, function ()
                    
                    Globals.selectedLightEntity = getSelectedLightEntity()

                    Globals.selectedEntity.Effect.Timeline.IsPaused = true
                    
                    Globals.LightParameters[Globals.selectedUuid] = Globals.LightParameters[Globals.selectedUuid] or {}

                    --Utils:Dump(getSelectedLightEntity(), 'LL_LightEntity_FX')

                end)
            
                DPrint('Callback create: %s, %s', Globals.selectedUuid, lightEntity)
                                        
                nameIndex = nameIndex + 1
                                        
                local name = 'Light #' .. nameIndex
                
                Globals.LightsNameUuidMap[name] = Globals.CreatedLightsServer[Globals.selectedUuid]
                -- DPrint('Globals.LightsNameUuidMap:')
                -- DDump(Globals.LightsNameUuidMap)
                
                UpdateCreatedLightsCombo()
                comboIHateCombos.SelectedIndex = #comboIHateCombos.Options - 1
                
                --sanitySelectedLight()

                -- Helpers.Timer:OnTicks(50, function ()
                --     Utils:Dump(Ext.Entity.Get(Globals.selectedUuid), 'LL2_Light_Client', true)
                -- end)

            end)
            

        end)

    end







    comboIHateCombos = p:AddCombo('Created lights')
    comboIHateCombos.Options = Globals.LightsNames
    comboIHateCombos.SelectedIndex = 0
    comboIHateCombos.OnChange = function (e)

        Globals.selectedUuid = getSelectedUuid()
        Globals.selectedEntity = getSelectedEntity()

        Channels.SelectedLight:SendToServer(Globals.selectedUuid)
        
        UpdateCreatedLightsCombo()

    end





    local comboRename = p:AddCombo('')
    comboRename.IDContext = 'adawdawdawdawd'
    comboRename.Disabled = true


    local btnRenameLight = p:AddButton('Rename')
    btnRenameLight.SameLine = true
    
    local btnDelete = p:AddButton('Delete')
    btnDelete.OnClick = function ()

        if Globals.selectedUuid then 

            -- DPrint(Globals.selectedUuid)

            Globals.CreatedLightsServer[Globals.selectedUuid] = nil
            Globals.LightsNameUuidMap[getSelectedLightName()] = nil
            Globals.LightsNames[getSelectedLightName()] = nil

            Channels.DeleteLight:SendToServer(Globals.selectedUuid)

            UpdateCreatedLightsCombo()

            comboIHateCombos.SelectedIndex = comboIHateCombos.SelectedIndex - 1

            if comboIHateCombos.SelectedIndex < 0 then
                comboIHateCombos.SelectedIndex = 0
            end

            if #comboIHateCombos.Options > 0 then
                Globals.selectedUuid = Ext.Entity.Get(getSelectedUuid()).Uuid.EntityUuid
            else
                Globals.selectedUuid = nil
            end

            -- DDump(Globals.CreatedLightsServer)
            -- DDump(Globals.LightsNameUuidMap)
            -- DDump(Globals.LightsNames)

        end

    end
    
    local btnDeleteAll = p:AddButton('Delete all')
    btnDeleteAll.SameLine = true
    btnDeleteAll.OnClick = function ()

        Channels.DeleteLight:SendToServer('All')
        Globals.CreatedLightsServer = {}
        Globals.LightsNameUuidMap = {}
        Globals.LightsNames = {}
        
        UpdateCreatedLightsCombo()

        -- DDump(Globals.CreatedLightsServer)
        -- DDump(Globals.LightsNameUuidMap)

    end

    
    local btnDuplicate = p:AddButton('Duplicate')
    btnDuplicate.SameLine = true
    

    

    
    ---------------------------------------------------------
    p:AddSeparatorText([[Character's position source]])
    ---------------------------------------------------------
                                                             


    
    local checkOriginSrc = p:AddCheckbox('Origin point')
    
    local checkCutsceneSrc = p:AddCheckbox('Cutscene')
    checkCutsceneSrc.SameLine = true
    
    local checkClientSrc = p:AddCheckbox('Client-side')
    checkClientSrc.SameLine = true


    p:AddSeparatorText('Parameters')


    function PopulateParameters(p)
        assert(false, 'Function is not implemented')
    local collapseParameters = p:AddCollapsingHeader('Main parameters')
    local gp = collapseParameters:AddGroup('Parameters1')
    


    local pickerLightColor = gp:AddColorEdit('Click me')
    pickerLightColor.NoAlpha = true
    pickerLightColor.Float = false
    pickerLightColor.InputRGB = true
    pickerLightColor.DisplayHex = true
    pickerLightColor.OnChange = function (e)

        local lightEntity = getSelectedLightEntity()
        if lightEntity then
            lightEntity.Color = {e.Color[1], e.Color[2], e.Color[3]}
            Globals.LightParameters[Globals.selectedUuid]['Color'] = {e.Color[1], e.Color[2], e.Color[3]}
        end

    end



    local slLightIntensity = gp:AddSlider('', 100, 0, 2000, 1)
    slLightIntensity.IDContext = 'lkjanerfliuaern'
    slLightIntensity.OnChange = function (e)

        local lightEntity = getSelectedLightEntity()
        if lightEntity then
            lightEntity.Intensity = e.Value[1]
            Globals.LightParameters[Globals.selectedUuid]['Intensity'] = e.Value[1]
        end
        
    end


    
    local slLightTemp = gp:AddSlider('', 5600, 1000, 40000, 1)
    slLightTemp.IDContext = 'wlekjfnlkm'
    slLightTemp.Logarithmic = true
    slLightTemp.OnChange = function (e)

        local lightEntity = getSelectedLightEntity()
        if lightEntity then
            local Color = Math:KelvinToRGB(e.Value[1])
            lightEntity.Color = {Color[1], Color[2], Color[3]}
            Globals.LightParameters[Globals.selectedUuid]['Color'] = {Color[1], Color[2], Color[3]}
        end

    end
    


    -- LightType
    -- SpotLightInnerAngle
    -- SpotLightOuterAngle

    
    local collapseAddParameters = p:AddCollapsingHeader('Additional parameters')
    local groupAddParameters = collapseAddParameters:AddGroup('AddParameters')

    
end

    ---x,y,z = GetPosition(_C().Uuid.EntityUuid)
    ---l = CreateAt('7279c199-1f14-4bce-8740-98866d9878be',x,y+1,z, 1,0,'')
    ---l = CreateAt('7f6ca8ba-07ed-474f-b5b6-e3eefbe3dc3d',x,y+1,z, 1,0,'')
    --Ext.Entity.GetAllEntitiesWithComponent('Light')[7].Light.Radius = 1
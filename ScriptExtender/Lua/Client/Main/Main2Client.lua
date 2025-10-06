Globals.CreatedLightsClient = {} --UNUSED


Globals.LightsNameUuidMap = {}
Globals.LightsNames = {}
Globals.LightParameters = {}

Globals.States = {}
Globals.States.allowLightCreation = {}

---@class Settings
Settings = Settings or {}
-- Settings.checkPrePlaced = Settings.checkPrePlaced or nil


---@type string EntityUuid
Globals.selectedUuid = nil

---@type EntityHandle 
Globals.selectedEntity = nil

---@type LightComponent
Globals.selectedLightEntity = nil


local LightEntities = {}

local checkTypePoint
local checkTypeSpot
local checkTypeDir
local type = 'Point'

local nameIndex = 0
local comboIHateCombos

-- local checkPrePlaced
-- local textPrePlacedNote


local btnCreate2
local E = {
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
local ER = {
    btnLightIntensityReset,
    btnLightTempReset,
    btnLightRadiusReset,
    btnLightOuterReset,
    btnLightInnerReset,
    btnLightScatterReset,
    btnLightSharpReset,
}

local textPositionInfo
local textRotationInfo

local modPosSlider




local function getSourceTranslate()
    local SourceTranslate = _C().Transform.Transform.Translate
function setSourceTranslate(SourceTranslate)
    -- local SourceTranslate = _C().Transform.Transform.Translate
    return SourceTranslate
end


local function UpdateCreatedLightsCombo()
    Globals.LightsNames = Utils:MapToArray(Globals.LightsNameUuidMap)
    table.sort(Globals.LightsNames, function(a, b)
        return tonumber(a:match("%d+")) < tonumber(b:match("%d+"))
    end)
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
local function getSelectedLightEntityWithoutLight()
    if getSelectedEntity() then return getSelectedEntity().Effect.Timeline.Components[2].LightEntity end
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


local function translate(entity)
    local Translate = entity.Transform.Transform.Translate
    return Translate[1], Translate[2], Translate[3]
end


local function rotation(entity)
    local RotationQuat = entity.Transform.Transform.RotationQuat
    local Deg = Helpers.Math.QuatToEuler(RotationQuat)
    return Deg[1], Deg[2], Deg[3]
end


local function UpdateTranformInfo(x, y, z, rx, ry, rz)
    textPositionInfo.Label = string.format('x: %.2f, y: %.2f, z: %.2f', x, y, z)
    textRotationInfo.Label = string.format('rx: %.2f, ry: %.2f, rz: %.2f', rx, ry, rz)
end


Channels.EntityTransform:SetHandler(function (Data)
    local rx, ry, rz = table.unpack(Data.HumanRotation)
    local x,y,z = table.unpack(Data.Translate)
    UpdateTranformInfo(x, y, z, rx, ry, rz)
end)



local function UpdateElements(selectedUuid)
    E.slIntLightType.Value = {Globals.LightParameters[selectedUuid]['Type'] or 0, 0, 0, 0}
    E.pickerLightColor.Color = Globals.LightParameters[selectedUuid]['Color'] or {1, 1, 1, 0}
    E.slLightIntensity.Value = {Globals.LightParameters[selectedUuid]['Power'] or 1, 0, 0, 0}
    E.slLightTemp.Value = {Globals.LightParameters[selectedUuid]['Temperature'] or 5600, 0, 0, 0}
    E.slLightRadius.Value = {Globals.LightParameters[selectedUuid]['Radius'] or 1, 0, 0, 0}
    E.slLightOuterAngle.Value = {Globals.LightParameters[selectedUuid]['SpotLightOuterAngle'] or 45, 0, 0, 0}
    E.slLightInnerAngle.Value = {Globals.LightParameters[selectedUuid]['SpotLightInnerAngle'] or 1, 0, 0, 0}
    E.checkLightFill.Checked = Globals.LightParameters[selectedUuid]['Flags'] ~= 184
    E.slLightScattering.Value = {Globals.LightParameters[selectedUuid]['ScatteringIntensityScale'] or 0, 0, 0, 0}
    E.slLightEdgeSharp.Value = {Globals.LightParameters[selectedUuid]['EdgeSharpening'] or 0, 0, 0, 0}

    Globals.States.allowLightCreation = true
    btnCreate2.Disabled = false
end





function MainTab(p)
    --local btn = p:AddButton('xddd')
    


    

    checkTypePoint = p:AddCheckbox('Point')
    checkTypePoint.Checked = true
    checkTypePoint.OnChange = function ()

        type = 'Point' -- 0

        checkTypeSpot.Checked = false
        checkTypeDir.Checked = false

    end
    
    
    checkTypeSpot = p:AddCheckbox('Spotlight')
    checkTypeSpot.SameLine = true
    checkTypeSpot.OnChange = function ()

        type = 'Spotlight' -- 1

        checkTypePoint.Checked = false
        checkTypeDir.Checked = false
        
    end
    

    checkTypeDir = p:AddCheckbox('Directional')
    checkTypeDir.SameLine = true
    checkTypeDir.OnChange = function ()

        type = 'Directional' -- 3

        checkTypePoint.Checked = false
        checkTypeSpot.Checked = false
    
    end




    Globals.SourceTranslate = _C().Transform.Transform.Translate

    
    btnCreate2 = p:AddButton('Create')
    btnCreate2.SameLine = true
    btnCreate2.OnClick = function ()
        if Globals.States.allowLightCreation then
            Globals.States.allowLightCreation = false
            btnCreate2.Disabled = true
            local Position = Globals.SourceTranslate
            local Data = {
                type = type or 0,
                Position = Position
            }
            
            Channels.CreateLight:RequestToServer(Data, function (Response)
                if Response then
                    Globals.CreatedLightsServer = Response[1]
                    Globals.selectedUuid = Response[2]

                    Helpers.Timer:OnTicks(10, function ()
                        Globals.LightParameters[Globals.selectedUuid] = Globals.LightParameters[Globals.selectedUuid] or {}
                        Globals.selectedEntity = Ext.Entity.Get(Globals.selectedUuid)
                        
                        
                        Helpers.Timer:OnTicks(4, function ()
                            local lightEntity = getSelectedLightEntity()
                            if type == 'Spotlight' then
                                lightEntity.LightType = 1
                            elseif type == 'Directional' then
                                lightEntity.LightType = 2
                            else
                                lightEntity.LightType = 0
                            end
                        end)
                        
                        DPrint('Callback Create: %s, %s', Globals.selectedUuid, Globals.selectedEntity)
                        
                        nameIndex = nameIndex + 1
                        local name = 'Light #' .. nameIndex .. ' ' .. type
                        Globals.LightsNameUuidMap[name] = Globals.CreatedLightsServer[Globals.selectedUuid]
                        
                        UpdateCreatedLightsCombo()
                        comboIHateCombos.SelectedIndex = #comboIHateCombos.Options - 1
                        
                        --sanitySelectedLight()
                        Helpers.Timer:OnTicks(10, function ()
                            UpdateElements(Globals.selectedUuid)
                            local x,y,z = table.unpack(Position)
                            UpdateTranformInfo(x, y, z, 0, 0, 0)
                        end)

                    end)
                else
                Globals.States.allowLightCreation = true
                btnCreate2.Disabled = false
                end
            end)
        end
    end







    comboIHateCombos = p:AddCombo('Created lights')
    comboIHateCombos.Options = Globals.LightsNames
    comboIHateCombos.SelectedIndex = 0
    comboIHateCombos.OnChange = function (e)
        Globals.selectedUuid = getSelectedUuid()
        Globals.selectedEntity = getSelectedEntity()
        Channels.SelectedLight:SendToServer(Globals.selectedUuid)
        UpdateCreatedLightsCombo()
        UpdateElements(Globals.selectedUuid)
    end





    local comboRename = p:AddCombo('')
    comboRename.IDContext = 'adawdawdawdawd'
    comboRename.Disabled = true


    local btnRenameLight = p:AddButton('Rename')
    btnRenameLight.SameLine = true
    btnRenameLight.Disabled = true



    local btnDelete = p:AddButton('Delete')
    btnDelete.OnClick = function ()
        if Globals.selectedUuid then 
            -- DPrint(Globals.selectedUuid)

            Globals.CreatedLightsServer[Globals.selectedUuid] = nil
            Globals.LightParameters[Globals.selectedUuid] = nil
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
                nameIndex = 0
            end
            -- DDump(Globals.CreatedLightsServer)
            -- DDump(Globals.jLightsNameUuidMap)
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
        Globals.LightParameters = {}
        nameIndex = 0
        UpdateCreatedLightsCombo()

        -- DDump(Globals.CreatedLightsServer)
        -- DDump(Globals.LightsNameUuidMap)
    end

    
    local btnDuplicate = p:AddButton('Duplicate')
    btnDuplicate.SameLine = true
    btnDuplicate.Disabled = true
    

    

    
    ---------------------------------------------------------
    p:AddSeparatorText([[Position source]])
    ---------------------------------------------------------
    
    
    
    
    local checkOriginSrc = p:AddCheckbox('Origin point')
    checkOriginSrc.Disabled = true
    
    local checkCutsceneSrc = p:AddCheckbox('Cutscene')
    checkCutsceneSrc.SameLine = true
    checkCutsceneSrc.Disabled = true
    
    local checkClientSrc = p:AddCheckbox('Client-side')
    checkClientSrc.SameLine = true
    checkClientSrc.Disabled = true
    
    


    
    ---------------------------------------------------------
    p:AddSeparatorText('Parameters')
    ---------------------------------------------------------




    local collapseParameters = p:AddCollapsingHeader('Main parameters')
    collapseParameters.DefaultOpen = true
    local gp = collapseParameters:AddGroup('Parameters1')
    
    
    local treeGen = gp:AddTree('General')
    treeGen.DefaultOpen = true

    
    -- TYPE

    
    local function SetLightType(value)
        local lightEntity = getSelectedLightEntity()
        if lightEntity then
            lightEntity.LightType = value
            Globals.LightParameters[Globals.selectedUuid]['Type'] = value
        end
    end

    
    E.slIntLightType = treeGen:AddSliderInt('Type', 0,0,2,1)
    E.slIntLightType.OnChange = function (e)
        SetLightType(e.Value[1])
    end
    



    -- COLOR


    


    local function SetLightColor(value)
        local lightEntity = getSelectedLightEntity()
        if lightEntity then
            lightEntity.Color = value
            Globals.LightParameters[Globals.selectedUuid]['Color'] = value
        end
    end


    E.pickerLightColor = treeGen:AddColorEdit('Color (click me)')
    E.pickerLightColor.NoAlpha = true
    E.pickerLightColor.Float = false
    E.pickerLightColor.InputRGB = true
    E.pickerLightColor.DisplayHex = true
    E.pickerLightColor.OnChange = function (e)
        SetLightColor({e.Color[1], e.Color[2], e.Color[3]})
    end



    -- INTENSITY

    
    local function SetLightIntensity(value)

        Globals.selectedEntity.Effect.EffectResource.Constructor.EffectComponents[1].Properties['Appearance.Intensity'].KeyFrames[1].Frames[1].Value = value
        Globals.selectedEntity.Effect.EffectResource.Constructor.EffectComponents[1].Properties['Appearance.Intensity'].KeyFrames[1].Frames[2].Value = value
        Globals.LightParameters[Globals.selectedUuid]['Power'] = value


        -- local lightEntity = getSelectedLightEntityWithoutLight()
        -- if lightEntity then
        --     lightEntity.Light.Intensity = value
        --     LightEntities[lightEntity] = LightEntities[lightEntity] or {}
        --     LightEntities[lightEntity].Intensity = value
        --     Utils:SubUnsubToTick('sub', Globals.selectedUuid, function () --[[ "Let it live its happy spinny life, why does everything have to be for the player" Aahz (Top 1 optick leaderboard) ]]
        --         for entity, parameter in pairs(LightEntities) do
        --             if Ext.Entity.Get(entity).Light then
        --                 -- DPrint('%s , %s ', entity, parameter.Intensity)
        --                 Ext.Entity.Get(entity).Light.Intensity = parameter.Intensity
        --             end
        --         end
        --     end)
        -- end
    end



    
    
    E.slLightIntensity = treeGen:AddSlider('', 1, 0, 60, 1)
    E.slLightIntensity.IDContext = 'lkjanerfliuaern'
    E.slLightIntensity.Logarithmic = true
    E.slLightIntensity.OnChange = function (e)
        SetLightIntensity(e.Value[1])
    end
    
    
    ER.btnLightIntensityReset = treeGen:AddButton('Power')
    ER.btnLightIntensityReset.SameLine = true
    ER.btnLightIntensityReset.OnClick = function ()
        E.slLightIntensity.Value = {1, 0, 0, 0}
        SetLightIntensity(E.slLightIntensity.Value[1])
    end
    
    
    
    -- TEMPERATURE
    
    
    
    E.slLightTemp = treeGen:AddSlider('', 5600, 1000, 40000, 1)
    E.slLightTemp.IDContext = 'wlekjfnlkm'
    E.slLightTemp.Logarithmic = true
    E.slLightTemp.OnChange = function (e)
        local Color = Math:KelvinToRGB(e.Value[1])
        SetLightColor({Color[1], Color[2], Color[3]})
        if Globals.selectedUuid then 
            Globals.LightParameters[Globals.selectedUuid]['Temperature'] = e.Value[1] --This is just for the slidere
        end
    end
    
    
    ER.btnLightTempReset = treeGen:AddButton('Temperature')
    ER.btnLightTempReset.SameLine = true
    ER.btnLightTempReset.OnClick = function ()
        E.slLightTemp.Value = {5600, 0, 0, 0}
        Globals.LightParameters[Globals.selectedUuid]['Temperature'] = 5600
        SetLightColor({1,0.93,0.88})
    end
    
    
    
    -- RADIUS
    
    
    local function SetLightRadius(value)

        Globals.selectedEntity.Effect.EffectResource.Constructor.EffectComponents[1].Properties['Appearance.Radius'].KeyFrames[1].Frames[1].Value = value
        Globals.selectedEntity.Effect.EffectResource.Constructor.EffectComponents[1].Properties['Appearance.Radius'].KeyFrames[1].Frames[2].Value = value
        Globals.LightParameters[Globals.selectedUuid]['Radius'] = value
        
        --     -- DDump(Globals.selectedEntity.Effect.EffectResource.Constructor.EffectComponents[1])
        --     lightEntity.Light.Radius = value
        --     LightEntities[lightEntity] = LightEntities[lightEntity] or {}
        --     LightEntities[lightEntity].Radius = value
        --     Utils:SubUnsubToTick('sub', Globals.selectedUuid, function () --[[ "Let it live its happy spinny life, why does everything have to be for the player" Aahz (Top 1 optick leaderboard) ]]
        --         for entity, parameter in pairs(LightEntities) do
        --             if Ext.Entity.Get(entity).Light then
        --                 -- DPrint('%s , %s ', entity, parameter.Radius)
        --                 Ext.Entity.Get(entity).Light.Radius = parameter.Radius
        --             end
        --         end
        --     end)
        -- end
    end

    

    E.slLightRadius = treeGen:AddSlider('', 1, 0, 60, 1)
    E.slLightRadius.IDContext = 'adwadqw3d'
    E.slLightRadius.Logarithmic = true
    E.slLightRadius.OnChange = function (e)
        SetLightRadius(e.Value[1])
    end
    
    
    ER.btnLightRadiusReset = treeGen:AddButton('Distance')
    ER.btnLightRadiusReset.SameLine = true
    ER.btnLightRadiusReset.OnClick = function ()
        E.slLightRadius.Value = {1, 0, 0, 0}
        SetLightRadius(E.slLightRadius.Value[1])
    end



    -- OUTER ANGLE

    local treeSpot = gp:AddTree('Spotlight')
    treeSpot.IDContext = 'sodkfn'



    local function SetLightOuterAngle(value)
        local lightEntity = getSelectedLightEntity()
        if lightEntity then
            lightEntity.SpotLightOuterAngle = value
            Globals.LightParameters[Globals.selectedUuid]['SpotLightOuterAngle'] = value
        end
    end

    

    E.slLightOuterAngle = treeSpot:AddSlider('', 45, 0, 360, 1)
    E.slLightOuterAngle.IDContext = '123dwfsefa'
    E.slLightOuterAngle.OnChange = function (e)
        SetLightOuterAngle(e.Value[1])
    end
    
    
    ER.btnLightOuterReset = treeSpot:AddButton('Outer angle')
    ER.btnLightOuterReset.SameLine = true
    ER.btnLightOuterReset.OnClick = function ()
        E.slLightOuterAngle.Value = {45, 0, 0, 0}
        SetLightOuterAngle(E.slLightOuterAngle.Value[1])
    end



    -- INNER ANGLE


    local function SetLightInnerAngle(value)
        local lightEntity = getSelectedLightEntity()
        if lightEntity then
            lightEntity.SpotLightInnerAngle = value
            Globals.LightParameters[Globals.selectedUuid]['SpotLightInnerAngle'] = value
        end
    end
    
    
    
    E.slLightInnerAngle = treeSpot:AddSlider('', 1, 0, 360, 1)
    E.slLightInnerAngle.IDContext = 'rfgrtynj5r6'
    E.slLightInnerAngle.OnChange = function (e)
        SetLightInnerAngle(e.Value[1])
    end
    
    
    ER.btnLightInnerReset = treeSpot:AddButton('Inner angle')
    ER.btnLightInnerReset.SameLine = true
    ER.btnLightInnerReset.OnClick = function ()
        E.slLightInnerAngle.Value = {45, 0, 0, 0}
        SetLightInnerAngle(E.slLightInnerAngle.Value[1])
    end
    
    
    
    local treeDir = gp:AddTree('Directional')
    treeDir.IDContext = 'sodsdfkfn'
    
    
    function SetLightDirectionalParameters(parameter, value)
        local lightEntity = getSelectedLightEntity()
        if lightEntity then
            if parameter == 'DirectionLightAttenuationEnd' then
                lightEntity.DirectionLightAttenuationEnd = value
                
            elseif parameter == 'DirectionLightAttenuationFunction' then
                lightEntity.DirectionLightAttenuationFunction = value
                
            elseif parameter == 'DirectionLightAttenuationSide' then
                lightEntity.DirectionLightAttenuationSide = value
                
            elseif parameter == 'DirectionLightAttenuationSide2' then
                lightEntity.DirectionLightAttenuationSide2 = value
                
            elseif parameter == 'DirectionLightDimensions' then
                lightEntity.DirectionLightDimensions = value
                
            end
            Globals.LightParameters[Globals.selectedUuid][parameter] = value
        end
    end



    E.slLightDirEnd = treeDir:AddSlider('End', 0, 0, 100, 1)
    E.slLightDirEnd.IDContext = 'olkjsdeafoiuzsrenbf'
    E.slLightDirEnd.OnChange = function (e)
        SetLightDirectionalParameters('DirectionLightAttenuationEnd', e.Value[1])
    end


    -- ER.btnLightDirEndReset = 

        
    E.slIntLightDirFunc = treeDir:AddSliderInt('Function', 0, 0, 3, 1)
    E.slIntLightDirFunc.IDContext = 'olkjsdsseafoiuzsrenbf'
    E.slIntLightDirFunc.OnChange = function (e)
        SetLightDirectionalParameters('DirectionLightAttenuationFunction', e.Value[1])
    end

        
    E.slLightDirSide = treeDir:AddSlider('Side', 0, 0, 20, 1)
    E.slLightDirSide.IDContext = 'o12312'
    E.slLightDirSide.OnChange = function (e)
        SetLightDirectionalParameters('DirectionLightAttenuationSide', e.Value[1])
    end

        
    E.slLightDirSide2 = treeDir:AddSlider('Side2', 0, 0, 10, 1)
    E.slLightDirSide2.IDContext = 'asdaw'
    E.slLightDirSide2.OnChange = function (e)
        SetLightDirectionalParameters('DirectionLightAttenuationSide2', e.Value[1])
    end

        
    E.slLightDirDim = treeDir:AddSlider('Dim', 0, 0, 10, 1)
    E.slLightDirDim.Components = 3
    E.slLightDirDim.IDContext = 'lkasenfaolkejfn'
    E.slLightDirDim.OnChange = function (e)
        SetLightDirectionalParameters('DirectionLightDimensions', {e.Value[1], e.Value[2],e.Value[3]})
    end



    local collapseAddParameters = p:AddCollapsingHeader('Additional parameters')
    local gap = collapseAddParameters:AddGroup('AddParameters')


    -- FILL
    
    -- 1 Render shadows

    local function SetLightFill(value)
        local lightEntity = getSelectedLightEntity()
        if lightEntity then
            lightEntity.Flags = value
            Globals.LightParameters[Globals.selectedUuid]['Flags'] = value
        end
    end
    
    
    E.checkLightFill = gap:AddCheckbox('Fill')
    E.checkLightFill.Checked = true
    E.checkLightFill.OnChange = function ()
        SetLightFill(E.checkLightFill.Checked and 184 or 56)
    end



    -- SCATTERING INTESITY
    

    
    local function SetLightScattering(value)
        local lightEntity = getSelectedLightEntity()
        if lightEntity then
            lightEntity.ScatteringIntensityScale = value
            Globals.LightParameters[Globals.selectedUuid]['ScatteringIntensityScale'] = value
        end
    end


    E.slLightScattering = gap:AddSlider('', 0, 0, 100, 1)
    E.slLightScattering.IDContext = 'esrgsrengsrg'
    E.slLightScattering.Logarithmic = true
    E.slLightScattering.OnChange = function (e)
        SetLightScattering(e.Value[1])
    end
    
    
    ER.btnLightScatterReset = gap:AddButton('Scattering')
    ER.btnLightScatterReset.SameLine = true
    ER.btnLightScatterReset.OnClick = function ()
        E.slLightScattering.Value = {0, 0, 0, 0}
        SetLightScattering(E.slLightScattering.Value[1])
    end



    -- EDGE SHARPENING

    
    local function SetLightEdgeSharp(value)
        local lightEntity = getSelectedLightEntity()
        if lightEntity then
            lightEntity.EdgeSharpening = value
            Globals.LightParameters[Globals.selectedUuid]['EdgeSharpening'] = value
        end
    end


    E.slLightEdgeSharp = gap:AddSlider('', 0, 0, 1, 1)
    E.slLightEdgeSharp.IDContext = 'sdfwerw34'
    E.slLightEdgeSharp.Logarithmic = false
    E.slLightEdgeSharp.OnChange = function (e)
        SetLightEdgeSharp(e.Value[1])
    end
    
    
    ER.btnLightSharpReset = gap:AddButton('Edge sharpening')
    ER.btnLightSharpReset.SameLine = true
    ER.btnLightSharpReset.OnClick = function ()
        E.slLightEdgeSharp.Value = {0, 0, 0, 0}
        SetLightEdgeSharp(E.slLightEdgeSharp.Value[1])
    end




    ---------------------------------------------------------
    p:AddSeparatorText('Positioning')
    ---------------------------------------------------------



    function MoveEntity(entity, axis, offset, step, mode)
        if entity then
            local Data = {
                axis = axis,
                step = step,
                offset = offset
            }


            if mode == 'World' then
                Channels.EntityTranslate:SendToServer(Data)
                    -- local x,y,z = table.unpack(Response.Translate)
                    -- UpdateTranformInfo(x, y, z, rx, ry, rz)
                    -- Globals.LightTranslate = Response.Translate
                    -- Globals.selectedEntity.Transform.Transform.Translate = {Globals.LightTranslate[1], Globals.LightTranslate[2], Globals.LightTranslate[3]}
                    -- Globals.selectedEntity.Visual.Visual.WorldTransform.Translate = {Globals.LightTranslate[1], Globals.LightTranslate[2], Globals.LightTranslate[3]}
                    
                    -- Globals.selectedEntity.Visual.Visual:SetWorldTranslate({Globals.LightTranslate[1], Globals.LightTranslate[2], Globals.LightTranslate[3]})

                    -- Globals.selectedLightEntity = getSelectedLightEntity()
                    -- Globals.selectedLightEntity.Template.Transform.Translate = {Globals.LightTranslate[1], Globals.LightTranslate[2], Globals.LightTranslate[3]}


                    -- DDebug('Transform -------------')
                    -- -- DDump(Globals.selectedEntity.Transform.Transform.Translate)
                    -- DDebug('World -------------')
                    -- DDump(Globals.selectedEntity.Visual.Visual.WorldTransform.Translate)
                -- end)
            else
                Channels.EntityRotationOrbit:SendToServer(Data)

                    -- Globals.LightRotation = Response.HumanRotation
                    -- Globals.LightQuats = Response.RotationQuat
                    -- Globals.selectedEntity.Transform.Transform.RotationQuat = {Globals.LightQuats[1], Globals.LightQuats[2], Globals.LightQuats[3], Globals.LightQuats[4]}
                    -- Globals.selectedEntity.Visual.Visual.WorldTransform.RotationQuat = {Globals.LightQuats[1], Globals.LightQuats[2], Globals.LightQuats[3], Globals.LightQuats[4]}
                -- end)
            end
        end
    end


    function RotateEntity(entity, axis, offset, step)
        if entity then
            local Data = {
                axis = axis,
                step = step,
                offset = offset
            }
            Channels.EntityRotation:SendToServer(Data)
                -- local rx,ry,rz = table.unpack(Response.HumanRotation)
                -- -- UpdateTranformInfo(x, y, z, rx, ry, rz)
                -- Globals.LightQuats = Response.RotationQuat
                -- Globals.selectedEntity.Transform.Transform.RotationQuat = {Globals.LightQuats[1], Globals.LightQuats[2], Globals.LightQuats[3], Globals.LightQuats[4]}
            -- end)
        end
    end


    textPositionInfo = p:AddText('')
    textPositionInfo.Label = string.format('x: %.2f, y: %.2f, z: %.2f', 0, 0, 0)

    textRotationInfo = p:AddText('')
    textRotationInfo.Label = string.format('rx: %.2f, ry: %.2f, rz: %.2f', 0, 0, 0)



    
    local modPosDefault = 8000
    local modRotDefault = 100
    local modPos = 20000
    local modRot = 1000
    
    local collapsPos = p:AddCollapsingHeader('Position')
    collapsPos.DefaultOpen = false


    local checkStick = collapsPos:AddCheckbox('Stick to camera')
    checkStick.OnChange = function (e)
        if Globals.selectedUuid then
            if checkStick.Checked then
                Utils:SubUnsubToTick('sub', 'Stick', function ()
                    local Translate = Camera:GetActiveCamera().Transform.Transform.Translate
                    local RotationQuat = Camera:GetActiveCamera().Transform.Transform.RotationQuat
                    local Data = {
                        Translate = Translate,
                        RotationQuat = RotationQuat
                    }
                    Channels.StickToCamera:SendToServer(Data)
                    

                    local x,y,z = table.unpack(Translate)
                    local rx,ry,rz = table.unpack(Helpers.Math.QuatToEuler(RotationQuat))
                    UpdateTranformInfo(x,y,z,rx,ry,rz)

                end)
            else
                Utils:SubUnsubToTick('unsub', 'Stick', _)
            end
        end
    end
    
    modPosSlider = collapsPos:AddSlider('', modPosDefault, -modPos, modPos, 0)
    modPosSlider.Value = {modPosDefault,0,0,0}
    modPosSlider.IDContext = 'ModID'


    local modPosReset = collapsPos:AddButton('Mod')
    modPosReset.IDContext = 'MOdd'
    modPosReset.SameLine = true
    modPosReset.OnClick = function ()
        modPosSlider.Value = {modPosDefault,0,0,0}
    end
    
    local worldTree = collapsPos:AddTree('World relative')




    local posZSlider = worldTree:AddSlider('', 0, -1000, 1000, 0.1)
    posZSlider.IDContext = 'NS'
    posZSlider.Value = {0,0,0,0}
    posZSlider.OnChange = function()
        MoveEntity(Globals.selectedEntity, 'z', posZSlider.Value[1], modPosSlider.Value[1], 'World')
        posZSlider.Value = {0,0,0,0}
    end

    local textZ = worldTree:AddText('N/S')
    textZ.IDContext = 'awdadwdawdawdawda'
    textZ.SameLine = true


    
    local posYSlider = worldTree:AddSlider('', 0, -1000, 1000, 0.1)
    posYSlider.IDContext = 'DU'
    posYSlider.Value = {0,0,0,0}
    posYSlider.OnChange = function()
        MoveEntity(Globals.selectedEntity, 'y', posYSlider.Value[1], modPosSlider.Value[1], 'World')
        posYSlider.Value = {0,0,0,0}
    end

    local textY = worldTree:AddText('D/U')
    textY.IDContext = 'awdadwdawdawdawda'
    textY.SameLine = true


    local posXSlider = worldTree:AddSlider('', 0, -1000, 1000, 0)
    posXSlider.IDContext = 'WE'
    posXSlider.Value = {0,0,0,0}
    posXSlider.OnChange = function()
        MoveEntity(Globals.selectedEntity, 'x', posXSlider.Value[1], modPosSlider.Value[1], 'World')
        posXSlider.Value = {0,0,0,0}
    end

    local textX = worldTree:AddText('W/E')
    textX.IDContext = 'awdawdawda'
    textX.SameLine = true



    local posReset = worldTree :AddButton('Reset')
    posReset.IDContext = 'resetPos'
    posReset.OnClick = function ()
        MoveEntity(Globals.selectedEntity, nil, nil, nil)
    end


    -- p:AddSeparator('')




    local orbitTree = collapsPos:AddTree('Character relative')



    local posOrbX = orbitTree:AddSlider('Cw/Cww', 0, -1000, 1000, 0.1)
    posOrbX.IDContext = 'NawdawwwdS'
    posOrbX.Value = {0,0,0,0}
    posOrbX.OnChange = function()
        MoveEntity(Globals.selectedEntity, 'x', posOrbX.Value[1], modPosSlider.Value[1], 'Orbit')
        posOrbX.Value = {0,0,0,0}
    end


    local posOrbY = orbitTree:AddSlider('Height', 0, -1000, 1000, 0.1)
    posOrbY.IDContext = 'NawawdwdawdS'
    posOrbY.Value = {0,0,0,0}
    posOrbY.OnChange = function()
        MoveEntity(Globals.selectedEntity, 'y', posOrbY.Value[1], modPosSlider.Value[1], 'Orbit')
        posOrbY.Value = {0,0,0,0}
    end

    local posOrbZ = orbitTree:AddSlider('Radius', 0, -1000, 1000, 0.1)
    posOrbZ.IDContext = 'NawdasdawdS'
    posOrbZ.Value = {0,0,0,0}
    posOrbZ.OnChange = function()
        MoveEntity(Globals.selectedEntity, 'z', posOrbZ.Value[1], modPosSlider.Value[1], 'Orbit')
        posOrbZ.Value = {0,0,0,0}
    end





    local collapsRot = p:AddCollapsingHeader('Rotation')
    collapsRot.DefaultOpen = false




    modRotSlider = collapsRot:AddSlider('', modRotDefault, -modRot, modRot, 0)
    modRotSlider.IDContext = 'RotMiodID'    
    modRotSlider.Value = {modRotDefault,0,0,0}

    local modRotReset = collapsRot:AddButton('Mod')
    modRotReset.IDContext = 'MOddRot'
    modRotReset.SameLine = true
    modRotReset.OnClick = function ()
        modRotSlider.Value = {modRotDefault,0,0,0}
    end

    local rotTiltSlider = collapsRot:AddSlider('', 0, -1000, 1000, 0.1)
    rotTiltSlider.IDContext = 'Tilt'
    rotTiltSlider.Value = {0,0,0,0}
    rotTiltSlider.OnChange = function(value)
        RotateEntity(Globals.selectedEntity, 'x', rotTiltSlider.Value[1], modRotSlider.Value[1])
        rotTiltSlider.Value = {0,0,0,0}
    end

    local rotTiltReset = collapsRot:AddText('Tilt')
    rotTiltReset.IDContext = 'resetTilt'
    rotTiltReset.SameLine = true



    local rotRollSlider = collapsRot:AddSlider('', 0, -1000, 1000, 0.1)
    rotRollSlider.IDContext = 'Yaw'
    rotRollSlider.Value = {0,0,0,0}
    rotRollSlider.OnChange = function()
        RotateEntity(Globals.selectedEntity, 'z', rotRollSlider.Value[1], modRotSlider.Value[1])
        rotRollSlider.Value = {0,0,0,0}
    end


    local rotRollReset = collapsRot:AddText('Yaw')
    rotRollReset.IDContext = 'resetROll'
    rotRollReset.SameLine = true

    
    
    local rotYawSlider = collapsRot:AddSlider('', 0, -1000, 1000, 0.1)
    rotYawSlider.IDContext = 'Roll'
    rotYawSlider.Value = {0,0,0,0}
    rotYawSlider.OnChange = function()
        RotateEntity(Globals.selectedEntity, 'y', rotYawSlider.Value[1], modRotSlider.Value[1])
        rotYawSlider.Value = {0,0,0,0}
    end

    local rotYawReset = collapsRot:AddText('Roll')
    rotYawReset.IDContext = 'resetYaw'
    rotYawReset.SameLine = true


    local rotReset = collapsRot:AddButton('Reset')
    rotReset.IDContext = 'resetRos'
    rotReset.Size = {90, 35}
    rotReset.OnClick = function ()
        RotateEntity(Globals.selectedEntity, nil, 0, 0)
    end

    ---------------------------------------------------------
    p:AddSeparatorText([[Position source]])
    ---------------------------------------------------------
    
    
    
    
    checkOriginSrc = p:AddCheckbox('Origin point')
    checkOriginSrc.Disabled = true
    


    checkCutsceneSrc = p:AddCheckbox('Cutscene')
    checkCutsceneSrc.SameLine = true
    checkCutsceneSrc.Disabled = false
    checkCutsceneSrc.OnChange = function ()
        SourceCutscene()
    end
    


    checkClientSrc = p:AddCheckbox('Client-side')
    checkClientSrc.SameLine = true
    checkClientSrc.Disabled = true
    
    
    
    
    ---------------------------------------------------------
    p:AddSeparatorText('Utilities')
    ---------------------------------------------------------
    
    
    -- checkPrePlaced = p:AddCheckbox('Disable pre-placed lights')
    -- checkPrePlaced.Checked = false
    -- checkPrePlaced.OnChange = function (e)
    --     for _, lightEnt in pairs(Ext.Entity.GetAllEntitiesWithComponent('Light')) do
    --         if lightEnt.Light.Template then
    --             lightEnt.Light.Template.Enabled = e.Checked
    --         end
    --     end
    --     -- Settings.checkPrePlaced = e.Checked
    --     textPrePlacedNote.Visible = true
    -- end

    -- textPrePlacedNote = p:AddText('Save/Load or Load a save')
    -- textPrePlacedNote.SameLine = true
    -- textPrePlacedNote.Visible = false
    
    function buttonSizes()
        for _, element in pairs(ER) do
            element.Size = {195/Style.buttonScale, 39/Style.buttonScale}
        end
    end
    buttonSizes()

    
end


Ext.RegisterConsoleCommand('lld', function (cmd, ...)
    DDump(Globals.LightParameters)

end)

    ---x,y,z = GetPosition(_C().Uuid.EntityUuid)
    ---l = CreateAt('7279c199-1f14-4bce-8740-98866d9878be',x,y+1,z, 1,0,'')
    ---l = CreateAt('7f6ca8ba-07ed-474f-b5b6-e3eefbe3dc3d',x,y+1,z, 1,0,'')
    
    --Ext.Entity.GetAllEntitiesWithComponent('Light')[7].Light.Radius = 1
    --_D(Ext.Entity.GetAllEntitiesWithComponent('Light'))


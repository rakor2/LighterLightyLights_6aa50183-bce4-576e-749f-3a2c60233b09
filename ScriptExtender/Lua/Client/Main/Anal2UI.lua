function Anal2Tab(p)

    
    local CHILD_WIN_SIZE = {554, 200}
    local winLtnFav
    local winAtmFav


    -- local valuesApplyButton = p:AddButton("Apply 2")
    -- valuesApplyButton.IDContext = "sunValuesDayLoad"
    -- valuesApplyButton.SameLine = false
    -- valuesApplyButton.OnClick = function()
    --     Ext.Net.PostMessageToServer("valuesApplyDay", "")
    -- end






    p:AddSeparatorText('Lighting')

    

    LLGlobals.FilteredLTNOptions = LLGlobals.LtnComboOptions


    
    local inpSearchLighting = p:AddInputText('')
    inpSearchLighting.IDContext = 'o9irtqjwno9485839c'
    inpSearchLighting.OnChange = function()
        LLGlobals.FilteredLTNOptions = UI:FilterOptions(inpSearchLighting.Text, LLGlobals.LtnComboOptions)
        GlobalsIMGUI.comboLighting.Options = LLGlobals.FilteredLTNOptions
        GlobalsIMGUI.comboLighting.SelectedIndex = 0
    end



    local btnClearSearch = p:AddButton('Search')
    btnClearSearch.SameLine = true
    btnClearSearch.OnClick = function ()
        inpSearchLighting.Text = ''
        LLGlobals.FilteredLTNOptions = LLGlobals.LtnComboOptions
        GlobalsIMGUI.comboLighting.Options = LLGlobals.LtnComboOptions
    end
    
    
    -- local btnApplyLtn = p:AddButton('Apply')
    -- btnApplyLtn.IDContext = ''
    -- btnApplyLtn.SameLine = true
    -- btnApplyLtn.OnClick = function ()
    --     Ext.Net.PostMessageToServer('LL_LightingApply', UI:SelectedOpt(GlobalsIMGUI.comboLighting))
    --     ChangeLTNValues()
    -- end





    GlobalsIMGUI.comboLighting = p:AddCombo('')
    GlobalsIMGUI.comboLighting.IDContext = ';oeirj4eiouh'
    GlobalsIMGUI.comboLighting.Options = LLGlobals.LtnComboOptions or {}
    GlobalsIMGUI.comboLighting.SelectedIndex = 0
    GlobalsIMGUI.comboLighting.OnChange = function ()
        comboLightingFunc()
    end
    GlobalsIMGUI.comboLighting.OnRightClick = function ()
        comboLightingFunc()
    end

    
    
    local btnPrevLtn = p:AddButton('<')
    btnPrevLtn.IDContext = ';olsikefnlieurhn'
    btnPrevLtn.SameLine = true
    btnPrevLtn.OnClick = function ()
        UI:PrevOption(GlobalsIMGUI.comboLighting)
        comboLightingFunc()
    end



    local btnNextLtn = p:AddButton('>')
    btnNextLtn.IDContext = ';olsikefnlieur3402934u20934uhn'
    btnNextLtn.SameLine = true
    btnNextLtn.OnClick = function ()
        UI:NextOption(GlobalsIMGUI.comboLighting)
        comboLightingFunc()
    end




    local btnAddToFav = p:AddButton('Add')
    btnAddToFav.IDContext = 'oiurfhaieowurhi4wh5iu'
    btnAddToFav.SameLine = true
    btnAddToFav.OnClick = function ()
        if LLGlobals.FavLighting[UI:SelectedOpt(GlobalsIMGUI.comboLighting)] == UI:SelectedOpt(GlobalsIMGUI.comboLighting) then
            return
        else
            CreateSelectable(winLtnFav, LLGlobals.FavLighting, LLGlobals.FilteredLTNOptions[GlobalsIMGUI.comboLighting.SelectedIndex + 1], 'FavoriteLighting', 'LL_LightingApply')
        end
    end



    local colFav = p:AddCollapsingHeader('Favorites')
    colFav.IDContext = 'iaeuhkbnkwbriyuwg34iy'
    


    winLtnFav = colFav:AddChildWindow('')
    winLtnFav.Size = CHILD_WIN_SIZE



    if Ext.IO.LoadFile('LightyLights/FavoriteLighting.json') then
        LLGlobals.FavLighting = Ext.Json.Parse(Ext.IO.LoadFile('LightyLights/FavoriteLighting.json'))
        PopulateLTNFavorites(winLtnFav, LLGlobals.FavLighting)
    else
        LLGlobals.FavLighting = {}
    end



    p:AddSeparatorText('Atmosphere')



    LLGlobals.FilteredATMOptions = LLGlobals.AtmComboOptions



    local inpSearchAtmosphere = p:AddInputText('')
    inpSearchAtmosphere.IDContext = 'pfkjawpo3i4rho83hr'
    inpSearchAtmosphere.OnChange = function()
        LLGlobals.FilteredATMOptions = UI:FilterOptions(inpSearchAtmosphere.Text, LLGlobals.AtmComboOptions)
        GlobalsIMGUI.comboAtmosphere.Options = LLGlobals.FilteredATMOptions
        GlobalsIMGUI.comboAtmosphere.SelectedIndex = 0
    end



    local btnClearSearchAtm = p:AddButton('Search')
    btnClearSearchAtm.IDContext = 'oweifjw3oiufhn'
    btnClearSearchAtm.SameLine = true
    btnClearSearchAtm.OnClick = function ()
        inpSearchAtmosphere.Text = ''
        LLGlobals.FilteredATMOptions = LLGlobals.AtmComboOptions
        GlobalsIMGUI.comboAtmosphere.Options = LLGlobals.AtmComboOptions
    end


    -- local btnApplyAtm = p:AddButton('Apply')
    -- btnApplyAtm.IDContext = 'awdawdawd'
    -- btnApplyAtm.SameLine = true
    -- btnApplyAtm.OnClick = function ()
    --     Ext.Net.PostMessageToServer('LL_AtmosphereApply', UI:SelectedOpt(GlobalsIMGUI.comboAtmosphere))
    -- end



    GlobalsIMGUI.comboAtmosphere = p:AddCombo('')
    GlobalsIMGUI.comboAtmosphere.IDContext = ';o342342etm'
    GlobalsIMGUI.comboAtmosphere.Options = LLGlobals.AtmComboOptions or {}
    GlobalsIMGUI.comboAtmosphere.SelectedIndex = 0
    GlobalsIMGUI.comboAtmosphere.OnChange = function (e)
        comboAtmosphereFunc()
    end
    GlobalsIMGUI.comboAtmosphere.OnRightClick = function (e)
        comboAtmosphereFunc()
    end



    local btnPrevAtm = p:AddButton('<')
    btnPrevAtm.IDContext = ';olsikefnli4444444eurhnatm'
    btnPrevAtm.SameLine = true
    btnPrevAtm.OnClick = function ()
        UI:PrevOption(GlobalsIMGUI.comboAtmosphere)
        comboAtmosphereFunc()
    end



    local btnNextAtm = p:AddButton('>')
    btnNextAtm.IDContext = ';ol123123sik34uhnatm'
    btnNextAtm.SameLine = true
    btnNextAtm.OnClick = function ()
        UI:NextOption(GlobalsIMGUI.comboAtmosphere)
        comboAtmosphereFunc()
    end



    local btnAddToFavAtm = p:AddButton('Add')
    btnAddToFavAtm.IDContext = 'oiu12312354125m'
    btnAddToFavAtm.SameLine = true
    btnAddToFavAtm.OnClick = function ()
        if LLGlobals.FavAtmosphere[UI:SelectedOpt(GlobalsIMGUI.comboAtmosphere)] == UI:SelectedOpt(GlobalsIMGUI.comboAtmosphere) then
            return
        else
            CreateSelectable(winAtmFav, LLGlobals.FavAtmosphere, LLGlobals.FilteredATMOptions[GlobalsIMGUI.comboAtmosphere.SelectedIndex + 1], 'FavoriteAtmosphere', 'LL_AtmosphereApply')
        end
    end



    local colFavAtm = p:AddCollapsingHeader('Favorites')
    colFavAtm.IDContext = 'iae1231231235156646hgdtm'

    winAtmFav = colFavAtm:AddChildWindow('')
    winAtmFav.Size = CHILD_WIN_SIZE



    if Ext.IO.LoadFile('LightyLights/FavoriteAtmosphere.json') then
        LLGlobals.FavAtmosphere = Ext.Json.Parse(Ext.IO.LoadFile('LightyLights/FavoriteAtmosphere.json'))
        PopulateATMFavorites(winAtmFav, LLGlobals.FavAtmosphere)
    else
        LLGlobals.FavAtmosphere = {}
    end



    local aepasdaw = p:AddSeparatorText('Reset')



    local resetLtnBtn = p:AddButton('Lighting')
    resetLtnBtn.OnClick = function ()
        Channels.ResetANL:SendToServer('Lighting')
    end
    


    local resetAtmBtn = p:AddButton('Atmosphere')
    resetAtmBtn.SameLine = true
    resetAtmBtn.OnClick = function ()
        Channels.ResetANL:SendToServer('Atmosphere')
    end

    

    




    p:AddSeparatorText('Parameters')

    local btnApplyParam = p:AddButton('Apply')
    btnApplyParam.OnClick = function (e)
        Apply_TheOptimizationIsUnspoken()
    end

    -- local btnCacheLTN = p:AddButton('Cache')
    -- btnCacheLTN.OnClick = function ()
    --     CacheLTN()
    -- end
    
    local btnResetCLTN = p:AddButton('Reset lighting')
    btnResetCLTN.SameLine = true
    btnResetCLTN.OnClick = function ()
        ResetLTN(false)
        Apply_TheOptimizationIsUnspoken()
    end
    btnResetCLTN.OnRightClick = function ()
        ResetLTN(true)
        Apply_TheOptimizationIsUnspoken()
    end
    
    local btnResetCATM = p:AddButton('Reset atmosphere')
    btnResetCATM.SameLine = true
    btnResetCATM.OnClick = function ()
        ResetATM(false)
        Apply_TheOptimizationIsUnspoken()
    end
    btnResetCATM.OnRightClick = function ()
        ResetATM(true)
        Apply_TheOptimizationIsUnspoken()
    end
    
    -- local btnResetALTN = p:AddButton('Reset lightin all')
    -- btnResetALTN.OnClick = function ()
    --     ResetLTN(true)
    --     Apply_TheOptimizationIsUnspoken()
    -- end

    -- local btnResetAATM = p:AddButton('Reset atmosphere all')
    -- btnResetAATM.SameLine = true
    -- btnResetAATM.OnClick = function ()
    --     ResetATM(true)
    --     Apply_TheOptimizationIsUnspoken()
    -- end


    local collapseParamsLTN = p:AddCollapsingHeader('Lighting')
    collapseParamsLTN.IDContext = 'awdaowikdn'

    local collapseParamsATM = p:AddCollapsingHeader('Atmosphere') 
    collapseParamsATM.IDContext = 'awdaowikdn'


    --half(80%)-slop
    function CreateUI(uuid, resource, mainParent, order)

        Imgui.ClearChildren(mainParent)

        local treeParameterName
        local treeSubParameterName
        
        local PARAMETER_ORDER = order

        local function getSortedKeys(tbl)
            local keys = {}
            local orderMap = {}
            
            for i, key in ipairs(PARAMETER_ORDER) do
                orderMap[key] = i
            end
            
            for k in pairs(tbl) do
                table.insert(keys, k)
            end
            
            table.sort(keys, function(a, b)
                local orderA = orderMap[a] or 9999
                local orderB = orderMap[b] or 9999
                
                if orderA ~= orderB then
                    return orderA < orderB
                else
                    return a < b
                end
            end)
            
            return keys
        end


        local function isColorParam(key)
            local excludeKeys = {
                "BlendedColorCorrection",
                "ColorCorrection",
                "ColorCorrectionInterpolationFactor"
            }
            
            for _, excludeKey in ipairs(excludeKeys) do
                if key == excludeKey or string.find(key, excludeKey) then
                    return false
                end
            end

            local colorKeys = {
                "Color", "Albedo", "BaseColor", "TopColor",
                "LinearClearColor", "CirrusCloudsColor",
                "ColorAdjustedForIntensity", "ColorTemperatureAdjustment",
                "SunColor", "ScatteringSunColor",
            }
            for _, colorKey in ipairs(colorKeys) do
                if key == colorKey or string.find(key, colorKey) then
                    return true
                end
            end
            return false
        end

        local function isVectorParam(key)
            local vectorKeys = {
                "NoiseFrequency", "NoiseRotation", "NoiseWind",
                "RotationAsVec3", "Offset", "ProcStarsSaturation"
            }
            for _, vectorKey in ipairs(vectorKeys) do
                if key == vectorKey or string.find(key, vectorKey) then
                    return true
                end
            end
            return false
        end

        local function isStringParam(key)
            local stringKeys = {
                "GUID", "ResourceGUID", "Tex", "ParentGUID",
                "AlbedoTexResourceGUID", "NormalTexResourceGUID",
                "TearsAlbedoTexResourceGUID", "TearsNormalTexResourceGUID",
                "TexResourceGUID", "SkydomeTex"
            }
            for _, stringKey in ipairs(stringKeys) do
                if key == stringKey or string.find(key, stringKey) then
                    return true
                end
            end
            return false
        end

        local function isBooleanParam(key)
            local booleanKeys = {
                "Enabled", "CastLightEnabled", "UseTemperature",
                "RotateSkydomeEnabled", "ScatteringEnabled", "SkydomeEnabled",
                "ShadowEnabled", "LocalCoverageEnabled", "LinearClearColorOverride",
                "TimelineFogOverride", "CirrusCloudsEnabled", "ProcStarsEnabled"
            }
            for _, booleanKey in ipairs(booleanKeys) do
                if key == booleanKey or string.find(key, booleanKey) then
                    return true
                end
            end
            return false
        end

        local function isIntParam(key)
            local intKeys = {
                "ShadowObscurity", "SunlightObscurity", "CascadeCount", "PhysicalModel", 'DirectLightInfluence'
            }
            for _, intKey in ipairs(intKeys) do
                if key == intKey or string.find(key, intKey) then
                    return true
                end
            end
            return false
        end


        local CONFIG = {

            -- Fog layers
            ["Fog.Phase"] = {min = -100, max = 100},
            ["Fog.RenderDistance"] = {min = 100.00, max = 10000.00},
            ["Fog.FogLayer0.Density0"] = {min = 0, max = 100, log = true},
            ["Fog.FogLayer0.Density1"] = {min = 0, max = 100, log = true},
            ["Fog.FogLayer0.Height0"]  = {min = -100, max = 100, log = true},
            ["Fog.FogLayer0.Height1"]  = {min = -100, max = 100, log = true},
            ["Fog.FogLayer0.NoiseCoverage"] = {min = 0, max = 100},
            ["Fog.FogLayer0.NoiseFrequency"] = {min = 0, max = 1},
            
            ["Fog.FogLayer1.Density0"] = {min = 0, max = 100, log = true},
            ["Fog.FogLayer1.Density1"] = {min = 0, max = 100, log = true},
            ["Fog.FogLayer1.Height0"]  = {min = -100, max = 100, log = true},
            ["Fog.FogLayer1.Height1"]  = {min = -100, max = 100, log = true},
            ["Fog.FogLayer1.NoiseCoverage"] = {min = 0, max = 100},
            ["Fog.FogLayer1.NoiseFrequency"] = {min = 0, max = 1},

            -- SkyLight
            ["SkyLight.Intensity"] = {min = 0, max = 200000, log = true},
            ["SkyLight.Kelvin"] = {min = 1000, max = 20000},
            ["SkyLight.CirrusCloudsAmount"] = {min = 0, max = 1},
            ["SkyLight.ProcStarsSaturation"] = {min = 0, max = 1},
            ["SkyLight.ProcStarsIntensity"] = {min = 0, max = 200000.09, log = true},
            ["SkyLight.ProcStarsAmount"] = {min = 0, max = 10.00},
            ["SkyLight.ProcStarsShimmer"] = {min = 0, max = 10.00},
            ["SkyLight.ScatteringIntensity"] = {min = 0, max = 35000.00, log = true},
            ["SkyLight.ScatteringSunIntensity"] = {min = 0, max = 120000.00, log = true},
            ["SkyLight.PhysicalModel"] = {min = 0, max = 4},

            -- Sun
            ["Sun.Intensity"] = {min = 0, max = 120000, log = true},
            ["Sun.Yaw"] = {min = 0, max = 360},
            ["Sun.Pitch"] = {min = 0, max = 360},
            ["Sun.Kelvin"] = {min = 1000, max = 25000.00},
            ["Sun.ShadowFade"] = {min = 0, max = 1},
            ["Sun.ShadowFarPlane"] = {min = 0.10, max = 1000, log = true},
            ["Sun.ShadowNearPlane"] = {min = 0.10, max = 1000, log = true},
            ["Sun.CascadeSpeed"] = {min = 0, max = 1},
            ["Sun.CascadeCount"] = {min = 0, max = 4},
            ["Sun.LightDistance"] = {min = 1, max = 1000},
            ["Sun.LightSize"] = {min = 0, max = 5},
            ["Sun.ShadowObscurity"] = {min = 0, max = 200},
            ["Sun.ShadowBias"] = {min = 0, max = 3},
            ["Sun.SunlightObscurity"] = {min = 0, max = 3},
            ["Sun.CoverageSettings.EndHeight"] = {min = 0, max = 10000},
            ["Sun.CoverageSettings.HorizonDistance"] = {min = 0, max = 50000.00},
            ["Sun.CoverageSettings.StartHeight"] = {min = 0, max = 5000.00},
            ["Sun.CoverageSettings.Offset"] = {min = 0, max = 1},

            -- Moon
            ["Moon.Intensity"] = {min = 0, max = 120000, log = true},
            ["Moon.Yaw"] = {min = 0, max = 360},
            ["Moon.Pitch"] = {min = 0, max = 360},
            ["Moon.Kelvin"] = {min = 1000, max = 25000.00},
            ["Moon.Radius"] = {min = 0, max = 50000.000},
            ["Moon.Earthshine"] = {min = 0, max = 1},
            ["Moon.Glare"] = {min = 0, max = 1},
            ["Moon.Distance"] = {min = 0.000, max = 50000.000},
            ["Moon.TearsScale"] = {min = 0, max = 10.000},
            ["Moon.TearsRotate"] = {min = -180, max = 180},


            -- SSAOSettings
            ["SSAOSettings.Bias"] = {min = 0, max = 2},
            ["SSAOSettings.Intensity"] = {min = 0, max = 10},
            ["SSAOSettings.Radius"] = {min = 0, max = 10},
            ["SSAOSettings.DirectLightInfluence"] = {min = 0, max = 1},

            -- TimelineFog
            ["TimelineFog.FogLayer0.Density0"] = {min = 0, max = 1, log = true},
            ["TimelineFog.FogLayer0.Density1"] = {min = 0, max = 1, log = true},
            ["TimelineFog.FogLayer1.Density0"] = {min = 0, max = 1, log = true},
            ["TimelineFog.FogLayer1.Density1"] = {min = 0, max = 1, log = true},

            -- VolumetricCloudSettings
            ["VolumetricCloudSettings.Intensity"] = {min = 0, max = 60000.00, log = true},
            ["VolumetricCloudSettings.AmbientLightFactor"] = {min = 0, max = 1},
            ["VolumetricCloudSettings.ConeRadius"] = {min = 0, max = 1},
            ["VolumetricCloudSettings.CoverageStartDistance"] = {min = 0, max = 1},
            ["VolumetricCloudSettings.CoverageEndDistance"] = {min = 0, max = 1},
            ["VolumetricCloudSettings.Density"] = {min = 0, max = 5},
            ["VolumetricCloudSettings.DetailScale"] = {min = 0, max = 20},
            ["VolumetricCloudSettings.RainCoverageMaxInfluence"] = {min = 0, max = 10},
            ["VolumetricCloudSettings.SunLightFactor"] = {min = 0, max = 1},
            ["VolumetricCloudSettings.SunRayLength"] = {min = 0, max = 100},

            
            ["PostProcess.Camera.LensFlareChromaticDistortion"] = {min = 0, max = 5},
            ["PostProcess.Camera.LensFlareGhostDispersal"] = {min = 0, max = 1},
            ["PostProcess.Camera.LensFlareHaloWidth"] = {min = 0, max = 1},
            ["PostProcess.Camera.LensFlareIntensity"] = {min = 0, max = 1},
            ["PostProcess.Camera.LensFlareTreshold"] = {min = 0, max = 10},

            ["PostProcess.Camera.GodRaysPower"] = {min = 0, max = 50},
            ["PostProcess.Camera.GodRaysRayIntensity"] = {min = 0, max = 10},
            ["PostProcess.Camera.GodRaysThreshold"] = {min = 0, max = 10},
            
            
        }

        local function trev(tbl, tbl2, depth, parent, path)
            tbl2 = tbl2 or {}
            depth = depth or 1
            path = path or {}
            
            for _, k in ipairs(getSortedKeys(tbl)) do
                local v = tbl[k]
                local currentPath = {}
                for i, p in ipairs(path) do
                    currentPath[i] = p
                end
                table.insert(currentPath, k)
                
                if type(v) == 'table' or type(v) == 'userdata' then
                    if isColorParam(k) then
                        if parent then
                            local colorEdit = parent:AddColorEdit(k)
                            colorEdit.IDContext = Ext.Math.Random(1,1000)
                            colorEdit.Color = {v[1] or 0, v[2] or 0, v[3] or 0, 1}
                            local p = currentPath
                            colorEdit.OnChange = function(e)
                                local target = Resource:GetResource(uuid, resource)
                                for i = 1, #p - 1 do
                                    target = target[p[i]]
                                end
                                target[p[#p]] = {e.Color[1], e.Color[2], e.Color[3]}
                            end
                        end
                        tbl2[k] = v
                    elseif isVectorParam(k) then
                        if parent then
                            local p = currentPath
                            local keyPath = table.concat(p, ".")
                            local conf = CONFIG[keyPath]
                            local minVal, maxVal, isLog = 0, 1, false
                            if conf then
                                minVal = conf.min or minVal
                                maxVal = conf.max or maxVal
                                isLog = conf.log or false
                            end

                            local slider = parent:AddSlider(k, 1, minVal, maxVal, 1)
                            slider.IDContext = Ext.Math.Random(1,1000)
                            slider.Value = {v[1] or 0, v[2] or 0, v[3] or 0, 0}
                            if isLog then slider.Logarithmic = true end
                            
                            
                            if k == 'ProcStarsSaturation' or k == 'Offset' or k == 'XYOffset' then --haha
                                slider.Components = 2
                                slider.OnChange = function(e)
                                    local target = Resource:GetResource(uuid, resource)
                                    for i = 1, #p - 1 do
                                        target = target[p[i]]
                                    end
                                    target[p[#p]] = {e.Value[1], e.Value[2]}
                                end
                            else
                                slider.Components = 3
                                slider.OnChange = function(e)
                                    local target = Resource:GetResource(uuid, resource)
                                    for i = 1, #p - 1 do
                                        target = target[p[i]]
                                    end
                                    target[p[#p]] = {e.Value[1], e.Value[2], e.Value[3]}
                                end
                            end

                        end
                        tbl2[k] = v
                    else
                        if depth == 1 then
                            treeParameterName = mainParent:AddTree(k)
                            tbl2[k] = {}
                            trev(v, tbl2[k], depth + 1, treeParameterName, currentPath)
                        elseif depth == 2 then
                            treeSubParameterName = parent:AddTree(k)
                            tbl2[k] = {}
                            trev(v, tbl2[k], depth + 1, treeSubParameterName, currentPath)
                        else
                            tbl2[k] = {}
                            trev(v, tbl2[k], depth + 1, parent, currentPath)
                        end
                    end
                else
                    if parent then
                        local p = currentPath
                        if isBooleanParam(k) or type(v) == 'boolean' then
                            local checkbox = parent:AddCheckbox(k)
                            checkbox.IDContext = Ext.Math.Random(1,1000)
                            checkbox.Checked = v
                            checkbox.OnChange = function(e)
                                local target = Resource:GetResource(uuid, resource)
                                for i = 1, #p - 1 do
                                    target = target[p[i]]
                                end
                                target[p[#p]] = e.Checked
                            end
                        elseif isStringParam(k) or type(v) == 'string' then
                            local inputText = parent:AddInputText(k)
                            inputText.IDContext = Ext.Math.Random(1,1000)
                            inputText.Text = tostring(v)
                            inputText.OnChange = function(e)
                                local target = Resource:GetResource(uuid, resource)
                                for i = 1, #p - 1 do
                                    target = target[p[i]]
                                end
                                target[p[#p]] = e.Text
                            end
                        elseif isIntParam(k) then
                            local keyPath = table.concat(p, ".")
                            local conf = CONFIG[keyPath]
                            local minVal, maxVal, isLog = 0, 100, false
                            if conf then
                                minVal = conf.min or minVal
                                maxVal = conf.max or maxVal
                                isLog = conf.log or false
                            end

                            local sliderInt = parent:AddSliderInt(k, 1, minVal, maxVal, 1)
                            sliderInt.IDContext = Ext.Math.Random(1,1000)
                            sliderInt.Value = {v, 0, 0, 0}
                            if isLog then sliderInt.Logarithmic = true end

                            sliderInt.OnChange = function(e)
                                local target = Resource:GetResource(uuid, resource)
                                for i = 1, #p - 1 do
                                    target = target[p[i]]
                                end
                                target[p[#p]] = e.Value[1]
                            end

                        else
                            local keyPath = table.concat(p, ".")
                            local conf = CONFIG[keyPath]
                            local minVal, maxVal, isLog = 0, 1, false
                            if conf then
                                minVal = conf.min or minVal
                                maxVal = conf.max or maxVal
                                isLog = conf.log or false
                            end
                            -- DPrint('k: %s, keypath: %s, min: %s, max: %s',k, keyPath, minVal,maxVal)
                            local slValue = parent:AddSlider(k, 1, minVal, maxVal, 1)
                            slValue.IDContext = Ext.Math.Random(1,1000)
                            slValue.Value = {v, 0, 0, 0}
                            if isLog then slValue.Logarithmic = true end

                            slValue.OnChange = function(e)
                                local target = Resource:GetResource(uuid, resource)
                                for i = 1, #p - 1 do
                                    target = target[p[i]]
                                end
                                target[p[#p]] = e.Value[1]
                            end
                        end
                    end
                    tbl2[k] = v
                end
            end
            return tbl2
        end
        
        -- DPrint(uuid)
        -- DPrint(resource)
        trev(Resource:GetResource(uuid, resource))

    end




    local uuid = '375af627-6f3c-19e8-1046-29265ae9e8f7'
    local resource = 'Lighting'
    local mainParent = collapseParamsLTN
    CreateUI(uuid, resource, mainParent, LTN_ORDER)

    local uuid = '73e03af9-7ab1-47a7-906b-a4e0362045ef'
    local resource = 'Atmosphere'
    local mainParent = collapseParamsATM
    CreateUI(uuid, resource, mainParent, LTN_ORDER)


    function comboLightingFunc()
        Ext.Net.PostMessageToServer('LL_LightingApply', UI:SelectedOpt(GlobalsIMGUI.comboLighting))
        CreateUI(ltn_templates2[UI:SelectedOpt(GlobalsIMGUI.comboLighting)], 'Lighting', collapseParamsLTN, LTN_ORDER) --yes.
    end

    function comboAtmosphereFunc()
        Ext.Net.PostMessageToServer('LL_AtmosphereApply', UI:SelectedOpt(GlobalsIMGUI.comboAtmosphere))
        CreateUI(atm_templates2[UI:SelectedOpt(GlobalsIMGUI.comboAtmosphere)], 'Atmosphere', collapseParamsATM, ATM_ORDER) --yes.
    end

    
    function Apply_TheOptimizationIsUnspoken()
        UI:PrevOption(GlobalsIMGUI.comboLighting)
        comboLightingFunc()
        comboAtmosphereFunc()
        Helpers.Timer:OnTicks(5, function ()
            UI:NextOption(GlobalsIMGUI.comboLighting)
            comboLightingFunc()
            comboAtmosphereFunc()
        end)
    end

    
    function ResetLTN(all)
        if all then
            for name, uuid in pairs(ltn_templates2) do
                ApplyCachedLighting(uuid, ZipBomb.CachedLighting)
            end
        else
            local uuid = ltn_templates2[UI:SelectedOpt(GlobalsIMGUI.comboLighting)]
            ApplyCachedLighting(uuid, ZipBomb.CachedLighting)
        end
    end

        
    function ResetATM(all)
        if all then
            for name, uuid in pairs(atm_templates2) do
                ApplyCachedAtmosphere(uuid, ZipBomb.CachedAtmosphere)
            end
        else
            local uuid = atm_templates2[UI:SelectedOpt(GlobalsIMGUI.comboAtmosphere)]
            ApplyCachedAtmosphere(uuid, ZipBomb.CachedAtmosphere)
        end
    end


    function ApplyCachedLighting(uuid, CachedTable)
        local CachedLTN = CachedTable[uuid]
        if CachedLTN then
            local values = CachedLTN[2]
            local lighting = Resource:GetResource(uuid, 'Lighting')
            for k, v in pairs(values) do
                lighting[k] = v
            end
        end
    end

    
    function ApplyCachedAtmosphere(uuid, CachedTable)
        local CachedATM = CachedTable[uuid]
        if CachedATM then
            local values = CachedATM[2]
            local atmosphere = Resource:GetResource(uuid, 'Atmosphere')
            for k, v in pairs(values) do
                atmosphere[k] = v
            end
        end
    end

end
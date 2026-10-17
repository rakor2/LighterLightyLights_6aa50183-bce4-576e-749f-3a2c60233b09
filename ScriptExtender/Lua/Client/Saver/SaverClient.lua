local Saver = {}
Saver.Scene = {}
Saver.selectedScene = mil

function Saver2Tab(p)
    p:AddSeparatorText('Do not use. Unless you are knower')


    function LoadSavedScene()
        local SavedScene = Ext.IO.LoadFile('LightyLights/Scenes/1a_SAVED_SCENES.json')
        if SavedScene then
            DPrint('SavedScenes')
            Saver.SavedScene = Ext.Json.Parse(SavedScene)
            Saver.selectedScene = Saver.SavedScene[1]
        else
            DPrint('No SavedScenes')
            Ext.IO.SaveFile('LightyLights/Scenes/1a_SAVED_SCENES.json', Ext.Json.Stringify({}))
            Saver.SavedScene = Ext.Json.Parse(Ext.IO.LoadFile('LightyLights/Scenes/1a_SAVED_SCENES.json'))
        end
        return Saver.SavedScene
    end



    E.comboScenes = p:AddCombo('')
        UI:Config(E.comboScenes, {
            Options = LoadSavedScene(),
            SelectedIndex = 0,
            OnChange = function(e)
                Saver.selectedScene = UI:SelectedOpt(e)
                Ch.SelectedScene:SendToServer(UI:SelectedOpt(e))
            end
        })



    E.btnLoadScene = p:AddButton('Load')
        UI:Config(E.btnLoadScene, {
            SameLine = true,
            OnClick = function(e)
                local json = Ext.IO.LoadFile('LightyLights/Scenes/' .. Saver.selectedScene .. '.json')
                if not json then return end

                Ch.SelectedScene:SendToServer(UI:SelectedOpt(E.comboScenes))
                Saver.Scene = Ext.Json.Parse(json)

                local GSC = Saver.Scene.Client
                local Lights = GSC.LightsUuidNameMap or {}
                local SavedCreated = GSC.CreatedLightsServer or {}
                local SavedParams = GSC.LightParametersClient or {}
                local GSS = Saver.Scene.Server

                local UuidMap = {}
                local SavedLightType = lightType

                local function CreateNext(i)
                    if i > #Lights then
                        lightType = SavedLightType

                        _GLL.selectedUuid = UuidMap[GSC.selectedUuid] or _GLL.selectedUuid

                        UpdateCreatedLightsCombo()
                        UpdateElements(_GLL.selectedUuid)

                        Ch.SceneLoad:RequestToServer(UuidMap, function(Response)
                            Ch.SelectedLight:SendToServer(_GLL.selectedUuid)
                        end)
                        return
                    end

                    local Entry = Lights[i]
                    local oldUuid = Entry.uuid
                    local rtUuid = SavedCreated[oldUuid]
                    local Params = SavedParams[oldUuid]

                    lightType = EnumLighType[Params and Params.LightType] or 'Point'

                    OnTicks(1, function()
                        -- DPrint('20')
                        CreateLight(rtUuid)

                        OnTicks(30 + Settings.lightCreateDelay, function()
                            -- DPrint('40')

                            local newUuid = _GLL.selectedUuid

                            -- if not newUuid then
                            --     lightType = SavedLightType
                            --     CreateNext(i + 1)
                            --     return
                            -- end

                            UuidMap[oldUuid] = newUuid

                            local Params = SavedParams[oldUuid]
                            if Params then
                                _GLL.LightParametersClient[newUuid] = Params
                                SetLightType(Params.LightType)
                                SetLightColor(Params.Color)
                                SetLightIntensity(Params.Intensity)
                                SetLightRadius(Params.Radius)
                                SetLightOuterAngle(Params.SpotLightOuterAngle)
                                SetLightInnerAngle(Params.SpotLightInnerAngle)
                                SetLightDirectionalParameters('DirectionLightAttenuationEnd',      Params.DirectionLightAttenuationEnd)
                                SetLightDirectionalParameters('DirectionLightAttenuationFunction', Params.DirectionLightAttenuationFunction)
                                SetLightDirectionalParameters('DirectionLightAttenuationSide',     Params.DirectionLightAttenuationSide)
                                SetLightDirectionalParameters('DirectionLightAttenuationSide2',    Params.DirectionLightAttenuationSide2)
                                SetLightDirectionalParameters('DirectionLightDimensions',          Params.DirectionLightDimensions)
                                SetLightFill(Params.Flags)
                                SetLightScattering(Params.ScatteringIntensityScale)
                                SetLightEdgeSharp(Params.EdgeSharpening)
                                SetLightChannel(Params.SliderLightChannelFlag)
                            end

                            -- for _, light in ipairs(_GLL.LightsUuidNameMap) do
                            --     if light.uuid == newUuid then
                            --         light.name = Entry.name
                            --         light.nameIndex = Entry.nameIndex
                            --         break
                            --     end
                            -- end

                            -- nameIndex = GSC.nameIndex or 0
                            UpdateElements(newUuid)

                            CreateNext(i + 1)
                        end)
                    end)
                end

                CreateNext(1)
            end
        })



    E.inputSceneName = p:AddInputText('')
    E.inputSceneName.IDContext = 'ad;ajndklajdn'

    E.btnSaveScene = p:AddButton('Save')
    E.btnSaveScene.SameLine = true
    E.btnSaveScene.OnClick = function(e)
        local sceneName = E.inputSceneName.Text

        if sceneName ~= '' then
            Saver.Scene.Client = {
                CreatedLightsServer   = _GLL.CreatedLightsServer,
                LightsUuidNameMap     = _GLL.LightsUuidNameMap,
                LightParametersClient = _GLL.LightParametersClient,
                selectedUuid          = _GLL.selectedUuid,
                nameIndex             = nameIndex,
                sceneName             = sceneName
            }

            Ch.SceneSave:SendToServer(Saver.Scene.Client)

            OnTicks(5, function()
                E.comboScenes.Options = LoadSavedScene()
            end)

        else
            DError('No scene name')
        end
    end


    local txtInfo = p:AddText('Perhaps some scene info here idk:')

    local txtInfo = p:AddSeparatorText('Warning')
    local txtInfo = p:AddText([[Scene saves relative to the world coordinates.
If you load your scene on different levels, it will be recreated in different places]])


end

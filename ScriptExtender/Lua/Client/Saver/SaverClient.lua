local Saver = {}
Saver.Scene = {}
Saver.selectedScene = mil

function Saver2Tab(p)
    p:AddSeparatorText('Save lights')


    function LoadSavedScene()
        local SavedScene = Ext.IO.LoadFile('LightyLights/Scenes/1a_SAVED_SCENES.json')
        if SavedScene then
            -- DPrint('SavedScenes')
            Saver.SavedScene = Ext.Json.Parse(SavedScene)
            Saver.selectedScene = Saver.SavedScene[1]
        else
            -- DPrint('No SavedScenes')
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
                -- local SavedLightType = lightType

                local function CreateNext(i)
                    if i > #Lights then
                        -- lightType = SavedLightType

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

                    OnTicks(0, function()
                        -- DPrint('20')
                        CreateLight(rtUuid)

                        -- OnTicks(40 + Settings.lightCreateDelay, function()
                        Ext.Timer.WaitFor(100 + Settings.lightCreateDelay, function()
                            -- DPrint('40')

                            local newUuid = _GLL.selectedUuid
                            _GLL.selectedEntity = Ext.Entity.Get(newUuid)
                            -- if not newUuid then
                            --     lightType = SavedLightType
                            --     CreateNext(i + 1)
                            --     return
                            -- end

                            UuidMap[oldUuid] = newUuid

                            local Params = SavedParams[oldUuid]
                            if Params then
                                _GLL.LightParametersClient[newUuid] = Params
                                SetLightType(Params.LightType, newUuid)
                                SetLightColor(Params.Color, newUuid)
                                SetLightIntensity(Params.Intensity, newUuid)
                                SetLightRadius(Params.Radius, newUuid)
                                SetLightOuterAngle(Params.SpotLightOuterAngle, newUuid)
                                SetLightInnerAngle(Params.SpotLightInnerAngle, newUuid)
                                SetLightDirectionalParameters('DirectionLightAttenuationEnd',      Params.DirectionLightAttenuationEnd, newUuid)
                                SetLightDirectionalParameters('DirectionLightAttenuationFunction', Params.DirectionLightAttenuationFunction, newUuid)
                                SetLightDirectionalParameters('DirectionLightAttenuationSide',     Params.DirectionLightAttenuationSide, newUuid)
                                SetLightDirectionalParameters('DirectionLightAttenuationSide2',    Params.DirectionLightAttenuationSide2, newUuid)
                                SetLightDirectionalParameters('DirectionLightDimensions',          Params.DirectionLightDimensions, newUuid)
                                SetLightFill(Params.Flags, newUuid)
                                SetLightScattering(Params.ScatteringIntensityScale, newUuid)
                                SetLightEdgeSharp(Params.EdgeSharpening, newUuid)
                                SetLightChannel(Params.SliderLightChannelFlag, newUuid)
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




    E.btnDeleteScene = p:AddButton('Delete')
    local resetId = UI:CreateConfirmButton(p, E.btnDeleteScene, 'Delete', function()
        local sceneName = UI:SelectedOpt(E.comboScenes)
        Ext.IO.SaveFile('LightyLights/Scenes/' .. sceneName ..'.json', Ext.Json.Stringify({}))

        local SavedScene = Ext.Json.Parse(Ext.IO.LoadFile('LightyLights/Scenes/1a_SAVED_SCENES.json'))
        local index = table.find(SavedScene, sceneName)
        table.remove(SavedScene, index)
        Ext.IO.SaveFile('LightyLights/Scenes/1a_SAVED_SCENES.json', Ext.Json.Stringify(SavedScene))

        OnTicks(5, function()
            E.comboScenes.Options = LoadSavedScene()
            E.comboScenes.SelectedIndex = 0
        end)

    end)
        UI:Config(E.btnDeleteScene, {
            OnClick = function()
                UI:Confirm(E.btnDeleteScene, resetId, 60)
            end
        })



    local txtInfo = p:AddText([[Perhaps some lights info here idk:
like level name anddddddddd
for now just put level name in the name yourself]])

    local txtInfo = p:AddSeparatorText('Warning')
    local txtInfo = p:AddText([[Currently saves lights relative to the world coordinates.
If you load your scene on different levels, it will be recreated in different places.
Currently won't save light names.]])


end

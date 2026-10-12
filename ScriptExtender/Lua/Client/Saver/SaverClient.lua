_GLL.Scene = {}
_GLL.Scene.Client = {}
_GLL.Scene.Server = {}



function Saver2Tab(p)
    local btnSaveScene = p:AddButton('Save scene')
    btnSaveScene.OnClick = function(e)
        _GLL.Scene.Client = {
            CreatedLightsServer   = _GLL.CreatedLightsServer,
            LightsUuidNameMap     = _GLL.LightsUuidNameMap,
            -- LightsNames           = _GLL.LightsNames,
            LightParametersClient = _GLL.LightParametersClient,
            selectedUuid          = _GLL.selectedUuid,
            -- markerUuid            = _GLL.markerUuid,
            -- selectedGobo          = _GLL.selectedGobo,
            nameIndex             = nameIndex,
        }
        Ch.SceneSave:SendToServer(_GLL.Scene.Client)
    end



    local btnLoadScene = p:AddButton('Load scene')
    btnLoadScene.OnClick = function(e)
        local json = Ext.IO.LoadFile("LightyLights/SceneState.json")
        _GLL.Scene = Ext.Json.Parse(json)

        local GSC = _GLL.Scene.Client
        local GSS = _GLL.Scene.Server
        local LightsUuidNameMap = GSC.LightsUuidNameMap

        local function createNext(i)
            if i > #LightsUuidNameMap then
                Ch.SceneLoad:RequestToServer(_GLL.LightsUuidNameMap, function(Response)
                    Ch.SelectedLight:SendToServer(_GLL.selectedUuid)
                end)
                return
            end

            local savedLight = LightsUuidNameMap[i]
            local oldUuid    = savedLight.uuid
            local rtUuid     = GSC.CreatedLightsServer[oldUuid]
            local LPS        = GSS.LightParametersServer[oldUuid]


            local Color     = GSC.LightParametersClient[oldUuid].Color
            local lightType = GSC.LightParametersClient[oldUuid].LightType
            local radius    = GSC.LightParametersClient[oldUuid].Radius

            Ext.OnNextTick(function()
                if lightType == 'Spotlight'   then lt = 'Spot' end
                if lightType == 'Directional' then lt = 'Direction' end
                Ext.Template.GetRootTemplate('aca228c3-f0c5-41e0-bc00-d11ddee12ed0').LightType = lt or 'Point'
                Ext.Template.GetRootTemplate('aca228c3-f0c5-41e0-bc00-d11ddee12ed0').Color = Color or {1,1,1}
                Ext.Template.GetRootTemplate('aca228c3-f0c5-41e0-bc00-d11ddee12ed0').Radius = radius or 5
                --- Int = 100
            end)

            CreateLight(rtUuid)

            Helpers.Timer:OnTicks(25, function()
                local newUuid     = _GLL.selectedUuid
                local SavedParams = GSC.LightParametersClient[oldUuid]

                if SavedParams then
                    _GLL.LightParametersClient[newUuid] = SavedParams
                    SetLightType(SavedParams.LightType)
                    SetLightColor(SavedParams.Color)
                    SetLightIntensity(SavedParams.Intensity)
                    SetLightRadius(SavedParams.Radius)
                    SetLightOuterAngle(SavedParams.SpotLightOuterAngle)
                    SetLightInnerAngle(SavedParams.SpotLightInnerAngle)
                    SetLightDirectionalParameters('DirectionLightAttenuationEnd',      SavedParams.DirectionLightAttenuationEnd)
                    SetLightDirectionalParameters('DirectionLightAttenuationFunction', SavedParams.DirectionLightAttenuationFunction)
                    SetLightDirectionalParameters('DirectionLightAttenuationSide',     SavedParams.DirectionLightAttenuationSide)
                    SetLightDirectionalParameters('DirectionLightAttenuationSide2',    SavedParams.DirectionLightAttenuationSide2)
                    SetLightDirectionalParameters('DirectionLightDimensions',          SavedParams.DirectionLightDimensions)
                    SetLightFill(SavedParams.Flags)
                    SetLightScattering(SavedParams.ScatteringIntensityScale)
                    SetLightEdgeSharp(SavedParams.EdgeSharpening)
                    SetLightChannel(SavedParams.SliderLightChannelFlag)
                    UpdateElements(newUuid)
                end

                local light = _GLL.LightsUuidNameMap[i]
                if light then
                    light.name      = savedLight.name
                    light.nameIndex = savedLight.nameIndex
                end
                UpdateCreatedLightsCombo()

                --- Slop for fun
                if LPS then
                    Ch.SceneAnimate:SendToServer({{
                        uuid = newUuid,
                        tx = LPS.Translate[1],
                        ty = LPS.Translate[2],
                        tz = LPS.Translate[3],
                        rx = LPS.HumanRotation[1],
                        ry = LPS.HumanRotation[2],
                        rz = LPS.HumanRotation[3],
                    }})
                end
                createNext(i + 1)
            end)
        end
        createNext(1)
    end
end
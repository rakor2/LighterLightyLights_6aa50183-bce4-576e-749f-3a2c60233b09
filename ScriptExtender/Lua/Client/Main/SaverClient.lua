_GLL.Scene = {}
_GLL.Scene.Client = {}
_GLL.Scene.Server = {}



function Saver2Tab(p)
    local btnSaveScene = p:AddButton('Save scene')
    btnSaveScene.OnClick = function(e)
        _GLL.Scene.Client = {
            CreatedLightsServer   = _GLL.CreatedLightsServer,
            LightsUuidNameMap     = _GLL.LightsUuidNameMap,
            LightsNames           = _GLL.LightsNames,
            LightParametersClient = _GLL.LightParametersClient,
            selectedUuid          = _GLL.selectedUuid,
            markerUuid            = _GLL.markerUuid,
            selectedGobo          = _GLL.selectedGobo,
            nameIndex             = nameIndex,
        }
        Ch.SceneSave:SendToServer(_GLL.Scene.Client)
    end



    local btnLoadScene = p:AddButton('Load scene')
    btnLoadScene.OnClick = function(e)
        local json = Ext.IO.LoadFile("LightyLights/SceneState.json")
        _GLL.Scene = Ext.Json.Parse(json)

        local gsc = _GLL.Scene.Client
        local gss = _GLL.Scene.Server
        local LightsUuidNameMap = gsc.LightsUuidNameMap

        nameIndex = 0

        local function createNext(i)
            if i > #LightsUuidNameMap then
                Ch.SceneLoad:RequestToServer(_GLL.LightsUuidNameMap, function(Response)
                end)
                return
            end

            local savedLight     = LightsUuidNameMap[i]
            local oldUuid        = savedLight.uuid
            local rtUuid         = gsc.CreatedLightsServer[oldUuid]
            local savedLightType = lightType

            if     savedLight.name:find('Spotlight')   then lightType = 'Spotlight'
            elseif savedLight.name:find('Directional') then lightType = 'Directional'
            else                                            lightType = 'Point'
            end

            CreateLight(rtUuid)

            Helpers.Timer:OnTicks(25, function()
                lightType = savedLightType

                local newUuid     = _GLL.selectedUuid
                local SavedParams = gsc.LightParametersClient[oldUuid]

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

                createNext(i + 1)
            end)
        end

        createNext(1)
    end
end
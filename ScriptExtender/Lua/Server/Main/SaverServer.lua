local Saver = {}
Saver.Scene = {}
Saver.Scene.Client = {}
Saver.Scene.Server = {}

local selectedScene



Ch.SelectedScene:SetHandler(function(Data)
    selectedScene = Data
end)



Ch.SceneSave:SetHandler(function(Data)
    Saver.Scene.Client = Data
    Saver.Scene.Server = {
        CreatedLightsServer   = _GLL.CreatedLightsServer,
        LightParametersServer = _GLL.LightParametersServer,
        OrbitParams           = _GLL.OrbitParams,
        selectedUuid          = _GLL.selectedUuid,
    }

    local Json = Ext.Json.Stringify(Saver.Scene)
    Ext.IO.SaveFile('LightyLights/Scenes/' .. Data.sceneName ..'.json', Json)

    local SavedScene = Ext.Json.Parse(Ext.IO.LoadFile('LightyLights/Scenes/1a_SAVED_SCENES.json'))
    table.insert(SavedScene, Data.sceneName)
    Ext.IO.SaveFile('LightyLights/Scenes/1a_SAVED_SCENES.json', Ext.Json.Stringify(SavedScene))
end)



Ch.SceneLoad:SetRequestHandler(function(Data)
    if not selectedScene then return DError('No selected scene') end

    -- if not selectedScene then
    --     local SavedScene = Ext.Json.Parse(Ext.IO.LoadFile('LightyLights/Scenes/1a_SAVED_SCENES.json'))
    --     selectedScene = SavedScene[1]
    -- end

    local json = Ext.IO.LoadFile('LightyLights/Scenes/' .. selectedScene .. '.json')
    if not json then return false end

    Saver.Scene = Ext.Json.Parse(json)

    local GSC = Saver.Scene.Client
    local GSS = Saver.Scene.Server

    for oldUuid, newUuid in pairs(Data) do
        local LPS = GSS.LightParametersServer and GSS.LightParametersServer[oldUuid]
        local Orbit = GSS.OrbitParams and GSS.OrbitParams[oldUuid]

        if LPS then
            _GLL.LightParametersServer[newUuid]               = _GLL.LightParametersServer[newUuid] or {}
            _GLL.LightParametersServer[newUuid].Translate     = LPS.Translate
            _GLL.LightParametersServer[newUuid].HumanRotation = LPS.HumanRotation
            _GLL.LightParametersServer[newUuid].RotationQuat  = LPS.RotationQuat

            if LPS.Translate and LPS.HumanRotation then
                Osi.ToTransform(
                    newUuid,
                    LPS.Translate[1],
                    LPS.Translate[2],
                    LPS.Translate[3],
                    LPS.HumanRotation[1],
                    LPS.HumanRotation[2],
                    LPS.HumanRotation[3]
                )
            end
        end

        _GLL.OrbitParams[newUuid] = Orbit

    end

    _GLL.selectedUuid = Data[GSC.selectedUuid] or _GLL.selectedUuid

    return true
end)

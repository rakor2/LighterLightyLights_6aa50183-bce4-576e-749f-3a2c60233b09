_GLL.Scene = {}
_GLL.Scene.Client = {}
_GLL.Scene.Server = {}



Ch.SceneSave:SetHandler(function(Data)
    _GLL.Scene.Client = Data
    _GLL.Scene.Server = {
        CreatedLightsServer   = _GLL.CreatedLightsServer,
        LightParametersServer = _GLL.LightParametersServer,
        OrbitParams           = _GLL.OrbitParams,
        markerUuid            = _GLL.markerUuid,
        selectedUuid          = _GLL.selectedUuid,
        GoboLightMap          = _GLL.GoboLightMap,
        GoboDistances         = _GLL.GoboDistances,
    }
    local json = Ext.Json.Stringify(_GLL.Scene)
    Ext.IO.SaveFile("LightyLights/SceneState.json", json)
end)



Ch.SceneLoad:SetRequestHandler(function(Data)
    local json = Ext.IO.LoadFile("LightyLights/SceneState.json")
    _GLL.Scene = Ext.Json.Parse(json)
    local gsc = _GLL.Scene.Client
    local gss = _GLL.Scene.Server

    Helpers.Timer:OnTicks(1, function()
        for i, savedEntry in ipairs(gsc.LightsUuidNameMap) do
            local oldUuid  = savedEntry.uuid
            local newLight = Data[i]

            local newUuid = newLight.uuid
            local lps = gss.LightParametersServer[oldUuid]

            local x, y, z    = table.unpack(lps.Translate)
            local rx, ry, rz = table.unpack(lps.HumanRotation)

            _GLL.LightParametersServer[newUuid]               = _GLL.LightParametersServer[newUuid] or {}
            _GLL.LightParametersServer[newUuid].Translate     = lps.Translate
            _GLL.LightParametersServer[newUuid].RotationQuat  = lps.RotationQuat
            _GLL.LightParametersServer[newUuid].HumanRotation = lps.HumanRotation
            _GLL.OrbitParams[newUuid]                         = gss.OrbitParams[oldUuid]

            Osi.ToTransform(newUuid, x, y, z, rx, ry, rz)

            _GLL.selectedUuid = newUuid
            UpdateMarkerPosition()
        end
    end)

    return _GLL.Scene.Client
end)
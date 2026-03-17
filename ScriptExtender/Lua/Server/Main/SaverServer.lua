_GLL.Scene = {}
_GLL.Scene.Client = {}
_GLL.Scene.Server = {}



Ch.SceneSave:SetHandler(function(Data)
    _GLL.Scene.Client = Data
    _GLL.Scene.Server = {
        CreatedLightsServer   = _GLL.CreatedLightsServer,
        LightParametersServer = _GLL.LightParametersServer,
        OrbitParams           = _GLL.OrbitParams,
        -- markerUuid            = _GLL.markerUuid,
        selectedUuid          = _GLL.selectedUuid,
        -- GoboLightMap          = _GLL.GoboLightMap,
        -- GoboDistances         = _GLL.GoboDistances,
    }
    local json = Ext.Json.Stringify(_GLL.Scene)
    Ext.IO.SaveFile("LightyLights/SceneState.json", json)
end)



Ch.SceneLoad:SetRequestHandler(function(Data)
    _GLL.Scene = Ext.Json.Parse(Ext.IO.LoadFile("LightyLights/SceneState.json"))
    local GSC = _GLL.Scene.Client
    local GSS = _GLL.Scene.Server

    Helpers.Timer:OnTicks(1, function()
        for i, savedEntry in ipairs(GSC.LightsUuidNameMap) do
            local oldUuid  = savedEntry.uuid
            local newLight = Data[i]
            local newUuid  = newLight.uuid
            local LPS      = GSS.LightParametersServer[oldUuid]

            _GLL.LightParametersServer[newUuid]               = _GLL.LightParametersServer[newUuid] or {}

            _GLL.LightParametersServer[newUuid].Translate     = LPS.Translate
            _GLL.LightParametersServer[newUuid].RotationQuat  = LPS.RotationQuat
            _GLL.LightParametersServer[newUuid].HumanRotation = LPS.HumanRotation
            _GLL.OrbitParams[newUuid]                         = GSS.OrbitParams[oldUuid]
        end
    end)
    return _GLL.Scene.Client
end)



--- Slop for fun (it's dogshit, I don't care, my brain is fried, I want some fun)
Ch.SceneAnimate:SetHandler(function(Data)
    local STEPS       = 30
    local INTERVAL_MS = 50

    local function lerp(a, b, t) return Ext.Math.Lerp(a, b, t) end
    local function ease(t) return 1 - (1 - t) * (1 - t) end
    -- local function ease(t) return t end
    -- local function ease(t) return t * t end
    -- local function ease(t) return 1 - (1 - t) * (1 - t) * (1 - t) end


    for _, light in ipairs(Data) do
        local uuid          = light.uuid
        local tx, ty, tz    = light.tx, light.ty, light.tz
        local rx, ry, rz    = light.rx, light.ry, light.rz
        local sx, sy, sz    = Osi.GetPosition(uuid)
        local srx, sry, srz = Osi.GetRotation(uuid)
        local step = 0

        local function tick()
            step = step + 1
            local t = ease(step / STEPS)
            Osi.ToTransform(uuid,
                lerp(sx, tx, t), lerp(sy, ty, t), lerp(sz, tz, t),
                lerp(srx, rx, t), lerp(sry, ry, t), lerp(srz, rz, t)
            )
            if step < STEPS then
                Ext.Timer.WaitFor(INTERVAL_MS, tick)
            else
                _GLL.LightParametersServer[uuid].Translate     = {tx, ty, tz}
                _GLL.LightParametersServer[uuid].HumanRotation = {rx, ry, rz}
                _GLL.selectedUuid = uuid
            end
        end

        Ext.Timer.WaitFor(INTERVAL_MS, tick)
    end
end)

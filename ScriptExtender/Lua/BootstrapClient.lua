Ext.Require('_Libs/_InitLibs.lua')
-- Ext.Require("Shared/_Libs.lua")
Ext.Require('Shared/_init.lua')


gizmoLibError = false

if Mods.GizmoLib then
    Utils.StripPrefixes(Mods.LL2, Mods.GizmoLib)

    --- IDK WHY IT CAN'T KEEP UP WITH INITIALIZATIONS FOR SOME PEOPLE T_T
    --- HOPEFULLY THIS WILL HELP
    GL_GLOBALS = GL_GLOBALS or {}
    GL_GLOBALS = Mods.GizmoLib.GL_GLOBALS

    function initGizmoLibColors()
        if GL_GLOBALS and Mods.GizmoLib.GL_GLOBALS then
            local tb = GL_GLOBALS.TransformToolbar
            tb.TopToolBar:SetColor("WindowBg", Style.Colors.windowBg)
            tb.TopToolBar:SetColor("Text", Style.Colors.textColor)
            tb.TopToolBar:SetColor("FrameBg", Style.Colors.frameBg)
            tb.TopToolBar:SetColor("TextDisabled", Style.Colors.textDisabled)
            tb.TopToolBar:SetColor("Button", Style.Colors.button)

            tb.CloseButton:SetColor("Button", Style.Colors.special)
            tb.CloseButton:SetColor("ButtonActive", Style.Colors.buttonActive)
            tb.CloseButton:SetColor("ButtonHovered", Style.Colors.buttonHovered)
            Mods.GizmoLib.MCM.Set("boxsel_border_color", Style.Colors.special)
        end
    end



    _GLL.gizmo = API.CreateManipulator()
    _GLL.gizmo.Config.IsSelectableEntity = function(info)
        return info.Type == "Unknown"
    end



    API.Events.OnTransformApplied:Subscribe(function(Data)
        for k, Target in pairs(Data.Targets) do
            local dummy = Ext.Entity.Get(Target.Guid).HasDummy.Entity
            local Ser = Ext.Types.Serialize(dummy.Visual.Visual.WorldTransform)
            Ext.Types.Unserialize(dummy.DummyOriginalTransform.Transform, Ser)
            -- DDump(dummy.Visual.Visual.WorldTransform)
        end
    end)



    API.Events.OnClearSelection:Subscribe(function(Data)
        if not _GLL.States.inPhotoMode then return end
        _GLL.GizmoDummySelections = {}
        for k, v in pairs(_GLL.DummyNames) do
            E.checkAddTarget[v].Checked = false
        end
    end)



    API.Events.OnCommandExecuted:Subscribe(function(Data)
        DDump(Data)
    end)



    API.Events.OnMoveToCursor:Subscribe(function(Data)
        if not _GLL.States.inPhotoMode then return end
        local Dummies = Ext.Entity.GetAllEntitiesWithComponent('Dummy')
        for k, dummy in pairs(Dummies) do
            local Ser = Ext.Types.Serialize(dummy.Visual.Visual.WorldTransform)
            Ext.Types.Unserialize(dummy.DummyOriginalTransform.Transform, Ser)
        end
    end)

end


ZipBomb = ZipBomb or {}

CACHE_VERSION = '1.7.Bober'



local DEFAULT_SETTINGS = {
    {'openByDefaultPMCamera',   false},
    {'openByDefaultPMInfo',     false},
    {'openByDefaultPMPos',      false},
    {'openByDefaultPMRot',      false},
    {'openByDefaultPMScale',    false},
    {'openByDefaultPMLook',     false},
    {'openByDefaultPMSave',     false},
    {'openByDefaultMainGen',    false},
    {'openByDefaultMainPoint',  false},
    {'openByDefaultMainSpot',   false},
    {'openByDefaultMainDir',    false},
    {'openByDefaultMainAdd',    false},
    {'openByDefaultMainWorld',  false},
    {'openByDefaultMainChar',   false},
    {'openByDefaultMainRot',    false},
    {'defaultLightType',        'Point'},
    {'biggerPicker',            false},
    {'markerScale',             0.699999988079071},
    {'fadeTime',                0.150},
    {'defaultCameraSpeed',      6},
    {'lightSetupState',         true},
    {'markerOff',               false},
    {'stickToggleOff',          false},
    {'RecentColors',            {}},
    {'applyDelay',              {500,0,0,0}},
    {'defaultGradient',         1},
    {'lockCrystalToWhite',      false},
    {'readTheRules',            false},
    {'colorfulMarkers',         true},
    {'style',                   1},
}




function SettingsSave()
    local Xdd = {}
    for _, setting in ipairs(DEFAULT_SETTINGS) do

        local name, defaultValue = setting[1], setting[2]
        local value = _G[name]

        if name == 'style' then
            value = StyleSettings and StyleSettings.selectedStyle
        end

        if value ~= nil then
            Xdd[name] = value
        else
            Xdd[name] = defaultValue
        end

    end

    local json = Ext.Json.Stringify(Xdd)
    Ext.IO.SaveFile('LightyLights/settings.json', json)

    return Xdd
end



function SettingsLoad()
    local json = Ext.IO.LoadFile('LightyLights/settings.json')
    if not json then return end
    local Xdd = Ext.Json.Parse(json)
    if not Xdd then return end
    for _, setting in ipairs(DEFAULT_SETTINGS) do
        local key, defaultValue = setting[1], setting[2]
        local value = Xdd[key]

        if key == 'style' then
            StyleSettings.selectedStyle = value ~= nil and value or defaultValue
        else
            if value ~= nil then
                _G[key] = value
            else
                _G[key] = defaultValue
            end
        end

    end
end




if Ext.IO.LoadFile('LightyLights/settings.json') then
    SettingsLoad()
else
    SettingsSave()
    SettingsLoad()
end



Ext.Require('Client/_init.lua')



function CacheLightingValues()
    local CachedLighting = {}

    for name, uuid in pairs(ltn_templates2) do
        local Lighting = Resource:GetResource(uuid, 'Lighting')

        if Lighting then
            local values = {}

            local function copyValues(source, target)
                for k, v in pairs(source) do
                    if type(v) == 'table' or type(v) == 'userdata' then
                        target[k] = {}
                        copyValues(v, target[k])
                    else
                        target[k] = v
                    end
                end
            end

            copyValues(Lighting, values)
            CachedLighting[uuid] = {
                {Name = name},
                values
            }

            CachedLighting.Version = CACHE_VERSION
        end
    end
    return CachedLighting
end


function CacheAtmosphereValues()
    local CachedAtmosphere = {}

    for name, uuid in pairs(atm_templates2) do
        local Atmosphere = Resource:GetResource(uuid, 'Atmosphere')

        if Atmosphere then
            local values = {}
            local function copyValues(source, target)

                for k, v in pairs(source) do
                    if type(v) == 'table' or type(v) == 'userdata' then
                        target[k] = {}
                        copyValues(v, target[k])
                    else
                        target[k] = v
                    end
                end
            end
            copyValues(Atmosphere, values)

            CachedAtmosphere[uuid] = {
                { Name = name },
                values
            }
            CachedAtmosphere.Version = CACHE_VERSION
        end
    end
    return CachedAtmosphere
end



function LoadCacheFromFile()
    if not Ext.IO.LoadFile('LightyLights/CachedAtmosphere.json') then DPrint('NO ANAL CACHE') return end

    ZipBomb.CachedLighting = Ext.Json.Parse(Ext.IO.LoadFile('LightyLights/CachedLighting.json'))
    ZipBomb.CachedAtmosphere = Ext.Json.Parse(Ext.IO.LoadFile('LightyLights/CachedAtmosphere.json'))

end



function SaveCacheToFile()
    if Ext.IO.LoadFile('LightyLights/CachedAtmosphere.json') then DPrint('Loading cached parameters') LoadCacheFromFile() return end

    local CachedLighting = CacheLightingValues()
    local CachedAtmosphere = CacheAtmosphereValues()
    CachedLighting.Version = CACHE_VERSION
    CachedAtmosphere.Version = CACHE_VERSION
    local jsonLtn = Ext.Json.Stringify(CachedLighting)
    Ext.IO.SaveFile('LightyLights/CachedLighting.json', jsonLtn)
    local jsonAtm = Ext.Json.Stringify(CachedAtmosphere)
    Ext.IO.SaveFile('LightyLights/CachedAtmosphere.json', jsonAtm)
end

SaveCacheToFile()

print('')
DPrint([[files location: AppData/Local/Larian Studios/Baldur's Gate 3/Script Extender/LightyLights]])
DPrint([[FOR MAZZLEDOCS to work you need to place the mod above Lighty Lights in the load order]])
print('')



-- local lastTimePressed = 0
-- Ext.Events.KeyInput:Subscribe(function(e)
--     if e.Event == "KeyDown" then
--         if e.Key == "NUM_1" then
--             local currentTime = Ext.Timer.MonotonicTime()
--             local diff = currentTime - lastTimePressed

--             if diff < 500 then
--                 Ext.Debug.Reset(false, true)
--                 lastTimePressed = 0
--             else
--                 lastTimePressed = currentTime
--             end
--         end

--         if e.Key == "NUM_2" then
--             local currentTime = Ext.Timer.MonotonicTime()
--             local diff = currentTime - lastTimePressed

--             if diff < 500 then
--                 Ext.Debug.Reset(true, false)
--                 lastTimePressed = 0
--             else
--                 lastTimePressed = currentTime
--             end
--         end

--     end
-- end)

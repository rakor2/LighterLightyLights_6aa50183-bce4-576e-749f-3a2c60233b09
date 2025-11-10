Ext.Require('_Libs/_InitLibs.lua')
Ext.Require('Shared/_init.lua')


ZipBomb = ZipBomb or {}


currentCacheVersion = '1.7.Bober'

Settings = {}

--- TBD:unhardcode

local function bool(v, default)
    if v == nil then return default end
    return v
end

function SettingsSave()
    local settings = {
        style = StyleSettings.selectedStyle or 1,
        picker = bool(pickerSize, false),

        openByDefaultPMCamera = bool(openByDefaultPMCamera, false),
        openByDefaultPMInfo = bool(openByDefaultPMInfo, false),
        openByDefaultPMPos = bool(openByDefaultPMPos, false),
        openByDefaultPMRot = bool(openByDefaultPMRot, false),
        openByDefaultPMScale = bool(openByDefaultPMScale, false),
        openByDefaultPMLook = bool(openByDefaultPMLook, false),
        openByDefaultPMSave = bool(openByDefaultPMSave, false),

        openByDefaultMainGen = bool(openByDefaultMainGen, false),
        openByDefaultMainPoint = bool(openByDefaultMainPoint, false),
        openByDefaultMainSpot = bool(openByDefaultMainSpot, false),
        openByDefaultMainDir = bool(openByDefaultMainDir, false),
        openByDefaultMainAdd = bool(openByDefaultMainAdd, false),
        openByDefaultMainWorld = bool(openByDefaultMainWorld, false),
        openByDefaultMainChar = bool(openByDefaultMainChar, false),
        openByDefaultMainRot = bool(openByDefaultMainRot, false),
        
        defaultLightType = defaultLightType or 'Point',

        biggerPicker = bool(biggerPicker, false),

        markerScale = markerScale or 0.699999988079071,

        fadeTime = fadeTime or 0,

        defaultCameraSpeed = defaultCameraSpeed or 6,

        lightSetupState = bool(lightSetupState, true),
        
        markerOff = bool(markerOff, false),

        stickToggleOff = bool(stickToggleOff, false),

    }

    local json = Ext.Json.Stringify(settings)
    Ext.IO.SaveFile('LightyLights/settings.json', json)
    
    return settings
end


function SettingsLoad()
    local json = Ext.IO.LoadFile('LightyLights/settings.json')
    if not json then return end

    local settings = Ext.Json.Parse(json)
    if not settings then return end

    StyleSettings.selectedStyle = settings.style or 1
    pickerSize = bool(settings.picker, false)

    openByDefaultPMCamera = bool(settings.openByDefaultPMCamera, false)
    openByDefaultPMInfo = bool(settings.openByDefaultPMInfo, false)
    openByDefaultPMPos = bool(settings.openByDefaultPMPos, false)
    openByDefaultPMRot = bool(settings.openByDefaultPMRot, false)
    openByDefaultPMScale = bool(settings.openByDefaultPMScale, false)
    openByDefaultPMLook = bool(settings.openByDefaultPMLook, false)
    openByDefaultPMSave = bool(settings.openByDefaultPMSave, false)

    openByDefaultMainGen = bool(settings.openByDefaultMainGen, false)
    openByDefaultMainPoint = bool(settings.openByDefaultMainPoint, false)
    openByDefaultMainSpot = bool(settings.openByDefaultMainSpot, false)
    openByDefaultMainDir = bool(settings.openByDefaultMainDir, false)
    openByDefaultMainAdd = bool(settings.openByDefaultMainAdd, false)
    openByDefaultMainWorld = bool(settings.openByDefaultMainWorld, false)
    openByDefaultMainChar = bool(settings.openByDefaultMainChar, false)
    openByDefaultMainRot = bool(settings.openByDefaultMainRot, false)

    defaultLightType = settings.defaultLightType or 'Point'
    biggerPicker = bool(settings.biggerPicker, false)

    markerScale = settings.markerScale or 0.699999988079071
    fadeTime = settings.fadeTime or 0.3
    defaultCameraSpeed = settings.defaultCameraSpeed or 6
    lightSetupState = bool(settings.lightSetupState, true)
    
    markerOff = bool(settings.markerOff, false)

    stickToggleOff = bool(settings.stickToggleOff, false)

end



if Ext.IO.LoadFile('LightyLights/settings.json') then
    SettingsLoad()
    print('')
    DPrint(' Settings loaded')
else

    print('')
    DPrint('Settings file not found. The file will be created after changing UI style')
    
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
                { Name = name },
                values
            }
            
            CachedLighting.Version = currentCacheVersion
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
            
            CachedAtmosphere.Version = currentCacheVersion
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

    CachedLighting.Version = currentCacheVersion
    CachedAtmosphere.Version = currentCacheVersion
    
    
    local jsonLtn = Ext.Json.Stringify(CachedLighting)
    Ext.IO.SaveFile('LightyLights/CachedLighting.json', jsonLtn)

    local jsonAtm = Ext.Json.Stringify(CachedAtmosphere)
    Ext.IO.SaveFile('LightyLights/CachedAtmosphere.json', jsonAtm)

end

SaveCacheToFile()








--- UNUSED

-- local function CacheSavedValues()
--     savedValuesTable.Version = currentCacheVersion

--     local json = Ext.Json.Stringify(savedValuesTable)
--     Ext.IO.SaveFile('LightyLights/LTN_Cache.json', json)

--     if Ext.IO.LoadFile('LightyLights/LTN_Cache.json') then
--         -- DPrint(' LTN cached successfully with verison ' .. Ext.Json.Parse(Ext.IO.LoadFile('LightyLights/LTN_Cache.json')).Version)
--         CacheCheck()
--     else
--         return
--     end

-- end



-- savedValuesTable = {}
-- function SavedValuesTable()
--     for k, template in pairs(ltn_templates) do
--         local lightingValue = Ext.Resource.Get(template.uuid, 'Lighting').Lighting
        
--         savedValuesTable = {
--             'UNUSED FILE'
--         }
--     end
--     DPrint(' Caching LTN values . . . ')
--     -- DDump(savedValuesTable[ltn_templates[1].uuid])
--     -- print('')
--     CacheSavedValues()
-- end



-- Ext.RegisterNetListener('ManualCache', function()
--     SavedValuesTable()
-- end)

-- Ext.RegisterNetListener('LLL_LevelStarted', function()
--     if Ext.IO.LoadFile('LightyLights/LTN_Cache.json') == nil then
--     -- DPrint(' Caching LTN values . . . ')
--     SavedValuesTable()
--     end
-- end)


-- function CacheCheck()
--     if Ext.IO.LoadFile('LightyLights/LTN_Cache.json') then
--         versionCheck = Ext.Json.Parse(Ext.IO.LoadFile('LightyLights/LTN_Cache.json')).Version
--         if versionCheck ~= currentCacheVersion then
--             -- DWarn('LTN cache version check not passed')
--             SavedValuesTable()
--         else
--             -- DPrint(' LTN cache loaded with verison ' .. Ext.Json.Parse(Ext.IO.LoadFile('LightyLights/LTN_Cache.json')).Version)
--         end

--     else
--         DPrint('LTN cache file not found. The file will be created after loading a save or by manually using !cacheltn console command while a save is loaded')
--     end
-- end

-- CacheCheck()

print('')
DPrint([[files location: AppData\\Local\\Larian Studios\\Baldur's Gate 3\\Script Extender\\LightyLights]])
print('')

-- Ext.RegisterConsoleCommand('cacheltnC', SaveValuesToTable)


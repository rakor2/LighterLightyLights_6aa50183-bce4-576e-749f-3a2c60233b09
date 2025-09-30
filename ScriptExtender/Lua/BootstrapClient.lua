
Ext.Require("_Libs/_InitLibs.lua")
Ext.Require("Shared/_init.lua")
Ext.Require("Client/_init.lua")



currentCacheVersion = "1.6.Elk"

Settings = {}

--TBD:unhardcode
function SettingsSave()
    local settings = {
        style = StyleSettings.selectedStyle,
        picker = pickerSize
    }
    local json = Ext.Json.Stringify(settings)
    Ext.IO.SaveFile("LightyLights/settings.json", json)
end

function SettingsLoad()
    local json = Ext.IO.LoadFile("LightyLights/settings.json")
    if json then
        local settings = Ext.Json.Parse(json)
        StyleSettings.selectedStyle = settings.style or 1
        pickerSize = settings.picker or false
    end
end

SettingsLoad()

if Ext.IO.LoadFile("LightyLights/settings.json") then
    print("")
    DPrint(" Settings loaded")
else
    print("")
    DPrint(" Settings file not found. The file will be created after changing UI style")
end

-- -- Load favorites when mod initializes _ai
-- function LoadFavoritesFromFile()
--     local exists = Ext.IO.LoadFile("LightyLights/AnL_Favorites.json")
    
--     -- Initialize empty lists and arrays _ai
--     ATMFavoritesList = {}
--     LTNFavoritesList = {}
--     ATMFavorites = {}
--     LTNFavorites = {}
    
--     if exists then
--         -- DPrint("Found favorites file")
--         local success, favorites = pcall(function()
--             return Ext.Json.Parse(exists)
--         end)
        
--         if success and favorites then
--             -- DPrint("Successfully parsed favorites file")
            
--             -- Load lists _ai
--             ATMFavoritesList = favorites.atm or {}
--             LTNFavoritesList = favorites.ltn or {}
            
--             -- Rebuild arrays _ai
--             for _, fav in ipairs(ATMFavoritesList) do
--                 table.insert(ATMFavorites, fav.index)
--             end
            
--             for _, fav in ipairs(LTNFavoritesList) do
--                 table.insert(LTNFavorites, fav.index)
--             end
            
--             -- DPrint("Loaded ATM favorites count:", #ATMFavoritesList)
--             -- DPrint("Loaded LTN favorites indices count:", #ATMFavorites)
--             -- DPrint("Loaded LTN favorites count:", #LTNFavoritesList)
--             -- DPrint("Loaded LTN favorites indices count:", #LTNFavorites)
--         else
--             -- DPrint("Error parsing favorites file:", favorites)
--         end
--     else
--         -- DPrint("No favorites file found - using empty lists")
--     end
-- end

-- LoadFavoritesFromFile()

-- if Ext.IO.LoadFile("LightyLights/AnL_Favorites.json") then
--     DPrint(" AnL favorites loaded")
-- else
--     DPrint(" AnL favorites file not found. The file will be created after adding an LTN or ATM in favorites")
-- end


-- Ext.Events.SessionLoaded:Subscribe(function()
-- end)

local function CacheSavedValues()
    savedValuesTable.Version = currentCacheVersion

    local json = Ext.Json.Stringify(savedValuesTable)
    Ext.IO.SaveFile("LightyLights/LTN_Cache.json", json)

    if Ext.IO.LoadFile("LightyLights/LTN_Cache.json") then
        DPrint(" LTN cached successfully with verison " .. Ext.Json.Parse(Ext.IO.LoadFile("LightyLights/LTN_Cache.json")).Version)
        CacheCheck()
    else
        return
    end

end


savedValuesTable = {}
function SavedValuesTable()
    for k, template in pairs(ltn_templates) do
        -- DPrint(k)
        local lightingValue = Ext.Resource.Get(template.uuid, "Lighting").Lighting
        
        savedValuesTable[template.uuid] = {
            {Name = template.name},
            {
                --Fog Layer 0
                FogLayer0Albedo = {
                    lightingValue.Fog.FogLayer0.Albedo[1],
                    lightingValue.Fog.FogLayer0.Albedo[2],
                    lightingValue.Fog.FogLayer0.Albedo[3]
                },

                FogLayer0Density0 = lightingValue.Fog.FogLayer0.Density0,
                FogLayer0Density1 = lightingValue.Fog.FogLayer0.Density1,
                FogLayer0Enabled = lightingValue.Fog.FogLayer0.Enabled,
                FogLayer0Height0 = lightingValue.Fog.FogLayer0.Height0,
                FogLayer0Height1 = lightingValue.Fog.FogLayer0.Height1,
                FogLayer0NoiseCoverage = lightingValue.Fog.FogLayer0.NoiseCoverage,
                
                FogLayer0NoiseFrequency = {
                    lightingValue.Fog.FogLayer0.NoiseFrequency[1],
                    lightingValue.Fog.FogLayer0.NoiseFrequency[2],
                    lightingValue.Fog.FogLayer0.NoiseFrequency[3]
                },

                FogLayer0NoiseRotation = {
                    lightingValue.Fog.FogLayer0.NoiseRotation[1],
                    lightingValue.Fog.FogLayer0.NoiseRotation[2],
                    lightingValue.Fog.FogLayer0.NoiseRotation[3]
                },

                FogLayer0NoiseWind = {
                    lightingValue.Fog.FogLayer0.NoiseWind[1],
                    lightingValue.Fog.FogLayer0.NoiseWind[2],
                    lightingValue.Fog.FogLayer0.NoiseWind[3]
                },
                
                --Fog Layer 1
                FogLayer1Albedo = {
                    lightingValue.Fog.FogLayer1.Albedo[1],
                    lightingValue.Fog.FogLayer1.Albedo[2],
                    lightingValue.Fog.FogLayer1.Albedo[3]
                },

                FogLayer1Density0 = lightingValue.Fog.FogLayer1.Density0,
                FogLayer1Density1 = lightingValue.Fog.FogLayer1.Density1,
                FogLayer1Enabled = lightingValue.Fog.FogLayer1.Enabled,
                FogLayer1Height0 = lightingValue.Fog.FogLayer1.Height0,
                FogLayer1Height1 = lightingValue.Fog.FogLayer1.Height1,
                FogLayer1NoiseCoverage = lightingValue.Fog.FogLayer1.NoiseCoverage,

                FogLayer1NoiseFrequency = {
                    lightingValue.Fog.FogLayer1.NoiseFrequency[1],
                    lightingValue.Fog.FogLayer1.NoiseFrequency[2],
                    lightingValue.Fog.FogLayer1.NoiseFrequency[3]
                },

                FogLayer1NoiseRotation = {
                    lightingValue.Fog.FogLayer1.NoiseRotation[1],
                    lightingValue.Fog.FogLayer1.NoiseRotation[2],
                    lightingValue.Fog.FogLayer1.NoiseRotation[3]
                },

                FogLayer1NoiseWind = {
                    lightingValue.Fog.FogLayer1.NoiseWind[1],
                    lightingValue.Fog.FogLayer1.NoiseWind[2],
                    lightingValue.Fog.FogLayer1.NoiseWind[3]
                },
                
                --Fog General
                FogPhase = lightingValue.Fog.Phase,
                FogRenderDistance = lightingValue.Fog.RenderDistance,
                
                --Moon
                MoonYaw = lightingValue.Moon.Yaw,
                MoonPitch = lightingValue.Moon.Pitch,
                MoonInt = lightingValue.Moon.Intensity,
                MoonRadius = lightingValue.Moon.Radius,
                MoonDistance = lightingValue.Moon.Distance,
                MoonEarthshine = lightingValue.Moon.Earthshine,
                MoonEnabled = lightingValue.Moon.Enabled,
                CastLightEnabled = lightingValue.Moon.CastLightEnabled,
                MoonGlare = lightingValue.Moon.MoonGlare,
                TearsRotate = lightingValue.Moon.TearsRotate,
                TearsScale = lightingValue.Moon.TearsScale,
                MoonColor = {
                    lightingValue.Moon.Color[1],
                    lightingValue.Moon.Color[2],
                    lightingValue.Moon.Color[3]
                },

                
                --SkyLight
                CirrusCloudsAmount = lightingValue.SkyLight.CirrusCloudsAmount,
                CirrusCloudsColor = {
                    lightingValue.SkyLight.CirrusCloudsColor[1],
                    lightingValue.SkyLight.CirrusCloudsColor[2],
                    lightingValue.SkyLight.CirrusCloudsColor[3]
                },

                CirrusCloudsEnabled = lightingValue.SkyLight.CirrusCloudsEnabled,
                CirrusCloudsIntensity = lightingValue.SkyLight.CirrusCloudsIntensity,
                RotateSkydomeEnabled = lightingValue.SkyLight.RotateSkydomeEnabled,
                ScatteringEnabled = lightingValue.SkyLight.ScatteringEnabled,
                ScatteringIntensity = lightingValue.SkyLight.ScatteringIntensity,

                ScatteringSunColor = {
                    lightingValue.SkyLight.ScatteringSunColor[1],
                    lightingValue.SkyLight.ScatteringSunColor[2],
                    lightingValue.SkyLight.ScatteringSunColor[3]
                },

                ScatteringSunIntensity = lightingValue.SkyLight.ScatteringSunIntensity,
                SkydomeEnabled = lightingValue.SkyLight.SkydomeEnabled,
                SkydomeTex = lightingValue.SkyLight.SkydomeTex,
                
                --Sun
                SunYaw = lightingValue.Sun.Yaw,
                SunPitch = lightingValue.Sun.Pitch,
                SunIntensity = lightingValue.Sun.SunIntensity,

                SunColor = {
                    lightingValue.Sun.SunColor[1],
                    lightingValue.Sun.SunColor[2],
                    lightingValue.Sun.SunColor[3]
                },

                CascadeCount = lightingValue.Sun.CascadeCount,
                CascadeSpeed = lightingValue.Sun.CascadeSpeed,
                LightSize = lightingValue.Sun.LightSize,
                ShadowBias = lightingValue.Sun.ShadowBias,
                ShadowEnabled = lightingValue.Sun.ShadowEnabled,
                ShadowFade = lightingValue.Sun.ShadowFade,
                ShadowFarPlane = lightingValue.Sun.ShadowFarPlane,
                ShadowNearPlane = lightingValue.Sun.ShadowNearPlane,
                ShadowObscurity = lightingValue.Sun.ShadowObscurity,
                ScatteringIntensityScale = lightingValue.Sun.ScatteringIntensityScale,
                
                --Volumetric Cloud
                CloudAmbientLightFactor = lightingValue.VolumetricCloudSettings.AmbientLightFactor,
                CloudBaseColor = {
                    lightingValue.VolumetricCloudSettings.BaseColor[1],
                    lightingValue.VolumetricCloudSettings.BaseColor[2],
                    lightingValue.VolumetricCloudSettings.BaseColor[3]
                },

                CloudEndHeight = lightingValue.VolumetricCloudSettings.CoverageSettings.EndHeight,
                CloudHorizonDistance = lightingValue.VolumetricCloudSettings.CoverageSettings.HorizonDistance,
                CloudOffset = {
                    lightingValue.VolumetricCloudSettings.CoverageSettings.Offset[1],
                    lightingValue.VolumetricCloudSettings.CoverageSettings.Offset[2]
                },

                CloudStartHeight = lightingValue.VolumetricCloudSettings.CoverageSettings.StartHeight,
                CloudCoverageStartDistance = lightingValue.VolumetricCloudSettings.CoverageStartDistance,
                CloudCoverageWindSpeed = lightingValue.VolumetricCloudSettings.CoverageWindSpeed,
                CloudDetailScale = lightingValue.VolumetricCloudSettings.DetailScale,
                CloudEnabled = lightingValue.VolumetricCloudSettings.Enabled,
                CloudIntensity = lightingValue.VolumetricCloudSettings.Intensity,
                CloudShadowFactor = lightingValue.VolumetricCloudSettings.ShadowFactor,
                CloudSunLightFactor = lightingValue.VolumetricCloudSettings.SunLightFactor,
                CloudSunRayLength = lightingValue.VolumetricCloudSettings.SunRayLength,
                CloudTopColor = {
                    lightingValue.VolumetricCloudSettings.TopColor[1],
                    lightingValue.VolumetricCloudSettings.TopColor[2],
                    lightingValue.VolumetricCloudSettings.TopColor[3]
                }
            }
        }
    end
    DPrint(" Caching LTN values . . . ")
    -- DDump(savedValuesTable[ltn_templates[1].uuid])
    -- print("")
    CacheSavedValues()
end



Ext.RegisterNetListener("ManualCache", function()
    SavedValuesTable()
end)

Ext.RegisterNetListener("LLL_LevelStarted", function()
    if Ext.IO.LoadFile("LightyLights/LTN_Cache.json") == nil then
    DPrint(" Caching LTN values . . . ")
    SavedValuesTable()
    end
end)


function CacheCheck()
    if Ext.IO.LoadFile("LightyLights/LTN_Cache.json") then
        versionCheck = Ext.Json.Parse(Ext.IO.LoadFile("LightyLights/LTN_Cache.json")).Version
        if versionCheck ~= currentCacheVersion then
            DWarn("LTN cache version check not passed")
            SavedValuesTable()
        else
            DPrint(" LTN cache loaded with verison " .. Ext.Json.Parse(Ext.IO.LoadFile("LightyLights/LTN_Cache.json")).Version)
        end

    else
        DPrint("LTN cache file not found. The file will be created after loading a save or by manually using !cacheltn console command while a save is loaded")
    end
end

CacheCheck()

print("")
DPrint("files location: AppData\\Local\\Larian Studios\\Baldur's Gate 3\\Script Extender\\LightyLights")
print("")

Ext.RegisterConsoleCommand("cacheltnC", SaveValuesToTable)




-- function SaveValuesToTable()

--     -- savedValuesTable.SunColor = {}
--     -- savedValuesTable.MoonColor = {}

    
--     for i = 1, #ltn_templates do
        
--         lightingValue = Ext.Resource.Get(ltn_templates[i].uuid, "Lighting").Lighting


--         savedValuesTable.SunYaw[i] = lightingValue.Sun.Yaw
--         savedValuesTable.SunPitch[i] = lightingValue.Sun.Pitch
--         savedValuesTable.SunInt[i] = lightingValue.Sun.SunIntensity
        
--         savedValuesTable.SunColor[i] = {
--             lightingValue.Sun.SunColor[1],
--             lightingValue.Sun.SunColor[2],
--             lightingValue.Sun.SunColor[3]
--         }

--         savedValuesTable.MoonCastLight[i] = lightingValue.Moon.CastLightEnabled
--         savedValuesTable.MoonYaw[i] = lightingValue.Moon.Yaw
--         savedValuesTable.MoonPitch[i] = lightingValue.Moon.Pitch
--         savedValuesTable.MoonInt[i] = lightingValue.Moon.Intensity
--         savedValuesTable.MoonRadius[i] = lightingValue.Moon.Radius

--         savedValuesTable.MoonColor[i] = {
--             lightingValue.Moon.Color[1],
--             lightingValue.Moon.Color[2],
--             lightingValue.Moon.Color[3]
--         }

--         savedValuesTable.StarsState[i] = lightingValue.SkyLight.ProcStarsEnabled
--         savedValuesTable.StarsAmount[i] = lightingValue.SkyLight.ProcStarsAmount
--         savedValuesTable.StarsInt[i] = lightingValue.SkyLight.ProcStarsIntensity
--         savedValuesTable.StarsSaturation1[i] = lightingValue.SkyLight.ProcStarsSaturation[1]
--         savedValuesTable.StarsSaturation2[i] = lightingValue.SkyLight.ProcStarsSaturation[2]
--         savedValuesTable.StarsShimmer[i] = lightingValue.SkyLight.ProcStarsShimmer

--         savedValuesTable.CascadeSpeed[i] = lightingValue.Sun.CascadeSpeed
--         savedValuesTable.LightSize[i] = lightingValue.Sun.LightSize
--     end

--     CacheSavedValues()
    
-- end
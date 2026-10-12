if Mods.Realm_Builder then
    setmetatable(Mods.LL2, {__index = Mods.Realm_Builder})
end


if Mods.GizmoLib then
    setmetatable(Mods.LL2, {__index = Mods.GizmoLib})
end

if Mods.QSAT then
    setmetatable(Mods.LL2, {__index = Mods.QSAT})
end


Ext.Require('Shared/_init.lua')
Ext.Require('Client/_init.lua')


local LTN_Templates, ATM_Templates = Ext.Require('Shared/Anal/ATM_LTN_Templates.lua')
local CACHE_VERSION = '2.0.Dani'

function CacheLightingValues()
    local CachedLighting = {}

    for name, uuid in pairs(LTN_Templates) do
        local Lighting = Resource:GetResource(uuid, 'Lighting')

        if Lighting then
            local SerResource = Ext.Types.Serialize(Lighting)

            CachedLighting[uuid] = {
                {Name = name},
                SerResource
            }

            CachedLighting.Version = CACHE_VERSION
        end
    end
    return CachedLighting
end



function CacheAtmosphereValues()
    local CachedAtmosphere = {}

    for name, uuid in pairs(ATM_Templates) do
        local Atmosphere = Resource:GetResource(uuid, 'Atmosphere')

        if Atmosphere then
            local SerResource = Ext.Types.Serialize(Atmosphere)

            CachedAtmosphere[uuid] = {
                { Name = name },
                SerResource
            }
            CachedAtmosphere.Version = CACHE_VERSION
        end
    end
    return CachedAtmosphere
end


local ZipBomb = {}

function SaveCacheToFile()
    local CachedLighting     = CacheLightingValues()
    local CachedAtmosphere   = CacheAtmosphereValues()
    CachedLighting.Version   = CACHE_VERSION
    CachedAtmosphere.Version = CACHE_VERSION

    Ext.IO.SaveFile('LightyLights/CachedLighting.json', Ext.Json.Stringify(CachedLighting))
    Ext.IO.SaveFile('LightyLights/CachedAtmosphere.json', Ext.Json.Stringify(CachedAtmosphere))

    ZipBomb.CachedLighting   = CachedLighting
    ZipBomb.CachedAtmosphere = CachedAtmosphere
end



function LoadCacheFromFile()
    local CL = Ext.IO.LoadFile('LightyLights/CachedLighting.json')
    local CA = Ext.IO.LoadFile('LightyLights/CachedAtmosphere.json')

    if not CL or not CA then
        DPrint('NO ANAL CACHE')
        SaveCacheToFile()
        return
    end

    local CachedLighting = Ext.Json.Parse(CL)

    if CachedLighting.Version ~= CACHE_VERSION then
        DPrint([[Lighting cache version doesn't match. Caching new one]])
        SaveCacheToFile()
        return
    end

    ZipBomb.CachedLighting   = CachedLighting
    ZipBomb.CachedAtmosphere = Ext.Json.Parse(CA)
end

LoadCacheFromFile()

--- TBD: Temp
function GetZipBombTemporary()
    return ZipBomb
end


print('')
DPrint([[files location: AppData/Local/Larian Studios/Baldur's Gate 3/Script Extender/LightyLights]])
DPrint([[FOR MAZZLEDOCS to work you need to place the mod above Lighty Lights in the load order]])
print('')





-- function tra()
-- end
--     _C().InventoryMemberSetTransform = {}


--[[
_C():CreateComponent('InventoryMemberSetTransform')
_D(_C().InventoryMemberSetTransform)
]]--

-- _C().InventoryMemberSetTransform.SetTransform = {[_C()] = {RotationQuat = {1,0,0,0}, Translate = {1,1,1}, Scale = {2,2,2}}}

-- Ext.Entity.GetAllEntitiesWithComponent('TimeFactor')
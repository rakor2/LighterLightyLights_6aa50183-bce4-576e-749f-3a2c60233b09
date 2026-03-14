function getLevelAvailableLTNTriggers()
    _GLL.LightingTriggers = Ext.Entity.GetAllEntitiesWithComponent('ServerLightingTrigger')
    return _GLL.LightingTriggers
end



function getLevelAvailableATMTriggers()
    _GLL.AtmosphereTriggers = Ext.Entity.GetAllEntitiesWithComponent('ServerAtmosphereTrigger')
    return _GLL.AtmosphereTriggers
end



Ext.RegisterNetListener('LL_GetLTNTriggers', function(channel, payload, user)
    getLevelAvailableLTNTriggers()
end)



Ext.RegisterNetListener('LL_GetATMTriggers', function(channel, payload, user)
    getLevelAvailableATMTriggers()
end)



Ch.GetTriggers:SetHandler(function(Data)
    getLevelAvailableLTNTriggers()
    getLevelAvailableATMTriggers()
end)



function LightingApply(payload)
    for _, trigger in pairs(_GLL.LightingTriggers) do
        Osi.TriggerSetLighting(trigger.Uuid.EntityUuid, ltn_templates2[payload])
    end
    _GLL.SelectedLighting = ltn_templates2[payload]
end



function AtmosphereApple(payload)
    for _, trigger in pairs(_GLL.AtmosphereTriggers) do
        Osi.TriggerSetAtmosphere(trigger.Uuid.EntityUuid, atm_templates2[payload])
    end
    _GLL.SelectedAtmosphere = atm_templates2[payload]
end



Ext.RegisterNetListener('LL_LightingApply', function(channel, payload, user)
    LightingApply(payload)
end)



Ext.RegisterNetListener('LL_AtmosphereApply', function(channel, payload, user)
    AtmosphereApple(payload)
end)



Ch.ApplyANL:SetRequestHandler(function(Data)
    local uuid = '6e3f3623-5c84-a681-6131-2da753fa2c8f'

    for _, trigger in pairs(_GLL.LightingTriggers) do
        Osi.TriggerSetLighting(trigger.Uuid.EntityUuid, uuid)
    end

    local uuid = _GLL.SelectedLighting or '6e3f3623-5c84-a681-6131-2da753fa2c8f'

    Helpers.Timer:OnTicks(2, function ()
        for _, trigger in pairs(_GLL.LightingTriggers) do
            Osi.TriggerSetLighting(trigger.Uuid.EntityUuid, uuid)
        end
    end)
    return true
end)



Ch.ResetANL:SetHandler(function(Data)
    if Data == 'Lighting' then
        for _, trigger in pairs(_GLL.LightingTriggers) do
            Osi.TriggerResetLighting(trigger.Uuid.EntityUuid)
        end
    else
        for _, trigger in pairs(_GLL.AtmosphereTriggers) do
            Osi.TriggerResetAtmosphere(trigger.Uuid.EntityUuid)
        end
    end
end)



--- Thx Mr.Clanker for math Gladge
local function isInPolygon(px, pz, points)
    local inside = false
    local n = #points
    local j = n
    for i = 1, n do
        local xi, zi = points[i][1], points[i][2]
        local xj, zj = points[j][1], points[j][2]
        if ((zi > pz) ~= (zj > pz)) and (px < (xj - xi) * (pz - zi) / (zj - zi) + xi) then
            inside = not inside
        end
        j = i
    end
    return inside
end



local function rotateByInv(point, rot)
    local qx, qy, qz, qw = rot[1], rot[2], rot[3], rot[4]
    local px, py, pz = point[1], point[2], point[3]
    local ix =  qw*px + qy*pz - qz*py
    local iy =  qw*py + qz*px - qx*pz
    local iz =  qw*pz + qx*py - qy*px
    local iw = -qx*px - qy*py - qz*pz
    return {
        ix*qw + iw*(-qx) + iy*(-qz) - iz*(-qy),
        iy*qw + iw*(-qy) + iz*(-qx) - ix*(-qz),
        iz*qw + iw*(-qz) + ix*(-qy) - iy*(-qx)
    }
end



local function isInTriggerArea(point, TriggerArea)
    local Bounds =  TriggerArea.Bounds
    local Physics = TriggerArea.Physics
    local Pos =     Bounds.Position
    local Rot =     TriggerArea.RotationInv

    local lp = {point[1] - Pos[1], point[2] - Pos[2], point[3] - Pos[3]}
    if Rot then lp = rotateByInv(lp, Rot) end

    local ok, extents = pcall(function() return Physics.Extents end)
    if ok and extents then
        return math.abs(lp[1]) <= extents[1]
           and math.abs(lp[2]) <= extents[2]
           and math.abs(lp[3]) <= extents[3]
    end

    local ok2, points = pcall(function() return Physics.Points end)
    if ok2 and points then
        local minY, maxY = Bounds.BoundsMin[2], Bounds.BoundsMax[2]
        if lp[2] < minY or lp[2] > maxY then return false end
        return isInPolygon(lp[1], lp[3], points)
    end

    return false
end



local function FindClosestTrigger(component, CT)
    local triggers = Ext.Entity.GetAllEntitiesWithComponent(component)
    local minDist = math.huge
    local found

    for _, trigger in ipairs(triggers) do
        if trigger[component] and trigger.TriggerArea and isInTriggerArea(CT, trigger.TriggerArea) then
            local TT = trigger.Transform.Transform.Translate
            local dx = TT[1] - CT[1]
            local dy = TT[2] - CT[2]
            local dz = TT[3] - CT[3]
            local d = math.sqrt(dx*dx + dy*dy + dz*dz)
            if d < minDist then
                minDist = d
                found = trigger
            end
        end
    end

    return found
end



function GetCurrentAtmosphere()
    DPrint('GetCurrentAtmosphere')
    local CT = _C().Transform.Transform.Translate
    local trigger = FindClosestTrigger('ServerAtmosphereTrigger', CT)
    return trigger and trigger.ServerAtmosphereTrigger.CurrentAtmosphereResourceID
end



function GetCurrentLighting()
    local CT = _C().Transform.Transform.Translate
    local trigger = FindClosestTrigger('ServerLightingTrigger', CT)
    return trigger and trigger.ServerLightingTrigger.CurrentLightingResourceID
end



function SetCurrentAtmosphereAndLightingServer()
    local uuidAtmosphere = GetCurrentAtmosphere()
    local uuidLighting = GetCurrentLighting()

    if not uuidAtmosphere or not uuidLighting then return end

    for _, trigger in pairs(_GLL.AtmosphereTriggers) do
        Osi.TriggerSetAtmosphere(trigger.Uuid.EntityUuid, uuidAtmosphere)
    end

    for _, trigger in pairs(_GLL.LightingTriggers) do
        Osi.TriggerSetLighting(trigger.Uuid.EntityUuid, uuidLighting)
    end

    _GLL.SelectedAtmosphere = uuidAtmosphere
    _GLL.SelectedLighting = uuidLighting

    local Response = {
        uuidAtmosphere = uuidAtmosphere,
        uuidLighting = uuidLighting
    }
    return Response
end



Ch.CurrentResource:SetRequestHandler(function(Data)
    return SetCurrentAtmosphereAndLightingServer()
end)



-- local function deepcopy(tbl, tbl2) --accidentally made deepcopy wtf
--     tbl2 = tbl2 or {}
--     for k, v in pairs(tbl) do
--         if type(v) == 'table' or type(v) == 'userdata' then
--             tbl2[k] = {}
--             deepcopy(v, tbl2[k])
--         else
--             tbl2[k] = v
--         end
--     end
--     -- DDump(tbl2)
--     return tbl2
-- end
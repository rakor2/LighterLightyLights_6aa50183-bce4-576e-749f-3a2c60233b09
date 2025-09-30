

GoboDistances = {}
GoboAngles = {} -- Таблица для хранения углов вращения гобо масок _ai

-- Add light marker tracking _ai
lightMarker = nil

-- Add table to store gobo distances for each light _ai
-- GoboDistances = {}


-- Create or move marker to light position _ai
function CreateOrMoveLightMarker(lightUUID)
    local lightPos = GetLightPosition(lightUUID)
    local rot = GetLightRotation(lightUUID)
    
    if lightMarker == nil then
        lightMarker = Osi.CreateAt(lightMarkerGUID, lightPos.x, lightPos.y, lightPos.z, 0, 1, "")
        Osi.ToTransform(lightMarker, lightPos.x, lightPos.y, lightPos.z, rot.x-90, rot.y, rot.z)
    else
        Osi.ToTransform(lightMarker, lightPos.x, lightPos.y, lightPos.z, rot.x-90, rot.y, rot.z)
    end
end

-- Send host position to client _ai
function SendHostPositionToClient()
    local charPos = GetHostPosition()
    Ext.Net.BroadcastMessage("HostPosition", Ext.Json.Stringify(charPos))
end


-- Helper function to get light transform _ai
function GetLightTransform(index)
    index = tonumber(index) -- Convert index to number _ai
    if not (index and index <= #ServerSpawnedLights) then
        return nil
    end
    
    local lightUUID = ServerSpawnedLights[index].uuid
    local pos = GetLightPosition(lightUUID)
    local rot = GetLightRotation(lightUUID)
    
    return lightUUID, pos.x, pos.y, pos.z, rot.x, rot.y, rot.z
end

-- Update gobo position for a light _ai
function UpdateGoboPosition(lightUUID)
    if LightGoboMap and LightGoboMap[lightUUID] then
        local pos = GetLightPosition(lightUUID)
        local rot = GetLightRotation(lightUUID)
        
        -- Calculate offset based on light rotation _ai
        local offsetDistance = GoboDistances[lightUUID] or 1.0 -- Use stored distance or default _ai
        
        local goboRotation = {x = 0, y = 0, z = 0}
        if GoboAngles[lightUUID] then
            if type(GoboAngles[lightUUID]) == "table" then
                goboRotation = GoboAngles[lightUUID]
            else
                goboRotation.z = GoboAngles[lightUUID]
            end
        end
        
        local angleX = math.rad(rot.x)
        local angleY = math.rad(rot.y)
        local angleZ = math.rad(rot.z)
        
        -- Calculate direction vector based on rotation angles _ai
        local dirX = math.sin(angleY)
        local dirY = -math.sin(angleX)
        local dirZ = math.cos(angleY) * math.cos(angleX)
        
        -- Normalize direction vector _ai
        local length = math.sqrt(dirX * dirX + dirY * dirY + dirZ * dirZ)
        dirX = dirX / length
        dirY = dirY / length
        dirZ = dirZ / length
        
        -- Apply offset to position _ai
        local goboX = pos.x + dirX * offsetDistance
        local goboY = pos.y + dirY * offsetDistance
        local goboZ = pos.z + dirZ * offsetDistance
        
        -- Применяем вращение гобо маски по всем осям _ai
        local goboRotX = rot.x + goboRotation.x
        local goboRotY = rot.y + goboRotation.y
        local goboRotZ = rot.z + goboRotation.z
        
        -- Update gobo position and rotation _ai
        Osi.ToTransform(LightGoboMap[lightUUID], goboX, goboY, goboZ, goboRotX, goboRotY, goboRotZ)
    end
end

-- Update marker position when light moves _ai
function UpdateMarkerPosition(lightUUID)
    if lightMarker then
        local pos = GetLightPosition(lightUUID)
        local rot = GetLightRotation(lightUUID)
        Osi.ToTransform(lightMarker, pos.x, pos.y, pos.z, rot.x-90, rot.y, rot.z)
        
        UpdateGoboPosition(lightUUID)
    end
end



function UpdateLightOrbitPosition(lightUUID)
    if currentAngle[lightUUID] then
        local charPos = GetHostPosition()
        lastMode[lightUUID] = "orbit"
        local angle = math.rad(currentAngle[lightUUID])
        local x = charPos.x + currentRadius[lightUUID] * math.cos(angle)
        local z = charPos.z + currentRadius[lightUUID] * math.sin(angle)
        local y = currentHeight[lightUUID]
        local baseRx, baseRy, _ = Orbit:CalculateLookAtRotation(x, y, z, charPos.x, charPos.y + 1.3, charPos.z)
        local rx = baseRx + (lightRotation.tilt[lightUUID] or 0)
        local ry = baseRy + (lightRotation.yaw[lightUUID] or 0)
        local rz = lightRotation.roll[lightUUID] or 0
        Osi.ToTransform(lightUUID, x, y, z, rx, ry, rz)
        CreateOrMoveLightMarker(lightUUID)
        UpdateGoboPosition(lightUUID)
    end
end

function LarianWhy()
    Ext.Stats.GetStatsManager().ExtraData["PhotoModeCameraFloorDistance"] = -99887766
    Ext.Stats.GetStatsManager().ExtraData["PhotoModeCameraRange"] = 11223344
end

-- Ext.Entity.OnSystemUpdate("ServerInventoryEquipment", function()
--     local sys = Ext.System.ServerInventoryEquipment.EquipmentSet[entity]
--     DDump(sys)
-- end)




-- function FindTriggers(triggerType)
--     local entity = _C()
--     local pos = entity.Transform.Transform.Translate
--     local entities = Ext.Entity.GetEntitiesAroundPosition({pos[1], pos[2], pos[3]}, 900, false, true)
--     DDump(entities)
--     DDump(entities[1]:GetAllComponents())
    
--     local triggers = Ext.Entity.GetAllEntitiesWithComponent('ServerAtmosphereTrigger')
--     --DDump(triggers[1]:GetAllComponents())

--     for k, v in ipairs(entities) do
--         if v.ServerAtmosphereTrigger then
--             DPrint(v)
--         end
--     end

-- end


--e8f3b1ea-c788-1086-1906-087341430359


Ext.RegisterConsoleCommand('entr', function (cmd, uuid)
    triggers = Ext.Entity.GetAllEntitiesWithComponent('ServerAtmosphereTrigger')
    for k, v in pairs(triggers) do
        v.ServerAtmosphereTrigger.CurrentAtmosphereResourceID = uuid
        v.ServerAtmosphereTrigger.AtmosphereResourceIDs = {}
    end
    --DDump(triggers[1]:GetAllComponents())
end)

LarianWhy()


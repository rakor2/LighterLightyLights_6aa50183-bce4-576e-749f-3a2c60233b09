LLGlobals.GoboLightMap = {}



Channels.CreateGobo:SetRequestHandler(function (Data)

    if not LLGlobals.selectedUuid then return end
    if LLGlobals.GoboLightMap[LLGlobals.selectedUuid] then return end

    if not Data.goboGuid then return end

    local x, y, z = Osi.GetPosition(LLGlobals.selectedUuid)
    local rx, ry, rz = Osi.GetRotation(LLGlobals.selectedUuid)
    local uuid = tostring(Data.goboGuid)

    local goboUuid = Osi.CreateAt(uuid, x, y, z, 0, 0,'')
    
    Osi.ToTransform(goboUuid, x, y, z, rx, ry, rz)
    
    LLGlobals.GoboLightMap[LLGlobals.selectedUuid] = goboUuid
    
    LLGlobals.GoboDistances = LLGlobals.GoboDistances or {}
    LLGlobals.GoboDistances[goboUuid] = 0.1
    
    UpdateGoboPosition()

    return goboUuid

end)



Channels.DeleteGobo:SetHandler(function (Data)
    
    
    if not LLGlobals.selectedUuid then return end
    if not LLGlobals.GoboLightMap[LLGlobals.selectedUuid] then return end


    local goboToDelete
    
    if Data then

        for light, gobo in pairs(LLGlobals.GoboLightMap) do
            Osi.RequestDelete(gobo)
        end

        LLGlobals.GoboLightMap = {}

    else
        
        for light, gobo in pairs(LLGlobals.GoboLightMap) do
            if light == LLGlobals.selectedUuid then
                goboToDelete = gobo
            end
        end
        
        LLGlobals.GoboLightMap[LLGlobals.selectedUuid] = nil
        Osi.RequestDelete(goboToDelete)

    end

end)

Channels.HideGobo:SetHandler(function (Data)
end)


-- tasty slopppppppppp
-- sloppy toppy 



Channels.GoboTranslate:SetHandler(function (Data)
    if not LLGlobals.selectedUuid then return end
    if not LLGlobals.GoboLightMap[LLGlobals.selectedUuid] then return end
    
    local goboUuid = LLGlobals.GoboLightMap[LLGlobals.selectedUuid]
    if not goboUuid then return end
    
    local offset = Data.offset
    local step = Data.step
    local distance = offset / step
    
    LLGlobals.GoboDistances = LLGlobals.GoboDistances or {}
    LLGlobals.GoboDistances[goboUuid] = distance
    
    UpdateGoboPosition()
end)


function UpdateGoboPosition()
    if not LLGlobals.selectedUuid then return end
    if not LLGlobals.GoboLightMap[LLGlobals.selectedUuid] then return end

    
    local goboUuid = LLGlobals.GoboLightMap[LLGlobals.selectedUuid]
    if not goboUuid then return end
    
    LLGlobals.GoboDistances = LLGlobals.GoboDistances or {}
    local distance = LLGlobals.GoboDistances[goboUuid] or 1.0
    
    local lx, ly, lz = Osi.GetPosition(LLGlobals.selectedUuid)
    local lrx, lry, lrz = Osi.GetRotation(LLGlobals.selectedUuid)
    
    local angleX = math.rad(lrx)
    local angleY = math.rad(lry)
    
    local dirX = math.sin(angleY) * math.cos(angleX)
    local dirY = -math.sin(angleX)
    local dirZ = math.cos(angleY) * math.cos(angleX)
    
    local length = math.sqrt(dirX * dirX + dirY * dirY + dirZ * dirZ)
    
    if length > 0 then
        dirX = dirX / length
        dirY = dirY / length
        dirZ = dirZ / length
    else
        return
    end
    
    local gx = lx + dirX * distance
    local gy = ly + dirY * distance
    local gz = lz + dirZ * distance
    
    Osi.ToTransform(goboUuid, gx, gy, gz, lrx, lry, lrz)
end



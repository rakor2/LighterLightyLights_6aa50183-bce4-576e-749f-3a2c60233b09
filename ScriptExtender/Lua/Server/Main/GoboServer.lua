_GLL.GoboLightMap = {}



Ch.CreateGobo:SetRequestHandler(function (Data)
    if not _GLL.selectedUuid then return end
    if _GLL.GoboLightMap[_GLL.selectedUuid] then return end
    if not Data.goboGuid then return end

    local x, y, z = Osi.GetPosition(_GLL.selectedUuid)
    local rx, ry, rz = Osi.GetRotation(_GLL.selectedUuid)
    local uuid = tostring(Data.goboGuid)

    local goboUuid = Osi.CreateAt(uuid, x, y, z, 0, 0,'')
    Osi.ToTransform(goboUuid, x, y, z, rx, ry, rz)

    _GLL.GoboLightMap[_GLL.selectedUuid] = goboUuid
    _GLL.GoboDistances = _GLL.GoboDistances or {}
    _GLL.GoboDistances[goboUuid] = 0.1

    UpdateGoboPosition()

    return goboUuid
end)



Ch.DeleteGobo:SetHandler(function (Data)
    local goboToDelete

    if Data == 'All' then
        local GOV = Ext.Entity.GetAllEntitiesWithComponent('GameObjectVisual')

        for _, entity in ipairs(GOV) do
            for guid, _ in pairs(GoboUuidNameMap) do
                if entity.GameObjectVisual.RootTemplateId == guid then
                    local uuid = entity.Uuid.EntityUuid
                    Osi.RequestDelete(uuid)
                end
            end
        end
        _GLL.GoboLightMap = {}
    else
        if not _GLL.GoboLightMap[_GLL.selectedUuid] then return end

        for light, gobo in pairs(_GLL.GoboLightMap) do
            if light == _GLL.selectedUuid then
                goboToDelete = gobo
            end
        end

        _GLL.GoboLightMap[_GLL.selectedUuid] = nil
        Osi.RequestDelete(goboToDelete)
    end
end)



Ch.GoboTranslate:SetHandler(function (Data)
    if not _GLL.selectedUuid then return end
    if not _GLL.GoboLightMap[_GLL.selectedUuid] then return end

    local goboUuid = _GLL.GoboLightMap[_GLL.selectedUuid]
    if not goboUuid then return end

    local offset = Data.offset
    local step = Data.step
    local distance = offset / step

    _GLL.GoboDistances = _GLL.GoboDistances or {}
    _GLL.GoboDistances[goboUuid] = distance

    UpdateGoboPosition()
end)


-- tasty slopppppppppp
-- sloppy toppy

function UpdateGoboPosition()
    if not _GLL.selectedUuid then return end
    if not _GLL.GoboLightMap[_GLL.selectedUuid] then return end

    local goboUuid = _GLL.GoboLightMap[_GLL.selectedUuid]
    if not goboUuid then return end

    _GLL.GoboDistances = _GLL.GoboDistances or {}
    local distance = _GLL.GoboDistances[goboUuid] or 1.0
    local lx, ly, lz = Osi.GetPosition(_GLL.selectedUuid)
    local lrx, lry, lrz = Osi.GetRotation(_GLL.selectedUuid)
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
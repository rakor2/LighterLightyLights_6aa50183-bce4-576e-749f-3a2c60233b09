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



local GoboUuidNameMap = {
    ['a0d2ac1c-efb5-4f64-9f7d-b01db470e091'] = 'Tree',
    ['c1c8b026-e3c8-4975-bb4f-6b29450c2d18'] = 'Figures',
    ['4eab6f6d-5d94-4827-9331-ae3f67747410'] = 'Window',
    ['13c358b1-9afc-4acf-b121-fa38994d72d2'] = 'Stars',
    ['34329d13-f74d-46ac-928c-c6b40b87b644'] = 'Star',
    ['0435655f-4c3b-48dc-970e-55afc2956cd6'] = 'Asstation',
    ['213674c9-8606-4f08-aaea-7ef3b7339e6e'] = 'Bhaal bs',
    ['fc270e8b-7192-47af-b440-f5a87dd3d2cf'] = 'Water',
    ['1b86fb4a-330e-413e-ba8f-fbb1e51846fe'] = 'Blinds',
    ['08a26239-974d-4837-88be-f0365792cad9'] = 'Dots',
    ['e6748263-1452-4a78-a2c7-e2ad32c90ff8'] = 'Flowers',
    ['1099002f-5ba1-4d17-80c3-e1d4371c5685'] = 'Droplets',
    ['731867e3-0dab-4b13-9d78-13275087a446'] = 'Idk',
    ['7608ddb7-6fac-453d-b972-c002ff694ccc'] = 'Shape flower',
}



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



Ch.HideGobo:SetHandler(function (Data)
end)




-- tasty slopppppppppp
-- sloppy toppy

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
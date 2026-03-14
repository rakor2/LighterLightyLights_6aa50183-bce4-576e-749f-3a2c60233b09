Ch.CreateOriginPoint:SetRequestHandler(function (Data)
    if _GLL.States.pointIsExisting then return end
    local x, y, z = table.unpack(getSourcePosition())
    _GLL.pointUuid = Osi.CreateAt(lightMarkerGUID, x, y, z, 0, 0, '')
    _GLL.pointEntity = Ext.Entity.Get(_GLL.pointUuid)
    _GLL.States.pointIsExisting = true
    local Response = {
        _GLL.pointUuid
    }
    return Response
end)



Ch.DeleteOriginPoint:SetHandler(function (Data)
    if _GLL.pointUuid then
        Osi.RequestDelete(_GLL.pointUuid)
        _GLL.States.pointIsExisting = false
    end
end)



--fuck it, I'll just make everything separate, idc
Ch.MoveOriginPoint:SetHandler(function (Data)
    local axis = Data.axis
    local step = Data.step
    local offset = Data.offset
    local uuid = _GLL.pointUuid
    local rx, ry, rz = Osi.GetRotation(uuid)
    local x, y, z = Osi.GetPosition(uuid)

    if axis == 'x' then
        local x = x + offset / step
        Osi.ToTransform(uuid, x, y, z, rx, ry, rz)
        -- entity.Transform.Transform.Translate = {x,y,z}

    elseif  axis == 'y' then
        local y = y + offset / step
        Osi.ToTransform(uuid, x, y, z, rx, ry, rz)
        -- entity.Transform.Transform.Translate = {x,y,z}

    elseif  axis == 'z' then
        local z = z + offset / step
        Osi.ToTransform(uuid, x, y, z, rx, ry, rz)
        -- entity.Transform.Transform.Translate = {x,y,z}
--
    else
        local x, y, z = table.unpack(_C().Transform.Transform.Translate) --- TBD:
        Osi.ToTransform(uuid, x, y, z, rx, ry, rz)
    end

end)


Ch.ToCamOriginPoint:SetHandler(function (Data)
    local uuid = _GLL.pointUuid
    local x,y,z = table.unpack(Data.Translate)
    Osi.ToTransform(uuid, x, y, z, 0, 0, 0)
end)
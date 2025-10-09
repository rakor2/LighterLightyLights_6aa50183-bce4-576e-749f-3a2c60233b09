
Channels.CreateOriginPoint:SetRequestHandler(function (Data)

    if Globals.States.pointIsExisting then return end

    local x, y, z = table.unpack(getSourcePosition())

    Globals.pointUuid = Osi.CreateAt(lightMarkerGUID, x, y, z, 0, 0, '')
    Globals.pointEntity = Ext.Entity.Get(Globals.pointUuid)

    Globals.States.pointIsExisting = true

    local Response = {
        Globals.pointUuid
    }

    return Response
end)



Channels.DeleteOriginPoint:SetHandler(function (Data)

    if Globals.pointUuid then
        Osi.RequestDelete(Globals.pointUuid)
        Globals.States.pointIsExisting = false
    end

end)


--fuck it, I'll just make everything separate, idc
Channels.MoveOriginPoint:SetHandler(function (Data)
    

    local axis = Data.axis
    local step = Data.step
    local offset = Data.offset
    local uuid = Globals.pointUuid
    
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


Channels.ToCamOriginPoint:SetHandler(function (Data)
    local uuid = Globals.pointUuid
    local x,y,z = table.unpack(Data.Translate)
    Osi.ToTransform(uuid, x, y, z, 0, 0, 0)
end)
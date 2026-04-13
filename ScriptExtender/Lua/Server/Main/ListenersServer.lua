Ext.RegisterNetListener('LL_WhenLevelGameplayStarted', function (channel, payload, user)
end)



Ext.Events.ResetCompleted:Subscribe(function()
    getLevelAvailableLTNTriggers()
    getLevelAvailableATMTriggers()
end)



Ext.RegisterNetListener('LL_DeleteLookAtTarget', function(channel, payload, user)
    if _GLL.tragetUuid then
        Osi.RequestDelete(_GLL.tragetUuid)
        _GLL.tragetUuid = nil
        lookAtExists = false
        _GLL.tragetEntity = nil
    end
end)



Ext.RegisterNetListener('LL_MoveLookAtTarget', function(channel, payload, user)
    local data = Ext.Json.Parse(payload)
    if _GLL.tragetUuid then
        Osi.ToTransform(_GLL.tragetUuid, data.x, data.y, data.z, 0, 0, 0)
    end
end)



Ext.RegisterNetListener('LL_MoveLookAtTargetToCam', function(channel, payload, user)
    local data = Ext.Json.Parse(payload)
    if _GLL.tragetUuid then
        Osi.ToTransform(_GLL.tragetUuid, data[1], data[2], data[3], 0, 0, 0)
    end
end)



Ext.Entity.OnDestroyDeferred('JumpFollow', function()
    Ext.Net.BroadcastMessage("LL_JumpFollow", "")
end)

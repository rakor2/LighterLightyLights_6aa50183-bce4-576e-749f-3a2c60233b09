Ext.RegisterNetListener('LL_WhenLevelGameplayStarted', function (channel, payload, user)
end)



Ext.Events.ResetCompleted:Subscribe(function()
    getLevelAvailableLTNTriggers()
    getLevelAvailableATMTriggers()
end)



local lookAtExists = false
Ext.RegisterNetListener('LL_CreateLookAtTarget', function(channel, payload, user)
    if lookAtExists ~= true then
        local pos = _C().Transform.Transform.Translate
        _GLL.tragetUuid = Osi.CreateAt('12f13f99-c12f-4b79-a487-4dc187d44cb5', pos[1], pos[2], pos[3], 1, 0, '')
        lookAtExists = true
        _GLL.tragetEntity = Ext.Entity.Get(_GLL.tragetUuid)
    end
    Ext.Net.BroadcastMessage('LL_SendLookAtTargetUuid', _GLL.tragetUuid)
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

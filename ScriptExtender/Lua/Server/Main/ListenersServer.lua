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
        LLGlobals.tragetUuid = Osi.CreateAt('12f13f99-c12f-4b79-a487-4dc187d44cb5', pos[1], pos[2], pos[3], 1, 0, '')
        lookAtExists = true
        LLGlobals.tragetEntity = Ext.Entity.Get(LLGlobals.tragetUuid)
    end
    Ext.Net.BroadcastMessage('LL_SendLookAtTargetUuid', LLGlobals.tragetUuid)
end)



Ext.RegisterNetListener('LL_DeleteLookAtTarget', function(channel, payload, user)
    if LLGlobals.tragetUuid then
        Osi.RequestDelete(LLGlobals.tragetUuid)
        LLGlobals.tragetUuid = nil
        lookAtExists = false
        LLGlobals.tragetEntity = nil
    end
end)



Ext.RegisterNetListener('LL_MoveLookAtTarget', function(channel, payload, user)
    local data = Ext.Json.Parse(payload)
    if LLGlobals.tragetUuid then
        Osi.ToTransform(LLGlobals.tragetUuid, data.x, data.y, data.z, 0, 0, 0)
    end
end)



Ext.RegisterNetListener('LL_MoveLookAtTargetToCam', function(channel, payload, user)
    local data = Ext.Json.Parse(payload)
    if LLGlobals.tragetUuid then
        Osi.ToTransform(LLGlobals.tragetUuid, data[1], data[2], data[3], 0, 0, 0)
    end
end)



Ext.Entity.OnDestroyDeferred('JumpFollow', function()
    Ext.Net.BroadcastMessage("LL_JumpFollow", "")
end)

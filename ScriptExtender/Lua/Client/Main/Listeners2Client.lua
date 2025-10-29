---@diagnostic disable: param-type-mismatch


local dummyCounter = 0

Ext.Entity.OnCreate('PhotoModeSession', function ()
    Helpers.Timer:OnTicks(30, function ()

        dummyCounter = 0
        
        LLGlobals.DummyNameMap = {}
        
        local dummies = Ext.Entity.GetAllEntitiesWithComponent('Dummy')
        for _, dummy in pairs(dummies) do
            dummyCounter = dummyCounter + 1
            LLGlobals.DummyNameMap[Dummy:Name(dummy) .. '##' .. dummyCounter] = dummy
        end
        
        LLGlobals.DummyNames = Utils:MapToArray(LLGlobals.DummyNameMap)
        visTemComob.Options = LLGlobals.DummyNames
        UpdateCharacterInfo(visTemComob.SelectedIndex + 1)
    end)
end)



Ext.Entity.OnDestroy('PhotoModeSession', function ()
    --DPrint('PhotoModeSession OnDestroy')
    LLGlobals.DummyNameMap = nil
    LLGlobals.DummyNames = nil
    visTemComob.Options = {'Not in Photo Mode'}
    visTemComob.SelectedIndex = 0
    checkPMSrc.Checked = false
    
    if Utils.subID and Utils.subID['SourcePhotoMode'] then
        Utils:SubUnsubToTick('unsub', 'SourcePhotoMode',_)
    end

    UpdateCharacterInfo(nil)
end)



Ext.RegisterNetListener('LL_SendLookAtTargetUuid', function(channel, payload)
    LLGlobals.tragetUuid = payload
    Helpers.Timer:OnTicks(3, function ()
        LLGlobals.tragetEntity = Ext.Entity.Get(LLGlobals.tragetUuid)
    end)
end)
---@diagnostic disable: param-type-mismatch


local dummyCounter = 0

Ext.Entity.OnCreate('PhotoModeSession', function ()
    Helpers.Timer:OnTicks(30, function ()
        
        LLGlobals.States.inPhotoMode = true

        dummyCounter = 0
        
        LLGlobals.DummyNameMap = {}
        
        local dummies = Ext.Entity.GetAllEntitiesWithComponent('Dummy')
        for _, dummy in pairs(dummies) do
            dummyCounter = dummyCounter + 1
            LLGlobals.DummyNameMap[Dummy:Name(dummy) .. '##' .. dummyCounter] = dummy
        end
        
        
        LLGlobals.DummyNames = Utils:MapToArray(LLGlobals.DummyNameMap)
        E.visTemComob.Options = LLGlobals.DummyNames
        



        Utils:SubUnsubToTick('sub', 'LLDOF', function ()
            pcall(function()
                distance = Ext.UI.GetRoot():Find("ContentRoot"):Child(21).DataContext.DOFDistance
                E.dofDistance.Value = {distance, 0, 0, 0}
            end)
        end)


        CharacterLightSetupState(E.checkLightSetupState.Checked)
        UpdateCharacterInfo(E.visTemComob.SelectedIndex + 1)



    end)
end)



Ext.Entity.OnDestroy('PhotoModeSession', function ()
    
    LLGlobals.States.inPhotoMode = false

    --DPrint('PhotoModeSession OnDestroy')
    LLGlobals.DummyNameMap = nil
    LLGlobals.DummyNames = nil
    E.visTemComob.Options = {'Not in Photo Mode'}
    E.visTemComob.SelectedIndex = 0
    E.checkPMSrc.Checked = false
    
    if Utils.subID and Utils.subID['SourcePhotoMode'] then
        Utils:SubUnsubToTick('unsub', 'SourcePhotoMode',_)
    end


    if Utils.subID and Utils.subID['LLDOF'] then
        Utils:SubUnsubToTick('unsub', 'LLDOF',_)
    end


    StopFollowIGCS()


    UpdateCharacterInfo(nil)
end)



Ext.RegisterNetListener('LL_SendLookAtTargetUuid', function(channel, payload)
    LLGlobals.tragetUuid = payload
    Helpers.Timer:OnTicks(3, function ()
        LLGlobals.tragetEntity = Ext.Entity.Get(LLGlobals.tragetUuid)
    end)
end)
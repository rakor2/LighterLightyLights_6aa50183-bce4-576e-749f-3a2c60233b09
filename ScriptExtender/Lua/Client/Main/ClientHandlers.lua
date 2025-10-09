function SourceCutscene(state)
    local entity = _C()
    
    if not entity then return end


    if state then
        Utils:SubUnsubToTick('sub', 'SourceCutscene', function ()
        if Dummy:TLPreviewDummyPlayer() then
            local Transform = Dummy:TLPreviewDummyPlayerTransform()
            Globals.SourceTranslate = Transform.Translate
            Channels.CurrentEntityTransform:SendToServer(Globals.SourceTranslate)
        else
            Utils:SubUnsubToTick('unsub', 'SourceCutscene',_)
            Globals.SourceTranslate = entity.Transform.Transform.Translate
            Channels.CurrentEntityTransform:SendToServer(nil)
        end
    end)
    else
        if Utils.subID['SourceCutscene'] then
            Utils:SubUnsubToTick('unsub', 'SourceCutscene',_)
            Globals.SourceTranslate = entity.Transform.Transform.Translate
        end
        Channels.CurrentEntityTransform:SendToServer(nil)
    end
end



function SourcePoint(state)
    local entity = Globals.pointEntity

    if not entity then return end

    if state then

        Utils:SubUnsubToTick('sub', 'SourcePoint', function ()
        -- local Transform = entity.Visual.Visual.WorldTransform
        local Transform = entity.Transform.Transform
        Globals.SourceTranslate = Transform.Translate
        Channels.CurrentEntityTransform:SendToServer(Globals.SourceTranslate)
    end)
    else
        if Utils.subID and Utils.subID['SourcePoint'] then
            Utils:SubUnsubToTick('unsub', 'SourcePoint',_)
            Globals.SourceTranslate = _C().Transform.Transform.Translate
        end
        Channels.CurrentEntityTransform:SendToServer(nil)
    end


    return 0
end



function SourceClient(state)
    
    if state then
        Utils:SubUnsubToTick('sub', 'SourceClient', function ()
        if _C() and _C().Visual and _C().Visual.Visual.WorldTransform then
            local Transform = _C().Visual.Visual.WorldTransform
            Globals.SourceTranslate = Transform.Translate
            Channels.CurrentEntityTransform:SendToServer(Globals.SourceTranslate)
        end
    end)
    else
        if Utils.subID['SourceClient'] then
            Utils:SubUnsubToTick('unsub', 'SourceClient',_)
            Globals.SourceTranslate = _C().Transform.Transform.Translate
        end
        Channels.CurrentEntityTransform:SendToServer(nil)
    end
end


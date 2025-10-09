local xd



function SourceCutscene(state)
    if state then
            Utils:SubUnsubToTick('sub', 'SourceCutscene', function ()
            if Dummy:TLPreviewDummyPlayer() then
                local Transform = Dummy:TLPreviewDummyPlayerTransform()
                Globals.SourceTranslate = Transform.Translate
                Channels.CurrentEntityTransform:SendToServer(Globals.SourceTranslate)
            else
                Utils:SubUnsubToTick('unsub', 'SourceCutscene',_)
                Globals.SourceTranslate = _C().Transform.Transform.Translate
                Channels.CurrentEntityTransform:SendToServer(nil)
            end
        end)
    else
        if Utils.subID['SourceCutscene'] then
            Utils:SubUnsubToTick('unsub', 'SourceCutscene',_)
            Globals.SourceTranslate = _C().Transform.Transform.Translate
        end
        Channels.CurrentEntityTransform:SendToServer(nil)
    end
end

function SourceOrigin()
    return
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

function SourceClient()
    return
end
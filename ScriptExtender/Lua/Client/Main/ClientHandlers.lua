local xd



function SourceCutscene()
    if checkCutsceneSrc.Checked then
        Utils:SubUnsubToTick('sub', 'SourceCutscene', function ()
            if Dummy:TLPreviewDummyPlayer() then
                local Transform = Dummy:TLPreviewDummyPlayerTransform()
                Globals.SourceTranslate = Transform.Translate
            else
                Utils:SubUnsubToTick('unsub', 'SourceCutscene',_)
                Globals.SourceTranslate = _C().Transfor.Transform.Translate
            end
        end)
    end
end

function SourceOrigin()
    return
end

function SourceClient()
    return
end
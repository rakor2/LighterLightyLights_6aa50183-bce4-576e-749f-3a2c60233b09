function DevTab(parent)
    parent:AddSeparatorText('AnL')
    E.getTriggersBtn = parent:AddButton('Update triggers')
    E.getTriggersBtn.OnClick = function ()
        Ch.GetTriggers:SendToServer({})
    end
end
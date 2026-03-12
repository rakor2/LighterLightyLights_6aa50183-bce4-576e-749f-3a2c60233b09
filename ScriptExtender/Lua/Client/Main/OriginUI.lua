function Origin2PointTab(p)
    p:AddSeparatorText('Funny buttons')

    E.btnCreateOP = p:AddButton('Create')
        UI:Config(E.btnCreateOP, {
            OnClick = function(e)
                if LLGlobals.pointUuid then return end

                Ch.CreateOriginPoint:RequestToServer({}, function(Response)
                    LLGlobals.pointUuid = Response[1]

                    Helpers.Timer:OnTicks(5, function()
                        LLGlobals.pointEntity = Ext.Entity.Get(LLGlobals.pointUuid)
                    end)
                end)
            end
        })


    E.btnToCampOP = p:AddButton('Move to cam')
        UI:Config(E.btnToCampOP, {
            SameLine = true,
            OnClick  = function(e)
                if not LLGlobals.pointUuid then return end

                local Translate = Camera:GetActiveCamera().Transform.Transform.Translate
                local Data = {
                    Translate = Translate,
                }
                Ch.ToCamOriginPoint:SendToServer(Data)
            end
        })



    E.btnHideOP = p:AddButton('Hide')
        UI:Config(E.btnHideOP, {
            SameLine = true,
            OnClick  = function(e)
                if not LLGlobals.pointUuid then return end
                ToggleMarker(LLGlobals.pointUuid)
            end
        })



    E.btnDeleteOP = p:AddButton('Delete')
        UI:Config(E.btnDeleteOP, {
            SameLine = true,
            OnClick  = function(e)
                if not LLGlobals.pointUuid then return end

                SourcePoint(false)
                E.checkOriginSrc.Checked = false
                Ch.DeleteOriginPoint:SendToServer({})
                LLGlobals.pointUuid   = nil
                LLGlobals.pointEntity = nil
            end
        })



    p:AddSeparatorText('Even funnier sliders')



    local step = 4000



    E.slPosOPX = p:AddSlider('South/North', 0, -100, 100, 1)
        UI:Config(E.slPosOPX, {
            IDContext = 'adawd',
            OnChange  = function(e)
                MoveEntity(LLGlobals.pointEntity, 'z', e.Value[1], step, nil, 'Point')
                e.Value = {0, 0, 0, 0}
            end
        })



    E.slPosOPY = p:AddSlider('Down/Up', 0, -100, 100, 1)
        UI:Config(E.slPosOPY, {
            IDContext = 'adawd',
            OnChange  = function(e)
                MoveEntity(LLGlobals.pointEntity, 'y', e.Value[1], step, nil, 'Point')
                e.Value = {0, 0, 0, 0}
            end
        })



    E.slPosOPZ = p:AddSlider('West/East', 0, -100, 100, 1)
        UI:Config(E.slPosOPZ, {
            IDContext = 'adawd',
            OnChange  = function(e)
                MoveEntity(LLGlobals.pointEntity, 'x', e.Value[1], step, nil, 'Point')
                e.Value = {0, 0, 0, 0}
            end
        })



    E.btnResetOP = p:AddButton('Reset')
        UI:Config(E.btnResetOP, {
            SameLine = false,
            OnClick  = function(e)
                MoveEntity(LLGlobals.pointEntity, nil, nil, nil, nil, 'Point')
            end
        })
end
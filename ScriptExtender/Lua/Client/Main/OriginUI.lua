function Origin2PointTab(p)
    p:AddSeparatorText('Funny buttons')

    E.btnCreateOP = p:AddButton('Create')
        UI:Config(E.btnCreateOP, {
            OnClick = function(e)
                if _GLL.pointUuid then return end

                local Data = {Position = getSourcePositionCl()}

                Ch.CreateOriginPoint:RequestToServer(Data, function(Response)
                    _GLL.pointUuid = Response[1]

                    Helpers.Timer:OnTicks(5, function()
                        _GLL.pointEntity = Ext.Entity.Get(_GLL.pointUuid)
                    end)
                end)
            end
        })


    E.btnToCampOP = p:AddButton('Move to cam')
        UI:Config(E.btnToCampOP, {
            SameLine = true,
            OnClick  = function(e)
                if not _GLL.pointUuid then return end

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
                if not _GLL.pointUuid then return end
                ToggleMarker(_GLL.pointUuid)
            end
        })



    E.btnDeleteOP = p:AddButton('Delete')
        UI:Config(E.btnDeleteOP, {
            SameLine = true,
            OnClick  = function(e)
                if not _GLL.pointUuid then return end

                SourcePoint(false)
                E.checkOriginSrc.Checked = false
                Ch.DeleteOriginPoint:SendToServer({})
                _GLL.pointUuid   = nil
                _GLL.pointEntity = nil
            end
        })



    p:AddSeparatorText('Even funnier sliders')



    local step = 4000



    E.slPosOPX = p:AddSlider('South/North', 0, -100, 100, 1)
        UI:Config(E.slPosOPX, {
            IDContext = 'adawd',
            OnChange  = function(e)
                MoveEntity(_GLL.pointEntity, 'z', e.Value[1], step, nil, 'Point')
                e.Value = {0, 0, 0, 0}
            end
        })



    E.slPosOPY = p:AddSlider('Down/Up', 0, -100, 100, 1)
        UI:Config(E.slPosOPY, {
            IDContext = 'adawd',
            OnChange  = function(e)
                MoveEntity(_GLL.pointEntity, 'y', e.Value[1], step, nil, 'Point')
                e.Value = {0, 0, 0, 0}
            end
        })



    E.slPosOPZ = p:AddSlider('West/East', 0, -100, 100, 1)
        UI:Config(E.slPosOPZ, {
            IDContext = 'adawd',
            OnChange  = function(e)
                MoveEntity(_GLL.pointEntity, 'x', e.Value[1], step, nil, 'Point')
                e.Value = {0, 0, 0, 0}
            end
        })



    E.btnResetOP = p:AddButton('Reset')
        UI:Config(E.btnResetOP, {
            SameLine = false,
            OnClick  = function(e)
                MoveEntity(_GLL.pointEntity, nil, nil, nil, nil, 'Point')
            end
        })
end
function Origin2PointTab(p)
    local btn = p:AddSeparatorText('xd')
    
    local btnCreateOP = p:AddButton('Create')
    btnCreateOP.OnClick = function (e)
        Channels.CreateOriginPoint:RequestToServer({}, function (Response)
            
            Globals.pointUuid = Response[1]

            Helpers.Timer:OnTicks(5, function ()
                Globals.pointEntity = Ext.Entity.Get(Globals.pointUuid)
            end)
        end)
    end


    
    local btnDeleteOP = p:AddButton('Delete')
    btnDeleteOP.SameLine = true
    btnDeleteOP.OnClick = function (e)
        SourcePoint(false)
        checkOriginSrc.Checked = false
        Channels.DeleteOriginPoint:SendToServer({})
        Globals.pointUuid = nil
        Globals.pointEntity = nil
    end
    


    local btnHideOP = p:AddButton('Hide')
    btnHideOP.SameLine = true
    btnHideOP.OnClick = function (e)
        ToggleMarker(Globals.pointUuid)
    end
    


    local btnToCampOP = p:AddButton('Move to cam')
    btnToCampOP.OnClick = function (e)

        local Translate = Camera:GetActiveCamera().Transform.Transform.Translate
        local Data = {
            Translate = Translate,
        }
        Channels.ToCamOriginPoint:SendToServer(Data)
    end 



    local btnResetOP = p:AddButton('Reset')
    btnResetOP.SameLine = true
    btnResetOP.OnClick = function (e)
        MoveEntity(Globals.pointEntity, nil, nil, nil, nil, 'Point')
    end

    
    local step = 4000


    local slPosOPX = p:AddSlider('South/North', 0, -100, 100, 1)
    slPosOPX.IDContext = 'adawd'
    slPosOPX.OnChange = function (e)
        MoveEntity(Globals.pointEntity, 'z', e.Value[1], step, nil, 'Point')
        e.Value = {0,0,0,0}
    end


    local slPosOPY = p:AddSlider('Down/Up', 0, -100, 100, 1)
    slPosOPY.IDContext = 'adawd'
    slPosOPY.OnChange = function (e)
        MoveEntity(Globals.pointEntity, 'y', e.Value[1], step, nil, 'Point')
        e.Value = {0,0,0,0}
    end


    local slPosOPZ = p:AddSlider('West/East', 0, -100, 100, 1)
    slPosOPZ.IDContext = 'adawd'
    slPosOPZ.OnChange = function (e)
        MoveEntity(Globals.pointEntity, 'x', e.Value[1], step, nil, 'Point')
        e.Value = {0,0,0,0}
    end

end
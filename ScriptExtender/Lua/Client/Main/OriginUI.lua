function Origin2PointTab(p)
    p:AddSeparatorText('Funny buttons')
    
    E.btnCreateOP = p:AddButton('Create')
    E.btnCreateOP.OnClick = function (e)

        if LLGlobals.pointUuid then return end

        Channels.CreateOriginPoint:RequestToServer({}, function (Response)
            
            LLGlobals.pointUuid = Response[1]

            Helpers.Timer:OnTicks(5, function ()
                LLGlobals.pointEntity = Ext.Entity.Get(LLGlobals.pointUuid)
            end)
        end)
    end


    E.btnToCampOP = p:AddButton('Move to cam')
    E.btnToCampOP.SameLine = true
    E.btnToCampOP.OnClick = function (e)

        if not LLGlobals.pointUuid then return end


        local Translate = Camera:GetActiveCamera().Transform.Transform.Translate
        local Data = {
            Translate = Translate,
        }
        Channels.ToCamOriginPoint:SendToServer(Data)
    end 




    
    E.btnHideOP = p:AddButton('Hide')
    E.btnHideOP.SameLine = true
    E.btnHideOP.OnClick = function (e)
        
        if not LLGlobals.pointUuid then return end

        ToggleMarker(LLGlobals.pointUuid)
    end
    
    



    E.btnDeleteOP = p:AddButton('Delete')
    E.btnDeleteOP.SameLine = true
    E.btnDeleteOP.OnClick = function (e)
        
        if not LLGlobals.pointUuid then return end

        SourcePoint(false)
        E.checkOriginSrc.Checked = false
        Channels.DeleteOriginPoint:SendToServer({})
        LLGlobals.pointUuid = nil
        LLGlobals.pointEntity = nil
    end
    
    










    
    
    p:AddSeparatorText('Even funnier sliders')


    local step = 4000


    E.slPosOPX = p:AddSlider('South/North', 0, -100, 100, 1)
    E.slPosOPX.IDContext = 'adawd'
    E.slPosOPX.OnChange = function (e)
        MoveEntity(LLGlobals.pointEntity, 'z', e.Value[1], step, nil, 'Point')
        e.Value = {0,0,0,0}
    end


    E.slPosOPY = p:AddSlider('Down/Up', 0, -100, 100, 1)
    E.slPosOPY.IDContext = 'adawd'
    E.slPosOPY.OnChange = function (e)
        MoveEntity(LLGlobals.pointEntity, 'y', e.Value[1], step, nil, 'Point')
        e.Value = {0,0,0,0}
    end


    E.slPosOPZ = p:AddSlider('West/East', 0, -100, 100, 1)
    E.slPosOPZ.IDContext = 'adawd'
    E.slPosOPZ.OnChange = function (e)
        MoveEntity(LLGlobals.pointEntity, 'x', e.Value[1], step, nil, 'Point')
        e.Value = {0,0,0,0}
    end

    
    E.btnResetOP = p:AddButton('Reset')
    E.btnResetOP.SameLine = false
    E.btnResetOP.OnClick = function (e)
        MoveEntity(LLGlobals.pointEntity, nil, nil, nil, nil, 'Point')
    end

end
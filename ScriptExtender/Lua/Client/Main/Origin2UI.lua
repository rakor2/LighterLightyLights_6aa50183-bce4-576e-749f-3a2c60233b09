function Origin2PointTab(p)
    p:AddSeparatorText('Funny buttons')
    
    local btnCreateOP = p:AddButton('Create')
    btnCreateOP.OnClick = function (e)

        if LLGlobals.pointUuid then return end

        Channels.CreateOriginPoint:RequestToServer({}, function (Response)
            
            LLGlobals.pointUuid = Response[1]

            Helpers.Timer:OnTicks(5, function ()
                LLGlobals.pointEntity = Ext.Entity.Get(LLGlobals.pointUuid)
            end)
        end)
    end


    local btnToCampOP = p:AddButton('Move to cam')
    btnToCampOP.SameLine = true
    btnToCampOP.OnClick = function (e)

        if not LLGlobals.pointUuid then return end


        local Translate = Camera:GetActiveCamera().Transform.Transform.Translate
        local Data = {
            Translate = Translate,
        }
        Channels.ToCamOriginPoint:SendToServer(Data)
    end 




    
    local btnHideOP = p:AddButton('Hide')
    btnHideOP.SameLine = true
    btnHideOP.OnClick = function (e)
        
        if not LLGlobals.pointUuid then return end

        ToggleMarker(LLGlobals.pointUuid)
    end
    
    



    local btnDeleteOP = p:AddButton('Delete')
    btnDeleteOP.SameLine = true
    btnDeleteOP.OnClick = function (e)
        
        if not LLGlobals.pointUuid then return end

        SourcePoint(false)
        checkOriginSrc.Checked = false
        Channels.DeleteOriginPoint:SendToServer({})
        LLGlobals.pointUuid = nil
        LLGlobals.pointEntity = nil
    end
    
    










    
    
    p:AddSeparatorText('Even funnier sliders')


    local step = 4000


    local slPosOPX = p:AddSlider('South/North', 0, -100, 100, 1)
    slPosOPX.IDContext = 'adawd'
    slPosOPX.OnChange = function (e)
        MoveEntity(LLGlobals.pointEntity, 'z', e.Value[1], step, nil, 'Point')
        e.Value = {0,0,0,0}
    end


    local slPosOPY = p:AddSlider('Down/Up', 0, -100, 100, 1)
    slPosOPY.IDContext = 'adawd'
    slPosOPY.OnChange = function (e)
        MoveEntity(LLGlobals.pointEntity, 'y', e.Value[1], step, nil, 'Point')
        e.Value = {0,0,0,0}
    end


    local slPosOPZ = p:AddSlider('West/East', 0, -100, 100, 1)
    slPosOPZ.IDContext = 'adawd'
    slPosOPZ.OnChange = function (e)
        MoveEntity(LLGlobals.pointEntity, 'x', e.Value[1], step, nil, 'Point')
        e.Value = {0,0,0,0}
    end

    
    local btnResetOP = p:AddButton('Reset')
    btnResetOP.SameLine = false
    btnResetOP.OnClick = function (e)
        MoveEntity(LLGlobals.pointEntity, nil, nil, nil, nil, 'Point')
    end

end
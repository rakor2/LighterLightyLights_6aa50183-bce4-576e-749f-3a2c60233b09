function MainTab(p)
    
    local checkTypePoint
    local checkTypeSpot
    local checkTypeDir
    
    --local btn = p:AddButton('xddd')

    
    checkTypePoint = p:AddCheckbox('Point')
    checkTypePoint.OnChange = function ()

        checkTypeSpot.Checked = false
        checkTypeDir.Checked = false

    end
    
    
    checkTypeSpot = p:AddCheckbox('Spotlight')
    checkTypeSpot.SameLine = true                     
    checkTypeSpot.OnChange = function ()

        checkTypePoint.Checked = false
        checkTypeDir.Checked = false
        
    end
    

    checkTypeDir = p:AddCheckbox('Directional')
    checkTypeDir.SameLine = true
    checkTypeDir.Disabled = true
    checkTypeDir.OnChange = function ()

        checkTypePoint.Checked = false
        checkTypeSpot.Checked = false
    
    end
    
    local btnCreate2 = p:AddButton('Create')
    btnCreate2.SameLine = true
    
    


    
    ---------------------------------------------------------
    local comboCreatedLights = p:AddCombo('Created lights')
    ---------------------------------------------------------
    


    
    
    local comboRenameLights = p:AddCombo('')
    comboRenameLights.IDContext = 'poiufdhgoiufdnb'
    
    local btnRenameLight = p:AddButton('Rename')
    btnRenameLight.SameLine = true
    
    local btnDelete = p:AddButton('Delete')
    
    local btnDeleteAll = p:AddButton('Delete all')
    btnDeleteAll.SameLine = true
    
    local btnDuplicate = p:AddButton('Duplicate')
    btnDuplicate.SameLine = true
    

    

    
    ---------------------------------------------------------
    p:AddSeparatorText([[Character's position source]])
    ---------------------------------------------------------
                                                             


    
    local checkOriginSrc = p:AddCheckbox('Origin point')
    
    local checkCutsceneSrc = p:AddCheckbox('Cutscene')
    checkCutsceneSrc.SameLine = true
    
    local checkClientSrc = p:AddCheckbox('Client-side')
    checkClientSrc.SameLine = true


    p:AddSeparatorText('Parameters')


    function PopulateParameters(p)
        assert(false, 'Function is not implemented')
    end
    

    
end

    ---x,y,z = GetPosition(_C().Uuid.EntityUuid)
    ---l = CreateAt('7279c199-1f14-4bce-8740-98866d9878be',x,y+1,z, 1,0,'')
    ---l = CreateAt('7f6ca8ba-07ed-474f-b5b6-e3eefbe3dc3d',x,y+1,z, 1,0,'')
    --Ext.Entity.GetAllEntitiesWithComponent('Light')[7].Light.Radius = 1
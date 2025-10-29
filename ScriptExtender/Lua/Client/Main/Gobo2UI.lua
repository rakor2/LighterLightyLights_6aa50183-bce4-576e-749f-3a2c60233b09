local xd

function Gobo2Tab(p)



    ---------------------------------------------------------
    p:AddSeparatorText('adawd')
    ---------------------------------------------------------


    local GoboNames = {}

    local GoboUuidNameMap = {
        ['a0d2ac1c-efb5-4f64-9f7d-b01db470e091'] = 'Tree',
        ['c1c8b026-e3c8-4975-bb4f-6b29450c2d18'] = 'Figures',
        ['4eab6f6d-5d94-4827-9331-ae3f67747410'] = 'Window',
        ['13c358b1-9afc-4acf-b121-fa38994d72d2'] = 'Stars',
        ['34329d13-f74d-46ac-928c-c6b40b87b644'] = 'Star',
        ['0435655f-4c3b-48dc-970e-55afc2956cd6'] = 'Asstation',
        ['213674c9-8606-4f08-aaea-7ef3b7339e6e'] = 'Asstation2',
        ['fc270e8b-7192-47af-b440-f5a87dd3d2cf'] = 'Water',
        ['1b86fb4a-330e-413e-ba8f-fbb1e51846fe'] = 'Blinds',
        ['08a26239-974d-4837-88be-f0365792cad9'] = 'Dots',
        ['e6748263-1452-4a78-a2c7-e2ad32c90ff8'] = 'Flowers',
    }

    for uuid, name in pairs(GoboUuidNameMap) do
        table.insert(GoboNames, name)
    end
    table.sort(GoboNames)

    
    for uuid, name in pairs(GoboUuidNameMap) do
        if name == GoboNames[1] then
            LLGlobals.selectedGobo = uuid
        end
    end

    
    comboIHateCombos2 = p:AddCombo('')
    comboIHateCombos2.Options = LLGlobals.LightsNames
    comboIHateCombos2.SelectedIndex = LLGlobals.syncedSelectedIndex
    comboIHateCombos2.OnChange = function (e)
        
        if not LLGlobals.selectedUuid then return end

        LLGlobals.syncedSelectedIndex = comboIHateCombos2.SelectedIndex
        comboIHateCombos.SelectedIndex = LLGlobals.syncedSelectedIndex
        SelectLight()
    end


    local txtCreateLight2 = p:AddText('Created lights')
    txtCreateLight2.SameLine = true



    local goboList = p:AddCombo('')
    goboList.IDContext = 'GoboMasksList'
    goboList.HeightLargest = true
    goboList.Options = GoboNames
    goboList.SelectedIndex = 0
    goboList.OnChange = function (e)
        
        if not LLGlobals.selectedUuid then return end
        
        for guid, name in pairs(GoboUuidNameMap) do
            if name == goboList.Options[goboList.SelectedIndex + 1] then
                LLGlobals.selectedGobo = guid
            end
        end
    end

    local goboPrev = p:AddButton('<')
    goboPrev.SameLine = true
    goboPrev.IDContext = 'a;leksfmn'
    goboPrev.OnClick = function (e)
        if not LLGlobals.selectedUuid then return end

        UI:PrevOption(goboList)
        
        for guid, name in pairs(GoboUuidNameMap) do
            if name == goboList.Options[goboList.SelectedIndex + 1] then
                LLGlobals.selectedGobo = guid
            end
        end

        Channels.DeleteGobo:SendToServer({})
        
        Helpers.Timer:OnTicks(3, function ()
            local Data = {
                goboGuid = LLGlobals.selectedGobo
            }
            
            Channels.CreateGobo:SendToServer(Data)
        end)

    end

    local goboNext = p:AddButton('>')
    goboNext.SameLine = true
    goboNext.IDContext = 'a;leksawdfmn'
    goboNext.OnClick = function (e)
        if not LLGlobals.selectedUuid then return end

        UI:NextOption(goboList)
        
        for guid, name in pairs(GoboUuidNameMap) do
            if name == goboList.Options[goboList.SelectedIndex + 1] then
                LLGlobals.selectedGobo = guid
            end
        end

        Channels.DeleteGobo:SendToServer({})
        
        Helpers.Timer:OnTicks(3, function ()
            local Data = {
                goboGuid = LLGlobals.selectedGobo
            }
            
            Channels.CreateGobo:SendToServer(Data)
        end)

    end

    
    local textMask = p:AddText('Masks')
    textMask.SameLine = true

    local goboDistanceSlider = p:AddSlider('Distance', 0.1, 0.1, 10, 1)
    goboDistanceSlider.IDContext = 'GoboDistanceSlider'
    goboDistanceSlider.OnChange = function(e)

        if not LLGlobals.selectedUuid then return end
        
        local Data = {
            step = 1,
            offset = e.Value[1],
        }

        Channels.GoboTranslate:SendToServer(Data)
    end

    local createGoboButton = p:AddButton('Create gobo')
    createGoboButton.IDContext = 'CreateGoboButton'
    createGoboButton.OnClick = function()

        if not LLGlobals.selectedUuid then return end
                

        local Data = {
            goboGuid = LLGlobals.selectedGobo
        }

        Channels.CreateGobo:SendToServer(Data)
    end


    local deleteGoboButton = p:AddButton('Delete')
    deleteGoboButton.IDContext = 'DeleteGoboButton'
    deleteGoboButton.SameLine = true
    deleteGoboButton.OnClick = function()
        
        if not LLGlobals.selectedUuid then return end


        Channels.DeleteGobo:SendToServer({})
    end



    local deleteGoboButton = p:AddButton('Delete all')
    deleteGoboButton.IDContext = 'DeleteGoboButton'
    deleteGoboButton.SameLine = true
    deleteGoboButton.OnClick = function()

        if not LLGlobals.selectedUuid then return end

        Channels.DeleteGobo:SendToServer('All')
    end

end




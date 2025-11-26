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
        ['213674c9-8606-4f08-aaea-7ef3b7339e6e'] = 'Bhaal bs',
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


    E.comboIHateCombos2 = p:AddCombo('')
    E.comboIHateCombos2.Options = LLGlobals.LightsNames
    E.comboIHateCombos2.SelectedIndex = LLGlobals.syncedSelectedIndex
    E.comboIHateCombos2.OnChange = function (e)

        if not LLGlobals.selectedUuid then return end

        LLGlobals.syncedSelectedIndex = E.comboIHateCombos2.SelectedIndex
        E.comboIHateCombos.SelectedIndex = LLGlobals.syncedSelectedIndex
        SelectLight()
    end


    E.txtCreateLight2 = p:AddText('Created lights')
    E.txtCreateLight2.SameLine = true



    E.goboList = p:AddCombo('')
    E.goboList.IDContext = 'GoboMasksList'
    E.goboList.HeightLargest = true
    E.goboList.Options = GoboNames
    E.goboList.SelectedIndex = 0
    E.goboList.OnChange = function (e)

        if not LLGlobals.selectedUuid then return end

        for guid, name in pairs(GoboUuidNameMap) do
            if name == E.goboList.Options[E.goboList.SelectedIndex + 1] then
                LLGlobals.selectedGobo = guid
            end
        end
    end

    E.goboPrev = p:AddButton('<')
    E.goboPrev.SameLine = true
    E.goboPrev.IDContext = 'a;leksfmn'
    E.goboPrev.OnClick = function (e)
        if not LLGlobals.selectedUuid then return end

        UI:PrevOption(E.goboList)

        for guid, name in pairs(GoboUuidNameMap) do
            if name == E.goboList.Options[E.goboList.SelectedIndex + 1] then
                LLGlobals.selectedGobo = guid
            end
        end

        Channels.DeleteGobo:SendToServer({})

        Helpers.Timer:OnTicks(3, function ()
            local Data = {
                goboGuid = LLGlobals.selectedGobo
            }

            Channels.CreateGobo:RequestToServer(Data, function (Response)
                LLGlobals.selectedGoboUuid = Response
            end)
        end)

    end

    E.goboNext = p:AddButton('>')
    E.goboNext.SameLine = true
    E.goboNext.IDContext = 'a;leksawdfmn'
    E.goboNext.OnClick = function (e)
        if not LLGlobals.selectedUuid then return end

        UI:NextOption(E.goboList)

        for guid, name in pairs(GoboUuidNameMap) do
            if name == E.goboList.Options[E.goboList.SelectedIndex + 1] then
                LLGlobals.selectedGobo = guid
            end
        end

        Channels.DeleteGobo:SendToServer({})

        Helpers.Timer:OnTicks(3, function ()
            local Data = {
                goboGuid = LLGlobals.selectedGobo
            }

            Channels.CreateGobo:RequestToServer(Data, function (Response)
                LLGlobals.selectedGoboUuid = Response
            end)
        end)

    end


    textMask = p:AddText('Masks')
    textMask.SameLine = true

    E.goboDistanceSlider = p:AddSlider('Distance', 0.1, 0.1, 10, 1)
    E.goboDistanceSlider.IDContext = 'E.goboDistanceSlider'
    E.goboDistanceSlider.OnChange = function(e)

        if not LLGlobals.selectedUuid then return end

        local Data = {
            step = 1,
            offset = e.Value[1],
        }

        Channels.GoboTranslate:SendToServer(Data)
    end

    E.createGoboButton = p:AddButton('Create gobo')
    E.createGoboButton.IDContext = 'E.createGoboButton'
    E.createGoboButton.OnClick = function()

        if not LLGlobals.selectedUuid then return end


        local Data = {
            goboGuid = LLGlobals.selectedGobo
        }

        Channels.CreateGobo:RequestToServer(Data, function (Response)
            LLGlobals.selectedGoboUuid = Response
        end)

    end


    E.deleteGoboButton = p:AddButton('Delete')
    E.deleteGoboButton.IDContext = 'E.deleteGoboButton'
    E.deleteGoboButton.SameLine = true
    E.deleteGoboButton.OnClick = function()

        if not LLGlobals.selectedUuid then return end


        Channels.DeleteGobo:SendToServer('Single')
    end


    E.deleteGoboButtonAll = p:AddButton('Delete all')
    E.deleteGoboButtonAll.IDContext = 'E.deleteGoboButton'
    E.deleteGoboButtonAll.SameLine = true
    E.deleteGoboButtonAll.OnClick = function()

        if not LLGlobals.selectedUuid then return end

        Channels.DeleteGobo:SendToServer('All')
    end


    function hideGobo()
        if not LLGlobals.selectedUuid then return end

        local uuid = LLGlobals.selectedGoboUuid
        local newScaleX
        local defaultScale = 0.07
        local entity = Ext.Entity.Get(uuid)
        if entity and entity.Visual then
            local scaleX = entity.Visual.Visual.WorldTransform.Scale[1]
            newScaleX = scaleX == 0 and defaultScale or 0
            entity.Visual.Visual:SetWorldScale({newScaleX,newScaleX,newScaleX})
        end
    end


    E.btnHideGobo = p:AddButton('Hide')
    E.btnHideGobo.IDContext = 'E.wdzawdawdawdw'
    E.btnHideGobo.SameLine = false
    E.btnHideGobo.OnClick = function()
        hideGobo()
    end


end




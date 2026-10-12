function Gobo2Tab(p)
    local GoboNames = {}


    p:AddSeparatorText('adawd')

    for uuid, name in pairs(GoboUuidNameMap) do
        table.insert(GoboNames, name)
    end
    table.sort(GoboNames)



    for uuid, name in pairs(GoboUuidNameMap) do
        if name == GoboNames[1] then
            _GLL.selectedGobo = uuid
        end
    end



    E.comboIHateCombos2 = p:AddCombo('')
        UI:Config(E.comboIHateCombos2, {
            Options       = _GLL.LightsNames,
            SelectedIndex = _GLL.syncedSelectedIndex,
            OnChange      = function(e)
                if not _GLL.selectedUuid then return end

                _GLL.syncedSelectedIndex = E.comboIHateCombos2.SelectedIndex
                E.comboIHateCombos.SelectedIndex = _GLL.syncedSelectedIndex
                SelectLight()
            end
        })



    E.txtCreateLight2 = p:AddText('Created lights')
        UI:Config(E.txtCreateLight2, { SameLine = true })



    local function ReCreateGobo()
        for guid, name in pairs(GoboUuidNameMap) do
            if name == E.goboList.Options[E.goboList.SelectedIndex + 1] then
                _GLL.selectedGobo = guid
            end
        end

        Ch.DeleteGobo:SendToServer({})

        Helpers.Timer:OnTicks(3, function()
            local Data = {
                goboGuid = _GLL.selectedGobo
            }

            Ch.CreateGobo:RequestToServer(Data, function(Response)
                _GLL.selectedGoboUuid = Response
            end)
        end)
    end



    E.goboList = p:AddCombo('')
        UI:Config(E.goboList, {
            IDContext    = 'GoboMasksList',
            HeightLargest = true,
            Options      = GoboNames,
            SelectedIndex = 0,
            OnChange     = function(e)
                if not _GLL.selectedUuid then return end
                ReCreateGobo()
            end,
            OnRightClick = function(e)
                if not _GLL.selectedUuid then return end
                ReCreateGobo()
            end
        })



    E.goboPrev = p:AddButton('<')
        UI:Config(E.goboPrev, {
            SameLine  = true,
            IDContext = 'a;leksfmn',
            OnClick   = function(e)
                if not _GLL.selectedUuid then return end
                UI:PrevOption(E.goboList)
                ReCreateGobo()
            end
        })



    E.goboNext = p:AddButton('>')
        UI:Config(E.goboNext, {
            SameLine  = true,
            IDContext = 'a;leksawdfmn',
            OnClick   = function(e)
                if not _GLL.selectedUuid then return end
                UI:NextOption(E.goboList)
                ReCreateGobo()
            end
        })



    textMask = p:AddText('Masks')
        UI:Config(textMask, { SameLine = true })



    E.goboDistanceSlider = p:AddSlider('Distance', 0.1, 0.1, 10, 1)
        UI:Config(E.goboDistanceSlider, {
            IDContext = 'E.goboDistanceSlider',
            OnChange  = function(e)
                if not _GLL.selectedUuid then return end
                local Data = {
                    step   = 1,
                    offset = e.Value[1],
                }
                Ch.GoboTranslate:SendToServer(Data)
            end
        })



    E.createGoboButton = p:AddButton('Create gobo')
        UI:Config(E.createGoboButton, {
            IDContext = 'E.createGoboButton',
            OnClick   = function()
                if not _GLL.selectedUuid then return end
                local Data = {
                    goboGuid = _GLL.selectedGobo
                }
                Ch.CreateGobo:RequestToServer(Data, function(Response)
                    _GLL.selectedGoboUuid = Response
                end)
            end
        })



    E.deleteGoboButton = p:AddButton('Delete')
        UI:Config(E.deleteGoboButton, {
            IDContext = 'E.deleteGoboButton',
            SameLine  = true,
            OnClick   = function()
                Ch.DeleteGobo:SendToServer('Single')
            end
        })



    E.deleteGoboButtonAll = p:AddButton('Delete all')
        UI:Config(E.deleteGoboButtonAll, {
            IDContext = 'E.deleteGoboButton',
            SameLine  = true,
            OnClick   = function()
                Ch.DeleteGobo:SendToServer('All')
            end
        })



    local function HideGobo()
        if not _GLL.selectedUuid then return end

        local uuid         = _GLL.selectedGoboUuid
        local newScaleX
        local defaultScale = 0.07
        local entity       = Ext.Entity.Get(uuid)
        if entity and entity.Visual then
            local scaleX = entity.Visual.Visual.WorldTransform.Scale[1]
            newScaleX = scaleX == 0 and defaultScale or 0
            entity.Visual.Visual:SetWorldScale({newScaleX, newScaleX, newScaleX})
        end
    end



    E.btnHideGobo = p:AddButton('Hide')
        UI:Config(E.btnHideGobo, {
            IDContext = 'E.wdzawdawdawdw',
            SameLine  = false,
            OnClick   = function()
                HideGobo()
            end
        })
end
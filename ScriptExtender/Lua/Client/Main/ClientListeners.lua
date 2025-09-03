---@diagnostic disable: param-type-mismatch

---Gets selected characters index in the Fill combo
function getSelectedFillCharacter()
    if visTemComob then
        local selectedOptionName = visTemComob.Options[visTemComob.SelectedIndex + 1]
        selectedCharacter = NamedOptions[selectedOptionName]
    end
end

---@param charUuid string
---@param dummies table<EntityHandle> | #table with PM dummies
---@return EntityHandle
function MatchCharacterAndPMDummy(charUuid, dummies)
    local originEnt = Ext.Entity.Get(charUuid)
    for i = 1, #dummies do
        if originEnt and originEnt.Transform
            and originEnt.Transform.Transform.Translate[1] == dummies[i].Transform.Transform.Translate[1]
            and originEnt.Transform.Transform.Translate[2] == dummies[i].Transform.Transform.Translate[2] 
            and originEnt.Transform.Transform.Translate[3] == dummies[i].Transform.Transform.Translate[3] then
            return dummies[i]
        end
    end
end

function matchDummyAndCharacter(entity, dummy)
    local e = Ext.Entity.Get(entity)
    if e and e.Transform
        and e.Transform.Transform.Translate[1] == dummy.Transform.Transform.Translate[1]
        and e.Transform.Transform.Translate[2] == dummy.Transform.Transform.Translate[2] 
        and e.Transform.Transform.Translate[3] == dummy.Transform.Transform.Translate[3] then
        return dummy
    end
end

local function hasPMDummyComponent(entity)
    local components = entity:GetAllComponentNames(false)
    for _, component in pairs(components) do
        if component:lower():find('ecl::dummy::dummycomponent') then
            return entity
        end
    end
    return false
end

function dumpDummies()
    local v = Ext.Entity.GetAllEntitiesWithComponent("Visual")
    for _, entity in pairs(v) do 
        for _, component in pairs(entity:GetAllComponentNames(false)) do
            if component:lower():find('dummy') then
                DPrint(entity)
                break
            end
        end
    end
end




---@return EntityHandle[] visTemplatesTable
---@return table visTemplatesOptions
function getDummyVisualTemplates()
end

local visTemplatesOptions = {}
Ext.Entity.OnCreate('PauseExcluded', function (entity)
    local characters = Ext.Entity.GetAllEntitiesWithComponent('Origin')
    for _, character in pairs(characters) do
        if matchDummyAndCharacter(character, entity) then
            local name = character.DisplayName.Name:Get()
            if name then
                table.insert(visTemplatesOptions, name .. '##' .. Ext.Math.Random(1,10000))
                table.insert(visTemplatesTable, entity)
                if visTemComob then
                    selectedCharacter = visTemComob.SelectedIndex + 1
                    visTemComob.Options = visTemplatesOptions
                end
            end
        end
    end
    Utils:AntiSpam(100, function ()
        UpdateCharacterInfo()
        Utils:SubUnsubToTick('sub', 'LL_PM', function ()
        if Entity:IsPMDummy(entity) then
            return
        else
            visTemplatesTable = {}
            visTemplatesOptions = {}
            visTemComob.Options = {}
            UpdateCharacterInfo()
            Utils:SubUnsubToTick('unsub', 'LL_PM', nil)
        end
    end)
    end)
end)

Ext.Events.ResetCompleted:Subscribe(function()
    Helpers.Timer:OnTicks(100, function ()
        if hasPMDummyComponent(_C()) then
            Helpers.Timer:OnTicks(1, function ()
                visTemplatesTable, _ = getDummyVisualTemplates()
                getSelectedFillCharacter()
                selectedCharacter = visTemComob.SelectedIndex + 1
            end)
        end
    end)
end)



-- Utils:SubUnsubToTick('sub', 'PM_Test',function ()
--     Mods.Luas._DD(Mods.LL2.Camera:GetActiveCamera(), '_PM_Cam_1', true)
-- end)



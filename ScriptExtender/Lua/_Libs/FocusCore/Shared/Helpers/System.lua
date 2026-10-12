local ExcludeProp = {
    MaterialGroups = 'MaterialGroups',
    EmotionalMaterials = 'EmotionalMaterials',
    Lighting = 'Lighting',
    SystemConfig = 'SystemConfig',
}


---@param system ExtSystemType
function WatchSystem(system)
    local previousValues = {}
    Ext.Entity.OnSystemUpdate(system, function()
        local sys = Ext.System[system]
        local props = Ext.Types.GetTypeInfo(Ext.Types.GetValueType(Ext.System[system])).Members
        for prop in pairs(props) do
            if not ExcludeProp[prop] then
                local value = sys[prop]
                local valueType = Ext.Types.GetBaseValueType(value)
                local currentValue
                local isCollection = valueType == "Set" or valueType == "Map" or valueType == "Array" or valueType == "table"
                if isCollection then
                    currentValue = #value
                else
                    currentValue = value
                end

                if previousValues[prop] ~= currentValue then
                    Ext.Log.Print(string.format("%s.%s %s --> %s", system, prop, previousValues[prop], currentValue))
                    previousValues[prop] = currentValue
                    if isCollection and currentValue ~= 0 then
                        Ext.DumpShallow(value)
                    end
                end
            else
                DPrint(prop)
            end
        end
    end)
end

---@param system ExtSystemType
---@param property string
function WatchSystemProperty(system, property)
    local previousValue = nil
    Ext.Entity.OnSystemUpdate(system, function()
        local sys = Ext.System[system]
        local value = sys[property]
        local valueType = Ext.Types.GetBaseValueType(value)
        local currentValue
        local isCollection = valueType == "Set" or valueType == "Map" or valueType == "Array" or valueType == "table"
        if isCollection then
            currentValue = #value
        else
            currentValue = value
        end

        if previousValue ~= currentValue then
            Ext.Log.Print(string.format("%s.%s %s --> %s", system, property, previousValue, currentValue))
            previousValue = currentValue
            if isCollection and currentValue ~= 0 then
                Ext.DumpShallow(value)
            end
        end
    end)
end

Ext.RegisterConsoleCommand("WatchSystem", function(_, system)
    WatchSystem(system)
end)

Ext.RegisterConsoleCommand("WatchSystemProperty", function(_, system, property)
    WatchSystemProperty(system, property)
end)




Globals.CreatedLightsServer = {}
Globals.selectedUuid = nil

INITIAL_LIGHT_TEMPLATE_0 = 'd92ed2ec-a332-4a28-ae3d-99f79ee0fa92'
INITIAL_LIGHT_TEMPLATE_1 = 'd92ed2ec-a332-4a28-ae3d-99f79ee0fa92'
INITIAL_LIGHT_TEMPLATE_2 = 'd92ed2ec-a332-4a28-ae3d-99f79ee0fa92'

Channels.CreateLight:SetRequestHandler(function (Data)
    
    local uuid 

    DDump(Data)

    if Data.type == 1 then
        uuid = INITIAL_LIGHT_TEMPLATE_1
    elseif Data.type == 2 then
        uuid = INITIAL_LIGHT_TEMPLATE_2
    else
        uuid = INITIAL_LIGHT_TEMPLATE_0
    end


    local x,y,z = Data.Position[1], Data.Position[2], Data.Position[3]

    local offset = 1
    local entUuid = Osi.CreateAt(uuid, x, y + offset, z, 1, 0, '')
    Globals.selectedUuid = entUuid



    local entity = Ext.Entity.Get(entUuid)

    Globals.CreatedLightsServer[Globals.selectedUuid] = Globals.selectedUuid
    
    --table.insert(Globals.CreatedLightsServer, entUuid)

    local Response = {
        Globals.CreatedLightsServer,
        Globals.selectedUuid
    }
    
    DPrint('%s, %s', entUuid, entity)
    
    -- Helpers.Timer:OnTicks(50, function ()
    --     Utils:Dump(Ext.Entity.Get(Globals.selectedUuid), 'LL2_Light_Server', true)
    -- end)

    return Response

end)

Channels.DeleteLight:SetHandler(function (selectedLight)
    if selectedLight == 'All' then
        for _, entUuid in pairs(Globals.CreatedLightsServer) do
            Osi.RequestDelete(entUuid)
            Globals.CreatedLightsServer = {}
        end
    else
        Osi.RequestDelete(selectedLight)
        Globals.CreatedLightsServer[selectedLight] = nil
    end
    DDump(Globals.CreatedLightsServer)
end)


Channels.SelectedLight:SetHandler(function (selectedLight)
    Globals.selectedUuid = selectedLight
end)

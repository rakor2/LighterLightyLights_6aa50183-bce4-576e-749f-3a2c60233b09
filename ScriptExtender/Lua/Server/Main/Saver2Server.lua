local ClientState = {}
local ServerState = {}
local SceneState = {}

Channels.SceneSave:SetHandler(function (Data)
    
    local ClientState = Data
    
    ServerState = {
        SV_CreatedLightsServer = LLGlobals.CreatedLightsServer,
        SV_LightParametersServer = LLGlobals.LightParametersServer,
        SV_markerUuid = LLGlobals.markerUuid,
        SV_selectedUuid = LLGlobals.selectedUuid,
        SV_GoboLightMap = LLGlobals.GoboLightMap,
        SV_GoboDistances = LLGlobals.GoboDistances,
    }
    
    SceneState = {
        ClientState = ClientState,
        ServerState = ServerState
    }


    local json = Ext.Json.Stringify(SceneState)
    Ext.IO.SaveFile("LightyLights/SceneState.json", json)
    


    DDump(ClientState)
    DDump(ServerState)


end)


Channels.SceneLoad:SetRequestHandler(function (Data)
    
    local json = Ext.IO.LoadFile("LightyLights/SceneState.json")
    SceneState = Ext.Json.Parse(json)
    ServerState = SceneState.ServerState

    -- DDump(SceneState.ServerState)

    LLGlobals.CreatedLightsServer = ServerState.SV_CreatedLightsServer
    LLGlobals.LightParametersServer = ServerState.SV_LightParametersServer
    LLGlobals.markerUuid = ServerState.SV_markerUuid
    LLGlobals.selectedUuid = ServerState.SV_selectedUuid
    LLGlobals.GoboLightMap = ServerState.SV_GoboLightMap
    LLGlobals.GoboDistances = ServerState.SV_GoboDistances

    return SceneState.ClientState
end)

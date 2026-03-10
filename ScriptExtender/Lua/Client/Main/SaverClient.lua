local ClientState = {}



function Saver2Tab(p)

    local btnSaveScene = p:AddButton('Save scene')
    btnSaveScene.OnClick = function (e)
        ClientState = {
            CL_CreatedLightsServer = LLGlobals.CreatedLightsServer,
            CL_LightsUuidNameMap = LLGlobals.LightsUuidNameMap,
            CL_LightsNames = LLGlobals.LightsNames,
            CL_LightParametersClient = LLGlobals.LightParametersClient,
            CL_selectedUuid = LLGlobals.selectedUuid,
            CL_markerUuid  = LLGlobals.markerUuid,
            CL_selectedGobo = LLGlobals.selectedGobo,
            CL_nameIndex = nameIndex,
        }
        Ch.SceneSave:SendToServer(ClientState)
    end



    local btnLoadScene = p:AddButton('Load scene')
    btnLoadScene.OnClick = function (e)
        Ch.SceneLoad:RequestToServer({},function (Response)
            ClientState = Response

            LLGlobals.CreatedLightsServer = ClientState.CL_CreatedLightsServer
            LLGlobals.LightsUuidNameMap = ClientState.CL_LightsUuidNameMap
            LLGlobals.LightsNames = ClientState.CL_LightsNames
            LLGlobals.LightParametersClient = ClientState.CL_LightParametersClient
            LLGlobals.selectedUuid = ClientState.CL_selectedUuid
            LLGlobals.markerUuid = ClientState.CL_markerUuid
            LLGlobals.selectedGobo = ClientState.CL_selectedGobo
            nameIndex = ClientState.CL_nameIndex

            Imgui.ClearChildren(mw)

            Helpers.Timer:OnTicks(50, function ()
                MainWindow(mw)
            end)
        end)
    end
end
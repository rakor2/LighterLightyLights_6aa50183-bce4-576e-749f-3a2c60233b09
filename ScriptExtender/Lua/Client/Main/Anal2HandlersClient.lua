    function ResetAllATM()
        return 0
    end

    function ResetAllLTN()
        return 0
    end

        
    LLGlobals.LtnComboOptions = {}
    LLGlobals.AtmComboOptions = {}

    function PopulateLTNOptions()
        for _, name in ipairs(Utils:MapToArray(ltn_templates2)) do
            table.insert(LLGlobals.LtnComboOptions, name)
        end
    end
    PopulateLTNOptions()



    function PopulateATMOptions()
        for _, name in ipairs(Utils:MapToArray(atm_templates2)) do
            table.insert(LLGlobals.AtmComboOptions, name)
        end
    end
    PopulateATMOptions()



    ---@param hardcode string #yeaaah, the code is hard af B) 
    function CreateSelectable(parent, tbl, lable, hardcode, hardcode2)
        local selectable
        local id = Ext.Math.Random(1, 9999)
        local delete = parent:AddButton('X')
        delete.IDContext = id
        delete.SameLine = false
        delete.OnClick = function ()
            tbl[lable] = nil
            Ext.IO.SaveFile('LightyLights/' .. hardcode .. '.json', Ext.Json.Stringify(tbl))
            selectable:Destroy()
            delete:Destroy()
        end
        selectable = parent:AddButton(lable)
        selectable.IDContext = id
        selectable.SameLine = true
        selectable.OnClick = function ()
            Ext.Net.PostMessageToServer(hardcode2, selectable.Label)
        end
        tbl[lable] = lable
        Ext.IO.SaveFile('LightyLights/' .. hardcode .. '.json', Ext.Json.Stringify(tbl))
    end

    
    function PopulateLTNFavorites(imguiWindow, tbl)
        for _,lable in pairs(tbl) do
            CreateSelectable(imguiWindow, tbl, lable, 'FavoriteLighting', 'LL_LightingApply')
        end
    end



    function PopulateATMFavorites(imguiWindow, tbl)
        for _,lable in pairs(tbl) do
            CreateSelectable(imguiWindow, tbl, lable, 'FavoriteAtmosphere', 'LL_AtmosphereApply')
        end
    end



    
    

        
--- slop
--- tbd: smol refactor
--#region I like it, but I'll stick to dumb way
--     local CONFIG = {
--         LIGHTING_GUID = '375af627-6f3c-19e8-1046-29265ae9e8f7',
--         ATMOSPHERE_GUID = 'be77c334-0d95-6d88-6cf7-b55f71d5f1d0',
        
--         INTEGER_PARAMS = {
--             CascadeCount = true,
--             ShadowObscurity = true,
--             SunlightObscurity = true,
--             PhysicalModel = true,
--             LutApplyMode = true,
--             ExposureMeteringMode = true,
--             InheritanceFlags = true,
--         },
        
--         IGNORED_PARAMS = {
--         },
        
--         SLIDER_CONFIG = {
--             ['CirrusCloudsIntensity'] = {5, 1, 10, false},
--             ['Kelvin'] = {5600, 1, 9000, false},
--         },
        
--         DEFAULT_SLIDER = {
--             default = 0,
--             min = -1000,
--             max = 1000,
--             logarithmic = false
--         }
--     }

--     local function isArray(tbl)
--         if type(tbl) ~= "table" then return false end
--         for k in pairs(tbl) do
--             if type(k) ~= "number" then return false end
--         end
--         return true
--     end

--     local function isColorParam(name)
--         local lower = string.lower(tostring(name))
--         return lower:find("color") or lower:find("albedo")
--     end

--     local function isIntegerParam(name)
--         return CONFIG.INTEGER_PARAMS[tostring(name)]
--     end

--     local function isIgnoredParam(name)
--         return CONFIG.IGNORED_PARAMS[tostring(name)]
--     end




--     local ResourceManager = {}

--     function ResourceManager.get(resourceType, guid)
--         if resourceType == 'Atmosphere' then
--             return Ext.Resource.Get(guid, 'Atmosphere').Atmosphere
--         else
--             return Ext.Resource.Get(guid, 'Lighting').Lighting
--         end
--     end

--     function ResourceManager.getValue(resourceType, guid, path)
--         local data = ResourceManager.get(resourceType, guid)
        
--         for part in path:gmatch("[^.]+") do
--             local key = tonumber(part) or part
--             if data == nil then return nil end
--             data = data[key]
--         end
        
--         return data
--     end

--     function ResourceManager.setValue(resourceType, guid, path, value)
--         local data = ResourceManager.get(resourceType, guid)
--         local parts = {}
--         for part in path:gmatch("[^.]+") do
--             table.insert(parts, tonumber(part) or part)
--         end
        
--         if #parts == 0 then return false end
        
--         for i = 1, #parts - 1 do
--             if data == nil then return false end
--             data = data[parts[i]]
--         end
        
--         if data == nil then return false end
        

--         data[parts[#parts]] = value
--         return true
--     end



    
--     local function getSliderConfig(name)
--         local config = CONFIG.SLIDER_CONFIG[tostring(name)]
--         if config then
--             return {
--                 default = config[1],
--                 min = config[2],
--                 max = config[3],
--                 logarithmic = config[4]
--             }
--         else
--             return CONFIG.DEFAULT_SLIDER
--         end
--     end


--     local UIBuilder = {}

--     function UIBuilder.createColorEdit(parent, name, path, color, resourceType)
--         local edit = parent:AddColorEdit(name)
--         edit.Color = {color[1] or 0, color[2] or 0, color[3] or 0, color[4] or 1}
--         edit.NoAlpha = true
--         edit.OnChange = function(e)
--             if resourceType == 'Atmosphere' then
--                 SetAtmosphereValue(path, {e.Color[1], e.Color[2], e.Color[3]})
--             else
--                 SetLightingValue(path, {e.Color[1], e.Color[2], e.Color[3]})
--             end
--         end
--     end

--     function UIBuilder.createSlider(parent, name, path, value, resourceType)
--         local sliderConfig = getSliderConfig(name)
        
--         local slider = parent:AddSlider(name, sliderConfig.default, sliderConfig.min, sliderConfig.max, 1)
--         slider.Value = {value, 0, 0, 0}
--         slider.Logarithmic = sliderConfig.logarithmic
--         slider.IDContext = Ext.Math.Random(1,100)
--         slider.OnChange = function(e)
--             if resourceType == 'Atmosphere' then
--                 SetAtmosphereValue(path, e.Value[1])
--             else
--                 SetLightingValue(path, e.Value[1])
--             end
--         end
--     end

--     function UIBuilder.createIntSlider(parent, name, path, value, resourceType)
--         local sliderConfig = getSliderConfig(name)
        
--         local slider = parent:AddSliderInt(name, sliderConfig.default, sliderConfig.min, sliderConfig.max, 1)
--         slider.Value = {value, 0, 0, 0}
--         slider.Logarithmic = sliderConfig.logarithmic
--         slider.IDContext = Ext.Math.Random(1,100)
--         slider.OnChange = function(e)
--             if resourceType == 'Atmosphere' then
--                 SetAtmosphereValue(path, e.Value[1])
--             else
--                 SetLightingValue(path, e.Value[1])
--             end
--         end
--     end

--     function UIBuilder.createCheckbox(parent, name, path, checked, resourceType)
--         local checkbox = parent:AddCheckbox(name)
--         checkbox.Checked = checked
--         checkbox.IDContext = Ext.Math.Random(1,100)
--         checkbox.OnChange = function(e)
--             if resourceType == 'Atmosphere' then
--                 SetAtmosphereValue(path, e.Checked)
--             else
--                 SetLightingValue(path, e.Checked)
--             end
--         end
--     end

--     function UIBuilder.createInputText(parent, name, path, text, resourceType)
--         local input = parent:AddInputText(name)
--         input.Text = text
--         input.IDContext = Ext.Math.Random(1,100)
--         input.OnChange = function(e)
--             if resourceType == 'Atmosphere' then
--                 SetAtmosphereValue(path, e.Text)
--             else
--                 SetLightingValue(path, e.Text)
--             end
--         end
--     end



--     local TreeBuilder = {}

--     function TreeBuilder.new(resourceType, guid)
--         local self = {
--             resourceType = resourceType,
--             guid = guid
--         }
        
--         function self.onChange(path, value)
--             ResourceManager.setValue(resourceType, guid, path, value)
--             DPrint(string.format("%s = %s", path, tostring(value)))
--         end
        
--         function self.createContainer(parent, name, level)
--             if level == 0 then
--                 return parent:AddCollapsingHeader(name)
--             else
--                 return parent:AddTree(name)
--             end
--         end
        
--         function self.processArray(parent, path, array, name)
--             if isColorParam(name) and (#array == 3 or #array == 4) then
--                 UIBuilder.createColorEdit(parent, name, path, array, self.resourceType)
--                 return
--             end
            
--             for i, val in ipairs(array) do
--                 local itemPath = path .. "." .. i
--                 self.processValue(parent, tostring(i), itemPath, val)
--             end
--         end
        
--         function self.processValue(parent, name, path, value)
--             local valueType = type(value)
            
--             if valueType == "boolean" then
--                 UIBuilder.createCheckbox(parent, name, path, value, self.resourceType)
                
--             elseif valueType == "number" then
--                 if isIntegerParam(name) then
--                     UIBuilder.createIntSlider(parent, name, path, value, self.resourceType)
--                 else
--                     UIBuilder.createSlider(parent, name, path, value, self.resourceType)
--                 end
                
--             elseif valueType == "string" then
--                 UIBuilder.createInputText(parent, name, path, value, self.resourceType)
--             end
--         end
        
--         function self.traverse(data, parent, path, level)
--             path = path or ""
--             level = level or 0
            
--             for key, value in pairs(data) do
--                 if isIgnoredParam(key) then goto continue end
                
--                 local currentPath = path == "" and tostring(key) or (path .. "." .. tostring(key))
--                 local valueType = type(value)
                
--                 if valueType == "table" and isArray(value) then
--                     if isColorParam(key) then
--                         self.processArray(parent, currentPath, value, key)
--                     else
--                         local container = self.createContainer(parent, tostring(key), level)
--                         self.processArray(container, currentPath, value, key)
--                     end
                    
--                 elseif valueType == "table" then
--                     local container = self.createContainer(parent, tostring(key), level)
--                     self.traverse(value, container, currentPath, level + 1)
                    
--                 elseif valueType == "userdata" then
--                     local container = self.createContainer(parent, tostring(key), level)
--                     pcall(function()
--                         self.traverse(value, container, currentPath, level + 1)
--                     end)
                    
--                 else
--                     self.processValue(parent, tostring(key), currentPath, value)
--                 end
                
--                 ::continue::
--             end
--         end
        
--         return self
--     end




--     function CreateParameters(resourceType, parent)
--         resourceType = resourceType or 'Lighting'
        
--         local guid = resourceType == 'Atmosphere'
--             and CONFIG.ATMOSPHERE_GUID
--             or CONFIG.LIGHTING_GUID
        
--         local data = ResourceManager.get(resourceType, guid)
--         local builder = TreeBuilder.new(resourceType, guid)
        
--         builder.traverse(data, parent)
--     end



-- -- 

--     function GetLightingValue(path)
--         return ResourceManager.getValue('Lighting', CONFIG.LIGHTING_GUID, path)
--     end

--     function GetAtmosphereValue(path)
--         return ResourceManager.getValue('Atmosphere', CONFIG.ATMOSPHERE_GUID, path)
--     end


--     function SetLightingValue(path, value)
--         return ResourceManager.setValue('Lighting', CONFIG.LIGHTING_GUID, path, value)
--     end


--     function SetAtmosphereValue(path, value)
--         return ResourceManager.setValue('Atmosphere', CONFIG.ATMOSPHERE_GUID, path, value)
--     end


--#endregion
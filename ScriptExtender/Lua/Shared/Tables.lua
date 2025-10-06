-- Store client-side spawned lights list _ai
ClientSpawnedLights = {}

-- Store server-side spawned lights list _ai
ServerSpawnedLights = {}

-- Store light UUIDs on server _ai
uuidServer = {}

-- Store light UUIDs on client _ai
uuidClient = {}

-- Store light entities _ai
entClient = {}

-- Store light VFX entities _ai
vfxEntClient = {}

-- Store VFX ready states _ai
vfxEntClientReady = {}

-- Add this to store color values for each light _ai
LightColorValues = {}

-- Add this to store intensity values for each light _ai
LightIntensityValues = {}

-- Add this to store radius values for each light _ai
LightRadiusValues = {}

-- Store saved positions for each light _ai
SavedLightPositions = {}

-- Store saved intensities for each light _ai
savedIntensities = {}

-- Global styles table _ai
Styles = {}


LightTemperatureValues = {}


VeRsIoNs = {
    ["1.1.5.10"] = "1.1.5_crab"
}

-- Hotkey settings storage _ai
HotkeySettings = {
    selectedKey = "None",
    selectedModifier = "None"
}


-- SDL key modifier values _ai
KeyModifiers = {
    SHIFT = 0x0001,
    CTRL = 0x0040,
    ALT = 0x0100
}

-- Keyboard keys table _ai
KeyboardKeys = {
    "None",
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
    "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
    "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12",
    "NUMPAD0", "NUMPAD1", "NUMPAD2", "NUMPAD3", "NUMPAD4", "NUMPAD5", "NUMPAD6", "NUMPAD7", "NUMPAD8", "NUMPAD9",
    "BACKSLASH", "SLASH", "MINUS", "EQUALS", "LBRACKET", "RBRACKET",
    "SEMICOLON", "APOSTROPHE", "PERIOD", "COMMA", "GRAVE"
}

-- Keyboard modifiers _ai
KeyboardModifiers = {
    "None",
    "Ctrl",
    "Alt",
    "Shift",
    "Ctrl+Alt",
    "Ctrl+Shift",
    "Alt+Shift",
    "Ctrl+Alt+Shift"
}

-- Light type options _ai
lightTypes = {
    "Point",
    "Directional_5",
    "Directional_10", 
    "Directional_20",
    "Directional_30",
    "Directional_40",
    "Directional_60",
    "Directional_90",
    "Directional_150",
    "Directional_180"
}

lightTypeNames = {
    "Point",
    "Directional 5°",
    "Directional 10°",
    "Directional 20°",
    "Directional 30°",
    "Directional 40°",
    "Directional 60°",
    "Directional 90°",
    "Directional 150°",
    "Directional 180°"
}

-- Initialize UsedLightSlots with empty tables for each type _ai
UsedLightSlots = {
    ["Directional_5"] = {},
    ["Directional_10"] = {},
    ["Directional_20"] = {},
    ["Directional_30"] = {},
    ["Directional_40"] = {},
    ["Directional_60"] = {},
    ["Directional_90"] = {},
    ["Directional_150"] = {},
    ["Directional_180"] = {},
    ["Point"] = {},
    ["Torch"] = {}
}

-- Store orbit state for each light _ai
currentAngle = {}
currentRadius = {}
currentHeight = {}

-- Store rotation offsets for each light _ai
lightRotation = {
    tilt = {},  -- rx offset
    yaw = {},   -- ry offset
    roll = {}   -- rz offset
}

-- Store last movement mode for each light _ai
lastMode = {} -- "orbit" or "default"

-- Favorites lists for ATM and LTN templates _ai
ATMFavoritesList = {}
LTNFavoritesList = {}

-- Storage for current values _ai
currentValues = {
    intensity = {},
    radius = {}
}

-- Origin point variables _ai
originPoint = {
    entity = nil,
    enabled = false,
    position = {x = 0, y = 0, z = 0}
}


RootTemplates = {
    ['b8305734-4f4a-4699-a0b5-91a735a5783a'] = true,
    ['28e9d938-4274-40e3-b3d8-a61a11b31aff'] = true,
    ['51ef42bb-d4e0-4c05-92c2-5a55e1fe4b6a'] = true,
    ['8c167ddf-a58e-44eb-b807-6a317c05ae4c'] = true,
    ['54bb7ddf-d98a-483a-97d4-b8cf297e3ba8'] = true,
    ['71a5994f-dc39-4933-9d56-1e1e067ccaa5'] = true,
    ['320200e5-d5c5-4697-ba23-453cc56b4ef7'] = true,
    ['e70d7eea-1c34-4e15-b7a2-4dc1fe6c2274'] = true,
    ['a383d308-4b12-4797-bb96-c13374487abb'] = true,
    ['fc70638d-7792-4842-abcd-b1091e16e56c'] = true,
    ['d2294326-3623-448d-a71a-84083d5a2179'] = true,
    ['6cf52089-f85e-4796-b072-b99d54d92fff'] = true,
    ['5ea71e24-9a10-43b6-a530-f8998b195a4a'] = true,
    ['3742cc40-f83d-431e-a253-91c3fd3a5f22'] = true,
    ['9e13a4bf-f5f9-47c7-83f6-63af21a5cfbd'] = true,
    ['babe77db-3764-4105-9b14-b01fb97f0aee'] = true,
    ['641f0daa-e539-4811-9967-8e4ed08766d7'] = true,
    ['f094df03-7f77-4142-8990-0d91fb59a7af'] = true,
    ['3cc107a1-e9b7-46dc-8b16-e98c1b2f55bf'] = true,
    ['9813d5d3-349f-4e0f-8eed-195cf46e9d48'] = true,
    ['4d2457c0-905f-424b-802c-60a2d0ba6624'] = true,
    ['e15494e9-b038-48d7-8a76-7de83a3f26a1'] = true,
    ['6ad71eda-ebe0-45ce-bd17-2ee0394904a4'] = true,
    ['423ceddd-dcbc-4bf1-8905-5daec85a6cf8'] = true,
    ['6a2b037b-bf3f-4254-88ac-43d1bf6abb4d'] = true,
    ['2ef04401-de99-452a-ba2a-a56bd1323bc8'] = true,
    ['9884decc-a501-400a-9f9a-bd36d125f626'] = true,
    ['738c44b7-3e4e-4888-a2cf-e41a04dc2bbe'] = true,
    ['6dfdf358-60f5-4197-9ce5-01d98aa29536'] = true,
    ['aa2c6132-9a50-443d-ad62-d582e8281c04'] = true,
    ['6f458a89-a14f-4ee4-9674-bc9be213e5d2'] = true,
    ['9ad3b79c-6fb6-4f40-bc4c-062bce7276de'] = true,
    ['b56ddd01-8ec3-43f2-8511-3ea2ce797892'] = true,
    ['bbe58ba0-0bdf-4340-977a-ee1595433ca9'] = true,
    ['0b7f39ca-d105-41c3-b581-498a7567c9a2'] = true,
    ['55cdeaab-98fd-465d-a660-57e8acdf7c8c'] = true,
    ['4814e916-1b17-4937-bf39-a2299ebb85c9'] = true,
    ['365937e2-5fe2-4924-a9f9-c8bbcb76b9d0'] = true,
    ['79f40ff2-e1f0-4c96-96b5-66350a5d3b88'] = true,
    ['3143320b-0f1c-4a28-bde4-fb5ea66ca5d2'] = true,
    ['a0a23351-9ccb-4112-97e8-717766594918'] = true,
    ['502f3b05-3c58-4efb-b400-8f6c01ccb462'] = true,
    ['0563e723-e170-43b5-b607-133f054af196'] = true,
    ['d3672274-6339-40e7-8e9c-c48dd488aae8'] = true,
    ['8eb180f0-bfa1-4521-b366-907b551804cb'] = true,
    ['aa46ab1c-a9e0-4e55-80bf-fdfcf6a3a172'] = true,
    ['485b3660-d29c-4b8d-9094-0f1c11708dbe'] = true,
    ['11244709-df7d-4dff-8ad4-ec624ba6a462'] = true,
    ['4566a55e-1701-4902-861e-dadb42c0cf29'] = true,
    ['3b7f1bdc-2115-4983-afee-89f0cc1fb075'] = true,
    ['541dde84-e610-473f-be5e-aa065c5df672'] = true,
    ['3cbb66fd-aafc-4123-b843-249bece1155e'] = true,
    ['b7acb7d6-13a0-4eea-b5f1-9fa4d444334d'] = true,
    ['8d5b9def-d1ba-4d7e-83f5-222efa8dab06'] = true,
    ['aca20fb6-a8dc-43e9-88ff-169e072dbaf1'] = true,
    ['dc644e42-a23b-4a2c-b944-c61575d20ae7'] = true,
    ['869c65cf-f9d8-40f3-b6a6-cc2dfceece64'] = true,
    ['45cc988a-891a-49d8-869f-868c166cb03a'] = true,
    ['6f9942c1-eb2a-42a6-8c7f-1f2c0234a96d'] = true,
    ['4e167524-a34b-42cb-977e-5d282d428667'] = true,
}



QOTD = {
    'xqc is the best streamer',
    'you should rest sometimes',
    'try terraria!',
    'what is omegilol?',
    'xd',
    'xqc is the best streamer',
    'xqc is the best streamer',
    'xqc is the best streamer',
    'xqc is the best streamer',
    'xqc is the best streamer',
    'xqc is the best streamer',
    'xqc is the best streamer',
    'xqc is the best streamer',
    'xqc is the best streamer',
    'xqc is the best streamer',
    'xqc is the best streamer',
    'xqc is the best streamer',
    'xqc is the best streamer',
    'xqc is the best streamer',
    'xqc is the best streamer',
}
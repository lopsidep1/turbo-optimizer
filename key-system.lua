-- 🚀 TURBO OPTIMIZER - Sistema de Keys SOLO API + Bordes redondeados + Botón X
-- Autor: lopsidep

local HttpService = game:GetService("HttpService")
local player = game.Players.LocalPlayer

-- CONFIG
local API_URL = "https://turbo-keys-api.onrender.com/keys"
local MAIN_SCRIPT = "https://raw.githubusercontent.com/lopsidep1/Opti/refs/heads/main/v_2.6_optimizer.lua"
local LINKVERTISE_URL = "https://link-hub.net/1381493/QFlC4jzoSzbm"

-- GUI principal
local gui = Instance.new("ScreenGui")
gui.Name = "KeySystem"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 250)
frame.Position = UDim2.new(0.5, -200, 0.5, -125)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

-- Botón Cerrar (X)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextScaled = true
closeBtn.Parent = frame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 15)
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(0,255,128)
title.Text = "🚀 TURBO OPTIMIZER"
title.Parent = frame

-- Caja de texto
local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(0.8, 0, 0, 35)
keyBox.Position = UDim2.new(0.1, 0, 0.3, 0)
keyBox.PlaceholderText = "Ingresa tu key..."
keyBox.Font = Enum.Font.Gotham
keyBox.TextScaled = true
keyBox.Text = ""
keyBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
keyBox.TextColor3 = Color3.new(1,1,1)
keyBox.Parent = frame
Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 8)

-- Botón Validar
local validateBtn = Instance.new("TextButton")
validateBtn.Size = UDim2.new(0.35, 0, 0, 35)
validateBtn.Position = UDim2.new(0.1, 0, 0.55, 0)
validateBtn.BackgroundColor3 = Color3.fromRGB(0,200,0)
validateBtn.Font = Enum.Font.GothamBold
validateBtn.TextColor3 = Color3.new(1,1,1)
validateBtn.Text = "✓ VALIDAR"
validateBtn.TextScaled = true
validateBtn.Parent = frame
Instance.new("UICorner", validateBtn).CornerRadius = UDim.new(0, 8)

-- Botón Get Key
local getKeyBtn = Instance.new("TextButton")
getKeyBtn.Size = UDim2.new(0.35, 0, 0, 35)
getKeyBtn.Position = UDim2.new(0.55, 0, 0.55, 0)
getKeyBtn.BackgroundColor3 = Color3.fromRGB(0,128,255)
getKeyBtn.Font = Enum.Font.GothamBold
getKeyBtn.TextColor3 = Color3.new(1,1,1)
getKeyBtn.Text = "🚀 GET KEY"
getKeyBtn.TextScaled = true
getKeyBtn.Parent = frame
Instance.new("UICorner", getKeyBtn).CornerRadius = UDim.new(0, 8)

-- Estado
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.8, 0, 0, 25)
statusLabel.Position = UDim2.new(0.1, 0, 0.8, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextScaled = true
statusLabel.TextColor3 = Color3.new(1,1,0)
statusLabel.Text = "Conectando a API..."
statusLabel.Parent = frame

-- Botón Copiar
local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0.2, 0, 0, 25)
copyBtn.Position = UDim2.new(0.75, 0, 0.25, 0)
copyBtn.BackgroundColor3 = Color3.fromRGB(200,100,0)
copyBtn.Text = "COPIAR"
copyBtn.TextColor3 = Color3.new(1,1,1)
copyBtn.Font = Enum.Font.Gotham
copyBtn.TextScaled = true
copyBtn.Visible = false
copyBtn.Parent = frame
Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 6)

-- Obtener keys de API (multi-intento, sin backups)
local function getKeysFromAPI()
    statusLabel.Text = "🔄 Conectando..."
    statusLabel.TextColor3 = Color3.new(1,1,0)

    for intento = 1, 3 do
        local success, result = pcall(function()
            return HttpService:GetAsync(API_URL.."?nocache="..HttpService:GenerateGUID(false))
        end)
        if success and result then
            local keys = HttpService:JSONDecode(result)
            if table.find(keys, keys[1]) then
                keyBox.Text = keys[1]
                copyBtn.Visible = true
                statusLabel.Text = "✅ API conectada"
                statusLabel.TextColor3 = Color3.new(0,1,0)
                return keys
            end
        end
        task.wait(0.5)
    end
    statusLabel.Text = "❌ Conecta a internet y obtén key"
    statusLabel.TextColor3 = Color3.new(1,0,0)
    copyBtn.Visible = false
    return {}
end

-- Validar key
local function validateKey(inputKey)
    local currentKeys = getKeysFromAPI()
    for _, validKey in ipairs(currentKeys) do
        if inputKey:upper() == validKey:upper() then
            return true
        end
    end
    return false
end

-- Eventos
copyBtn.MouseButton1Click:Connect(function()
    if keyBox.Text ~= "" then
        setclipboard(keyBox.Text)
        local orig = copyBtn.Text
        copyBtn.Text = "✓"
        copyBtn.BackgroundColor3 = Color3.fromRGB(0,200,0)
        task.wait(0.8)
        copyBtn.Text = orig
        copyBtn.BackgroundColor3 = Color3.fromRGB(200,100,0)
    end
end)

validateBtn.MouseButton1Click:Connect(function()
    local key = keyBox.Text:gsub("%s+", "")
    if key == "" then
        statusLabel.Text = "❌ Ingresa una key"
        statusLabel.TextColor3 = Color3.new(1,0,0)
        return
    end
    statusLabel.Text = "🔍 Validando..."
    statusLabel.TextColor3 = Color3.new(1,1,0)

    if validateKey(key) then
        statusLabel.Text = "✅ Cargando..."
        statusLabel.TextColor3 = Color3.new(0,1,0)
        task.wait(0.5)
        local ok, err = pcall(function()
            loadstring(game:HttpGet(MAIN_SCRIPT))()
        end)
        if ok then
            gui:Destroy()
        else
            statusLabel.Text = "❌ Error al cargar"
            statusLabel.TextColor3 = Color3.new(1,0,0)
        end
    else
        statusLabel.Text = "❌ Key inválida o sin conexión"
        statusLabel.TextColor3 = Color3.new(1,0,0)
    end
end)

getKeyBtn.MouseButton1Click:Connect(function()
    setclipboard(L

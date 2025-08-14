-- 🚀 TURBO OPTIMIZER - Sistema de Keys SOLO API
-- Autor: lopsidep
-- ✔ Sin respaldo offline
-- ✔ Forza el paso por Linkvertise + API
-- ✔ Multi-intento con anti-caché

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- CONFIG
local API_URL = "https://turbo-keys-api.onrender.com/keys"
local MAIN_SCRIPT = "https://raw.githubusercontent.com/lopsidep1/Opti/refs/heads/main/v_2.6_optimizer.lua"
local LINKVERTISE_URL = "https://link-hub.net/1381493/QFlC4jzoSzbm"

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "KeySystem"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 230)
frame.Position = UDim2.new(0.5, -200, 0.5, -115)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(0,255,128)
title.Text = "🚀 TURBO OPTIMIZER"
title.Parent = frame

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

local validateBtn = Instance.new("TextButton")
validateBtn.Size = UDim2.new(0.35, 0, 0, 35)
validateBtn.Position = UDim2.new(0.1, 0, 0.55, 0)
validateBtn.BackgroundColor3 = Color3.fromRGB(0,200,0)
validateBtn.Font = Enum.Font.GothamBold
validateBtn.TextColor3 = Color3.new(1,1,1)
validateBtn.Text = "✓ VALIDAR"
validateBtn.TextScaled = true
validateBtn.Parent = frame

local getKeyBtn = Instance.new("TextButton")
getKeyBtn.Size = UDim2.new(0.35, 0, 0, 35)
getKeyBtn.Position = UDim2.new(0.55, 0, 0.55, 0)
getKeyBtn.BackgroundColor3 = Color3.fromRGB(0,128,255)
getKeyBtn.Font = Enum.Font.GothamBold
getKeyBtn.TextColor3 = Color3.new(1,1,1)
getKeyBtn.Text = "🚀 GET KEY"
getKeyBtn.TextScaled = true
getKeyBtn.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.8, 0, 0, 25)
statusLabel.Position = UDim2.new(0.1, 0, 0.8, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextScaled = true
statusLabel.TextColor3 = Color3.new(1,1,0)
statusLabel.Text = "Conectando a API..."
statusLabel.Parent = frame

-- 🔍 Validar Key contra API
local function validarKey(key)
    for intento = 1, 3 do
        local success, data = pcall(function()
            return HttpService:GetAsync(API_URL.."?nocache="..HttpService:GenerateGUID(false))
        end)
        if success and data then
            local keysList = HttpService:JSONDecode(data)
            if table.find(keysList, key) then
                return true
            end
        end
        task.wait(0.6) -- espera entre intentos
    end
    return false
end

-- Eventos
validateBtn.MouseButton1Click:Connect(function()
    local key = keyBox.Text:gsub("%s+", "")
    if key == "" then
        statusLabel.Text = "❌ Ingresa una key"
        statusLabel.TextColor3 = Color3.new(1,0,0)
        return
    end
    statusLabel.Text = "🔍 Validando..."
    statusLabel.TextColor3 = Color3.new(1,1,0)

    if validarKey(key) then
        statusLabel.Text = "✅ Key válida. Cargando..."
        statusLabel.TextColor3 = Color3.new(0,1,0)
        task.wait(0.5)
        local ok, err = pcall(function()
            loadstring(game:HttpGet(MAIN_SCRIPT))()
        end)
        if not ok then
            warn(err)
            statusLabel.Text = "❌ Error al cargar script"
            statusLabel.TextColor3 = Color3.new(1,0,0)
        else
            gui:Destroy()
        end
    else
        statusLabel.Text = "❌ Key inválida o sin conexión"
        statusLabel.TextColor3 = Color3.new(1,0,0)
    end
end)

getKeyBtn.MouseButton1Click:Connect(function()
    setclipboard(LINKVERTISE_URL)
    statusLabel.Text = "🔗 Link copiado al portapapeles"
    statusLabel.TextColor3 = Color3.fromRGB(0,180,255)
end)

-- 🔄 Intento de conexión inicial
task.spawn(function()
    local success, data = pcall(function()
        return HttpService:GetAsync(API_URL.."?test="..tick())
    end)
    if success then
        statusLabel.Text = "✅ API conectada"
        statusLabel.TextColor3 = Color3.new(0,1,0)
    else
        statusLabel.Text = "❌ Conecta a internet y obtén key"
        statusLabel.TextColor3 = Color3.new(1,0,0)
    end
end)

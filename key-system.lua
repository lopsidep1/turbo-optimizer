-- 🔑 Turbo Optimizer - GUI con Key System Adaptado a HTML
-- lopsidep | Producción lista

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- ⚙ Configuración
local API_URL = "https://turbo-keys-api.onrender.com/"
local GUI_NAME = "TurboOptimizerGUI"

-- 🖥 Crear GUI base (si no existe)
local gui = Player:FindFirstChildOfClass("PlayerGui"):FindFirstChild(GUI_NAME)
if not gui then
    gui = Instance.new("ScreenGui")
    gui.Name = GUI_NAME
    gui.ResetOnSpawn = false
    gui.Parent = Player:WaitForChild("PlayerGui")
end

-- Marco principal
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 180)
frame.Position = UDim2.new(0.5, -150, 0.5, -90)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = gui

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 30)
title.Position = UDim2.new(0, 10, 0, 5)
title.Text = "🔑 Turbo Optimizer"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.BackgroundTransparency = 1
title.Parent = frame

-- Botón cerrar
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.BackgroundTransparency = 0.3
closeBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
closeBtn.Parent = frame
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Cuadro de texto para key
local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(1, -20, 0, 30)
keyBox.Position = UDim2.new(0, 10, 0, 50)
keyBox.PlaceholderText = "Ingresa tu key..."
keyBox.Text = ""
keyBox.ClearTextOnFocus = false
keyBox.TextColor3 = Color3.fromRGB(0, 0, 0)
keyBox.Font = Enum.Font.Gotham
keyBox.TextSize = 14
keyBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
keyBox.Parent = frame

-- Botón validar
local validateBtn = Instance.new("TextButton")
validateBtn.Size = UDim2.new(1, -20, 0, 30)
validateBtn.Position = UDim2.new(0, 10, 0, 90)
validateBtn.Text = "VALIDAR"
validateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
validateBtn.Font = Enum.Font.GothamBold
validateBtn.TextSize = 14
validateBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
validateBtn.Parent = frame

-- Botón obtener key
local getKeyBtn = Instance.new("TextButton")
getKeyBtn.Size = UDim2.new(1, -20, 0, 30)
getKeyBtn.Position = UDim2.new(0, 10, 0, 130)
getKeyBtn.Text = "GET KEY"
getKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
getKeyBtn.Font = Enum.Font.GothamBold
getKeyBtn.TextSize = 14
getKeyBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
getKeyBtn.Parent = frame
getKeyBtn.MouseButton1Click:Connect(function()
    -- Abre tu monetización (Linkvertise, etc.)
    setclipboard("https://tu-linkvertise-aqui.com")
end)

-- Label de estado
local statusLbl = Instance.new("TextLabel")
statusLbl.Size = UDim2.new(1, -20, 0, 20)
statusLbl.Position = UDim2.new(0, 10, 0, 165)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = ""
statusLbl.Font = Enum.Font.Gotham
statusLbl.TextSize = 12
statusLbl.TextColor3 = Color3.fromRGB(255, 255, 0)
statusLbl.Parent = frame

-- 📥 Extraer keys desde el HTML
local function fetchKeys()
    local ok, body = pcall(function()
        return HttpService:GetAsync(API_URL, true)
    end)
    if not ok then
        return {}
    end
    local keys = {}
    for key in body:gmatch("TURBO%-%w+") do
        table.insert(keys, key)
    end
    return keys
end

-- ✅ Validar la key
local function validateKey(userKey)
    local keys = fetchKeys()
    if #keys == 0 then
        statusLbl.Text = "⚠ No se pudieron obtener keys."
        statusLbl.TextColor3 = Color3.fromRGB(255, 200, 0)
        return
    end
    for _, k in ipairs(keys) do
        if k == userKey then
            statusLbl.Text = "✅ Key válida. Optimización activada."
            statusLbl.TextColor3 = Color3.fromRGB(0, 255, 0)
            return
        end
    end
    statusLbl.Text = "❌ Key inválida o expirada."
    statusLbl.TextColor3 = Color3.fromRGB(255, 0, 0)
end

-- Evento botón VALIDAR
validateBtn.MouseButton1Click:Connect(function()
    validateKey(keyBox.Text)
end)

-- 🚀 TURBO OPTIMIZER — Key System Validación API
-- Autor: lopsidep (versión optimizada por GPT)

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- ⚙️ CONFIG
local VERIFY_URL_TEMPLATE = "https://turbo-keys-api.onrender.com/api/keys/validate/%s" -- API de validación
local MAIN_SCRIPT = "https://raw.githubusercontent.com/lopsidep1/Opti/refs/heads/main/v_2.6_optimizer.lua"
local LINKVERTISE_URL = "https://link-hub.net/1381493/QFlC4jzoSzbm"

-- 📌 Función universal para hacer peticiones HTTP
local function httpGet(url)
    if syn and syn.request then
        local res = syn.request({Url = url, Method = "GET"})
        return res and res.Body
    elseif request then
        local res = request({Url = url, Method = "GET"})
        return res and res.Body
    elseif http_request then
        local res = http_request({Url = url, Method = "GET"})
        return res and res.Body
    else
        local ok, res = pcall(function()
            return game:HttpGet(url)
        end)
        return ok and res or nil
    end
end

-- 🖼️ GUI
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
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

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
Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 8)

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

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.8, 0, 0, 25)
statusLabel.Position = UDim2.new(0.1, 0, 0.8, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextScaled = true
statusLabel.TextColor3 = Color3.new(1,1,0)
statusLabel.Text = "Conectando a API..."
statusLabel.Parent = frame

-- ✅ Validación directa contra API
local function validateKey(input)
    local key = (input or ""):gsub("%s+",""):upper()
    if key == "" then
        statusLabel.Text = "❌ Ingresa una key"
        statusLabel.TextColor3 = Color3.new(1,0,0)
        return false
    end

    local url = string.format(VERIFY_URL_TEMPLATE, HttpService:UrlEncode(key))
    local body = httpGet(url)
    if not body then
        statusLabel.Text = "❌ Sin conexión o API caída"
        statusLabel.TextColor3 = Color3.new(1,0,0)
        return false
    end

    local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
    if ok and data and data.valid == true then
        return true
    end
    return false
end

-- 🎛️ Eventos
validateBtn.MouseButton1Click:Connect(function()
    statusLabel.Text = "🔍 Validando..."
    statusLabel.TextColor3 = Color3.new(1,1,0)

    local ok = validateKey(keyBox.Text)
    if ok then
        statusLabel.Text = "✅ Key válida. Cargando..."
        statusLabel.TextColor3 = Color3.new(0,1,0)
        task.wait(0.4)
        local loaded, err = pcall(function()
            loadstring(game:HttpGet(MAIN_SCRIPT))()
        end)
        if loaded then
            gui:Destroy()
        else
            warn("[KeySystem] Error al cargar MAIN_SCRIPT:", err)
            statusLabel.Text = "❌ Error al cargar"
            statusLabel.TextColor3 = Color3.new(1,0,0)
        end
    else
        statusLabel.Text = "❌ Key inválida"
        statusLabel.TextColor3 = Color3.new(1,0,0)
    end
end)

getKeyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(LINKVERTISE_URL)
        statusLabel.Text = "🔗 Link copiado (ve al navegador)"
        statusLabel.TextColor3 = Color3.fromRGB(0,180,255)
    else
        statusLabel.Text = "Abre este enlace: " .. LINKVERTISE_URL
        statusLabel.TextColor3 = Color3.fromRGB(0,180,255)
    end
end)

-- 🔄 Ping inicial (ver si API responde)
task.spawn(function()
    local testUrl = string.format(VERIFY_URL_TEMPLATE, "TEST")
    local body = httpGet(testUrl)
    if body then
        statusLabel.Text = "✅ API conectada"
        statusLabel.TextColor3 = Color3.new(0,1,0)
    else
        statusLabel.Text = "❌ No se pudo conectar a la API"
        statusLabel.TextColor3 = Color3.new(1,0,0)
    end
end)

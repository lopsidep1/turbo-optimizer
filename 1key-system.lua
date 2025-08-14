-- 🚀 TURBO OPTIMIZER — Key System HÍBRIDO (JSON + HTML)
-- Mismo diseño que GUIHERMOSO.txt, motor de validación adaptado

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- ⚙️ CONFIG
local API_URL = "https://turbo-keys-api.onrender.com/keys" -- En modo JSON: /keys; en modo HTML: cámbialo a raíz si quieres
local MAIN_SCRIPT = "https://raw.githubusercontent.com/lopsidep1/Opti/refs/heads/main/v_2.6_optimizer.lua"
local LINKVERTISE_URL = "https://link-hub.net/1381493/QFlC4jzoSzbm"

-- 🧠 Estado
local KEYS_CACHE, CACHE_AT, FETCHING = nil, 0, false
local CACHE_TTL = 60 -- segundos

-- 🖼 GUI (idéntica al original)
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

-- 🌐 Función híbrida: JSON o HTML
local function parseKeys(body)
    -- 1) Intentar JSON
    local okJson, data = pcall(function()
        return HttpService:JSONDecode(body)
    end)
    if okJson then
        if typeof(data) == "table" then
            -- Si es objeto y tiene .keys
            if data.keys and typeof(data.keys) == "table" then
                return data.keys
            else
                return data
            end
        end
    end
    -- 2) Si no es JSON válido, extraer TURBO-... del texto
    local keys = {}
    for key in body:gmatch("TURBO%-%w+") do
        table.insert(keys, key)
    end
    return keys
end

local function fetchKeys(force)
    if FETCHING then return KEYS_CACHE or {} end
    if not force and KEYS_CACHE and (time() - CACHE_AT) < CACHE_TTL then
        return KEYS_CACHE
    end
    FETCHING = true

    local req = {
        Url = API_URL .. "?nocache=" .. HttpService:GenerateGUID(false),
        Method = "GET",
        Headers = { ["Cache-Control"] = "no-cache" }
    }
    local ok, res = pcall(function()
        return HttpService:RequestAsync(req)
    end)
    if not ok or not res.Success then
        statusLabel.Text = "❌ Error API (" .. tostring(res and res.StatusCode or "sin conexión") .. ")"
        statusLabel.TextColor3 = Color3.new(1,0,0)
        FETCHING = false
        return {}
    end

    local keys = parseKeys(res.Body or "")
    if #keys == 0 then
        statusLabel.Text = "❌ Sin keys detectadas"
        statusLabel.TextColor3 = Color3.new(1,0,0)
        FETCHING = false
        return {}
    end

    -- Normalizar
    for i,k in ipairs(keys) do keys[i] = k:upper() end

    KEYS_CACHE, CACHE_AT, FETCHING = keys, time(), false
    statusLabel.Text = "✅ API conectada"
    statusLabel.TextColor3 = Color3.new(0,1,0)
    return keys
end

local function validateKey(input)
    local key = (input or ""):gsub("%s+",""):upper()
    if key == "" then
        statusLabel.Text = "❌ Ingresa una key"
        statusLabel.TextColor3 = Color3.new(1,0,0)
        return false
    end
    local keys = fetchKeys(true)
    return table.find(keys, key) ~= nil
end

-- 🎛 Eventos
validateBtn.MouseButton1Click:Connect(function()
    statusLabel.Text = "🔍 Validando..."
    statusLabel.TextColor3 = Color3.new(1,1,0)
    if validateKey(keyBox.Text) then
        statusLabel.Text = "✅ Key válida. Cargando..."
        statusLabel.TextColor3 = Color3.new(0,1,0)
        task.wait(0.4)
        local loaded, err = pcall(function()
            loadstring(game:HttpGet(MAIN_SCRIPT))()
        end)
        if loaded then
            gui:Destroy()
        else
            warn("[KeySystem] Error MAIN_SCRIPT:", err)
            statusLabel.Text = "❌ Error al cargar"
            statusLabel.TextColor3 = Color3.new(1,0,0)
        end
    else
        status

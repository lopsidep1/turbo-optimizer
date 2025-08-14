-- 🚀 TURBO OPTIMIZER — Key System SOLO API (con diagnóstico real)
-- Autor: lopsidep

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- ⚙️ CONFIG
local API_URL = "https://turbo-keys-api.onrender.com/keys" -- Debe devolver JSON: ["TURBO-...","..."]
local MAIN_SCRIPT = "https://raw.githubusercontent.com/lopsidep1/Opti/refs/heads/main/v_2.6_optimizer.lua"
local LINKVERTISE_URL = "https://link-hub.net/1381493/QFlC4jzoSzbm"

-- 🧠 Estado
local KEYS_CACHE = nil
local CACHE_AT = 0
local CACHE_TTL = 60 -- segundos
local FETCHING = false

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

-- Botón Cerrar (X) — se queda
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

-- 🌐 Fetch con diagnóstico (RequestAsync)
local function fetchKeys(force)
    if FETCHING then return KEYS_CACHE or {} end
    if not force and KEYS_CACHE and (time() - CACHE_AT) < CACHE_TTL then
        return KEYS_CACHE
    end

    FETCHING = true
    local url = API_URL .. "?nocache=" .. HttpService:GenerateGUID(false)

    local req = {
        Url = url,
        Method = "GET",
        Headers = {
            ["Accept"] = "application/json",
            ["Cache-Control"] = "no-cache",
        }
    }

    local ok, res = pcall(function()
        return HttpService:RequestAsync(req)
    end)

    if not ok then
        print("[KeySystem] RequestAsync fallo:", res)
        statusLabel.Text = "❌ Conecta a internet y obtén key"
        statusLabel.TextColor3 = Color3.new(1,0,0)
        FETCHING = false
        return {}
    end

    -- Log de diagnóstico
    print(string.format("[KeySystem] GET %s -> success=%s status=%d len=%d",
        url, tostring(res.Success), tonumber(res.StatusCode or 0), #(res.Body or "")))

    if not res.Success then
        -- Mensajes específicos por status
        if res.StatusCode == 404 then
            statusLabel.Text = "❌ API 404: revisa la ruta /keys"
        elseif res.StatusCode == 403 then
            statusLabel.Text = "❌ API 403: acceso denegado"
        else
            statusLabel.Text = "❌ Error API ("..tostring(res.StatusCode)..")"
        end
        statusLabel.TextColor3 = Color3.new(1,0,0)
        FETCHING = false
        return {}
    end

    -- Parse JSON estricto: debe ser un array de strings
    local okJson, data = pcall(function()
        return HttpService:JSONDecode(res.Body)
    end)

    if not okJson or type(data) ~= "table" then
        print("[KeySystem] JSON inválido. Body (primeros 200 chars):", string.sub(res.Body or "",1,200))
        statusLabel.Text = "❌ Respuesta inválida de la API"
        statusLabel.TextColor3 = Color3.new(1,0,0)
        FETCHING = false
        return {}
    end

    -- Normalizar a strings y mayúsculas
    local keys = {}
    for _, v in ipairs(data) do
        if type(v) == "string" then
            table.insert(keys, v:upper())
        end
    end

    if #keys == 0 then
        statusLabel.Text = "❌ Sin keys disponibles"
        statusLabel.TextColor3 = Color3.new(1,0,0)
        FETCHING = false
        return {}
    end

    KEYS_CACHE = keys
    CACHE_AT = time()
    statusLabel.Text = "✅ API conectada"
    statusLabel.TextColor3 = Color3.new(0,1,0)
    FETCHING = false
    return keys
end

-- ✅ Validación: compara contra lista en API (no mostramos ni autocompletamos)
local function validateKey(input)
    local key = (input or ""):gsub("%s+",""):upper()
    if key == "" then
        statusLabel.Text = "❌ Ingresa una key"
        statusLabel.TextColor3 = Color3.new(1,0,0)
        return false
    end

    -- Hasta 3 intentos con anticache
    for attempt = 1, 3 do
        local keys = fetchKeys(true)
        if #keys > 0 then
            if table.find(keys, key) then
                return true
            end
        end
        task.wait(0.6)
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
        statusLabel.Text = "❌ Key inválida o sin conexión"
        statusLabel.TextColor3 = Color3.new(1,0,0)
    end
end)

getKeyBtn.MouseButton1Click:Connect(function()
    setclipboard(LINKVERTISE_URL)
    statusLabel.Text = "🔗 Link copiado (ve al navegador)"
    statusLabel.TextColor3 = Color3.fromRGB(0,180,255)
end)

-- 🔄 Ping inicial (solo estado, sin mostrar keys)
task.spawn(function()
    local _ = fetchKeys(true)
end)

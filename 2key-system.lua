-- 🚀 TURBO OPTIMIZER — Key System HÍBRIDO (JSON + HTML) con diagnóstico real
-- Autor: lopsidep
-- Notas:
-- - Mantiene el MISMO diseño que GUIHERMOSO.txt (tamaños, posiciones, colores, UICorner, texto).
-- - Motor de validación tolerante: JSON puro (array), JSON con .keys, o HTML/Text extrayendo "TURBO-...".
-- - Fallback automático: si /keys falla o no hay keys, intenta la raíz "/" y extrae con patrón.
-- - Cache liviano, anticache GUID, y mensajes claros en statusLabel.
-- - Listo para producción como LocalScript en StarterGui (Allow HTTP Requests debe estar habilitado).

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- ⚙️ CONFIG
local API_URL = "https://turbo-keys-api.onrender.com/keys"      -- Primario (JSON esperado)
local ALT_API_URL = "https://turbo-keys-api.onrender.com/"       -- Secundario (HTML/Texto con TURBO-... visibles)
local MAIN_SCRIPT = "https://raw.githubusercontent.com/lopsidep1/Opti/refs/heads/main/v_2.6_optimizer.lua"
local LINKVERTISE_URL = "https://link-hub.net/1381493/QFlC4jzoSzbm"

-- 🧠 Estado
local KEYS_CACHE = nil
local CACHE_AT = 0
local CACHE_TTL = 60 -- segundos
local FETCHING = false

-- ─────────────────────────────────────────────────────────────────────────────
-- 🖼️ GUI (idéntica al diseño original GUIHERMOSO.txt)
-- ─────────────────────────────────────────────────────────────────────────────

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

-- ─────────────────────────────────────────────────────────────────────────────
-- 🔎 Utilidades de parsing y normalización
-- ─────────────────────────────────────────────────────────────────────────────

local function toUpperTrim(s)
    return (s or ""):gsub("%s+", ""):upper()
end

local function normalizeKeys(keys)
    local out, seen = {}, {}
    for _, v in ipairs(keys) do
        if typeof(v) == "string" then
            local k = toUpperTrim(v)
            if k ~= "" and not seen[k] then
                seen[k] = true
                table.insert(out, k)
            end
        end
    end
    return out
end

-- Intenta decodificar como JSON. Acepta:
-- - Array de strings: ["TURBO-...","..."]
-- - Objeto con campo .keys: { "keys": ["TURBO-..."] }
local function tryParseJson(body)
    local ok, data = pcall(function()
        return HttpService:JSONDecode(body)
    end)
    if not ok then
        return {}
    end
    if typeof(data) == "table" then
        -- Si es objeto con .keys
        if data.keys and typeof(data.keys) == "table" then
            return normalizeKeys(data.keys)
        end
        -- Si es array simple
        local isArray = true
        local count = 0
        for k, _ in pairs(data) do
            if typeof(k) ~= "number" then
                isArray = false
                break
            end
            count += 1
        end
        if isArray and count > 0 then
            return normalizeKeys(data)
        end
    end
    return {}
end

-- Extrae keys del texto/HTML usando patrón TURBO-%w+
local function parseFromHtml(body)
    local keys = {}
    for key in (body or ""):gmatch("TURBO%-%w+") do
        table.insert(keys, key)
    end
    return normalizeKeys(keys)
end

-- Wrapper para RequestAsync con anticache GUID
local function httpGetRaw(url)
    local finalUrl = url .. (url:find("%?") and "&" or "?") .. "nocache=" .. HttpService:GenerateGUID(false)
    local ok, res = pcall(function()
        return HttpService:RequestAsync({
            Url = finalUrl,
            Method = "GET",
            Headers = {
                ["Cache-Control"] = "no-cache",
                -- No forzamos Accept para no romper HTML/JSON según backend
            }
        })
    end)
    if not ok then
        return false, { Success = false, StatusCode = 0, Body = tostring(res) }
    end
    return true, res
end

-- ─────────────────────────────────────────────────────────────────────────────
-- 🌐 Fetch híbrido con fallback
-- ─────────────────────────────────────────────────────────────────────────────

local function fetchKeys(force)
    -- Respeta cache si no se fuerza
    if FETCHING then
        return KEYS_CACHE or {}
    end
    if not force and KEYS_CACHE and (time() - CACHE_AT) < CACHE_TTL then
        return KEYS_CACHE
    end

    FETCHING = true

    -- 1) Intento primario: API_URL (JSON esperado)
    local ok1, res1 = httpGetRaw(API_URL)

    if not ok1 or not res1.Success then
        print(string.format("[KeySystem] GET %s -> success=%s status=%s len=%d",
            API_URL, tostring(ok1 and res1.Success or false), tostring(res1.StatusCode), #(res1.Body or "")))
    end

    if ok1 and res1.Success then
        local keysJson = tryParseJson(res1.Body or "")
        if #keysJson > 0 then
            KEYS_CACHE = keysJson
            CACHE_AT = time()
            statusLabel.Text = "✅ API conectada"
            statusLabel.TextColor3 = Color3.new(0,1,0)
            FETCHING = false
            return keysJson
        else
            print("[KeySystem] JSON vacío o inválido en primario; intentando fallback HTML…")
        end
    else
        -- Mensaje específico por status si hay código
        if res1 and res1.StatusCode == 404 then
            statusLabel.Text = "❌ API 404: revisa la ruta /keys"
        elseif res1 and res1.StatusCode == 403 then
            statusLabel.Text = "❌ API 403: acceso denegado"
        elseif res1 and res1.StatusCode and res1.StatusCode ~= 0 then
            statusLabel.Text = "❌ Error API (" .. tostring(res1.StatusCode) .. ")"
        else
            -- Posible: HTTP no permitido en juego
            if res1 and typeof(res1.Body) == "string" and res1.Body:lower():find("http requests are not enabled", 1, true) then
                statusLabel.Text = "❌ Activa Allow HTTP Requests"
            else
                statusLabel.Text = "❌ Sin conexión a API"
            end
        end
        statusLabel.TextColor3 = Color3.new(1,0,0)
        -- No retornamos todavía: haremos fallback a HTML
    end

    -- 2) Fallback secundario: ALT_API_URL (HTML/Texto con keys)
    local ok2, res2 = httpGetRaw(ALT_API_URL)

    if not ok2 or not res2.Success then
        print(string.format("[KeySystem] GET %s -> success=%s status=%s len=%d",
            ALT_API_URL, tostring(ok2 and res2.Success or false), tostring(res2.StatusCode), #(res2.Body or "")))
    end

    if ok2 and res2.Success then
        local keysHtml = parseFromHtml(res2.Body or "")
        if #keysHtml > 0 then
            KEYS_CACHE = keysHtml
            CACHE_AT = time()
            statusLabel.Text = "✅ API conectada"
            statusLabel.TextColor3 = Color3.new(0,1,0)
            FETCHING = false
            return keysHtml
        else
            print("[KeySystem] Fallback HTML sin keys visibles (¿cambió el formato del sitio?).")
            statusLabel.Text = "❌ Sin keys detectadas"
            statusLabel.TextColor3 = Color3.new(1,0,0)
            FETCHING = false
            return {}
        end
    else
        -- Fallback también falló
        if res2 and res2.StatusCode == 404 then
            statusLabel.Text = "❌ Fallback 404 en raíz"
        elseif res2 and res2.StatusCode == 403 then
            statusLabel.Text = "❌ Fallback 403 en raíz"
        elseif res2 and res2.StatusCode and res2.StatusCode ~= 0 then
            statusLabel.Text = "❌ Fallback error (" .. tostring(res2.StatusCode) .. ")"
        else
            if res2 and typeof(res2.Body) == "string" and res2.Body:lower():find("http requests are not enabled", 1, true) then
                statusLabel.Text = "❌ Activa Allow HTTP Requests"
            else
                statusLabel.Text = "❌ Fallback sin conexión"
            end
        end
        statusLabel.TextColor3 = Color3.new(1,0,0)
        FETCHING = false
        return {}
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- ✅ Validación (hasta 3 intentos con anticache)
-- ─────────────────────────────────────────────────────────────────────────────

local function validateKey(input)
    local key = toUpperTrim(input)
    if key == "" then
        statusLabel.Text = "❌ Ingresa una key"
        statusLabel.TextColor3 = Color3.new(1,0,0)
        return false
    end

    for attempt = 1, 3 do
        local keys = fetchKeys(true)
        if #keys > 0 then
            if table.find(keys, key) then
                return true
            end
        end
        task.wait(0.5)
    end

    return false
end

-- ─────────────────────────────────────────────────────────────────────────────
-- 🎛️ Eventos de botones (mismo comportamiento)
-- ─────────────────────────────────────────────────────────────────────────────

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

-- ─────────────────────────────────────────────────────────────────────────────
-- 🔄 Ping inicial (solo estado)
-- ─────────────────────────────────────────────────────────────────────────────

task.spawn(function()
    -- Intento inicial para pintar estado “API conectada” o error claro
    local _ = fetchKeys(true)
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- 📋 Resumen rápido de comportamiento:
-- - Crea la GUI y la muestra SIEMPRE (diseño intacto).
-- - Al validar: intenta /keys (JSON). Si no hay datos válidos, hace fallback a raíz (HTML).
-- - Extrae TURBO-... de texto/HTML si no hay JSON.
-- - Mensajes de error útiles: 404/403/Allow HTTP Requests/Conexión/API sin keys.
-- - No expone las keys; solo valida contra la lista obtenida.
-- - Cachea por 60s para evitar spam de peticiones (se fuerza en validación).
-- ─────────────────────────────────────────────────────────────────────────────
```

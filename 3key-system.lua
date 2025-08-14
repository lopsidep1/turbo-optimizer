-- 🚀 TURBO OPTIMIZER - SISTEMA COMPLETO CON VALIDACIÓN HÍBRIDA
-- Creador: lopsidep + Copilot
-- Colocar en: StarterGui > LocalScript

-- ▒ CONFIGURACIÓN PRINCIPAL ▒
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local API_URL_JSON = "https://turbo-keys-api.onrender.com/keys"
local API_URL_HTML = "https://turbo-keys-api.onrender.com/"

-- ▒ FUNCIÓN: OBTENER KEYS DESDE API ▒
local function obtenerKeys()
    local success, keys = pcall(function()
        -- Intentar primero JSON
        local jsonResp = HttpService:GetAsync(API_URL_JSON)
        return HttpService:JSONDecode(jsonResp)
    end)

    if success and type(keys) == "table" then
        return keys
    else
        -- Si falla JSON, intentar HTML
        local ok, html = pcall(function()
            return HttpService:GetAsync(API_URL_HTML)
        end)
        if ok and html then
            local list = {}
            for key in html:gmatch("(TURBO%-%w+)") do
                table.insert(list, key)
            end
            return list
        end
    end
    return {}
end

-- ▒ FUNCIÓN: CREAR GUI ▒
local function crearGUI()
    -- Pantalla principal
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TurboOptimizer"
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- Marco contenedor
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 400, 0, 300)
    Frame.Position = UDim2.new(0.5, -200, 0.5, -150)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Frame.BorderColor3 = Color3.fromRGB(255, 200, 0)
    Frame.BorderSizePixel = 2
    Frame.Parent = ScreenGui

    -- Título
    local Title = Instance.new("TextLabel")
    Title.Text = "🚀 TURBO OPTIMIZER"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(255, 200, 0)
    Title.TextScaled = true
    Title.Font = Enum.Font.SourceSansBold
    Title.Parent = Frame

    -- Lista de Keys
    local KeysList = Instance.new("TextLabel")
    KeysList.Size = UDim2.new(1, -20, 0, 200)
    KeysList.Position = UDim2.new(0, 10, 0, 50)
    KeysList.BackgroundTransparency = 1
    KeysList.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeysList.TextWrapped = true
    KeysList.TextScaled = true
    KeysList.Font = Enum.Font.SourceSans
    KeysList.Text = "⏳ Obteniendo keys..."
    KeysList.Parent = Frame

    -- Botón actualizar
    local Btn = Instance.new("TextButton")
    Btn.Text = "🔄 Actualizar Keys"
    Btn.Size = UDim2.new(1, -20, 0, 40)
    Btn.Position = UDim2.new(0, 10, 1, -50)
    Btn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    Btn.TextColor3 = Color3.fromRGB(0, 0, 0)
    Btn.TextScaled = true
    Btn.Font = Enum.Font.SourceSansBold
    Btn.Parent = Frame

    -- Función de actualización
    local function actualizarKeys()
        local keys = obtenerKeys()
        if #keys > 0 then
            KeysList.Text = "✅ Keys encontradas:\n" .. table.concat(keys, "\n")
        else
            KeysList.Text = "❌ No se encontraron keys."
        end
    end

    -- Primer update
    actualizarKeys()

    -- Click en botón
    Btn.MouseButton1Click:Connect(function()
        actualizarKeys()
    end)
end

-- ▒ PROTECCIÓN: SÓLO CLIENTE ▒
if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
    crearGUI()
else
    warn("⚠️ Este script debe ejecutarse como LocalScript en cliente.")
end

-- 🚀 TURBO OPTIMIZER - Sistema de Keys Automático
-- API: turbo-keys-api.onrender.com
-- Autor: lopsidep1

local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- 🔑 CONFIGURACIÓN
local API_URL = "https://turbo-keys-api.onrender.com"
local MAIN_SCRIPT = "https://raw.githubusercontent.com/lopsidep1/Opti/refs/heads/main/v_2.6_optimizer.lua"

-- 🎨 GUI
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local KeyBox = Instance.new("TextBox")
local ValidateBtn = Instance.new("TextButton")
local GetKeyBtn = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")
local CopyBtn = Instance.new("TextButton")
local CloseBtn = Instance.new("TextButton")

ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Frame principal
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 400, 0, 250)
Frame.Position = UDim2.new(0.5, -200, 0.5, -125)
Frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

-- Bordes redondeados
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Frame

-- Título
Title.Parent = Frame
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "🚀 TURBO OPTIMIZER"
Title.TextColor3 = Color3.new(0, 1, 0.5)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold

-- Input de key
KeyBox.Parent = Frame
KeyBox.Size = UDim2.new(0.8, 0, 0, 35)
KeyBox.Position = UDim2.new(0.1, 0, 0.3, 0)
KeyBox.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
KeyBox.TextColor3 = Color3.new(1, 1, 1)
KeyBox.PlaceholderText = "Ingresa tu key aquí..."
KeyBox.Text = ""
KeyBox.Font = Enum.Font.Gotham
KeyBox.TextScaled = true

local KeyCorner = Instance.new("UICorner")
KeyCorner.CornerRadius = UDim.new(0, 8)
KeyCorner.Parent = KeyBox

-- Botón Validar
ValidateBtn.Parent = Frame
ValidateBtn.Size = UDim2.new(0.35, 0, 0, 35)
ValidateBtn.Position = UDim2.new(0.1, 0, 0.55, 0)
ValidateBtn.BackgroundColor3 = Color3.new(0, 0.8, 0)
ValidateBtn.Text = "✓ VALIDAR"
ValidateBtn.TextColor3 = Color3.new(1, 1, 1)
ValidateBtn.Font = Enum.Font.GothamBold
ValidateBtn.TextScaled = true

local ValidateCorner = Instance.new("UICorner")
ValidateCorner.CornerRadius = UDim.new(0, 8)
ValidateCorner.Parent = ValidateBtn

-- Botón Get Key
GetKeyBtn.Parent = Frame
GetKeyBtn.Size = UDim2.new(0.35, 0, 0, 35)
GetKeyBtn.Position = UDim2.new(0.55, 0, 0.55, 0)
GetKeyBtn.BackgroundColor3 = Color3.new(0, 0.5, 1)
GetKeyBtn.Text = "🚀 GET KEY"
GetKeyBtn.TextColor3 = Color3.new(1, 1, 1)
GetKeyBtn.Font = Enum.Font.GothamBold
GetKeyBtn.TextScaled = true

local GetKeyCorner = Instance.new("UICorner")
GetKeyCorner.CornerRadius = UDim.new(0, 8)
GetKeyCorner.Parent = GetKeyBtn

-- Status
StatusLabel.Parent = Frame
StatusLabel.Size = UDim2.new(0.8, 0, 0, 25)
StatusLabel.Position = UDim2.new(0.1, 0, 0.78, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Conectando a API..."
StatusLabel.TextColor3 = Color3.new(1, 1, 0)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextScaled = true

-- Botón Copiar (oculto inicialmente)
CopyBtn.Parent = Frame
CopyBtn.Size = UDim2.new(0.2, 0, 0, 25)
CopyBtn.Position = UDim2.new(0.75, 0, 0.25, 0)
CopyBtn.BackgroundColor3 = Color3.new(0.8, 0.4, 0)
CopyBtn.Text = "COPIAR"
CopyBtn.TextColor3 = Color3.new(1, 1, 1)
CopyBtn.Font = Enum.Font.Gotham
CopyBtn.TextScaled = true
CopyBtn.Visible = false

local CopyCorner = Instance.new("UICorner")
CopyCorner.CornerRadius = UDim.new(0, 6)
CopyCorner.Parent = CopyBtn

-- Botón Cerrar (X)
CloseBtn.Parent = Frame
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.new(1, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextScaled = true

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 15)
CloseCorner.Parent = CloseBtn

-- 🔑 SIN KEYS DE RESPALDO (Para forzar uso de Linkvertise)
local backupKeys = {} -- Vacío

-- 🌐 FUNCIÓN MEJORADA: Obtener keys de API
local function getKeysFromAPI()
    StatusLabel.Text = "🔄 Conectando API..."
    StatusLabel.TextColor3 = Color3.new(1, 1, 0)
    
    -- Múltiples intentos con diferentes métodos
    local attempts = {
        API_URL,
        API_URL .. "/",
        API_URL .. "?cache=" .. tick(),
        "https://turbo-keys-api.onrender.com/keys"  -- Endpoint alternativo
    }
    
    for i, url in ipairs(attempts) do
        local success, result = pcall(function()
            local response = HttpService:GetAsync(url, false)  -- Sin cache
            return response
        end)
        
        if success and result then
            -- Intentar parsear las keys
            local keys = {}
            
            -- Método 1: Buscar patrón TURBO-
            for key in result:gmatch("TURBO%-[A-Z0-9]+") do
                table.insert(keys, key)
            end
            
            -- Método 2: Si es JSON
            if #keys == 0 then
                local jsonSuccess, jsonData = pcall(function()
                    return HttpService:JSONDecode(result)
                end)
                
                if jsonSuccess and jsonData then
                    if jsonData.keys then
                        keys = jsonData.keys
                    elseif type(jsonData) == "table" then
                        for _, v in pairs(jsonData) do
                            if type(v) == "string" and v:match("TURBO%-") then
                                table.insert(keys, v)
                            end
                        end
                    end
                end
            end
            
            if #keys > 0 then
                StatusLabel.Text = "✅ API Conectada (" .. #keys .. " keys)"
                StatusLabel.TextColor3 = Color3.new(0, 1, 0)
                
                -- Mostrar primera key en el input y botón copiar
                KeyBox.Text = keys[1]
                CopyBtn.Visible = true
                
                return keys
            end
        else
            -- Log del error (solo para debug)
            if i == 1 then
                print("Error API intento " .. i .. ":", result)
            end
        end
        
        wait(0.5) -- Espera entre intentos
    end
    
    -- Si todos los intentos fallan
    StatusLabel.Text = "❌ Conecta a internet y obtén key"
    StatusLabel.TextColor3 = Color3.new(1, 0, 0)
    KeyBox.Text = ""
    CopyBtn.Visible = false
    
    return {}
end

-- ✅ FUNCIÓN: Validar key
local function validateKey(key)
    -- Primero intentar obtener keys actuales
    local currentKeys = getKeysFromAPI()
    
    -- Verificar si la key está en la lista actual
    for _, validKey in ipairs(currentKeys) do
        if key:upper() == validKey:upper() then
            return true
        end
    end
    
    return false
end

-- 📋 FUNCIÓN: Copiar key
CopyBtn.MouseButton1Click:Connect(function()
    if KeyBox.Text ~= "" then
        setclipboard(KeyBox.Text)
        
        local originalText = CopyBtn.Text
        CopyBtn.Text = "✓"
        CopyBtn.BackgroundColor3 = Color3.new(0, 0.8, 0)
        
        wait(1)
        CopyBtn.Text = originalText
        CopyBtn.BackgroundColor3 = Color3.new(0.8, 0.4, 0)
    end
end)

-- 🔍 EVENTO: Validar key
ValidateBtn.MouseButton1Click:Connect(function()
    local key = KeyBox.Text:gsub("%s+", "")
    
    if key == "" then
        StatusLabel.Text = "❌ Ingresa una key"
        StatusLabel.TextColor3 = Color3.new(1, 0, 0)
        return
    end
    
    StatusLabel.Text = "🔍 Validando..."
    StatusLabel.TextColor3 = Color3.new(1, 1, 0)
    
    if validateKey(key) then
        StatusLabel.Text = "✅ Cargando script..."
        StatusLabel.TextColor3 = Color3.new(0, 1, 0)
        
        wait(1)
        
        -- Cargar script principal
        local success = pcall(function()
            loadstring(game:HttpGet(MAIN_SCRIPT))()
        end)
        
        if success then
            ScreenGui:Destroy()
        else
            StatusLabel.Text = "❌ Error al cargar script"
            StatusLabel.TextColor3 = Color3.new(1, 0, 0)
        end
    else
        StatusLabel.Text = "❌ Key inválida"
        StatusLabel.TextColor3 = Color3.new(1, 0, 0)
        
        -- Auto-actualizar keys
        spawn(function()
            wait(2)
            getKeysFromAPI()
        end)
    end
end)

-- 🔗 EVENTO: Obtener key
GetKeyBtn.MouseButton1Click:Connect(function()
    setclipboard("https://link-hub.net/1381493/QFlC4jzoSzbm")
end)

-- ❌ EVENTO: Cerrar GUI
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- 🚀 INICIALIZAR
spawn(function()
    wait(1)
    getKeysFromAPI()
end)

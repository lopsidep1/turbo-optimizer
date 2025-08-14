# 📁 Archivos para tu Repositorio

## 1️⃣ key-system.lua
```lua
-- 🚀 TURBO OPTIMIZER - Sistema de Keys Automático
-- API: turbo-keys-api.onrender.com
-- Autor: lopsidep1

local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- 🔑 CONFIGURACIÓN
local API_URL = "https://turbo-keys-api.onrender.com"
local MAIN_SCRIPT = "https://raw.githubusercontent.com/lopsidep1/turbo-optimizer/main/main-optimizer.lua"

-- 🎨 GUI
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local KeyBox = Instance.new("TextBox")
local ValidateBtn = Instance.new("TextButton")
local GetKeyBtn = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")
local CopyBtn = Instance.new("TextButton")

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

-- 🔑 KEYS DE RESPALDO
local backupKeys = {
    "TURBO-JZBNKSVVXBU11B97",
    "TURBO-BNSALSTR2CYYI4ZX", 
    "TURBO-J9TMDMPKD4A09DCR",
    "TURBO-WRCTJ9OE3GJ22LUN"
}

-- 🌐 FUNCIÓN: Obtener keys de API
local function getKeysFromAPI()
    local success, result = pcall(function()
        return HttpService:GetAsync(API_URL)
    end)
    
    if success and result then
        local keys = {}
        -- Buscar keys en formato TURBO-XXXXX
        for key in result:gmatch("TURBO%-[A-Z0-9]+") do
            table.insert(keys, key)
        end
        
        if #keys > 0 then
            StatusLabel.Text = "✅ Conectado a API (" .. #keys .. " keys)"
            StatusLabel.TextColor3 = Color3.new(0, 1, 0)
            
            -- Mostrar una key válida
            KeyBox.Text = keys[1]
            CopyBtn.Visible = true
            
            return keys
        end
    end
    
    -- Si falla, usar respaldo
    StatusLabel.Text = "⚠️ Usando keys de respaldo"
    StatusLabel.TextColor3 = Color3.new(1, 0.8, 0)
    KeyBox.Text = backupKeys[1]
    CopyBtn.Visible = true
    
    return backupKeys
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
    setclipboard("https://linkvertise.com/1282506/turbo-optimizer-keys")
end)

-- 🚀 INICIALIZAR
spawn(function()
    wait(1)
    getKeysFromAPI()
end)
```

## 2️⃣ main-optimizer.lua
```lua
-- Este archivo contendrá tu Turbo Optimizer principal
-- Por ahora puedes poner un placeholder:

print("🚀 TURBO OPTIMIZER CARGADO EXITOSAMENTE!")
print("✅ Sistema de keys funcionando correctamente")

-- Aquí irá todo tu código del Turbo Optimizer actual
```

## 3️⃣ README.md (Opcional)
```markdown
# 🚀 Turbo Optimizer

Sistema de keys automático para Roblox.

## 📋 Uso

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/lopsidep1/turbo-optimizer/main/key-system.lua"))()
```

## 🔑 Obtener Keys
- Ejecuta el comando
- Clic en "GET KEY" 
- Completa el Linkvertise
- Copia la key del sitio
- Pega en el input y valida

## ⚡ Características
- ✅ Sistema automático de keys
- ✅ API en la nube 24/7
- ✅ Actualizaciones automáticas
- ✅ Interfaz moderna
```
-- 🔑 Turbo Optimizer - Key System Adaptado
-- Extrae keys desde HTML/texto sin depender de JSON puro

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local API_URL = "https://turbo-keys-api.onrender.com/" -- URL raíz de tu sistema
local LOCAL_PLAYER = Players.LocalPlayer

-- 💬 Función de alerta
local function showAlert(msg, color)
    print(msg)
    if game.CoreGui:FindFirstChild("ScreenGui") then
        -- Si tienes ya tu GUI de validación, integra aquí el cambio de texto/color
    end
end

-- 📥 Obtener keys desde la API (HTML o texto)
local function fetchKeys()
    local ok, body = pcall(function()
        return HttpService:GetAsync(API_URL, true) -- true = sin caché
    end)

    if not ok then
        warn("Error al conectar con la API:", body)
        return {}
    end

    local keys = {}
    for key in body:gmatch("TURBO%-%w+") do
        table.insert(keys, key)
    end

    return keys
end

-- ✅ Validar key ingresada por usuario
local function validateKey(userKey)
    local keys = fetchKeys()

    if #keys == 0 then
        showAlert("⚠ No se pudieron obtener keys activas. Intenta más tarde.", Color3.fromRGB(255, 200, 0))
        return false
    end

    for _, k in ipairs(keys) do
        if k == userKey then
            showAlert("✅ Key válida. Optimización activada.", Color3.fromRGB(0, 255, 0))
            return true
        end
    end

    showAlert("❌ Key inválida o expirada.", Color3.fromRGB(255, 0, 0))
    return false
end

-- 📌 Ejemplo de uso: conecta esto al botón VALIDAR de tu GUI
--[[
BotonValidar.MouseButton1Click:Connect(function()
    local keyIngresada = CuadroTexto.Text -- tu TextBox
    validateKey(keyIngresada)
end)
]]


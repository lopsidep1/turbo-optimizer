-- 🔑 Turbo Optimizer - key-system.lua (versión con JSON esperado en /keys)

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- URL del endpoint que debía existir en tu backend
local API_URL = "https://turbo-keys-api.onrender.com/keys"

-- Función para mostrar mensajes en consola o GUI
local function showStatus(msg)
    print(msg)
end

-- Función para descargar y decodificar las keys
local function fetchKeys()
    local ok, res = pcall(function()
        return HttpService:GetAsync(API_URL, true) -- true = no cache
    end)
    if not ok then
        warn("Error HTTP:", res)
        return {}
    end

    local okDecode, data = pcall(function()
        return HttpService:JSONDecode(res)
    end)
    if not okDecode then
        warn("Error al decodificar JSON:", data)
        return {}
    end

    return data -- se esperaba un array de strings ["TURBO-XXX", ...]
end

-- Función para validar la key ingresada
local function validateKey(userKey)
    local keys = fetchKeys()
    if #keys == 0 then
        showStatus("⚠ No se encontraron keys en la API.")
        return
    end

    for _, k in ipairs(keys) do
        if k == userKey then
            showStatus("✅ Key válida. Optimización activada.")
            return
        end
    end

    showStatus("❌ Key inválida o expirada.")
end

-- Ejemplo de uso
-- validateKey("TURBO-XXXX")

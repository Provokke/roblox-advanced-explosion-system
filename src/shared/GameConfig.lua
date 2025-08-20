-- Shared game configuration module
-- This module can be required by both client and server scripts

local GameConfig = {}

-- Game settings
GameConfig.GAME_NAME = "Rojo + Trae IDE Demo"
GameConfig.VERSION = "1.0.0"
GameConfig.MAX_PLAYERS = 50

-- Player settings
GameConfig.DEFAULT_WALKSPEED = 16
GameConfig.DEFAULT_JUMPPOWER = 50

-- UI settings
GameConfig.NOTIFICATION_DURATION = 5
GameConfig.WELCOME_MESSAGE = "Welcome to the Rojo + Trae IDE demo!"

-- Debug settings
GameConfig.DEBUG_MODE = true

-- Utility functions
function GameConfig.log(message)
    if GameConfig.DEBUG_MODE then
        print("[" .. GameConfig.GAME_NAME .. "] " .. tostring(message))
    end
end

function GameConfig.formatPlayerMessage(playerName, action)
    return playerName .. " " .. action .. " (" .. GameConfig.GAME_NAME .. ")"
end

return GameConfig
-- Client initialization script
-- This script runs on each client when they join the game

print("Client script loaded successfully!")
print("Rojo + Trae IDE client setup is working!")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

-- Wait for the RemoteEvent to be created by the server
local playerJoinedEvent = ReplicatedStorage:WaitForChild("PlayerJoinedEvent")

-- Handle player joined messages from server
playerJoinedEvent.OnClientEvent:Connect(function(message)
    print("Received from server: " .. message)
    
    -- Show a notification to the player (with error handling)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Player Update";
            Text = message;
            Duration = 3;
        })
    end)
end)

-- Welcome message for the local player
local localPlayer = Players.LocalPlayer
print("Welcome, " .. localPlayer.Name .. "!")
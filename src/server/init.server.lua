-- Server initialization script
-- This script runs on the server when the game starts

print("Server script loaded successfully!")
print("Rojo + Trae IDE setup is working!")

-- Example: Create a simple remote event for client-server communication
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Create a RemoteEvent for player communication
local playerJoinedEvent = Instance.new("RemoteEvent")
playerJoinedEvent.Name = "PlayerJoinedEvent"
playerJoinedEvent.Parent = ReplicatedStorage

-- Handle player joining
Players.PlayerAdded:Connect(function(player)
    print(player.Name .. " joined the game!")
    playerJoinedEvent:FireAllClients(player.Name .. " has joined!")
end)
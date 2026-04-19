local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoinConstants = require(ReplicatedStorage:WaitForChild("CoinConstants"))
local CoinUtility = require(ReplicatedStorage:WaitForChild("CoinUtility"))

local CoinManager = require(script.Parent:WaitForChild("CoinManager"))

while true do
    task.wait(CoinConstants.SPAWN_INTERVAL)
    
    local currentCount = CoinUtility:GetCurrentCoinCount()
    
    if currentCount < CoinConstants.MAX_COINS then
        local position = CoinUtility:GetRandomSpawnPosition()
        CoinUtility:GenerateCoin(position, CoinManager.OnCoinPickedUp)
    end
end

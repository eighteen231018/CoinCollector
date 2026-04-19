local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoinConstants = require(ReplicatedStorage:WaitForChild("CoinConstants"))
local CoinUtility = require(ReplicatedStorage:WaitForChild("CoinUtility"))

-- 等待 CoinManager 加载
local CoinManager
local success, err = pcall(function()
    CoinManager = require(script.Parent:WaitForChild("CoinManager"))
end)

if not success then
    warn("⚠️ 无法加载 CoinManager: " .. tostring(err))
    return
end

-- 等待一小段时间让系统稳定
task.wait(1)

while true do
    task.wait(CoinConstants.SPAWN_INTERVAL)
    
    local currentCount = CoinUtility:GetCurrentCoinCount()
    
    if currentCount < CoinConstants.MAX_COINS then
        local position = CoinUtility:GetRandomSpawnPosition()
        CoinUtility:GenerateCoin(position, CoinManager.OnCoinPickedUp)
    end
end

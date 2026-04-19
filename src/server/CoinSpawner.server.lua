local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CoinConstants = require(ReplicatedStorage:WaitForChild("CoinConstants"))
local PlayerData = require(ReplicatedStorage:WaitForChild("PlayerData"))
local CoinUtility = require(ReplicatedStorage:WaitForChild("CoinUtility"))

-- 获取或创建 RemoteEvent
local updateCoinEvent = ReplicatedStorage:FindFirstChild("UpdateCoinEvent")
if not updateCoinEvent then
    updateCoinEvent = Instance.new("RemoteEvent")
    updateCoinEvent.Name = "UpdateCoinEvent"
    updateCoinEvent.Parent = ReplicatedStorage
end

-- 金币拾取回调
local function onCoinPickedUp(player, coinModel)
    if not coinModel or not coinModel.Parent then
        return
    end
    
    local newCount = PlayerData:AddCoins(player, 1)
    coinModel:Destroy()
    updateCoinEvent:FireClient(player, newCount)
end

-- 等待系统稳定
task.wait(2)

print("🚀 金币生成器已启动")

-- 主循环
while true do
    task.wait(CoinConstants.SPAWN_INTERVAL)
    
    local currentCount = CoinUtility:GetCurrentCoinCount()
    
    if currentCount < CoinConstants.MAX_COINS then
        local position = CoinUtility:GetRandomSpawnPosition()
        CoinUtility:GenerateCoin(position, onCoinPickedUp)
        print("🪙 生成了新金币 (当前: " .. CoinUtility:GetCurrentCoinCount() .. "/" .. CoinConstants.MAX_COINS .. ")")
    end
end

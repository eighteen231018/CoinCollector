local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoinConstants = require(ReplicatedStorage:WaitForChild("CoinConstants"))
local PlayerData = require(ReplicatedStorage:WaitForChild("PlayerData"))
local CoinUtility = require(ReplicatedStorage:WaitForChild("CoinUtility"))

-- 创建远程事件
local updateCoinEvent = Instance.new("RemoteEvent")
updateCoinEvent.Name = "UpdateCoinEvent"
updateCoinEvent.Parent = ReplicatedStorage

local function onCoinPickedUp(player, coinModel)
    if not coinModel or not coinModel.Parent then
        return
    end
    
    local newCount = PlayerData:AddCoins(player, 1)
    coinModel:Destroy()
    updateCoinEvent:FireClient(player, newCount)
end

local function setupExistingCoins()
    for _, object in ipairs(Workspace:GetChildren()) do
        if object:IsA("Model") and object.Name == CoinConstants.COIN_MODEL_NAME then
            CoinUtility:SetupCoinPrompt(object, onCoinPickedUp)
        end
    end
end

local function spawnInitialCoins()
    local currentCount = CoinUtility:GetCurrentCoinCount()
    local needed = CoinConstants.INITIAL_COINS - currentCount
    
    if needed > 0 then
        for i = 1, needed do
            local position = CoinUtility:GetRandomSpawnPosition()
            CoinUtility:GenerateCoin(position, onCoinPickedUp)
        end
    end
end

-- 延迟初始化，确保所有模块加载完成
task.wait(0.1)
setupExistingCoins()
spawnInitialCoins()

return {
    OnCoinPickedUp = onCoinPickedUp,
    UpdateCoinEvent = updateCoinEvent
}

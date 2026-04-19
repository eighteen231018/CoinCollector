local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoinConstants = require(ReplicatedStorage:WaitForChild("CoinConstants"))
local CoinUtility = require(ReplicatedStorage:WaitForChild("CoinUtility"))

-- 确保 RemoteEvent 存在
local updateCoinEvent = ReplicatedStorage:FindFirstChild("UpdateCoinEvent")
if not updateCoinEvent then
    updateCoinEvent = Instance.new("RemoteEvent")
    updateCoinEvent.Name = "UpdateCoinEvent"
    updateCoinEvent.Parent = ReplicatedStorage
end

-- 金币拾取回调（用于现有金币）
local function onCoinPickedUp(player, coinModel)
    if not coinModel or not coinModel.Parent then
        return
    end
    
    local PlayerData = require(ReplicatedStorage:WaitForChild("PlayerData"))
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

-- 延迟初始化
task.wait(1)
setupExistingCoins()

print("✅ CoinManager 初始化完成")

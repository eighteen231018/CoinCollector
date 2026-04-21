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

-- 创建地面
local function createBaseplate()
    local baseplate = Workspace:FindFirstChild("Baseplate")
    if not baseplate then
        baseplate = Instance.new("Part")
        baseplate.Name = "Baseplate"
        baseplate.Size = Vector3.new(200, 1, 200)
        baseplate.Position = Vector3.new(0, -0.5, 0)
        baseplate.Color = Color3.new(0.4, 0.4, 0.4)
        baseplate.Anchored = true
        baseplate.Parent = Workspace
        print("🌍 地面创建完成！")
    end
end

-- 创建玩家出生点
local function createSpawnLocation()
    local spawnLocation = Workspace:FindFirstChild("SpawnLocation")
    if not spawnLocation then
        spawnLocation = Instance.new("SpawnLocation")
        spawnLocation.Name = "SpawnLocation"
        spawnLocation.Position = Vector3.new(0, 2, 0)
        spawnLocation.Enabled = true
        spawnLocation.Duration = 0
        spawnLocation.Parent = Workspace
        print("🏠 玩家出生点创建完成！")
    end
end

-- 金币拾取回调
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

local function spawnInitialCoins()
    local currentCount = CoinUtility:GetCurrentCoinCount()
    local needed = CoinConstants.INITIAL_COINS - currentCount
    
    if needed > 0 then
        print("🪙 正在生成初始金币... (" .. needed .. "个)")
        for i = 1, needed do
            local position = CoinUtility:GetRandomSpawnPosition()
            CoinUtility:GenerateCoin(position, onCoinPickedUp)
        end
        print("✅ 初始金币生成完成！")
    else
        print("💡 地图上已有足够金币，跳过生成")
    end
end

-- 延迟初始化
task.wait(1)
createBaseplate()
createSpawnLocation()
setupExistingCoins()
spawnInitialCoins()

print("✅ CoinManager 初始化完成")

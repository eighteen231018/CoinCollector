local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoinConstants = require(ReplicatedStorage:WaitForChild("CoinConstants"))
local PlayerData = require(ReplicatedStorage:WaitForChild("PlayerData"))

local coinDataStore
local dataStoreEnabled = false

-- 尝试初始化 DataStore
local success, err = pcall(function()
    coinDataStore = DataStoreService:GetDataStore(CoinConstants.DATASTORE_NAME)
    dataStoreEnabled = true
end)

if not success then
    warn("⚠️ DataStore 不可用 (需要发布游戏): " .. tostring(err))
end

local function savePlayerData(player)
    if not dataStoreEnabled then
        print("📝 [本地模式] 玩家 " .. player.Name .. " 金币: " .. PlayerData:GetCoins(player))
        return
    end
    
    local userId = player.UserId
    local coinCount = PlayerData:GetCoins(player)
    
    local saveSuccess, saveErr = pcall(function()
        coinDataStore:SetAsync("User_" .. tostring(userId), coinCount)
    end)
    
    if saveSuccess then
        print("✅ 成功保存玩家 " .. player.Name .. " 的金币: " .. coinCount)
    else
        warn("❌ 保存玩家 " .. player.Name .. " 的数据失败: " .. tostring(saveErr))
    end
end

local function loadPlayerData(player)
    local userId = player.UserId
    
    if not dataStoreEnabled then
        PlayerData:SetCoins(player, CoinConstants.DEFAULT_COINS)
        print("📥 [本地模式] 玩家 " .. player.Name .. " 初始金币: " .. CoinConstants.DEFAULT_COINS)
    else
        local loadSuccess, data = pcall(function()
            return coinDataStore:GetAsync("User_" .. tostring(userId))
        end)
        
        if loadSuccess and data then
            PlayerData:SetCoins(player, data)
            print("📥 加载玩家 " .. player.Name .. " 的金币: " .. data)
        else
            PlayerData:SetCoins(player, CoinConstants.DEFAULT_COINS)
            print("📥 玩家 " .. player.Name .. " 首次游戏，初始金币: " .. CoinConstants.DEFAULT_COINS)
        end
    end
    
    -- 等待 UpdateCoinEvent 创建
    local updateCoinEvent = ReplicatedStorage:WaitForChild("UpdateCoinEvent", 10)
    if updateCoinEvent then
        updateCoinEvent:FireClient(player, PlayerData:GetCoins(player))
    else
        warn("⚠️ 未找到 UpdateCoinEvent")
    end
end

Players.PlayerAdded:Connect(loadPlayerData)
Players.PlayerRemoving:Connect(function(player)
    savePlayerData(player)
    PlayerData:RemovePlayer(player)
end)

game:BindToClose(function()
    for _, player in ipairs(Players:GetPlayers()) do
        savePlayerData(player)
    end
end)

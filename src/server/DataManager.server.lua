local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoinConstants = require(ReplicatedStorage:WaitForChild("CoinConstants"))
local PlayerData = require(ReplicatedStorage:WaitForChild("PlayerData"))

local coinDataStore = DataStoreService:GetDataStore(CoinConstants.DATASTORE_NAME)

local function savePlayerData(player)
    local userId = player.UserId
    local coinCount = PlayerData:GetCoins(player)
    
    local success, err = pcall(function()
        coinDataStore:SetAsync("User_" .. tostring(userId), coinCount)
    end)
    
    if success then
        print("✅ 成功保存玩家 " .. player.Name .. " 的金币: " .. coinCount)
    else
        warn("❌ 保存玩家 " .. player.Name .. " 的数据失败: " .. tostring(err))
    end
end

local function loadPlayerData(player)
    local userId = player.UserId
    
    local success, data = pcall(function()
        return coinDataStore:GetAsync("User_" .. tostring(userId))
    end)
    
    if success and data then
        PlayerData:SetCoins(player, data)
        print("📥 加载玩家 " .. player.Name .. " 的金币: " .. data)
    else
        PlayerData:SetCoins(player, CoinConstants.DEFAULT_COINS)
        print("📥 玩家 " .. player.Name .. " 首次游戏，初始金币: " .. CoinConstants.DEFAULT_COINS)
    end
    
    local updateCoinEvent = ReplicatedStorage:FindFirstChild("UpdateCoinEvent")
    if updateCoinEvent then
        updateCoinEvent:FireClient(player, PlayerData:GetCoins(player))
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

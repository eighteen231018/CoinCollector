local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CoinConstants = require(ReplicatedStorage:WaitForChild("CoinConstants"))
local PlayerData = require(ReplicatedStorage:WaitForChild("PlayerData"))

local coinDataStore
local dataStoreEnabled = false
local isStudio = RunService:IsStudio()

-- 本地存储（仅用于 Studio 测试）
local localDataStorage = {}

-- 尝试初始化 DataStore
local success, err = pcall(function()
    coinDataStore = DataStoreService:GetDataStore(CoinConstants.DATASTORE_NAME)
    dataStoreEnabled = true
end)

if not success then
    warn("⚠️ DataStore 不可用 (需要发布游戏): " .. tostring(err))
    if isStudio then
        print("💡 Studio 模式: 使用本地临时存储（会话有效）")
    end
end

local function savePlayerData(player)
    local userId = player.UserId
    local coinCount = PlayerData:GetCoins(player)
    
    if dataStoreEnabled then
        -- 正常保存到 DataStore
        local saveSuccess, saveErr = pcall(function()
            coinDataStore:SetAsync("User_" .. tostring(userId), coinCount)
        end)
        
        if saveSuccess then
            print("✅ 成功保存玩家 " .. player.Name .. " 的金币: " .. coinCount)
        else
            warn("❌ 保存玩家 " .. player.Name .. " 的数据失败: " .. tostring(saveErr))
        end
    else
        -- 本地模式保存
        localDataStorage[userId] = coinCount
        print("📝 [本地存储] 玩家 " .. player.Name .. " 金币已保存: " .. coinCount)
        print("💡 提示: 在 Studio 中可以使用 /save 和 /load 命令")
    end
end

local function loadPlayerData(player)
    local userId = player.UserId
    
    if dataStoreEnabled then
        -- 从 DataStore 加载
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
    else
        -- 本地模式加载
        local savedData = localDataStorage[userId]
        if savedData then
            PlayerData:SetCoins(player, savedData)
            print("📥 [本地存储] 加载玩家 " .. player.Name .. " 的金币: " .. savedData)
        else
            PlayerData:SetCoins(player, CoinConstants.DEFAULT_COINS)
            print("📥 [本地模式] 玩家 " .. player.Name .. " 初始金币: " .. CoinConstants.DEFAULT_COINS)
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

-- 玩家聊天命令处理（仅 Studio 有效）
local function onPlayerChatted(player, message)
    if not isStudio then return end
    
    local lowerMessage = string.lower(message)
    
    if lowerMessage == "/save" then
        savePlayerData(player)
    elseif lowerMessage == "/load" then
        loadPlayerData(player)
        -- 重新发送金币数量到客户端
        local updateCoinEvent = ReplicatedStorage:FindFirstChild("UpdateCoinEvent")
        if updateCoinEvent then
            updateCoinEvent:FireClient(player, PlayerData:GetCoins(player))
        end
    elseif lowerMessage == "/reset" then
        PlayerData:SetCoins(player, 0)
        print("🔄 [本地存储] 玩家 " .. player.Name .. " 金币已重置")
        local updateCoinEvent = ReplicatedStorage:FindFirstChild("UpdateCoinEvent")
        if updateCoinEvent then
            updateCoinEvent:FireClient(player, 0)
        end
    elseif lowerMessage == "/help" then
        print("📋 可用命令:")
        print("  /save - 保存当前金币")
        print("  /load - 加载保存的金币")
        print("  /reset - 重置金币为 0")
        print("  /help - 显示帮助")
    end
end

Players.PlayerAdded:Connect(function(player)
    loadPlayerData(player)
    player.Chatted:Connect(function(message)
        onPlayerChatted(player, message)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    savePlayerData(player)
    PlayerData:RemovePlayer(player)
end)

game:BindToClose(function()
    for _, player in ipairs(Players:GetPlayers()) do
        savePlayerData(player)
    end
end)

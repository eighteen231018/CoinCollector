local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CoinConstants = require(ReplicatedStorage:WaitForChild("CoinConstants"))
local PlayerData = require(ReplicatedStorage:WaitForChild("PlayerData"))

local coinDataStore
local dataStoreEnabled = false
local isStudio = RunService:IsStudio()

-- 本地存储（用于 Studio 测试或 DataStore 失败时）
local localDataStorage = {}

-- 尝试初始化 DataStore
local function initDataStore()
    local success, err = pcall(function()
        coinDataStore = DataStoreService:GetDataStore(CoinConstants.DATASTORE_NAME)
        -- 尝试读取一个测试值来验证连接
        coinDataStore:GetAsync("TestKey")
        dataStoreEnabled = true
    end)
    
    if success then
        print("✅ DataStore 连接成功！")
        return true
    else
        warn("⚠️ DataStore 不可用: " .. tostring(err))
        if isStudio then
            print("")
            print("💡 提示: 想要在 Studio 中使用真正的 DataStore？")
            print("   1. 点击 Game Settings")
            print("   2. 选择 Security")
            print("   3. 开启 'Enable Studio Access to API Services'")
            print("   4. 保存并重新测试")
            print("")
            print("💡 当前使用本地临时存储（会话有效）")
        end
        return false
    end
end

initDataStore()

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
            -- DataStore 失败时，保存到本地
            localDataStorage[userId] = coinCount
            print("📝 [本地备份] 已保存到本地存储")
        end
    else
        -- 本地模式保存
        localDataStorage[userId] = coinCount
        print("📝 [本地存储] 玩家 " .. player.Name .. " 金币已保存: " .. coinCount)
    end
end

local function loadPlayerData(player)
    local userId = player.UserId
    local loadedFrom = nil
    local finalCoins = CoinConstants.DEFAULT_COINS
    
    if dataStoreEnabled then
        -- 从 DataStore 加载
        local loadSuccess, data = pcall(function()
            return coinDataStore:GetAsync("User_" .. tostring(userId))
        end)
        
        if loadSuccess and data ~= nil then
            finalCoins = data
            loadedFrom = "DataStore"
        elseif loadSuccess then
            loadedFrom = "DataStore(新玩家)"
        else
            -- DataStore 失败，尝试本地
            local localData = localDataStorage[userId]
            if localData then
                finalCoins = localData
                loadedFrom = "本地备份"
            else
                loadedFrom = "DataStore(新玩家)"
            end
        end
    else
        -- 本地模式加载
        local localData = localDataStorage[userId]
        if localData then
            finalCoins = localData
            loadedFrom = "本地存储"
        else
            loadedFrom = "本地模式(新玩家)"
        end
    end
    
    -- 设置玩家金币
    PlayerData:SetCoins(player, finalCoins)
    
    -- 打印信息
    if loadedFrom:find("新玩家") then
        print("📥 " .. player.Name .. " 首次游戏，初始金币: " .. finalCoins)
    else
        print("📥 从 " .. loadedFrom .. " 加载 " .. player.Name .. " 的金币: " .. finalCoins)
    end
    
    -- 发送到客户端
    local updateCoinEvent = ReplicatedStorage:WaitForChild("UpdateCoinEvent", 10)
    if updateCoinEvent then
        updateCoinEvent:FireClient(player, finalCoins)
    else
        warn("⚠️ 未找到 UpdateCoinEvent")
    end
end

-- 玩家聊天命令处理
local function onPlayerChatted(player, message)
    if not isStudio then return end
    
    local lowerMessage = string.lower(message)
    local userId = player.UserId
    
    if lowerMessage == "/save" then
        savePlayerData(player)
    elseif lowerMessage == "/load" then
        loadPlayerData(player)
    elseif lowerMessage == "/reset" then
        PlayerData:SetCoins(player, 0)
        print("🔄 玩家 " .. player.Name .. " 金币已重置")
        local updateCoinEvent = ReplicatedStorage:FindFirstChild("UpdateCoinEvent")
        if updateCoinEvent then
            updateCoinEvent:FireClient(player, 0)
        end
    elseif lowerMessage == "/list" then
        print("📋 当前存储的玩家数据:")
        local hasLocalData = false
        for storedUserId, coins in pairs(localDataStorage) do
            print(string.format("  [本地] 用户ID: %d, 金币: %d", storedUserId, coins))
            hasLocalData = true
        end
        if not hasLocalData then
            print("  [本地] (空)")
        end
    elseif lowerMessage == "/help" then
        print("📋 可用命令:")
        print("  /save - 保存当前金币")
        print("  /load - 加载保存的金币")
        print("  /reset - 重置金币为 0")
        print("  /list - 查看本地保存的数据")
        print("  /help - 显示帮助")
        print("")
        if dataStoreEnabled then
            print("✅ 当前使用: DataStore (真正的持久化)")
        else
            print("⚠️ 当前使用: 本地临时存储 (同一会话有效)")
        end
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

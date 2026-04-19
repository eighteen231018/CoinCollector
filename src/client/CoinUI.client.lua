local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 获取远程事件（由服务器脚本创建）
local updateCoinEvent = ReplicatedStorage:WaitForChild("UpdateCoinEvent")

-- 获取UI元素（需先在StarterGui中创建好）
local coinDisplay = playerGui:WaitForChild("CoinDisplayGui")
local coinText = coinDisplay:WaitForChild("Frame"):WaitForChild("CoinText")

-- 监听服务器发来的金币更新事件
updateCoinEvent.OnClientEvent:Connect(function(coinCount)
    coinText.Text = "💰 " .. tostring(coinCount)
end)
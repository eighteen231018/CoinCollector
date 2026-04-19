local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 创建 GUI
local coinDisplay = Instance.new("ScreenGui")
coinDisplay.Name = "CoinDisplayGui"
coinDisplay.ResetOnSpawn = false
coinDisplay.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "Frame"
frame.Size = UDim2.new(0, 200, 0, 80)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BackgroundTransparency = 0.3
frame.Parent = coinDisplay

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = frame

local coinText = Instance.new("TextLabel")
coinText.Name = "CoinText"
coinText.Size = UDim2.new(1, 0, 1, 0)
coinText.BackgroundTransparency = 1
coinText.Text = "💰 0"
coinText.TextSize = 32
coinText.TextColor3 = Color3.new(1, 1, 1)
coinText.Font = Enum.Font.GothamBold
coinText.Parent = frame

-- 获取远程事件
local updateCoinEvent = ReplicatedStorage:WaitForChild("UpdateCoinEvent")

-- 监听服务器发来的金币更新事件
updateCoinEvent.OnClientEvent:Connect(function(coinCount)
    coinText.Text = "💰 " .. tostring(coinCount)
end)
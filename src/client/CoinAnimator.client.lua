local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoinConstants = require(game.ReplicatedStorage:WaitForChild("CoinConstants"))

-- 每帧更新所有金币的旋转角度
RunService.Heartbeat:Connect(function(deltaTime)
    -- 遍历工作区中的所有金币模型
    for _, object in ipairs(Workspace:GetChildren()) do
        if object:IsA("Model") and object.Name == CoinConstants.COIN_MODEL_NAME then
            local primaryPart = object.PrimaryPart
            if primaryPart then
                -- 使用 PivotTo 实现平滑自转
                local currentCFrame = object:GetPivot()
                local rotationAmount = math.rad(CoinConstants.ROTATION_SPEED * deltaTime)
                local newCFrame = currentCFrame * CFrame.Angles(0, rotationAmount, 0)
                object:PivotTo(newCFrame)
            end
        end
    end
end)
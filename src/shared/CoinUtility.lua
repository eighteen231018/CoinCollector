local CoinUtility = {}

local Workspace = game:GetService("Workspace")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoinConstants = require(ReplicatedStorage:WaitForChild("CoinConstants"))

function CoinUtility:GetCurrentCoinCount()
    local count = 0
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and obj.Name == CoinConstants.COIN_MODEL_NAME then
            count += 1
        end
    end
    return count
end

function CoinUtility:GetRandomSpawnPosition()
    local rng = Random.new()
    local x = rng:NextNumber(-CoinConstants.SPAWN_AREA_SIZE.X / 2, CoinConstants.SPAWN_AREA_SIZE.X / 2)
    local z = rng:NextNumber(-CoinConstants.SPAWN_AREA_SIZE.Z / 2, CoinConstants.SPAWN_AREA_SIZE.Z / 2)
    
    local rayOrigin = Vector3.new(x, 50, z)
    local rayDirection = Vector3.new(0, -100, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Include
    
    local baseplate = Workspace:FindFirstChild("Baseplate")
    if baseplate then
        raycastParams.FilterDescendantsInstances = {baseplate}
    end
    
    local raycastResult = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    
    if raycastResult then
        return raycastResult.Position + Vector3.new(0, 2, 0)
    else
        return Vector3.new(x, 2, z)
    end
end

function CoinUtility:SetupCoinPrompt(coinModel, onPickedUp)
    local prompt = coinModel:FindFirstChildWhichIsA("ProximityPrompt")
    if not prompt then
        prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "拾取金币"
        prompt.ObjectText = "💰 金币"
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 5
        prompt.Parent = coinModel
    end
    
    prompt.Triggered:Connect(function(player)
        onPickedUp(player, coinModel)
    end)
end

function CoinUtility:GenerateCoin(position, onPickedUp)
    local coinTemplate = ServerStorage:WaitForChild("CoinTemplate")
    local newCoin = coinTemplate:Clone()
    newCoin.Parent = Workspace
    
    newCoin:PivotTo(CFrame.new(position))
    
    self:SetupCoinPrompt(newCoin, onPickedUp)
    
    return newCoin
end

return CoinUtility

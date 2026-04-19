local PlayerData = {}

local playerData = {}

function PlayerData:GetCoins(player)
    return playerData[player] or 0
end

function PlayerData:SetCoins(player, amount)
    playerData[player] = amount
    return playerData[player]
end

function PlayerData:AddCoins(player, amount)
    playerData[player] = (playerData[player] or 0) + amount
    return playerData[player]
end

function PlayerData:RemovePlayer(player)
    playerData[player] = nil
end

return PlayerData

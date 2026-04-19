local CoinConstants = {}

-- 金币相关配置
CoinConstants.COIN_MODEL_NAME = "Coin"
CoinConstants.MAX_COINS = 10                    -- 同时存在的最大金币数量
CoinConstants.SPAWN_INTERVAL = 5                 -- 生成间隔（秒）
CoinConstants.SPAWN_AREA_SIZE = Vector3.new(50, 0, 50)  -- 生成区域大小
CoinConstants.ROTATION_SPEED = 120               -- 旋转速度（度/秒）
CoinConstants.INITIAL_COINS = 5                  -- 初始金币数量

-- 数据存储配置
CoinConstants.DATASTORE_NAME = "PlayerCoinData"
CoinConstants.DEFAULT_COINS = 0

return CoinConstants

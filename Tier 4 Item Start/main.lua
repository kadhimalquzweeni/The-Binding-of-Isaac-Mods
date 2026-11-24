
local mod = RegisterMod("Tier 4 Item Start", 1)
local json = require("json")

local game = Game()
local itemConfig = Isaac.GetItemConfig()

local MAX_ATTEMPTS = 100

mod.state = {
    spent = false
}

--------------------------------------------------
-- FIND A QUALITY 4 ITEM
--------------------------------------------------

local function RollTier4Item(itemPoolType, seed)
    local rng = RNG()
    rng:SetSeed(seed, 0)

    local itemPool = game:GetItemPool()

    for attempt = 1, MAX_ATTEMPTS do
        local itemID = itemPool:GetCollectible(
            itemPoolType,
            false,
            seed
        )

        if itemID and itemID > 0 then
            local item = itemConfig:GetCollectible(itemID)

            if item and item.Quality == 4 then
                Isaac.DebugString(
                    "[Tier 4 Item Start] Selected item: "
                    .. item.Name
                )

                return itemID
            end
        end

        seed = rng:Next()
    end

    Isaac.DebugString(
        "[Tier 4 Item Start] Failed to find a Quality 4 item."
    )

    return nil
end

--------------------------------------------------
-- INTERCEPT TREASURE ROOM ITEM GENERATION
--------------------------------------------------

function mod:RollCollectible(itemPoolType, decrease, seed)
    if mod.state.spent then
        return
    end

    local room = game:GetLevel():GetCurrentRoom()

    if itemPoolType ~= ItemPoolType.POOL_TREASURE then
        return
    end

    if room:GetType() ~= RoomType.ROOM_TREASURE then
        return
    end

    local itemID = RollTier4Item(itemPoolType, seed)

    if itemID then
        mod.state.spent = true
        return itemID
    end
end

--------------------------------------------------
-- SAVE / LOAD
--------------------------------------------------

function mod:SaveState()
    mod:SaveData(json.encode(mod.state))
end

function mod:LoadState(isContinued)
    if mod:HasData() then
        local success, data = pcall(function()
            return json.decode(mod:LoadData())
        end)

        if success and type(data) == "table" then
            mod.state = data
        end
    end

    if not isContinued then
        mod.state.spent = false
    end
end

--------------------------------------------------
-- CALLBACKS
--------------------------------------------------

mod:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    mod.LoadState
)

mod:AddCallback(
    ModCallbacks.MC_PRE_GET_COLLECTIBLE,
    mod.RollCollectible
)

mod:AddCallback(
    ModCallbacks.MC_PRE_GAME_EXIT,
    mod.SaveState
)

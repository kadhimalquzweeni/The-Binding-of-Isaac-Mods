-- Lucky Foot Start
-- Gives the player Lucky Foot when a new run begins.

local LuckyFootMod = RegisterMod("Lucky Foot Start", 1)

local LUCKY_FOOT_ITEM_ID = CollectibleType.COLLECTIBLE_LUCKY_FOOT
local isNewGameAndNoLuckyFoot = false

function LuckyFootMod:onPostNewLevel()
    local player = Isaac.GetPlayer(0)

    if Game():GetLevel():GetStage() == 1 then
        isNewGameAndNoLuckyFoot = not player:HasCollectible(LUCKY_FOOT_ITEM_ID, true)
    end
end

function LuckyFootMod:onPostPlayerInit()
    local player = Isaac.GetPlayer(0)
    isNewGameAndNoLuckyFoot = not player:HasCollectible(LUCKY_FOOT_ITEM_ID, true)
end

function LuckyFootMod:onPostPlayerRender()
    local player = Isaac.GetPlayer(0)

    if isNewGameAndNoLuckyFoot and not player:HasCollectible(LUCKY_FOOT_ITEM_ID, true) then
        player:AddCollectible(LUCKY_FOOT_ITEM_ID, 0, false)
        isNewGameAndNoLuckyFoot = false
    end
end

LuckyFootMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, LuckyFootMod.onPostNewLevel)
LuckyFootMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, LuckyFootMod.onPostPlayerInit)
LuckyFootMod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, LuckyFootMod.onPostPlayerRender)

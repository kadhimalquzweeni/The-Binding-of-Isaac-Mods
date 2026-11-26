-- Head of the Keeper Start
-- Gives the player Head of the Keeper when a new run begins.

local HeadoftheKeeperStartMod = RegisterMod("Head of the Keeper Start", 1)

-- Collectible ID: 429
local ITEM_ID = 429
local isNewGameAndNoHeadoftheKeeper = false

function HeadoftheKeeperStartMod:onPostNewLevel()
    local player = Isaac.GetPlayer(0)

    if Game():GetLevel():GetStage() == 1 then
        isNewGameAndNoHeadoftheKeeper = not player:HasCollectible(ITEM_ID, true)
    end
end

function HeadoftheKeeperStartMod:onPostPlayerInit()
    local player = Isaac.GetPlayer(0)
    isNewGameAndNoHeadoftheKeeper = not player:HasCollectible(ITEM_ID, true)
end

function HeadoftheKeeperStartMod:onPostPlayerRender()
    local player = Isaac.GetPlayer(0)

    if isNewGameAndNoHeadoftheKeeper and not player:HasCollectible(ITEM_ID, true) then
        player:AddCollectible(ITEM_ID, 0, false)
        isNewGameAndNoHeadoftheKeeper = false
    end
end

HeadoftheKeeperStartMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, HeadoftheKeeperStartMod.onPostNewLevel)
HeadoftheKeeperStartMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, HeadoftheKeeperStartMod.onPostPlayerInit)
HeadoftheKeeperStartMod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, HeadoftheKeeperStartMod.onPostPlayerRender)

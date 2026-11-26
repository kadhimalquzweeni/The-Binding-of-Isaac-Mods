-- There's Options Start
-- Gives the player There's Options when a new run begins.

local TheresOptionsStartMod = RegisterMod("There's Options Start", 1)

-- Collectible ID: 249
local ITEM_ID = 249
local isNewGameAndNoTheresOptions = false

function TheresOptionsStartMod:onPostNewLevel()
    local player = Isaac.GetPlayer(0)

    if Game():GetLevel():GetStage() == 1 then
        isNewGameAndNoTheresOptions = not player:HasCollectible(ITEM_ID, true)
    end
end

function TheresOptionsStartMod:onPostPlayerInit()
    local player = Isaac.GetPlayer(0)
    isNewGameAndNoTheresOptions = not player:HasCollectible(ITEM_ID, true)
end

function TheresOptionsStartMod:onPostPlayerRender()
    local player = Isaac.GetPlayer(0)

    if isNewGameAndNoTheresOptions and not player:HasCollectible(ITEM_ID, true) then
        player:AddCollectible(ITEM_ID, 0, false)
        isNewGameAndNoTheresOptions = false
    end
end

TheresOptionsStartMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, TheresOptionsStartMod.onPostNewLevel)
TheresOptionsStartMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, TheresOptionsStartMod.onPostPlayerInit)
TheresOptionsStartMod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, TheresOptionsStartMod.onPostPlayerRender)

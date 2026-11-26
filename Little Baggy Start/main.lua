-- Little Baggy Start
-- Gives the player Little Baggy when a new run begins.

local LittleBaggyStartMod = RegisterMod("Little Baggy Start", 1)

-- Collectible ID: 252
local ITEM_ID = 252
local isNewGameAndNoLittleBaggy = false

function LittleBaggyStartMod:onPostNewLevel()
    local player = Isaac.GetPlayer(0)

    if Game():GetLevel():GetStage() == 1 then
        isNewGameAndNoLittleBaggy = not player:HasCollectible(ITEM_ID, true)
    end
end

function LittleBaggyStartMod:onPostPlayerInit()
    local player = Isaac.GetPlayer(0)
    isNewGameAndNoLittleBaggy = not player:HasCollectible(ITEM_ID, true)
end

function LittleBaggyStartMod:onPostPlayerRender()
    local player = Isaac.GetPlayer(0)

    if isNewGameAndNoLittleBaggy and not player:HasCollectible(ITEM_ID, true) then
        player:AddCollectible(ITEM_ID, 0, false)
        isNewGameAndNoLittleBaggy = false
    end
end

LittleBaggyStartMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, LittleBaggyStartMod.onPostNewLevel)
LittleBaggyStartMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, LittleBaggyStartMod.onPostPlayerInit)
LittleBaggyStartMod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, LittleBaggyStartMod.onPostPlayerRender)

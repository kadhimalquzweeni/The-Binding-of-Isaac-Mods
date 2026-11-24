-- More Options Start
-- Gives the player More Options when a new run begins.

local MoreOptionsMod = RegisterMod("More Options Start", 1)

local MORE_OPTIONS_ITEM_ID = CollectibleType.COLLECTIBLE_MORE_OPTIONS
local isNewGameAndNoMoreOptions = false

function MoreOptionsMod:onPostNewLevel()
    local player = Isaac.GetPlayer(0)

    if Game():GetLevel():GetStage() == 1 then
        isNewGameAndNoMoreOptions = not player:HasCollectible(MORE_OPTIONS_ITEM_ID, true)
    end
end

function MoreOptionsMod:onPostPlayerInit()
    local player = Isaac.GetPlayer(0)
    isNewGameAndNoMoreOptions = not player:HasCollectible(MORE_OPTIONS_ITEM_ID, true)
end

function MoreOptionsMod:onPostPlayerRender()
    local player = Isaac.GetPlayer(0)

    if isNewGameAndNoMoreOptions and not player:HasCollectible(MORE_OPTIONS_ITEM_ID, true) then
        player:AddCollectible(MORE_OPTIONS_ITEM_ID, 0, false)
        isNewGameAndNoMoreOptions = false
    end
end

MoreOptionsMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, MoreOptionsMod.onPostNewLevel)
MoreOptionsMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, MoreOptionsMod.onPostPlayerInit)
MoreOptionsMod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, MoreOptionsMod.onPostPlayerRender)

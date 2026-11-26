-- Wooden Spoon Start
-- Gives the player Wooden Spoon when a new run begins.

local WoodenSpoonStartMod = RegisterMod("Wooden Spoon Start", 1)

-- Collectible ID: 27
local ITEM_ID = 27
local isNewGameAndNoWoodenSpoon = false

function WoodenSpoonStartMod:onPostNewLevel()
    local player = Isaac.GetPlayer(0)

    if Game():GetLevel():GetStage() == 1 then
        isNewGameAndNoWoodenSpoon = not player:HasCollectible(ITEM_ID, true)
    end
end

function WoodenSpoonStartMod:onPostPlayerInit()
    local player = Isaac.GetPlayer(0)
    isNewGameAndNoWoodenSpoon = not player:HasCollectible(ITEM_ID, true)
end

function WoodenSpoonStartMod:onPostPlayerRender()
    local player = Isaac.GetPlayer(0)

    if isNewGameAndNoWoodenSpoon and not player:HasCollectible(ITEM_ID, true) then
        player:AddCollectible(ITEM_ID, 0, false)
        isNewGameAndNoWoodenSpoon = false
    end
end

WoodenSpoonStartMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, WoodenSpoonStartMod.onPostNewLevel)
WoodenSpoonStartMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, WoodenSpoonStartMod.onPostPlayerInit)
WoodenSpoonStartMod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, WoodenSpoonStartMod.onPostPlayerRender)

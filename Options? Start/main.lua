-- Options? Start
-- Gives the player Options? when a new run begins.

local OptionsStartMod = RegisterMod("Options? Start", 1)

-- Collectible ID: 670
local ITEM_ID = 670
local isNewGameAndNoOptions = false

function OptionsStartMod:onPostNewLevel()
    local player = Isaac.GetPlayer(0)

    if Game():GetLevel():GetStage() == 1 then
        isNewGameAndNoOptions = not player:HasCollectible(ITEM_ID, true)
    end
end

function OptionsStartMod:onPostPlayerInit()
    local player = Isaac.GetPlayer(0)
    isNewGameAndNoOptions = not player:HasCollectible(ITEM_ID, true)
end

function OptionsStartMod:onPostPlayerRender()
    local player = Isaac.GetPlayer(0)

    if isNewGameAndNoOptions and not player:HasCollectible(ITEM_ID, true) then
        player:AddCollectible(ITEM_ID, 0, false)
        isNewGameAndNoOptions = false
    end
end

OptionsStartMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, OptionsStartMod.onPostNewLevel)
OptionsStartMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, OptionsStartMod.onPostPlayerInit)
OptionsStartMod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, OptionsStartMod.onPostPlayerRender)

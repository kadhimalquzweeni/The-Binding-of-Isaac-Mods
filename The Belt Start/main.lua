-- The Belt Start
-- Gives the player The Belt when a new run begins.

local TheBeltStartMod = RegisterMod("The Belt Start", 1)

-- Collectible ID: 28
local ITEM_ID = 28
local isNewGameAndNoTheBelt = false

function TheBeltStartMod:onPostNewLevel()
    local player = Isaac.GetPlayer(0)

    if Game():GetLevel():GetStage() == 1 then
        isNewGameAndNoTheBelt = not player:HasCollectible(ITEM_ID, true)
    end
end

function TheBeltStartMod:onPostPlayerInit()
    local player = Isaac.GetPlayer(0)
    isNewGameAndNoTheBelt = not player:HasCollectible(ITEM_ID, true)
end

function TheBeltStartMod:onPostPlayerRender()
    local player = Isaac.GetPlayer(0)

    if isNewGameAndNoTheBelt and not player:HasCollectible(ITEM_ID, true) then
        player:AddCollectible(ITEM_ID, 0, false)
        isNewGameAndNoTheBelt = false
    end
end

TheBeltStartMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, TheBeltStartMod.onPostNewLevel)
TheBeltStartMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, TheBeltStartMod.onPostPlayerInit)
TheBeltStartMod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, TheBeltStartMod.onPostPlayerRender)

-- The Ladder Start
-- Gives the player The Ladder when a new run begins.

local TheLadderStartMod = RegisterMod("The Ladder Start", 1)

-- Collectible ID: 60
local ITEM_ID = 60
local isNewGameAndNoTheLadder = false

function TheLadderStartMod:onPostNewLevel()
    local player = Isaac.GetPlayer(0)

    if Game():GetLevel():GetStage() == 1 then
        isNewGameAndNoTheLadder = not player:HasCollectible(ITEM_ID, true)
    end
end

function TheLadderStartMod:onPostPlayerInit()
    local player = Isaac.GetPlayer(0)
    isNewGameAndNoTheLadder = not player:HasCollectible(ITEM_ID, true)
end

function TheLadderStartMod:onPostPlayerRender()
    local player = Isaac.GetPlayer(0)

    if isNewGameAndNoTheLadder and not player:HasCollectible(ITEM_ID, true) then
        player:AddCollectible(ITEM_ID, 0, false)
        isNewGameAndNoTheLadder = false
    end
end

TheLadderStartMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, TheLadderStartMod.onPostNewLevel)
TheLadderStartMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, TheLadderStartMod.onPostPlayerInit)
TheLadderStartMod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, TheLadderStartMod.onPostPlayerRender)

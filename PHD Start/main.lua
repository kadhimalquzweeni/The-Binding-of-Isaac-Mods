-- PHD Start
-- Gives the player PHD when a new run begins.

local PHDStartMod = RegisterMod("PHD Start", 1)

-- Collectible ID: 75
local ITEM_ID = 75
local isNewGameAndNoPHD = false

function PHDStartMod:onPostNewLevel()
    local player = Isaac.GetPlayer(0)

    if Game():GetLevel():GetStage() == 1 then
        isNewGameAndNoPHD = not player:HasCollectible(ITEM_ID, true)
    end
end

function PHDStartMod:onPostPlayerInit()
    local player = Isaac.GetPlayer(0)
    isNewGameAndNoPHD = not player:HasCollectible(ITEM_ID, true)
end

function PHDStartMod:onPostPlayerRender()
    local player = Isaac.GetPlayer(0)

    if isNewGameAndNoPHD and not player:HasCollectible(ITEM_ID, true) then
        player:AddCollectible(ITEM_ID, 0, false)
        isNewGameAndNoPHD = false
    end
end

PHDStartMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, PHDStartMod.onPostNewLevel)
PHDStartMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, PHDStartMod.onPostPlayerInit)
PHDStartMod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, PHDStartMod.onPostPlayerRender)

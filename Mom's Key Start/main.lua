-- Mom's Key Start
-- Gives the player Mom's Key when a new run begins.

local MomsKeyStartMod = RegisterMod("Mom's Key Start", 1)

-- Collectible ID: 199
local ITEM_ID = 199
local isNewGameAndNoMomsKey = false

function MomsKeyStartMod:onPostNewLevel()
    local player = Isaac.GetPlayer(0)

    if Game():GetLevel():GetStage() == 1 then
        isNewGameAndNoMomsKey = not player:HasCollectible(ITEM_ID, true)
    end
end

function MomsKeyStartMod:onPostPlayerInit()
    local player = Isaac.GetPlayer(0)
    isNewGameAndNoMomsKey = not player:HasCollectible(ITEM_ID, true)
end

function MomsKeyStartMod:onPostPlayerRender()
    local player = Isaac.GetPlayer(0)

    if isNewGameAndNoMomsKey and not player:HasCollectible(ITEM_ID, true) then
        player:AddCollectible(ITEM_ID, 0, false)
        isNewGameAndNoMomsKey = false
    end
end

MomsKeyStartMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, MomsKeyStartMod.onPostNewLevel)
MomsKeyStartMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, MomsKeyStartMod.onPostPlayerInit)
MomsKeyStartMod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, MomsKeyStartMod.onPostPlayerRender)

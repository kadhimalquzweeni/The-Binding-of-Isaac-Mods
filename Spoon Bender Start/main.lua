-- Spoon Bender Start
-- Gives the player Spoon Bender when a new run begins.

local SpoonBenderStartMod = RegisterMod("Spoon Bender Start", 1)

-- Collectible ID: 3
local ITEM_ID = 3
local isNewGameAndNoSpoonBender = false

function SpoonBenderStartMod:onPostNewLevel()
    local player = Isaac.GetPlayer(0)

    if Game():GetLevel():GetStage() == 1 then
        isNewGameAndNoSpoonBender = not player:HasCollectible(ITEM_ID, true)
    end
end

function SpoonBenderStartMod:onPostPlayerInit()
    local player = Isaac.GetPlayer(0)
    isNewGameAndNoSpoonBender = not player:HasCollectible(ITEM_ID, true)
end

function SpoonBenderStartMod:onPostPlayerRender()
    local player = Isaac.GetPlayer(0)

    if isNewGameAndNoSpoonBender and not player:HasCollectible(ITEM_ID, true) then
        player:AddCollectible(ITEM_ID, 0, false)
        isNewGameAndNoSpoonBender = false
    end
end

SpoonBenderStartMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, SpoonBenderStartMod.onPostNewLevel)
SpoonBenderStartMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, SpoonBenderStartMod.onPostPlayerInit)
SpoonBenderStartMod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, SpoonBenderStartMod.onPostPlayerRender)

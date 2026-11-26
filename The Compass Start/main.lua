-- The Compass Start
-- Gives the player The Compass when a new run begins.

local TheCompassStartMod = RegisterMod("The Compass Start", 1)

-- Collectible ID: 21
local ITEM_ID = 21
local isNewGameAndNoTheCompass = false

function TheCompassStartMod:onPostNewLevel()
    local player = Isaac.GetPlayer(0)

    if Game():GetLevel():GetStage() == 1 then
        isNewGameAndNoTheCompass = not player:HasCollectible(ITEM_ID, true)
    end
end

function TheCompassStartMod:onPostPlayerInit()
    local player = Isaac.GetPlayer(0)
    isNewGameAndNoTheCompass = not player:HasCollectible(ITEM_ID, true)
end

function TheCompassStartMod:onPostPlayerRender()
    local player = Isaac.GetPlayer(0)

    if isNewGameAndNoTheCompass and not player:HasCollectible(ITEM_ID, true) then
        player:AddCollectible(ITEM_ID, 0, false)
        isNewGameAndNoTheCompass = false
    end
end

TheCompassStartMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, TheCompassStartMod.onPostNewLevel)
TheCompassStartMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, TheCompassStartMod.onPostPlayerInit)
TheCompassStartMod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, TheCompassStartMod.onPostPlayerRender)

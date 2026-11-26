-- Sacred Orb Start
-- Gives the player Sacred Orb when a new run begins.

local SacredOrbStartMod = RegisterMod("Sacred Orb Start", 1)

-- Collectible ID: 691
local ITEM_ID = 691
local isNewGameAndNoSacredOrb = false

function SacredOrbStartMod:onPostNewLevel()
    local player = Isaac.GetPlayer(0)

    if Game():GetLevel():GetStage() == 1 then
        isNewGameAndNoSacredOrb = not player:HasCollectible(ITEM_ID, true)
    end
end

function SacredOrbStartMod:onPostPlayerInit()
    local player = Isaac.GetPlayer(0)
    isNewGameAndNoSacredOrb = not player:HasCollectible(ITEM_ID, true)
end

function SacredOrbStartMod:onPostPlayerRender()
    local player = Isaac.GetPlayer(0)

    if isNewGameAndNoSacredOrb and not player:HasCollectible(ITEM_ID, true) then
        player:AddCollectible(ITEM_ID, 0, false)
        isNewGameAndNoSacredOrb = false
    end
end

SacredOrbStartMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, SacredOrbStartMod.onPostNewLevel)
SacredOrbStartMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, SacredOrbStartMod.onPostPlayerInit)
SacredOrbStartMod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, SacredOrbStartMod.onPostPlayerRender)

-- Steam Sale Start
-- Gives the player Steam Sale when a new run begins.

local SteamSaleStartMod = RegisterMod("Steam Sale Start", 1)

-- Collectible ID: 64
local ITEM_ID = 64
local isNewGameAndNoSteamSale = false

function SteamSaleStartMod:onPostNewLevel()
    local player = Isaac.GetPlayer(0)

    if Game():GetLevel():GetStage() == 1 then
        isNewGameAndNoSteamSale = not player:HasCollectible(ITEM_ID, true)
    end
end

function SteamSaleStartMod:onPostPlayerInit()
    local player = Isaac.GetPlayer(0)
    isNewGameAndNoSteamSale = not player:HasCollectible(ITEM_ID, true)
end

function SteamSaleStartMod:onPostPlayerRender()
    local player = Isaac.GetPlayer(0)

    if isNewGameAndNoSteamSale and not player:HasCollectible(ITEM_ID, true) then
        player:AddCollectible(ITEM_ID, 0, false)
        isNewGameAndNoSteamSale = false
    end
end

SteamSaleStartMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, SteamSaleStartMod.onPostNewLevel)
SteamSaleStartMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, SteamSaleStartMod.onPostPlayerInit)
SteamSaleStartMod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, SteamSaleStartMod.onPostPlayerRender)

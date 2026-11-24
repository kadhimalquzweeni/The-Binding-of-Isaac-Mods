-- YO LISTEN! Start
-- Gives the player YO LISTEN! when a new run begins.

local YoListenMod = RegisterMod("YO LISTEN Start", 1)

local YO_LISTEN_ITEM_ID = CollectibleType.COLLECTIBLE_YO_LISTEN
local isNewGameAndNoYoListen = false

function YoListenMod:onPostNewLevel()
    local player = Isaac.GetPlayer(0)

    if Game():GetLevel():GetStage() == 1 then
        isNewGameAndNoYoListen = not player:HasCollectible(YO_LISTEN_ITEM_ID, true)
    end
end

function YoListenMod:onPostPlayerInit()
    local player = Isaac.GetPlayer(0)
    isNewGameAndNoYoListen = not player:HasCollectible(YO_LISTEN_ITEM_ID, true)
end

function YoListenMod:onPostPlayerRender()
    local player = Isaac.GetPlayer(0)

    if isNewGameAndNoYoListen and not player:HasCollectible(YO_LISTEN_ITEM_ID, true) then
        player:AddCollectible(YO_LISTEN_ITEM_ID, 0, false)
        isNewGameAndNoYoListen = false
    end
end

YoListenMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, YoListenMod.onPostNewLevel)
YoListenMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, YoListenMod.onPostPlayerInit)
YoListenMod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, YoListenMod.onPostPlayerRender)

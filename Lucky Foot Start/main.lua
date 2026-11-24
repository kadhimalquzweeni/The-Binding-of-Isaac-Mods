local LuckyFootStartMod = RegisterMod("Lucky Foot Start", 1)

local game = Game()

local function GiveLuckyFoot(isContinued)
    -- Only grant the item when a new run is started, not when continuing a save.
    if isContinued then
        return
    end

    for playerIndex = 0, game:GetNumPlayers() - 1 do
        local player = game:GetPlayer(playerIndex)
        player:AddCollectible(CollectibleType.COLLECTIBLE_LUCKY_FOOT)
    end
end

LuckyFootStartMod:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    GiveLuckyFoot
)

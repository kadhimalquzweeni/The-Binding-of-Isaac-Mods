local YoListenStartMod = RegisterMod("YO LISTEN Start", 1)

local game = Game()

local function GiveYoListen(isContinued)
    -- Only grant the trinket when a new run is started, not when continuing a save.
    if isContinued then
        return
    end

    for playerIndex = 0, game:GetNumPlayers() - 1 do
        local player = game:GetPlayer(playerIndex)
        player:AddTrinket(TrinketType.TRINKET_YO_LISTEN)
    end
end

YoListenStartMod:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    GiveYoListen
)

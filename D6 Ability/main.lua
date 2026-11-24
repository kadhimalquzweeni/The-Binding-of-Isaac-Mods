--==================================================
-- D6 ABILITY
-- Press Left Ctrl or Right Ctrl to reroll collectible
-- pedestals in the current room.
-- Recharges after clearing six rooms.
--==================================================

local D6Ability = RegisterMod("D6 Ability", 1)
local game = Game()

local CHARGE_ROOMS = 6
local chargeProgress = 0

local function SaveCharge()
    D6Ability:SaveData(tostring(chargeProgress))
end

function D6Ability:LoadRunData(isContinued)
    if isContinued and self:HasData() then
        local savedProgress = tonumber(self:LoadData())
        chargeProgress = math.max(0, math.min(CHARGE_ROOMS, savedProgress or 0))
    else
        chargeProgress = 0
        SaveCharge()
    end
end

function D6Ability:OnRoomCleared()
    if chargeProgress < CHARGE_ROOMS then
        chargeProgress = chargeProgress + 1
        SaveCharge()

        Isaac.DebugString(
            "[D6 Ability] Recharge: "
            .. chargeProgress
            .. "/"
            .. CHARGE_ROOMS
        )
    end
end

function D6Ability:RerollRoom()
    if chargeProgress < CHARGE_ROOMS then
        Isaac.DebugString(
            "[D6 Ability] Not charged. Progress: "
            .. chargeProgress
            .. "/"
            .. CHARGE_ROOMS
        )
        return
    end

    local room = game:GetRoom()
    local itemPool = game:GetItemPool()
    local rerolled = 0

    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity.Type == EntityType.ENTITY_PICKUP
            and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE then

            local pickup = entity:ToPickup()

            if pickup and pickup.SubType > 0 and pickup:CanReroll() then
                local poolType = itemPool:GetPoolForRoom(room:GetType(), pickup.InitSeed)
                local newItem = itemPool:GetCollectible(poolType, true, pickup.InitSeed)

                if newItem and newItem > 0 then
                    pickup:Morph(
                        EntityType.ENTITY_PICKUP,
                        PickupVariant.PICKUP_COLLECTIBLE,
                        newItem,
                        true,
                        false,
                        false
                    )

                    pickup.Touched = false
                    pickup.ShopItemId = -1
                    rerolled = rerolled + 1
                end
            end
        end
    end

    chargeProgress = 0
    SaveCharge()

    Isaac.DebugString("[D6 Ability] Collectible pedestals rerolled: " .. rerolled)
end

function D6Ability:OnPostRender()
    if Input.IsButtonTriggered(Keyboard.KEY_LEFT_CONTROL, 0)
        or Input.IsButtonTriggered(Keyboard.KEY_RIGHT_CONTROL, 0) then
        self:RerollRoom()
    end
end

function D6Ability:OnGameExit()
    SaveCharge()
end

D6Ability:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, D6Ability.LoadRunData)
D6Ability:AddCallback(ModCallbacks.MC_POST_ROOM_TRIGGER_CLEAR, D6Ability.OnRoomCleared)
D6Ability:AddCallback(ModCallbacks.MC_POST_RENDER, D6Ability.OnPostRender)
D6Ability:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, D6Ability.OnGameExit)

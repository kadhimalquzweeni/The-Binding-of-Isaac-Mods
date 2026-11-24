--==================================================
-- D6 ABILITY
-- Press Left Ctrl or Right Ctrl to reroll collectible
-- pedestals in the current room.
-- Can be used an unlimited number of times.
--==================================================

local D6Ability = RegisterMod("D6 Ability", 1)
local game = Game()

function D6Ability:RerollRoom()
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

    Isaac.DebugString("[D6 Ability] Collectible pedestals rerolled: " .. rerolled)
end

function D6Ability:OnPostRender()
    if Input.IsButtonTriggered(Keyboard.KEY_LEFT_CONTROL, 0)
        or Input.IsButtonTriggered(Keyboard.KEY_RIGHT_CONTROL, 0) then
        self:RerollRoom()
    end
end

D6Ability:AddCallback(ModCallbacks.MC_POST_RENDER, D6Ability.OnPostRender)

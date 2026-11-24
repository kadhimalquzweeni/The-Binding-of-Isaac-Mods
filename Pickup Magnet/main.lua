--==================================================
-- PICKUP MAGNET
-- Attracts nearby coins, bombs, keys and grab bags.
--==================================================

local PickupMagnet = RegisterMod("Pickup Magnet", 1)

local MAGNET_RANGE = 2000
local MAGNET_ACCELERATION = 3
local MAGNET_DAMPING = 0.85
local MAGNET_MAX_SPEED = 9

function PickupMagnet:IsMagneticPickup(entity)
    if entity.Type ~= EntityType.ENTITY_PICKUP then
        return false
    end

    local variant = entity.Variant

    return variant == PickupVariant.PICKUP_COIN
        or variant == PickupVariant.PICKUP_BOMB
        or variant == PickupVariant.PICKUP_KEY
        or variant == PickupVariant.PICKUP_GRAB_BAG
end

function PickupMagnet:AttractPickups()
    local player = Isaac.GetPlayer(0)

    if not player or player:IsDead() then
        return
    end

    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if self:IsMagneticPickup(entity) then
            local toPlayer = player.Position - entity.Position
            local distance = toPlayer:Length()

            if distance > 0 and distance <= MAGNET_RANGE then
                local direction = toPlayer:Normalized()
                local velocity = entity.Velocity * MAGNET_DAMPING
                    + direction * MAGNET_ACCELERATION

                if velocity:Length() > MAGNET_MAX_SPEED then
                    velocity = velocity:Resized(MAGNET_MAX_SPEED)
                end

                entity.Velocity = velocity
            end
        end
    end
end

PickupMagnet:AddCallback(ModCallbacks.MC_POST_UPDATE, PickupMagnet.AttractPickups)

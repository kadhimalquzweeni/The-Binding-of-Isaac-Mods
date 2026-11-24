
--==================================================
-- ROOM CLEANER
-- The Binding of Isaac: Repentance / Repentance+
-- Version 1.7.0
--==================================================

local RoomCleaner = RegisterMod("Room Cleaner", 1)

local game = Game()

--------------------------------------------------
-- SETTINGS
--------------------------------------------------

local MAGNET_RANGE = 2000
local MAGNET_ACCELERATION = 3
local MAGNET_DAMPING = 0.85
local MAGNET_MAX_SPEED = 9

--------------------------------------------------
-- GRID OBJECTS
--------------------------------------------------

local DESTROY_TYPES = {
    [2] = true,
    [3] = true,
    [4] = true,
    [5] = true,
    [6] = true,
    [8] = true,
    [9] = true,
    [10] = true,
    [11] = true,
    [12] = true,
    [20] = true,
    [22] = true,
    [23] = true,
    [25] = true,
    [26] = true,
    [27] = true
}

--------------------------------------------------
-- CREATE EXPLOSION DAMAGE SOURCE
--------------------------------------------------

function RoomCleaner:GetExplosionSource()

    local player = Isaac.GetPlayer(0)

    return EntityRef(player)

end

--------------------------------------------------
-- DESTROY GRID OBJECTS
--------------------------------------------------

function RoomCleaner:CleanGrid()

    local room = game:GetRoom()

    local destroyed = 0

    for index = 0, room:GetGridSize() - 1 do

        local grid = room:GetGridEntity(index)

        if grid then

            local gridType = grid:GetType()

            if DESTROY_TYPES[gridType]
            or gridType == GridEntityType.GRID_POOP then

                if room:DestroyGrid(index, false) then
                    destroyed = destroyed + 1
                end

            end
        end
    end

    Isaac.DebugString(
        "[Room Cleaner] Grid objects destroyed: "
        .. destroyed
    )

end

--------------------------------------------------
-- DESTROY FIREPLACES AND SHOPKEEPERS
--------------------------------------------------

function RoomCleaner:DestroyEnvironmentalEntities()

    local entities = Isaac.GetRoomEntities()

    local source = self:GetExplosionSource()

    local destroyedFireplaces = 0
    local destroyedShopkeepers = 0

    for _, entity in ipairs(entities) do

        if entity.Type == EntityType.ENTITY_FIREPLACE then

            entity:TakeDamage(
                1000,
                DamageFlag.DAMAGE_EXPLOSION,
                source,
                0
            )

            destroyedFireplaces =
                destroyedFireplaces + 1

        elseif entity.Type == EntityType.ENTITY_SHOPKEEPER then

            entity:TakeDamage(
                1000,
                DamageFlag.DAMAGE_EXPLOSION,
                source,
                0
            )

            destroyedShopkeepers =
                destroyedShopkeepers + 1

        end

    end

    Isaac.DebugString(
        "[Room Cleaner] Fireplaces hit: "
        .. destroyedFireplaces
        .. " | Shopkeepers hit: "
        .. destroyedShopkeepers
    )

end

--------------------------------------------------
-- MAGNET PICKUPS
--------------------------------------------------

function RoomCleaner:IsMagneticPickup(entity)

    if entity.Type ~= EntityType.ENTITY_PICKUP then
        return false
    end

    local variant = entity.Variant

    return variant == PickupVariant.PICKUP_COIN
        or variant == PickupVariant.PICKUP_BOMB
        or variant == PickupVariant.PICKUP_KEY
        or variant == PickupVariant.PICKUP_GRAB_BAG

end

function RoomCleaner:AttractPickups()

    local player = Isaac.GetPlayer(0)

    if not player or player:IsDead() then
        return
    end

    local entities = Isaac.GetRoomEntities()

    for _, entity in ipairs(entities) do

        if self:IsMagneticPickup(entity) then

            local toPlayer = player.Position - entity.Position
            local distance = toPlayer:Length()

            if distance > 0 and distance <= MAGNET_RANGE then

                local direction = toPlayer:Normalized()

                local velocity =
                    entity.Velocity * MAGNET_DAMPING
                    + direction * MAGNET_ACCELERATION

                if velocity:Length() > MAGNET_MAX_SPEED then

                    velocity = velocity:Resized(MAGNET_MAX_SPEED)

                end

                entity.Velocity = velocity

            end

        end

    end

end

--------------------------------------------------
-- TELEPORT TO BOSS ROOM - SHIFT
--------------------------------------------------

function RoomCleaner:TeleportToBossRoom()

    local level = game:GetLevel()
    local player = Isaac.GetPlayer(0)

    if not player or player:IsDead() then
        return
    end

    local currentRoom = level:GetCurrentRoomDesc()

    -- Do not teleport if already in the boss room.
    if currentRoom
    and currentRoom.Data
    and currentRoom.Data.Type == RoomType.ROOM_BOSS then

        Isaac.DebugString(
            "[Room Cleaner] Already in the boss room."
        )

        return

    end

    local rooms = level:GetRooms()
    local bossRoomIndex = nil

    -- Search all generated rooms on this floor.
    for i = 0, rooms.Size - 1 do

        local roomDesc = rooms:Get(i)

        if roomDesc
        and roomDesc.Data
        and roomDesc.Data.Type == RoomType.ROOM_BOSS then

            bossRoomIndex = roomDesc.SafeGridIndex
            break

        end

    end

    if bossRoomIndex == nil then

        Isaac.DebugString(
            "[Room Cleaner] No boss room found on this floor."
        )

        return

    end

    Isaac.DebugString(
        "[Room Cleaner] Teleporting to boss room."
    )

    game:StartRoomTransition(
        bossRoomIndex,
        Direction.NO_DIRECTION,
        RoomTransitionAnim.FADE,
        player,
        -1
    )

end

--------------------------------------------------
-- CLEAN ROOM
--------------------------------------------------

function RoomCleaner:CleanRoom()

    self:CleanGrid()
    self:DestroyEnvironmentalEntities()

end

--------------------------------------------------
-- KILL ALL ENEMIES - C KEY
--------------------------------------------------

function RoomCleaner:KillAllEnemies()

    local killed = 0

    for _, entity in ipairs(Isaac.GetRoomEntities()) do

        if entity:IsActiveEnemy() then

            entity:Kill()

            killed = killed + 1

        end

    end

    Isaac.DebugString(
        "[Room Cleaner] Enemies killed: "
        .. killed
    )

end

--------------------------------------------------
-- ROOM ENTRY
--------------------------------------------------

RoomCleaner.CleanupPending = false

function RoomCleaner:OnNewRoom()

    self:CleanGrid()

    self.CleanupPending = true

end

RoomCleaner:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    RoomCleaner.OnNewRoom
)

--------------------------------------------------
-- DEFERRED ENVIRONMENT CLEANUP
--------------------------------------------------

function RoomCleaner:OnPostUpdate()

    if self.CleanupPending then

        self.CleanupPending = false

        self:DestroyEnvironmentalEntities()

    end

    self:AttractPickups()

end

RoomCleaner:AddCallback(
    ModCallbacks.MC_POST_UPDATE,
    RoomCleaner.OnPostUpdate
)

--------------------------------------------------
-- KEYBOARD SHORTCUTS
--------------------------------------------------

function RoomCleaner:OnPostRender()

    -- C: Kill all enemies.
    if Input.IsButtonTriggered(Keyboard.KEY_C, -1) then

        self:KillAllEnemies()

    end

    -- Left Shift: Teleport to boss room.
    if Input.IsButtonTriggered(Keyboard.KEY_LEFT_SHIFT, -1) then

        self:TeleportToBossRoom()

    end

end

RoomCleaner:AddCallback(
    ModCallbacks.MC_POST_RENDER,
    RoomCleaner.OnPostRender
)

--==================================================
-- END OF ROOM CLEANER
--==================================================

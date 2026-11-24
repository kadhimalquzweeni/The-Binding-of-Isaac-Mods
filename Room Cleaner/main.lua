--==================================================
-- ROOM CLEANER
-- Automatically destroys supported environmental objects on room entry.
--==================================================

local RoomCleaner = RegisterMod("Room Cleaner", 1)
local game = Game()

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

function RoomCleaner:GetExplosionSource()
    return EntityRef(Isaac.GetPlayer(0))
end

function RoomCleaner:CleanGrid()
    local room = game:GetRoom()
    local destroyed = 0

    for index = 0, room:GetGridSize() - 1 do
        local grid = room:GetGridEntity(index)

        if grid then
            local gridType = grid:GetType()

            if DESTROY_TYPES[gridType] or gridType == GridEntityType.GRID_POOP then
                if room:DestroyGrid(index, false) then
                    destroyed = destroyed + 1
                end
            end
        end
    end

    Isaac.DebugString("[Room Cleaner] Grid objects destroyed: " .. destroyed)
end

function RoomCleaner:DestroyEnvironmentalEntities()
    local source = self:GetExplosionSource()
    local destroyedFireplaces = 0
    local destroyedShopkeepers = 0

    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity.Type == EntityType.ENTITY_FIREPLACE then
            entity:TakeDamage(1000, DamageFlag.DAMAGE_EXPLOSION, source, 0)
            destroyedFireplaces = destroyedFireplaces + 1
        elseif entity.Type == EntityType.ENTITY_SHOPKEEPER then
            entity:TakeDamage(1000, DamageFlag.DAMAGE_EXPLOSION, source, 0)
            destroyedShopkeepers = destroyedShopkeepers + 1
        end
    end

    Isaac.DebugString(
        "[Room Cleaner] Fireplaces hit: "
        .. destroyedFireplaces
        .. " | Shopkeepers hit: "
        .. destroyedShopkeepers
    )
end

RoomCleaner.CleanupPending = false

function RoomCleaner:OnNewRoom()
    self:CleanGrid()
    self.CleanupPending = true
end

RoomCleaner:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, RoomCleaner.OnNewRoom)

function RoomCleaner:OnPostUpdate()
    if self.CleanupPending then
        self.CleanupPending = false
        self:DestroyEnvironmentalEntities()
    end
end

RoomCleaner:AddCallback(ModCallbacks.MC_POST_UPDATE, RoomCleaner.OnPostUpdate)

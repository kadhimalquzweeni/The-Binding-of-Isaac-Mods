--==================================================
-- BOSS ROOM TELEPORT
-- Press Left Shift to teleport to the boss room.
--==================================================

local BossRoomTeleport = RegisterMod("Boss Room Teleport", 1)

local game = Game()

function BossRoomTeleport:TeleportToBossRoom()
    local level = game:GetLevel()
    local player = Isaac.GetPlayer(0)

    if not player or player:IsDead() then
        return
    end

    local currentRoom = level:GetCurrentRoomDesc()

    if currentRoom
    and currentRoom.Data
    and currentRoom.Data.Type == RoomType.ROOM_BOSS then
        Isaac.DebugString("[Boss Room Teleport] Already in the boss room.")
        return
    end

    local rooms = level:GetRooms()
    local bossRoomIndex = nil

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
        Isaac.DebugString("[Boss Room Teleport] No boss room found on this floor.")
        return
    end

    Isaac.DebugString("[Boss Room Teleport] Teleporting to boss room.")

    game:StartRoomTransition(
        bossRoomIndex,
        Direction.NO_DIRECTION,
        RoomTransitionAnim.FADE,
        player,
        -1
    )
end

function BossRoomTeleport:OnPostRender()
    if Input.IsButtonTriggered(Keyboard.KEY_LEFT_SHIFT, -1) then
        self:TeleportToBossRoom()
    end
end

BossRoomTeleport:AddCallback(ModCallbacks.MC_POST_RENDER, BossRoomTeleport.OnPostRender)

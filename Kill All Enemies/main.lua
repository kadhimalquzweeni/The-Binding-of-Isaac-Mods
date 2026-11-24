--==================================================
-- KILL ALL ENEMIES
-- Press C to kill all active enemies in the current room.
--==================================================

local KillAllEnemies = RegisterMod("Kill All Enemies", 1)

function KillAllEnemies:KillAll()
    local killed = 0

    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity:IsActiveEnemy() then
            entity:Kill()
            killed = killed + 1
        end
    end

    Isaac.DebugString("[Kill All Enemies] Enemies killed: " .. killed)
end

function KillAllEnemies:OnPostRender()
    if Input.IsButtonTriggered(Keyboard.KEY_C, -1) then
        self:KillAll()
    end
end

KillAllEnemies:AddCallback(ModCallbacks.MC_POST_RENDER, KillAllEnemies.OnPostRender)

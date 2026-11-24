
local Mod = RegisterMod("Unbreakable Donation Machines", 1)
local game = Game()

local function RefreshMachines(variant)
    local machines = Isaac.FindByType(6, variant, -1, false, true)

    if #machines == 0 then
        Isaac.DebugString(
            "[Unbreakable Donation Machines] No machine found for variant " .. variant
        )
        return
    end

    for i = 1, #machines do
        local machine = machines[i]

        Isaac.Spawn(
            6,
            machine.Variant,
            0,
            machine.Position,
            Vector(0, 0),
            nil
        )

        machine:Remove()
    end
end

function Mod:PostUpdate()
    -- Normal donation machine
    if game:GetStateFlag(
        GameStateFlag.STATE_DONATION_SLOT_JAMMED
    ) then
        Isaac.DebugString(
            "[Unbreakable Donation Machines] Normal donation machine jam detected"
        )

        game:SetStateFlag(
            GameStateFlag.STATE_DONATION_SLOT_JAMMED,
            false
        )

        RefreshMachines(8)
    end

    -- Greed donation machine
    if game:GetStateFlag(
        GameStateFlag.STATE_GREED_SLOT_JAMMED
    ) then
        Isaac.DebugString(
            "[Unbreakable Donation Machines] Greed donation machine jam detected"
        )

        game:SetStateFlag(
            GameStateFlag.STATE_GREED_SLOT_JAMMED,
            false
        )

        RefreshMachines(11)
    end
end

Mod:AddCallback(
    ModCallbacks.MC_POST_UPDATE,
    Mod.PostUpdate
)

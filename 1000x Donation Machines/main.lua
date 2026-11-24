local DonationMachinesMod = RegisterMod("1000x Donation Machines", 1)

local TARGET_DONATION_BALANCE = 999

local DONATION_COUNTERS = {
    {
        name = "Normal Donation Machine",
        counter = EventCounter.DONATION_MACHINE_COUNTER
    },
    {
        name = "Greed Donation Machine",
        counter = EventCounter.GREED_DONATION_MACHINE_COUNTER
    }
}

local function SetDonationMachineBalances()
    if not REPENTOGON then
        Isaac.ConsoleOutput(
            "[1000x Donation Machines] REPENTOGON is required; balances were not changed.\n"
        )
        return
    end

    local success, persistentGameData = pcall(function()
        return Isaac.GetPersistentGameData()
    end)

    if not success or persistentGameData == nil then
        Isaac.ConsoleOutput(
            "[1000x Donation Machines] Could not access persistent game data: "
                .. tostring(persistentGameData)
                .. "\n"
        )
        return
    end

    for _, entry in ipairs(DONATION_COUNTERS) do
        local readSuccess, currentBalance = pcall(function()
            return persistentGameData:GetEventCounter(entry.counter)
        end)

        if not readSuccess then
            Isaac.ConsoleOutput(
                "[1000x Donation Machines] Could not read "
                    .. entry.name
                    .. " balance: "
                    .. tostring(currentBalance)
                    .. "\n"
            )
        else
            local balanceChange = TARGET_DONATION_BALANCE - currentBalance

            if balanceChange ~= 0 then
                local updateSuccess, updateError = pcall(function()
                    persistentGameData:IncreaseEventCounter(
                        entry.counter,
                        balanceChange
                    )
                end)

                if not updateSuccess then
                    Isaac.ConsoleOutput(
                        "[1000x Donation Machines] Could not update "
                            .. entry.name
                            .. " balance: "
                            .. tostring(updateError)
                            .. "\n"
                    )
                end
            end

            local verifySuccess, updatedBalance = pcall(function()
                return persistentGameData:GetEventCounter(entry.counter)
            end)

            if verifySuccess then
                Isaac.ConsoleOutput(
                    "[1000x Donation Machines] "
                        .. entry.name
                        .. " balance: "
                        .. tostring(currentBalance)
                        .. " -> "
                        .. tostring(updatedBalance)
                        .. "\n"
                )
            else
                Isaac.ConsoleOutput(
                    "[1000x Donation Machines] Updated "
                        .. entry.name
                        .. " balance, but could not verify it: "
                        .. tostring(updatedBalance)
                        .. "\n"
                )
            end
        end
    end
end

DonationMachinesMod:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    SetDonationMachineBalances
)

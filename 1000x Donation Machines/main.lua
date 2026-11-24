local Mod = RegisterMod("1000x Donation Machines", 1)

local MULTIPLIER = 1000
local BONUS_PER_COIN = MULTIPLIER - 1

local game = Game()
local persistentData = nil
local lastCounters = {}
local hasReportedError = false

local TRACKED_COUNTERS = {
    {
        name = "Normal donation machine",
        counter = EventCounter.DONATION_MACHINE_COUNTER
    },
    {
        name = "Greed donation machine",
        counter = EventCounter.GREED_DONATION_MACHINE_COUNTER
    }
}

local function InitialiseCounters()
    if persistentData ~= nil then
        return
    end

    local success, result = pcall(function()
        return Isaac.GetPersistentGameData()
    end)

    if not success or result == nil then
        if not hasReportedError then
            Isaac.DebugString(
                "[1000x Donation Machines] Could not access persistent game data: "
                    .. tostring(result)
            )
            hasReportedError = true
        end
        return
    end

    persistentData = result

    for _, entry in ipairs(TRACKED_COUNTERS) do
        local counterSuccess, value = pcall(function()
            return persistentData:GetEventCounter(entry.counter)
        end)

        if counterSuccess then
            lastCounters[entry.counter] = value
            Isaac.DebugString(
                "[1000x Donation Machines] Tracking "
                    .. entry.name
                    .. " counter from "
                    .. tostring(value)
            )
        else
            Isaac.DebugString(
                "[1000x Donation Machines] Failed to read "
                    .. entry.name
                    .. " counter: "
                    .. tostring(value)
            )
        end
    end
end

local function ApplyMultiplier(entry)
    local previousValue = lastCounters[entry.counter]
    if previousValue == nil then
        return
    end

    local success, currentValue = pcall(function()
        return persistentData:GetEventCounter(entry.counter)
    end)

    if not success then
        if not hasReportedError then
            Isaac.DebugString(
                "[1000x Donation Machines] Failed to read "
                    .. entry.name
                    .. " counter: "
                    .. tostring(currentValue)
            )
            hasReportedError = true
        end
        return
    end

    if currentValue < previousValue then
        -- A reset or other counter decrease occurred. Re-baseline without
        -- applying a bonus to the reset.
        lastCounters[entry.counter] = currentValue
        return
    end

    local acceptedCoins = currentValue - previousValue
    if acceptedCoins <= 0 then
        return
    end

    local bonus = acceptedCoins * BONUS_PER_COIN

    local increaseSuccess, increaseError = pcall(function()
        persistentData:IncreaseEventCounter(entry.counter, bonus)
    end)

    if not increaseSuccess then
        -- Keep the last observed value unchanged so the bonus can be retried.
        if not hasReportedError then
            Isaac.DebugString(
                "[1000x Donation Machines] Failed to apply "
                    .. tostring(bonus)
                    .. " bonus points to "
                    .. entry.name
                    .. " counter: "
                    .. tostring(increaseError)
            )
            hasReportedError = true
        end
        return
    end

    local readBackSuccess, updatedValue = pcall(function()
        return persistentData:GetEventCounter(entry.counter)
    end)

    if readBackSuccess then
        lastCounters[entry.counter] = updatedValue
    else
        -- Avoid applying the same bonus twice if the read-back fails.
        lastCounters[entry.counter] = currentValue + bonus
    end

    Isaac.DebugString(
        "[1000x Donation Machines] "
            .. entry.name
            .. ": detected "
            .. tostring(acceptedCoins)
            .. " accepted coin(s); applied "
            .. tostring(bonus)
            .. " bonus point(s)"
    )
end

function Mod:PostUpdate()
    InitialiseCounters()

    if persistentData == nil then
        return
    end

    for _, entry in ipairs(TRACKED_COUNTERS) do
        ApplyMultiplier(entry)
    end
end

Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, Mod.PostUpdate)

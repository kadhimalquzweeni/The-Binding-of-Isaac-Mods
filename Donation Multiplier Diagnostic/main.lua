local Mod = RegisterMod("Donation Multiplier Diagnostic", 1)

local persistentData = nil
local previousNormalDonationCount = nil
local previousGreedDonationCount = nil

local function ReadCounter(counter)
    if not persistentData then
        return nil
    end

    local success, value = pcall(function()
        return persistentData:GetEventCounter(counter)
    end)

    if not success then
        Isaac.DebugString(
            "[Donation Multiplier Diagnostic] Failed to read event counter: "
                .. tostring(value)
        )
        return nil
    end

    return value
end

local function InitialiseCounters()
    if persistentData then
        return
    end

    -- PersistentGameData is accessed from a callback after the game has
    -- finished initialising, as required by REPENTOGON.
    local success, result = pcall(function()
        return Isaac.GetPersistentGameData()
    end)

    if not success or not result then
        Isaac.DebugString(
            "[Donation Multiplier Diagnostic] Could not access PersistentGameData: "
                .. tostring(result)
        )
        return
    end

    persistentData = result

    previousNormalDonationCount = ReadCounter(
        EventCounter.DONATION_MACHINE_COUNTER
    )

    previousGreedDonationCount = ReadCounter(
        EventCounter.GREED_DONATION_MACHINE_COUNTER
    )

    Isaac.DebugString(
        "[Donation Multiplier Diagnostic] Initial normal donation counter: "
            .. tostring(previousNormalDonationCount)
    )

    Isaac.DebugString(
        "[Donation Multiplier Diagnostic] Initial Greed donation counter: "
            .. tostring(previousGreedDonationCount)
    )
end

local function CheckCounter(label, counter, previousValue)
    local currentValue = ReadCounter(counter)

    if currentValue == nil then
        return previousValue
    end

    if previousValue == nil then
        return currentValue
    end

    if currentValue ~= previousValue then
        Isaac.DebugString(
            "[Donation Multiplier Diagnostic] "
                .. label
                .. " counter changed: "
                .. tostring(previousValue)
                .. " -> "
                .. tostring(currentValue)
                .. " (change: "
                .. tostring(currentValue - previousValue)
                .. ")"
        )
    end

    return currentValue
end

function Mod:PostUpdate()
    InitialiseCounters()

    if not persistentData then
        return
    end

    previousNormalDonationCount = CheckCounter(
        "Normal donation machine",
        EventCounter.DONATION_MACHINE_COUNTER,
        previousNormalDonationCount
    )

    previousGreedDonationCount = CheckCounter(
        "Greed donation machine",
        EventCounter.GREED_DONATION_MACHINE_COUNTER,
        previousGreedDonationCount
    )
end

Mod:AddCallback(
    ModCallbacks.MC_POST_UPDATE,
    Mod.PostUpdate
)

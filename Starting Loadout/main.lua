local mod = RegisterMod("Starting Loadout", 1)
local json = require("json")
local game = Game()
local itemConfig = Isaac.GetItemConfig()

local COLUMNS = 8
local ROWS = 4
local ITEMS_PER_PAGE = COLUMNS * ROWS

local GRID_START_X = 128
local GRID_START_Y = 112
local GRID_SPACING_X = 48
local GRID_SPACING_Y = 43
local ICON_SCALE = 0.65

local menuOpen = false
local dataLoaded = false
local itemList = {}
local selectedIndex = 1
local currentPage = 1

mod.state = {
    selectedItems = {}
}

local function BuildItemList()
    itemList = {}

    for itemID = 1, CollectibleType.NUM_COLLECTIBLES - 1 do
        local item = itemConfig:GetCollectible(itemID)

        if item and item.Name and item.Name ~= "" then
            table.insert(itemList, {
                id = itemID,
                name = item.Name
            })
        end
    end
end

local function LoadSavedSelection()
    if dataLoaded then
        return
    end

    dataLoaded = true

    if not mod:HasData() then
        return
    end

    local success, savedData = pcall(function()
        return json.decode(mod:LoadData())
    end)

    if not success or type(savedData) ~= "table" then
        Isaac.DebugString("[Starting Loadout] Could not load saved selection.")
        return
    end

    local savedItems = savedData.selectedItems
    if type(savedItems) ~= "table" then
        return
    end

    mod.state.selectedItems = {}

    for _, itemID in ipairs(savedItems) do
        itemID = tonumber(itemID)
        if itemID and itemConfig:GetCollectible(itemID) then
            mod.state.selectedItems[itemID] = true
        end
    end
end

local function SaveSelection()
    local selectedItems = {}

    for itemID, isSelected in pairs(mod.state.selectedItems) do
        if isSelected then
            table.insert(selectedItems, tonumber(itemID))
        end
    end

    table.sort(selectedItems)

    local success, encoded = pcall(function()
        return json.encode({
            selectedItems = selectedItems
        })
    end)

    if success and encoded then
        mod:SaveData(encoded)
    else
        Isaac.DebugString("[Starting Loadout] Could not save selection.")
    end
end

local function GetSelectedCount()
    local count = 0

    for _, isSelected in pairs(mod.state.selectedItems) do
        if isSelected then
            count = count + 1
        end
    end

    return count
end

local function GetCurrentItem()
    return itemList[selectedIndex]
end

local function ToggleCurrentItem()
    local item = GetCurrentItem()
    if not item then
        return
    end

    if mod.state.selectedItems[item.id] then
        mod.state.selectedItems[item.id] = nil
    else
        mod.state.selectedItems[item.id] = true
    end

    SaveSelection()
end

local function MoveSelection(offset)
    if #itemList == 0 then
        return
    end

    selectedIndex = math.max(1, math.min(#itemList, selectedIndex + offset))
    currentPage = math.floor((selectedIndex - 1) / ITEMS_PER_PAGE) + 1
end

local function ChangePage(offset)
    local pageCount = math.max(1, math.ceil(#itemList / ITEMS_PER_PAGE))
    currentPage = math.max(1, math.min(pageCount, currentPage + offset))
    selectedIndex = math.min(
        #itemList,
        ((currentPage - 1) * ITEMS_PER_PAGE) + 1
    )
end

local function HandleMenuInput()
    if Input.IsButtonTriggered(Keyboard.KEY_I, 0) then
        menuOpen = not menuOpen
        if menuOpen then
            LoadSavedSelection()
            if #itemList == 0 then
                BuildItemList()
            end
        end
        return
    end

    if not menuOpen then
        return
    end

    if Input.IsButtonTriggered(Keyboard.KEY_ESCAPE, 0)
        or Input.IsButtonTriggered(Keyboard.KEY_ENTER, 0) then
        menuOpen = false
        return
    end

    if Input.IsButtonTriggered(Keyboard.KEY_LEFT, 0) then
        MoveSelection(-1)
    elseif Input.IsButtonTriggered(Keyboard.KEY_RIGHT, 0) then
        MoveSelection(1)
    elseif Input.IsButtonTriggered(Keyboard.KEY_UP, 0) then
        MoveSelection(-COLUMNS)
    elseif Input.IsButtonTriggered(Keyboard.KEY_DOWN, 0) then
        MoveSelection(COLUMNS)
    elseif Input.IsButtonTriggered(Keyboard.KEY_PAGEUP, 0) then
        ChangePage(-1)
    elseif Input.IsButtonTriggered(Keyboard.KEY_PAGEDOWN, 0) then
        ChangePage(1)
    elseif Input.IsButtonTriggered(Keyboard.KEY_SPACE, 0) then
        ToggleCurrentItem()
    end
end

local function RenderMenu()
    if not menuOpen then
        return
    end

    if #itemList == 0 then
        BuildItemList()
    end

    local pageCount = math.max(1, math.ceil(#itemList / ITEMS_PER_PAGE))
    local firstItemIndex = ((currentPage - 1) * ITEMS_PER_PAGE) + 1
    local lastItemIndex = math.min(#itemList, firstItemIndex + ITEMS_PER_PAGE - 1)

    Isaac.RenderText("STARTING LOADOUT", 222, 48, 1, 1, 1, 1)
    Isaac.RenderText(
        "Selected: " .. tostring(GetSelectedCount()),
        48,
        72,
        1,
        1,
        1,
        1
    )
    Isaac.RenderText(
        "Page " .. tostring(currentPage) .. " / " .. tostring(pageCount),
        520,
        72,
        1,
        1,
        1,
        1
    )

    for itemIndex = firstItemIndex, lastItemIndex do
        local item = itemList[itemIndex]
        local pageIndex = itemIndex - firstItemIndex
        local column = pageIndex % COLUMNS
        local row = math.floor(pageIndex / COLUMNS)

        local x = GRID_START_X + (column * GRID_SPACING_X)
        local y = GRID_START_Y + (row * GRID_SPACING_Y)
        local isSelected = mod.state.selectedItems[item.id] == true
        local isHighlighted = itemIndex == selectedIndex

        local iconColor
        if isSelected then
            iconColor = Color(1, 1, 1, 1)
        else
            iconColor = Color(0.45, 0.45, 0.45, 1)
        end

        Isaac.RenderCollectionItem(
            item.id,
            Vector(x, y),
            Vector(ICON_SCALE, ICON_SCALE),
            iconColor
        )

        if isHighlighted then
            Isaac.RenderText(">", x - 17, y - 7, 1, 1, 0, 1)
        end

        if isSelected then
            Isaac.RenderText("*", x + 10, y + 8, 0.3, 1, 0.3, 1)
        end
    end

    local currentItem = GetCurrentItem()
    if currentItem then
        local status = mod.state.selectedItems[currentItem.id] and "SELECTED" or "NOT SELECTED"
        Isaac.RenderText(
            currentItem.name .. " - " .. status,
            48,
            300,
            1,
            1,
            1,
            1
        )
    end

    Isaac.RenderText(
        "Arrows: Browse   SPACE: Toggle   PAGE UP/DOWN: Change page   I / ENTER / ESC: Close",
        48,
        326,
        1,
        1,
        1,
        1
    )
end

local function GrantStartingItems(isContinued)
    LoadSavedSelection()

    if isContinued then
        return
    end

    local selectedIDs = {}

    for itemID, isSelected in pairs(mod.state.selectedItems) do
        if isSelected then
            table.insert(selectedIDs, tonumber(itemID))
        end
    end

    table.sort(selectedIDs)

    if #selectedIDs == 0 then
        return
    end

    for playerIndex = 0, game:GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(playerIndex)

        for _, itemID in ipairs(selectedIDs) do
            player:AddCollectible(itemID, 0, true)
        end
    end

    Isaac.DebugString(
        "[Starting Loadout] Granted "
            .. tostring(#selectedIDs)
            .. " selected collectible(s) to each player."
    )
end

mod:AddCallback(ModCallbacks.MC_POST_RENDER, RenderMenu)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, HandleMenuInput)
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, GrantStartingItems)

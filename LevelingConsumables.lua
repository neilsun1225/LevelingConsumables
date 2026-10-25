-- SPDX-License-Identifier: MIT
-- Copyright (c) 2026 Ballyh (B站八厉害)

local ADDON_NAME = ...

local CATEGORY_ORDER = { "food", "drink", "heal", "mana" }
local MACRO_NAMES = {
    food = "LCF",
    drink = "LCD",
    heal = "LCH",
    mana = "LCM",
}
local LEGACY_MACRO_NAMES = {
    food = "LC_Food",
    drink = "LC_Drink",
    heal = "LC_Heal",
    mana = "LC_Mana",
}
local DEFAULT_POTIONS = {
    heal = { [118] = true, [858] = true, [929] = true, [1710] = true, [3928] = true, [13446] = true },
    mana = { [2455] = true, [3385] = true, [3827] = true, [6149] = true, [13443] = true, [13444] = true },
}
local DEFAULT_FOOD_DRINK = {
    food = { [4537] = true, [4592] = true }, -- 泰拉比姆香蕉、长嘴泥鳅
    drink = { [1179] = true, [1205] = true }, -- 冰镇牛奶、果汁
}
local LABELS = { food = "食物", drink = "饮料", heal = "治疗药水", mana = "法力药水" }
local MARKER = "#LevelingConsumables:"
local selected = {}
local warned = {}
local scheduled = false
local pending = false
local scanTooltip

local function Say(message)
    print("|cff49b3b3[" .. ADDON_NAME .. "]|r " .. message)
end

local function DB()
    LevelingConsumablesDB = LevelingConsumablesDB or {}
    LevelingConsumablesDB.extra = LevelingConsumablesDB.extra or {}
    for _, category in ipairs(CATEGORY_ORDER) do
        LevelingConsumablesDB.extra[category] = LevelingConsumablesDB.extra[category] or {}
    end
    return LevelingConsumablesDB.extra
end

local function RestorationInText(text)
    text = (text or ""):lower()
    local restores = text:find("恢复", 1, true) or text:find("恢復", 1, true)
        or text:find("回复", 1, true) or text:find("回復", 1, true)
        or text:find("restore", 1, true) or text:find("regenerat", 1, true)
    local seated = text:find("坐", 1, true) or text:find("seated", 1, true)
        or text:find("sitting", 1, true)
    return restores and (text:find("生命", 1, true) or text:find("health", 1, true)),
        restores and (text:find("法力", 1, true) or text:find("mana", 1, true)), seated
end

local function TooltipText(bag, slot)
    local texts = {}
    if C_TooltipInfo and C_TooltipInfo.GetBagItem then
        local ok, data = pcall(C_TooltipInfo.GetBagItem, bag, slot)
        if ok and data and data.lines then
            for _, line in ipairs(data.lines) do
                texts[#texts + 1] = line.leftText or ""
                texts[#texts + 1] = line.rightText or ""
            end
        end
    end
    if not scanTooltip then
        scanTooltip = CreateFrame("GameTooltip", "LevelingConsumablesScanTooltip", UIParent, "GameTooltipTemplate")
    end
    scanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
    scanTooltip:ClearLines()
    if pcall(scanTooltip.SetBagItem, scanTooltip, bag, slot) then
        for index = 1, scanTooltip:NumLines() do
            local left = _G["LevelingConsumablesScanTooltipTextLeft" .. index]
            local right = _G["LevelingConsumablesScanTooltipTextRight" .. index]
            texts[#texts + 1] = left and left:GetText() or ""
            texts[#texts + 1] = right and right:GetText() or ""
        end
    end
    scanTooltip:Hide()
    return table.concat(texts, " ")
end

local function HasFoodBuff(text)
    text = text:lower():gsub("%s+", " ")
    -- Exclude a food's eating-buff clause without ranking its attributes.
    return text:find("如果", 1, true) or text:find("if you spend", 1, true)
        or text:find("if you eat", 1, true) or text:find("well fed", 1, true)
        or text:find("充分进食", 1, true) or text:find("进食充分", 1, true)
end

local function ItemLevel(itemID)
    local _, _, _, level, requiredLevel = C_Item.GetItemInfo(itemID)
    if not level then
        C_Item.RequestLoadItemDataByID(itemID)
        return nil
    end
    return level, requiredLevel or 0
end

local function Better(candidate, previous)
    if not previous then return true end
    if candidate.requiredLevel ~= previous.requiredLevel then
        return candidate.requiredLevel < previous.requiredLevel
    end
    if candidate.itemLevel ~= previous.itemLevel then
        return candidate.itemLevel < previous.itemLevel
    end
    if candidate.count ~= previous.count then
        return candidate.count < previous.count
    end
    return candidate.itemID < previous.itemID
end

local function ScanBags()
    local best = {}
    local extra = DB()
    local playerLevel = UnitLevel("player")
    local slots, counts = {}, {}
    for bag = 0, 4 do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info and info.itemID and info.stackCount > 0 then
                slots[#slots + 1] = { bag = bag, slot = slot, itemID = info.itemID }
                counts[info.itemID] = (counts[info.itemID] or 0) + info.stackCount
            end
        end
    end
    for _, entry in ipairs(slots) do
        local bag, slot, itemID = entry.bag, entry.slot, entry.itemID
        local itemLevel, requiredLevel = ItemLevel(itemID)
        if itemLevel and requiredLevel <= playerLevel then
            local categories = {}
            for _, category in ipairs(CATEGORY_ORDER) do
                if extra[category][itemID] then categories[category] = true end
            end
            if DEFAULT_POTIONS.heal[itemID] then categories.heal = true end
            if DEFAULT_POTIONS.mana[itemID] then categories.mana = true end
            if DEFAULT_FOOD_DRINK.food[itemID] then categories.food = true end
            if DEFAULT_FOOD_DRINK.drink[itemID] then categories.drink = true end

            local _, _, _, _, _, classID, subclassID = C_Item.GetItemInfoInstant(itemID)
            local isFoodDrink = classID == 0 and (subclassID == 5 or subclassID == 0)
            if isFoodDrink or categories.food or categories.drink then
                local tooltipText = TooltipText(bag, slot)
                local restoresHealth, restoresMana, seated = RestorationInText(tooltipText)
                if isFoodDrink and (subclassID == 5 or seated) then
                    if restoresHealth then categories.food = true end
                    if restoresMana then categories.drink = true end
                end
                if HasFoodBuff(tooltipText) then
                    categories.food = nil
                    categories.drink = nil
                elseif not tooltipText:match("%S") then
                    -- Unknown food effects must not bypass the exclusion via a manual entry.
                    if not DEFAULT_FOOD_DRINK.food[itemID] then categories.food = nil end
                    if not DEFAULT_FOOD_DRINK.drink[itemID] then categories.drink = nil end
                end
            end

            local candidate = {
                itemID = itemID,
                itemLevel = itemLevel,
                requiredLevel = requiredLevel,
                count = counts[itemID],
            }
            for category in pairs(categories) do
                if Better(candidate, best[category]) then best[category] = candidate end
            end
        end
    end
    return best
end

local function MacroBody(category, itemID)
    if itemID then
        return "#showtooltip item:" .. itemID .. "\n/use item:" .. itemID .. "\n" .. MARKER .. category
    end
    return "#showtooltip\n" .. MARKER .. category
end

local function IsManagedMacro(body, category)
    if type(body) ~= "string" then return false end
    if body == MacroBody(category) then return true end
    local shown, used = body:match("^#showtooltip item:(%d+)\n/use item:(%d+)\n" .. MARKER .. category .. "$")
    return shown ~= nil and shown == used
end

local function FindAccountMacro(name)
    local accountMacros = GetNumMacros()
    for index = 1, accountMacros do
        local macroName, _, body = GetMacroInfo(index)
        if macroName == name then return index, body end
    end
end

local function ForEachMacro(callback)
    local accountMacros, characterMacros = GetNumMacros()
    local characterBase = MAX_ACCOUNT_MACROS or 120
    -- Descending order also permits deleting obsolete macros without skipping entries.
    for index = characterBase + characterMacros, characterBase + 1, -1 do callback(index) end
    for index = accountMacros, 1, -1 do callback(index) end
end

local function DisableLegacyMacros(category)
    local legacyName, body = LEGACY_MACRO_NAMES[category], MacroBody(category)
    local found = false
    ForEachMacro(function(index)
        local name, _, oldBody = GetMacroInfo(index)
        if name == legacyName and IsManagedMacro(oldBody, category) then
            if oldBody ~= body then EditMacro(index, nil, nil, body) end
            found = true
        end
    end)
    if found and not warned[legacyName] then
        Say("旧宏 " .. legacyName .. " 已停用；请改用通用宏 " .. MACRO_NAMES[category]
            .. "。如新宏不存在，请先处理同名冲突或宏栏已满，再 /lc refresh。")
        warned[legacyName] = true
    end
end

local function UpdateMacro(category, itemID)
    local name = MACRO_NAMES[category]
    local index, oldBody = FindAccountMacro(name)
    local body = MacroBody(category, itemID)
    selected[category] = nil
    if index and not IsManagedMacro(oldBody, category) then
        if not warned[name] then Say("已有同名自定义宏 " .. name .. "，已跳过；请将它改名后 /lc refresh。") warned[name] = true end
        DisableLegacyMacros(category)
        return
    end

    if not index then
        local legacyIndex, legacyBody = FindAccountMacro(LEGACY_MACRO_NAMES[category])
        if legacyIndex and IsManagedMacro(legacyBody, category) then
            -- Use the game's rename path, preserving the macro instead of recreating it.
            -- A rename reorders indices: always find the short name again afterwards.
            pcall(EditMacro, legacyIndex, name, nil, body)
            index, oldBody = FindAccountMacro(name)
        end
    end
    DisableLegacyMacros(category)

    if not index then
        local ok, createdIndex = pcall(CreateMacro, name, "INV_Misc_QuestionMark", body, false)
        if not ok or not createdIndex or createdIndex == 0 then
            if not warned[name] then Say("无法创建账号通用宏 " .. name .. "；请检查通用宏栏是否已满。") warned[name] = true end
            return
        end
        index = createdIndex
        Say("已创建账号通用宏 " .. name .. "；请从宏界面的通用宏栏拖到技能栏。")
    else
        if oldBody ~= body then EditMacro(index, nil, nil, body) end
    end
    selected[category] = itemID
end

local function RemoveLegacyBuffMacros()
    ForEachMacro(function(index)
        local name, _, body = GetMacroInfo(index)
        if name == "LC_Buff" and IsManagedMacro(body, "buff") then DeleteMacro(index) end
    end)
end

local function Refresh()
    if InCombatLockdown() then pending = true return end
    pending = false
    RemoveLegacyBuffMacros()
    local best = ScanBags()
    for _, category in ipairs(CATEGORY_ORDER) do
        UpdateMacro(category, best[category] and best[category].itemID)
    end
end

local function RequestRefresh()
    if InCombatLockdown() then pending = true return end
    if scheduled then return end
    scheduled = true
    C_Timer.After(0.1, function()
        scheduled = false
        Refresh()
    end)
end

local function PrintStatus()
    for _, category in ipairs(CATEGORY_ORDER) do
        local itemID = selected[category]
        local name = itemID and (C_Item.GetItemInfo(itemID) or ("item:" .. itemID)) or "无"
        Say(MACRO_NAMES[category] .. "（" .. LABELS[category] .. "）: " .. name)
    end
    if pending then Say("背包在战斗中变化；脱离战斗后会更新图标。") end
end

local function PrintExtras()
    local extra = DB()
    for _, category in ipairs(CATEGORY_ORDER) do
        local ids = {}
        for itemID in pairs(extra[category]) do ids[#ids + 1] = itemID end
        table.sort(ids)
        Say(LABELS[category] .. "额外物品: " .. (#ids > 0 and table.concat(ids, ", ") or "无"))
    end
end

local function PrintHelp()
    Say("/lc status 查看当前选择；/lc refresh 刷新；/lc list 查看额外物品")
    Say("/lc add food|drink|heal|mana 物品ID（或物品链接）")
    Say("/lc remove food|drink|heal|mana 物品ID")
end

SLASH_LEVELINGCONSUMABLES1 = "/lc"
SLASH_LEVELINGCONSUMABLES2 = "/levelconsumables"
SlashCmdList.LEVELINGCONSUMABLES = function(message)
    local action, category, rest = message:match("^%s*(%S*)%s*(%S*)%s*(.-)%s*$")
    if action == "status" then PrintStatus() return end
    if action == "refresh" then RequestRefresh() return end
    if action == "list" then PrintExtras() return end
    if action ~= "add" and action ~= "remove" then PrintHelp() return end
    if not MACRO_NAMES[category] then PrintHelp() return end

    local itemID = tonumber(rest:match("|Hitem:(%d+):") or rest:match("^item:(%d+)") or rest:match("^(%d+)$"))
    if not itemID or itemID < 1 then Say("请提供有效的物品ID或聊天物品链接。") return end
    local extra = DB()
    if action == "add" then
        if not C_Item.GetItemInfoInstant(itemID) then Say("当前客户端不认识这个物品ID。") return end
        extra[category][itemID] = true
        Say("已把 item:" .. itemID .. " 加入" .. LABELS[category] .. "列表。")
    else
        extra[category][itemID] = nil
        Say("已从" .. LABELS[category] .. "额外列表移除 item:" .. itemID .. "。")
    end
    RequestRefresh()
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("BAG_UPDATE_DELAYED")
events:RegisterEvent("PLAYER_LEVEL_UP")
events:RegisterEvent("GET_ITEM_INFO_RECEIVED")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then DB() end
    RequestRefresh()
end)

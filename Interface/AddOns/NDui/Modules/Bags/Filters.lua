local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Bags")

local LE_ITEM_QUALITY_POOR, LE_ITEM_QUALITY_COMMON, LE_ITEM_QUALITY_LEGENDARY = LE_ITEM_QUALITY_POOR, LE_ITEM_QUALITY_COMMON, LE_ITEM_QUALITY_LEGENDARY
local LE_ITEM_CLASS_GEM, LE_ITEM_GEM_ARTIFACTRELIC = LE_ITEM_CLASS_GEM, LE_ITEM_GEM_ARTIFACTRELIC
local LE_ITEM_CLASS_CONSUMABLE, LE_ITEM_CLASS_ITEM_ENHANCEMENT = LE_ITEM_CLASS_CONSUMABLE, LE_ITEM_CLASS_ITEM_ENHANCEMENT
local LE_ITEM_CLASS_MISCELLANEOUS, LE_ITEM_MISCELLANEOUS_MOUNT, LE_ITEM_MISCELLANEOUS_COMPANION_PET = LE_ITEM_CLASS_MISCELLANEOUS, LE_ITEM_MISCELLANEOUS_MOUNT, LE_ITEM_MISCELLANEOUS_COMPANION_PET
local LE_ITEM_CLASS_WEAPON, LE_ITEM_CLASS_ARMOR, LE_ITEM_CLASS_TRADEGOODS = LE_ITEM_CLASS_WEAPON, LE_ITEM_CLASS_ARMOR, LE_ITEM_CLASS_TRADEGOODS
local C_ToyBox_GetToyInfo = C_ToyBox.GetToyInfo
local C_Item_IsAnimaItemByID = C_Item.IsAnimaItemByID
local C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItemByID = C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID

-- Custom filter
local CustomFilterList = {
	[37863] = false,	-- 酒吧传送器
	[187532] = false,	-- 魂焰凿石器 @TradeGoods
	[141333] = true,	-- 宁神圣典
	[141446] = true,	-- 宁神书卷
	[153646] = true,	-- 静心圣典
	[153647] = true,	-- 静心书卷
	[161053] = true,	-- 水手咸饼干
}

local function isCustomFilter(item)
	if not C.db["Bags"]["ItemFilter"] then return end
	return CustomFilterList[item.id]
end

-- Default filter
local function isItemInBag(item)
	return item.bagID >= 0 and item.bagID <= 4
end

local function isItemInBank(item)
	return item.bagID == -1 or item.bagID >= 5 and item.bagID <= 11
end

local function isItemJunk(item)
	if not C.db["Bags"]["ItemFilter"] then return end
	if not C.db["Bags"]["FilterJunk"] then return end
	return (item.quality == LE_ITEM_QUALITY_POOR or NDuiADB["CustomJunkList"][item.id]) and item.hasPrice and not module:IsPetTrashCurrency(item.id)
end

local function isItemEquipSet(item)
	if not C.db["Bags"]["ItemFilter"] then return end
	if not C.db["Bags"]["FilterEquipSet"] then return end
	return item.isInSet
end

local function isAzeriteArmor(item)
	if not C.db["Bags"]["ItemFilter"] then return end
	if not C.db["Bags"]["FilterAzerite"] then return end
	if not item.link then return end
	return C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItemByID(item.link)
end

local iLvlClassIDs = {
	[LE_ITEM_CLASS_GEM] = LE_ITEM_GEM_ARTIFACTRELIC,
	[LE_ITEM_CLASS_ARMOR] = 0,
	[LE_ITEM_CLASS_WEAPON] = 0,
}
function module:IsItemHasLevel(item)
	local index = iLvlClassIDs[item.classID]
	return index and (index == 0 or index == item.subClassID)
end

local function isItemEquipment(item)
	if not C.db["Bags"]["ItemFilter"] then return end
	if not C.db["Bags"]["FilterEquipment"] then return end
	return item.link and item.quality > LE_ITEM_QUALITY_COMMON and module:IsItemHasLevel(item)
end

local consumableIDs = {
	[LE_ITEM_CLASS_CONSUMABLE] = true,
	[LE_ITEM_CLASS_ITEM_ENHANCEMENT] = true,
}
local function isItemConsumable(item)
	if not C.db["Bags"]["ItemFilter"] then return end
	if not C.db["Bags"]["FilterConsumable"] then return end
	if isCustomFilter(item) == false then return end
	return isCustomFilter(item) or consumableIDs[item.classID]
end

local function isItemLegendary(item)
	if not C.db["Bags"]["ItemFilter"] then return end
	if not C.db["Bags"]["FilterLegendary"] then return end
	return item.quality == LE_ITEM_QUALITY_LEGENDARY
end

local isPetToy = {
	[174925] = true,
}
local collectionIDs = {
	[LE_ITEM_MISCELLANEOUS_MOUNT] = LE_ITEM_CLASS_MISCELLANEOUS,
	[LE_ITEM_MISCELLANEOUS_COMPANION_PET] = LE_ITEM_CLASS_MISCELLANEOUS,
}
local function isMountOrPet(item)
	return not isPetToy[item.id] and item.subClassID and collectionIDs[item.subClassID] == item.classID
end

local petTrashCurrenies = {
	[3300] = true,
	[3670] = true,
	[6150] = true,
	[11406] = true,
	[11944] = true,
	[25402] = true,
	[36812] = true,
	[62072] = true,
	[67410] = true,
}
function module:IsPetTrashCurrency(itemID)
	return C.db["Bags"]["PetTrash"] and petTrashCurrenies[itemID]
end

local function isItemCollection(item)
	if not C.db["Bags"]["ItemFilter"] then return end
	if not C.db["Bags"]["FilterCollection"] then return end
	return item.id and C_ToyBox_GetToyInfo(item.id) or isMountOrPet(item) or module:IsPetTrashCurrency(item.id)
end

local function isItemCustom(item, index)
	if not C.db["Bags"]["ItemFilter"] then return end
	if not C.db["Bags"]["FilterFavourite"] then return end
	local customIndex = item.id and C.db["Bags"]["CustomItems"][item.id]
	return customIndex and customIndex == index
end

local function isEmptySlot(item)
	if not C.db["Bags"]["GatherEmpty"] then return end
	return module.initComplete and not item.texture and module.BagsType[item.bagID] == 0
end

local function isTradeGoods(item)
	if not C.db["Bags"]["ItemFilter"] then return end
	if not C.db["Bags"]["FilterGoods"] then return end
	if isCustomFilter(item) == false then return end
	return item.classID == LE_ITEM_CLASS_TRADEGOODS
end

local function isQuestItem(item)
	if not C.db["Bags"]["ItemFilter"] then return end
	if not C.db["Bags"]["FilterQuest"] then return end
	return item.questID or item.isQuestItem
end

local function isAnimaItem(item)
	if not C.db["Bags"]["ItemFilter"] then return end
	if not C.db["Bags"]["FilterAnima"] then return end
	return item.id and C_Item_IsAnimaItemByID(item.id)
end

local relicSpellIDs = {
	[356931] = true,
	[356933] = true,
	[356934] = true,
	[356935] = true,
	[356936] = true,
	[356937] = true,
	[356938] = true,
	[356939] = true,
	[356940] = true,
}
local function isKorthiaRelicByID(itemID)
	local _, spellID = GetItemSpell(itemID)
	return spellID and relicSpellIDs[spellID]
end
local function isKorthiaRelic(item)
	if not C.db["Bags"]["ItemFilter"] then return end
	if not C.db["Bags"]["FilterRelic"] then return end
	return item.id and isKorthiaRelicByID(item.id)
end

function module:GetFilters()
	local filters = {}

	filters.onlyBags = function(item) return isItemInBag(item) and not isEmptySlot(item) end
	filters.bagAzeriteItem = function(item) return isItemInBag(item) and isAzeriteArmor(item) end
	filters.bagEquipment = function(item) return isItemInBag(item) and isItemEquipment(item) end
	filters.bagEquipSet = function(item) return isItemInBag(item) and isItemEquipSet(item) end
	filters.bagConsumable = function(item) return isItemInBag(item) and isItemConsumable(item) end
	filters.bagsJunk = function(item) return isItemInBag(item) and isItemJunk(item) end
	filters.onlyBank = function(item) return isItemInBank(item) and not isEmptySlot(item) end
	filters.bankAzeriteItem = function(item) return isItemInBank(item) and isAzeriteArmor(item) end
	filters.bankLegendary = function(item) return isItemInBank(item) and isItemLegendary(item) end
	filters.bankEquipment = function(item) return isItemInBank(item) and isItemEquipment(item) end
	filters.bankEquipSet = function(item) return isItemInBank(item) and isItemEquipSet(item) end
	filters.bankConsumable = function(item) return isItemInBank(item) and isItemConsumable(item) end
	filters.onlyReagent = function(item) return item.bagID == -3 and not isEmptySlot(item) end
	filters.bagCollection = function(item) return isItemInBag(item) and isItemCollection(item) end
	filters.bankCollection = function(item) return isItemInBank(item) and isItemCollection(item) end
	filters.bagGoods = function(item) return isItemInBag(item) and isTradeGoods(item) end
	filters.bankGoods = function(item) return isItemInBank(item) and isTradeGoods(item) end
	filters.bagQuest = function(item) return isItemInBag(item) and isQuestItem(item) end
	filters.bankQuest = function(item) return isItemInBank(item) and isQuestItem(item) end
	filters.bagAnima = function(item) return isItemInBag(item) and isAnimaItem(item) end
	filters.bankAnima = function(item) return isItemInBank(item) and isAnimaItem(item) end
	filters.bagRelic = function(item) return isItemInBag(item) and isKorthiaRelic(item) end

	for i = 1, 5 do
		filters["bagCustom"..i] = function(item) return isItemInBag(item) and isItemCustom(item, i) end
		filters["bankCustom"..i] = function(item) return isItemInBank(item) and isItemCustom(item, i) end
	end

	return filters
end
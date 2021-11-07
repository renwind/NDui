local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")
local M = B:GetModule("Mover")

local indexToValue = {
	[1] = "Bar1Size",
	[2] = "Bar1Font",
	[3] = "Bar1Num",
	[4] = "Bar1PerRow",

	[5] = "Bar2Size",
	[6] = "Bar2Font",
	[7] = "Bar2Num",
	[8] = "Bar2PerRow",

	[9] = "Bar3Size",
	[10] = "Bar3Font",
	[11] = "Bar3Num",
	[12] = "Bar3PerRow",

	[13] = "Bar4Size",
	[14] = "Bar4Font",
	[15] = "Bar4Num",
	[16] = "Bar4PerRow",

	[17] = "Bar5Size",
	[18] = "Bar5Font",
	[19] = "Bar5Num",
	[20] = "Bar5PerRow",

	[21] = "BarPetSize",
	[22] = "BarPetFont",
	[23] = "BarPetNum",
	[24] = "BarPetPerRow",
}

local moverValues = {
	[1] = "Bar1",
	[2] = "Bar2",
	[3] = "Bar3L",
	[4] = "Bar3R",
	[5] = "Bar4",
	[6] = "Bar5",
	[7] = "PetBar",
}

local abbrToAnchor = {
	["TL"] = "TOPLEFT",
	["T"] = "TOP",
	["TR"] = "TOPRIGHT",
	["L"] = "LEFT",
	["R"] = "RIGHT",
	["BL"] = "BOTTOMLEFT",
	["B"] = "BOTTOM",
	["BR"] = "BOTTOMRIGHT",
}

local anchorToAbbr = {}
for abbr, anchor in pairs(abbrToAnchor) do
	anchorToAbbr[anchor] = abbr
end

--/run gogo(_, "NAB:34:12:12:12:34:12:12:12:32:12:0:12:32:12:12:1:32:12:12:1:26:12:10:10:0B24:0B60:-271B26:271B26:-1BR336:-35BR336:0B100")
-- NAB:34:12:12:12:34:12:12:12:32:12:0:12:32:12:12:1:32:12:12:1:26:12:10:10
function Bar:ImportActionbarStyle(preset)
	if not preset then return end

	local values = {strsplit(":", preset)}
	if values[1] ~= "NAB" then return end

	local numValues = #values
	local maxOptions = numValues - 7

	for index = 2, maxOptions do
		local value = values[index]
		value = tonumber(value)
		C.db["Actionbar"][indexToValue[index-1]] = value
	end
	Bar:UpdateAllScale()

	for index = maxOptions+1, numValues do
		local value = values[index]
		local x, point, y = strmatch(values[index], "(-*%d+)(%a+)(-*%d+)")
		local moverIndex = index - maxOptions
		local mover = Bar.movers[moverIndex]
		if mover then
			x, y = tonumber(x), tonumber(y)
			point = abbrToAnchor[point]
			mover:ClearAllPoints()
			mover:SetPoint(point, "UIParent", point, x, y)
			C.db["Mover"][moverValues[moverIndex]] = {point, "UIParent", point, x, y}
		end
	end
end
gogo = Bar.ImportActionbarStyle

function Bar:ExportActionbarStyle()
	local styleStr = "NAB"
	for index, value in ipairs(indexToValue) do
		styleStr = styleStr..":"..C.db["Actionbar"][value]
	end

	for index, mover in ipairs(Bar.movers) do
		local x, y, point = M:CalculateMoverPoints(mover)
		styleStr = styleStr..":"..x..anchorToAbbr[point]..y
	end

	print(styleStr)
end
hehe = Bar.ExportActionbarStyle
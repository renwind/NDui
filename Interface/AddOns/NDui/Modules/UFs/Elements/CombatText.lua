local _, ns = ...
local B, C, L, DB = unpack(ns)

local oUF = ns.oUF
local UF = B:GetModule("UnitFrames")

local scrolls = {}
function UF:UpdateScrollingFont()
	local fontSize = C.db["UFs"]["FCTFontSize"]
	for _, scroll in pairs(scrolls) do
		scroll:SetFont(DB.Font[1], fontSize, "OUTLINE")
		scroll:SetSize(10*fontSize, 10*fontSize)
	end
end

function UF:CreateFCT(self)
	if not C.db["UFs"]["CombatText"] then return end

	local parentFrame = CreateFrame("Frame", nil, UIParent)
	local parentName = self:GetName()
	local fcf = CreateFrame("Frame", parentName.."CombatTextFrame", parentFrame)
	fcf:SetSize(32, 32)
	if self.mystyle == "player" then
		B.Mover(fcf, L["CombatText"], "PlayerCombatText", {"BOTTOM", self, "TOPLEFT", 0, 120})
	else
		B.Mover(fcf, L["CombatText"], "TargetCombatText", {"BOTTOM", self, "TOPRIGHT", 0, 120})
	end

	for i = 1, 36 do
		fcf[i] = parentFrame:CreateFontString("$parentText", "OVERLAY")
	end

	local scrolling = CreateFrame("ScrollingMessageFrame", parentName.."CombatTextScrollingFrame", parentFrame)
	scrolling:SetSpacing(3)
	scrolling:SetMaxLines(20)
	scrolling:SetFadeDuration(.2)
	scrolling:SetTimeVisible(3)
	scrolling:SetJustifyH("CENTER")
	scrolling:SetPoint("BOTTOM", fcf)
	fcf.Scrolling = scrolling
	tinsert(scrolls, scrolling)

	fcf.font = DB.Font[1]
	fcf.fontFlags = DB.Font[3]
	fcf.abbreviateNumbers = true
	self.FloatingCombatFeedback = fcf

	-- Default CombatText
	SetCVar("enableFloatingCombatText", 0)
	B.HideOption(InterfaceOptionsCombatPanelEnableFloatingCombatText)
end
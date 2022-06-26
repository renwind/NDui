local _, ns = ...
local B, C, L, DB = unpack(ns)

local oUF = ns.oUF
local UF = B:GetModule("UnitFrames")

function UF:CreateQuakeTimer(self)
	if not C.db["UFs"]["Castbars"] then return end

	local bar = CreateFrame("StatusBar", nil, self)
	bar:SetSize(C.db["UFs"]["PlayerCBWidth"], C.db["UFs"]["PlayerCBHeight"])
	B.CreateSB(bar, true, 0, 1, 0)
	bar:Hide()

	bar.SpellName = B.CreateFS(bar, 12, "", false, "LEFT", 2, 0)
	bar.Text = B.CreateFS(bar, 12, "", false, "RIGHT", -2, 0)
	createBarMover(bar, L["QuakeTimer"], "QuakeTimer", {"BOTTOM", UIParent, "BOTTOM", 0, 200})

	local icon = bar:CreateTexture(nil, "ARTWORK")
	icon:SetSize(bar:GetHeight(), bar:GetHeight())
	icon:SetPoint("RIGHT", bar, "LEFT", -3, 0)
	B.ReskinIcon(icon, true)
	bar.Icon = icon

	self.QuakeTimer = bar
end
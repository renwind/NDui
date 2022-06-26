local _, ns = ...
local B, C, L, DB = unpack(ns)
local UF = B:GetModule("UnitFrames")

function UF:CreatePrediction(self)
	local frame = CreateFrame("Frame", nil, self)
	frame:SetAllPoints()

	local mhpb = frame:CreateTexture(nil, "BORDER", nil, 5)
	mhpb:SetWidth(1)
	mhpb:SetTexture(DB.normTex)
	mhpb:SetVertexColor(0, 1, .5, .5)

	local ohpb = frame:CreateTexture(nil, "BORDER", nil, 5)
	ohpb:SetWidth(1)
	ohpb:SetTexture(DB.normTex)
	ohpb:SetVertexColor(0, 1, 0, .5)

	local abb = frame:CreateTexture(nil, "BORDER", nil, 5)
	abb:SetWidth(1)
	abb:SetTexture(DB.normTex)
	abb:SetVertexColor(.66, 1, 1, .7)

	local abbo = frame:CreateTexture(nil, "ARTWORK", nil, 1)
	abbo:SetAllPoints(abb)
	abbo:SetTexture("Interface\\RaidFrame\\Shield-Overlay", true, true)
	abbo.tileSize = 32

	local oag = frame:CreateTexture(nil, "ARTWORK", nil, 1)
	oag:SetWidth(15)
	oag:SetTexture("Interface\\RaidFrame\\Shield-Overshield")
	oag:SetBlendMode("ADD")
	oag:SetAlpha(.7)
	oag:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", -5, 2)
	oag:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMRIGHT", -5, -2)

	local hab = CreateFrame("StatusBar", nil, frame)
	hab:SetPoint("TOPLEFT", self.Health)
	hab:SetPoint("BOTTOMRIGHT", self.Health:GetStatusBarTexture())
	hab:SetReverseFill(true)
	hab:SetStatusBarTexture(DB.normTex)
	hab:SetStatusBarColor(0, .5, .8, .5)
	hab:SetFrameLevel(frame:GetFrameLevel())

	local ohg = frame:CreateTexture(nil, "ARTWORK", nil, 1)
	ohg:SetWidth(15)
	ohg:SetTexture("Interface\\RaidFrame\\Absorb-Overabsorb")
	ohg:SetBlendMode("ADD")
	ohg:SetAlpha(.5)
	ohg:SetPoint("TOPRIGHT", self.Health, "TOPLEFT", 5, 2)
	ohg:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMLEFT", 5, -2)

	self.HealPredictionAndAbsorb = {
		myBar = mhpb,
		otherBar = ohpb,
		absorbBar = abb,
		absorbBarOverlay = abbo,
		overAbsorbGlow = oag,
		healAbsorbBar = hab,
		overHealAbsorbGlow = ohg,
		maxOverflow = 1,
	}
	self.predicFrame = frame
end
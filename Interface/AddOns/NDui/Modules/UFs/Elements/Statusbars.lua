local _, ns = ...
local B, C, L, DB = unpack(ns)

local oUF = ns.oUF
local UF = B:GetModule("UnitFrames")

function UF.PostUpdateAltPower(element, _, cur, _, max)
	if cur and max then
		local perc = floor((cur/max)*100)
		if perc < 35 then
			element:SetStatusBarColor(0, 1, 0)
		elseif perc < 70 then
			element:SetStatusBarColor(1, 1, 0)
		else
			element:SetStatusBarColor(1, 0, 0)
		end
	end
end

function UF:CreateAltPower(self)
	local bar = CreateFrame("StatusBar", nil, self)
	bar:SetStatusBarTexture(DB.normTex)
	bar:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -3)
	bar:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, -3)
	bar:SetHeight(2)
	B.SetBD(bar, 0)

	local text = B.CreateFS(bar, 14, "")
	text:SetJustifyH("CENTER")
	self:Tag(text, "[altpower]")

	self.AlternativePower = bar
	self.AlternativePower.PostUpdate = UF.PostUpdateAltPower
end

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

function UF:ToggleSwingBars()
	local frame = _G.oUF_Player
	if not frame then return end

	if C.db["UFs"]["SwingBar"] then
		if not frame:IsElementEnabled("Swing") then
			frame:EnableElement("Swing")
		end
	elseif frame:IsElementEnabled("Swing") then
		frame:DisableElement("Swing")
	end
end

function UF:CreateSwing(self)
	local width, height = C.db["UFs"]["SwingWidth"], C.db["UFs"]["SwingHeight"]

	local bar = CreateFrame("Frame", nil, self)
	bar:SetSize(width, height)
	bar.mover = B.Mover(bar, L["UFs SwingBar"], "Swing", {"BOTTOM", UIParent, "BOTTOM", 0, 170})
	bar:ClearAllPoints()
	bar:SetPoint("CENTER", bar.mover)

	local two = CreateFrame("StatusBar", nil, bar)
	two:Hide()
	two:SetAllPoints()
	B.CreateSB(two, true, .8, .8, .8)

	local main = CreateFrame("StatusBar", nil, bar)
	main:Hide()
	main:SetAllPoints()
	B.CreateSB(main, true, .8, .8, .8)

	local off = CreateFrame("StatusBar", nil, bar)
	off:Hide()
	if C.db["UFs"]["OffOnTop"] then
		off:SetPoint("BOTTOMLEFT", bar, "TOPLEFT", 0, 3)
		off:SetPoint("BOTTOMRIGHT", bar, "TOPRIGHT", 0, 3)
	else
		off:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 0, -3)
		off:SetPoint("TOPRIGHT", bar, "BOTTOMRIGHT", 0, -3)
	end
	off:SetHeight(height)
	B.CreateSB(off, true, .8, .8, .8)

	bar.Text = B.CreateFS(bar, 12, "")
	bar.Text:SetShown(C.db["UFs"]["SwingTimer"])
	bar.TextMH = B.CreateFS(main, 12, "")
	bar.TextMH:SetShown(C.db["UFs"]["SwingTimer"])
	bar.TextOH = B.CreateFS(off, 12, "")
	bar.TextOH:SetShown(C.db["UFs"]["SwingTimer"])

	self.Swing = bar
	self.Swing.Twohand = two
	self.Swing.Mainhand = main
	self.Swing.Offhand = off
	self.Swing.hideOoc = true
end

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
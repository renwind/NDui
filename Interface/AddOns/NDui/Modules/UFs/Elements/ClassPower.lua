local _, ns = ...
local B, C, L, DB = unpack(ns)

local oUF = ns.oUF
local UF = B:GetModule("UnitFrames")

-- Class Powers
function UF.PostUpdateClassPower(element, cur, max, diff, powerType, chargedPowerPoints)
	if not cur or cur == 0 then
		for i = 1, 6 do
			element[i].bg:Hide()
		end

		element.prevColor = nil
	else
		for i = 1, max do
			element[i].bg:Show()
		end

		element.thisColor = cur == max and 1 or 2
		if not element.prevColor or element.prevColor ~= element.thisColor then
			local r, g, b = 1, 0, 0
			if element.thisColor == 2 then
				local color = element.__owner.colors.power[powerType]
				r, g, b = color[1], color[2], color[3]
			end
			for i = 1, #element do
				element[i]:SetStatusBarColor(r, g, b)
			end
			element.prevColor = element.thisColor
		end
	end

	if diff then
		for i = 1, max do
			element[i]:SetWidth((element.__owner.ClassPowerBar:GetWidth() - (max-1)*C.margin)/max)
		end
		for i = max + 1, 6 do
			element[i].bg:Hide()
		end
	end

	for i = 1, 6 do
		local bar = element[i]
		if not bar.chargeStar then break end

		bar.chargeStar:SetShown(chargedPowerPoints and tContains(chargedPowerPoints, i))
	end
end

function UF:OnUpdateRunes(elapsed)
	local duration = self.duration + elapsed
	self.duration = duration
	self:SetValue(duration)
	self.timer:SetText(nil)
	if C.db["UFs"]["RuneTimer"] then
		local remain = self.runeDuration - duration
		if remain > 0 then
			self.timer:SetText(B.FormatTime(remain))
		end
	end
end

function UF.PostUpdateRunes(element, runemap)
	for index, runeID in next, runemap do
		local rune = element[index]
		local start, duration, runeReady = GetRuneCooldown(runeID)
		if rune:IsShown() then
			if runeReady then
				rune:SetAlpha(1)
				rune:SetScript("OnUpdate", nil)
				rune.timer:SetText(nil)
			elseif start then
				rune:SetAlpha(.6)
				rune.runeDuration = duration
				rune:SetScript("OnUpdate", UF.OnUpdateRunes)
			end
		end
	end
end

function UF:CreateClassPower(self)
	local barWidth, barHeight = C.db["UFs"]["CPWidth"], C.db["UFs"]["CPHeight"]
	local barPoint = {"BOTTOMLEFT", self, "TOPLEFT", C.db["UFs"]["CPxOffset"], C.db["UFs"]["CPyOffset"]}
	if self.mystyle == "PlayerPlate" then
		barWidth, barHeight = C.db["Nameplate"]["PPWidth"], C.db["Nameplate"]["PPBarHeight"]
		barPoint = {"BOTTOMLEFT", self, "TOPLEFT", 0, C.margin}
	elseif self.mystyle == "targetplate" then
		barWidth, barHeight = C.db["Nameplate"]["PlateWidth"], C.db["Nameplate"]["PPBarHeight"]
		barPoint = {"CENTER", self}
	end

	local isDK = DB.MyClass == "DEATHKNIGHT"
	local bar = CreateFrame("Frame", "$parentClassPowerBar", self.Health)
	bar:SetSize(barWidth, barHeight)
	bar:SetPoint(unpack(barPoint))

	-- show bg while size changed
	if not isDK then
		bar.bg = B.SetBD(bar)
		bar.bg:SetFrameLevel(5)
		bar.bg:SetBackdropBorderColor(1, .8, 0)
		bar.bg:Hide()
	end

	local bars = {}
	for i = 1, 6 do
		bars[i] = CreateFrame("StatusBar", nil, bar)
		bars[i]:SetHeight(barHeight)
		bars[i]:SetWidth((barWidth - 5*C.margin) / 6)
		bars[i]:SetStatusBarTexture(DB.normTex)
		bars[i]:SetFrameLevel(self:GetFrameLevel() + 5)
		B.SetBD(bars[i], 0)
		if i == 1 then
			bars[i]:SetPoint("BOTTOMLEFT")
		else
			bars[i]:SetPoint("LEFT", bars[i-1], "RIGHT", C.margin, 0)
		end

		bars[i].bg = (isDK and bars[i] or bar):CreateTexture(nil, "BACKGROUND")
		bars[i].bg:SetAllPoints(bars[i])
		bars[i].bg:SetTexture(DB.normTex)
		bars[i].bg.multiplier = .25

		if isDK then
			bars[i].timer = B.CreateFS(bars[i], 13, "")
		elseif DB.MyClass == "ROGUE" then
			local chargeStar = bars[i]:CreateTexture()
			chargeStar:SetAtlas("VignetteKill")
			chargeStar:SetDesaturated(true)
			chargeStar:SetSize(22, 22)
			chargeStar:SetPoint("CENTER")
			chargeStar:Hide()
			bars[i].chargeStar = chargeStar
		end
	end

	if isDK then
		bars.colorSpec = true
		bars.sortOrder = "asc"
		bars.PostUpdate = UF.PostUpdateRunes
		bars.__max = 6
		self.Runes = bars
	else
		bars.PostUpdate = UF.PostUpdateClassPower
		self.ClassPower = bars
	end

	self.ClassPowerBar = bar
end

function UF:StaggerBar(self)
	if DB.MyClass ~= "MONK" then return end

	local barWidth, barHeight = C.db["UFs"]["CPWidth"], C.db["UFs"]["CPHeight"]
	local barPoint = {"BOTTOMLEFT", self, "TOPLEFT", C.db["UFs"]["CPxOffset"], C.db["UFs"]["CPyOffset"]}
	if self.mystyle == "PlayerPlate" then
		barWidth, barHeight = C.db["Nameplate"]["PPWidth"], C.db["Nameplate"]["PPBarHeight"]
		barPoint = {"BOTTOMLEFT", self, "TOPLEFT", 0, C.margin}
	end

	local stagger = CreateFrame("StatusBar", nil, self.Health)
	stagger:SetSize(barWidth, barHeight)
	stagger:SetPoint(unpack(barPoint))
	stagger:SetStatusBarTexture(DB.normTex)
	stagger:SetFrameLevel(self:GetFrameLevel() + 5)
	B.SetBD(stagger, 0)

	local bg = stagger:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture(DB.normTex)
	bg.multiplier = .25

	local text = B.CreateFS(stagger, 13)
	text:SetPoint("CENTER", stagger, "TOP")
	self:Tag(text, "[monkstagger]")

	self.Stagger = stagger
	self.Stagger.bg = bg
end

function UF:ToggleUFClassPower()
	local playerFrame = _G.oUF_Player
	if not playerFrame then return end

	if C.db["UFs"]["ClassPower"] then
		if playerFrame.ClassPower then
			if not playerFrame:IsElementEnabled("ClassPower") then
				playerFrame:EnableElement("ClassPower")
				playerFrame.ClassPower:ForceUpdate()
			end
		end
		if playerFrame.Runes then
			if not playerFrame:IsElementEnabled("Runes") then
				playerFrame:EnableElement("Runes")
				playerFrame.Runes:ForceUpdate()
			end
		end
		if playerFrame.Stagger then
			if not playerFrame:IsElementEnabled("Stagger") then
				playerFrame:EnableElement("Stagger")
				playerFrame.Stagger:ForceUpdate()
			end
		end
	else
		if playerFrame.ClassPower then
			if playerFrame:IsElementEnabled("ClassPower") then
				playerFrame:DisableElement("ClassPower")
			end
		end
		if playerFrame.Runes then
			if playerFrame:IsElementEnabled("Runes") then
				playerFrame:DisableElement("Runes")
			end
		end
		if playerFrame.Stagger then
			if playerFrame:IsElementEnabled("Stagger") then
				playerFrame:DisableElement("Stagger")
			end
		end
	end
end

function UF:UpdateUFClassPower()
	local playerFrame = _G.oUF_Player
	if not playerFrame then return end

	local barWidth, barHeight = C.db["UFs"]["CPWidth"], C.db["UFs"]["CPHeight"]
	local xOffset, yOffset = C.db["UFs"]["CPxOffset"], C.db["UFs"]["CPyOffset"]
	local bars = playerFrame.ClassPower or playerFrame.Runes
	if bars then
		local bar = playerFrame.ClassPowerBar
		bar:SetSize(barWidth, barHeight)
		bar:SetPoint("BOTTOMLEFT", playerFrame, "TOPLEFT", xOffset, yOffset)
		if bar.bg then bar.bg:Show() end
		local max = bars.__max
		for i = 1, max do
			bars[i]:SetHeight(barHeight)
			bars[i]:SetWidth((barWidth - (max-1)*C.margin) / max)
		end
	end

	if playerFrame.Stagger then
		playerFrame.Stagger:SetSize(barWidth, barHeight)
		playerFrame.Stagger:SetPoint("BOTTOMLEFT", playerFrame, "TOPLEFT", xOffset, yOffset)
	end
end

function UF.PostUpdateAddPower(element, cur, max)
	if element.Text and max > 0 then
		local perc = cur/max * 100
		if perc > 95 then
			perc = ""
			element:SetAlpha(0)
		else
			perc = format("%d%%", perc)
			element:SetAlpha(1)
		end
		element.Text:SetText(perc)
	end
end

function UF:CreateAddPower(self)
	local bar = CreateFrame("StatusBar", nil, self)
	bar:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -3)
	bar:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, -3)
	bar:SetHeight(4)
	bar:SetStatusBarTexture(DB.normTex)
	B.SetBD(bar, 0)
	bar.colorPower = true
	B:SmoothBar(bar)

	local bg = bar:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture(DB.normTex)
	bg.multiplier = .25
	local text = B.CreateFS(bar, 12, "", false, "CENTER", 1, -3)

	self.AdditionalPower = bar
	self.AdditionalPower.bg = bg
	self.AdditionalPower.Text = text
	self.AdditionalPower.PostUpdate = UF.PostUpdateAddPower
	self.AdditionalPower.displayPairs = {
		["DRUID"] = {
			[1] = true,
			[3] = true,
			[8] = true,
		},
		["SHAMAN"] = {
			[11] = true,
		},
		["PRIEST"] = {
			[13] = true,
		}
	}
end
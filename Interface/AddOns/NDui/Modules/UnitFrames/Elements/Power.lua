local _, ns = ...
local B, C, L, DB = unpack(ns)

local oUF = ns.oUF
local UF = B:GetModule("UnitFrames")

-- PowerBar
function UF:UpdatePowerColorByIndex(power, index)
	power.colorPower = (index == 2)
	power.colorClass = (index ~= 2)
	power.colorReaction = (index ~= 2)
	if power.SetColorTapping then
		power:SetColorTapping(index ~= 2)
	else
		power.colorTapping = (index ~= 2)
	end
	if power.SetColorDisconnected then
		power:SetColorDisconnected(index ~= 2)
	else
		power.colorDisconnected = (index ~= 2)
	end
end

function UF:UpdatePowerBarColor(self, force)
	local power = self.Power
	local mystyle = self.mystyle
	if mystyle == "PlayerPlate" then
		power.colorPower = true
	else
		UF:UpdatePowerColorByIndex(power, self.db.healtColorIndex)
	end
	--[=[elseif mystyle == "raid" then
		UF:UpdatePowerColorByIndex(power, C.db["UFs"]["RaidHealthColor"])
	else
		UF:UpdatePowerColorByIndex(power, C.db["UFs"]["HealthColor"])
	end]=]

	if force then
		power:ForceUpdate()
	end
end

--[=[local frequentUpdateCheck = {
	["player"] = true,
	["target"] = true,
	["focus"] = true,
	["PlayerPlate"] = true,
}]=]
function UF:CreatePowerBar(self)
	local mystyle = self.mystyle
	local power = CreateFrame("StatusBar", nil, self)
	power:SetStatusBarTexture(DB.normTex)
	power:SetPoint("BOTTOMLEFT", self)
	power:SetPoint("BOTTOMRIGHT", self)
	power:SetHeight(self.db.powerHeight)
	--[=[local powerHeight
	if mystyle == "PlayerPlate" then
		powerHeight = C.db["Nameplate"]["PPPowerHeight"]
	elseif mystyle == "raid" then
		if self.raidType == "party" then
			powerHeight = C.db["UFs"]["PartyPowerHeight"]
		elseif self.raidType == "pet" then
			powerHeight = C.db["UFs"]["PartyPetPowerHeight"]
		elseif self.raidType == "simple" then
			powerHeight = 2*C.db["UFs"]["SMRScale"]/10
		else
			powerHeight = C.db["UFs"]["RaidPowerHeight"]
		end
	else
		powerHeight = retVal(self, C.db["UFs"]["PlayerPowerHeight"], C.db["UFs"]["FocusPowerHeight"], C.db["UFs"]["BossPowerHeight"], C.db["UFs"]["PetPowerHeight"])
	end
	power:SetHeight(powerHeight)]=]
	power:SetFrameLevel(self:GetFrameLevel() - 2)
	power.backdrop = B.CreateBDFrame(power, 0)
	B:SmoothBar(power)

	if self.Health.shadow then
		self.Health.shadow:SetPoint("BOTTOMRIGHT", power.backdrop, C.mult+3, -C.mult-3)
	end

	local bg = power:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture(DB.normTex)
	bg.multiplier = .25

	self.textFrame = CreateFrame("Frame", nil, self)
	self.textFrame:SetAllPoints(self.Power)

	self.Power = power
	self.Power.bg = bg

	power.frequentUpdates = self.db.frequentUpdates
	UF:UpdatePowerBarColor(self)
end

-- PowerText
function UF:UpdateFramePowerTag()
	local valueType = UF.VariousTagIndex[self.db.powerTagIndex]
	--[=[if mystyle == "player" or mystyle == "target" then
		valueType = UF.VariousTagIndex[C.db["UFs"]["PlayerMPTag"]]
	elseif mystyle == "focus" then
		valueType = UF.VariousTagIndex[C.db["UFs"]["FocusMPTag"]]
	else
		valueType = UF.VariousTagIndex[C.db["UFs"]["BossMPTag"]]
	end]=]

	self:Tag(self.powerText, "[color][VariousMP("..valueType..")]")
	self.powerText:UpdateTag()
end

function UF:PowerText_Config(self)
	local ppval = self.powerText
	if not ppval then return end

	B.SetFontSize(ppval, self.db.powerTextSize)
	ppval:SetJustifyH(self.db.powerJustifyH)
	ppval:ClearAllPoints()
	ppval:SetPoint(self.db.powerTextAnchor, self.db.powerTextXOffset, self.db.powertextYOffset)
end

function UF:CreatePowerText(self)
	self.powerText = B.CreateFS(self.textFrame, self.db.powerTextSize)
	--[=[local mystyle = self.mystyle
	if mystyle == "raid" then
		ppval:SetScale(C.db["UFs"]["RaidTextScale"])
	elseif mystyle == "player" or mystyle == "target" then
		ppval:SetPoint("RIGHT", -3, C.db["UFs"]["PlayerPowerOffset"])
	elseif mystyle == "focus" then
		ppval:SetPoint("RIGHT", -3, C.db["UFs"]["FocusPowerOffset"])
	elseif mystyle == "boss" or mystyle == "arena" then
		ppval:SetPoint("RIGHT", -3, C.db["UFs"]["BossPowerOffset"])
	end]=]
	UF:PowerText_Config(self)
	UF.UpdateFramePowerTag(self)
end
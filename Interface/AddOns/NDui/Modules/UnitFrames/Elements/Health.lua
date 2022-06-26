local _, ns = ...
local B, C, L, DB = unpack(ns)

local oUF = ns.oUF
local UF = B:GetModule("UnitFrames")

-- HealthBar
function UF:UpdateHealthColorByIndex(health, index)
	health.colorClass = (index == 2)
	health.colorReaction = (index == 2)
	if health.SetColorTapping then
		health:SetColorTapping(index == 2)
	else
		health.colorTapping = (index == 2)
	end
	if health.SetColorDisconnected then
		health:SetColorDisconnected(index == 2)
	else
		health.colorDisconnected = (index == 2)
	end
	health.colorSmooth = (index == 3)
	if index == 1 then
		health:SetStatusBarColor(.1, .1, .1)
		health.bg:SetVertexColor(.6, .6, .6)
	end
end

function UF:UpdateHealthBarColor(self, force)
	local health = self.Health
	local mystyle = self.mystyle
	if mystyle == "PlayerPlate" then
		health.colorHealth = true
	else
		UF:UpdateHealthColorByIndex(health, self.db.healtColorIndex)
	end
--[=[	elseif mystyle == "raid" then
		UF:UpdateHealthColorByIndex(health, C.db["UFs"]["RaidHealthColor"])
	else
		UF:UpdateHealthColorByIndex(health, C.db["UFs"]["HealthColor"])
	end]=]

	if force then
		health:ForceUpdate()
	end
end

function UF:HealthBar_Config(self)
	local health = self.Health
	if not health then return end

	health:SetHeight(self.db.healthHeight)
	health:SetStatusBarColor(unpack(self.db.healthBgColor))
end

function UF:CreateHealthBar(self)
	local health = CreateFrame("StatusBar", nil, self)
	health:SetPoint("TOPLEFT", self)
	health:SetPoint("TOPRIGHT", self)
	health:SetHeight(self.db.healthHeight)
	health:SetStatusBarTexture(DB.normTex)
	health:SetStatusBarColor(.1, .1, .1)
	health:SetFrameLevel(self:GetFrameLevel() - 2)
	health.backdrop = B.SetBD(health, 0) -- don't mess up with libs
	health.shadow = health.backdrop.__shadow
	B:SmoothBar(health)

	local bg = health:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture(DB.bdTex)
	bg:SetVertexColor(.6, .6, .6)
	bg.multiplier = .25

	self.Health = health
	self.Health.bg = bg

	self.textFrame = CreateFrame("Frame", nil, self)
	self.textFrame:SetAllPoints(self.Health)

	UF:UpdateHealthBarColor(self)
end

-- NameText
function UF:UpdateFrameNameTag()
	local name = self.nameText
	if not name then return end

	local mystyle = self.mystyle
	if mystyle == "nameplate" then return end

	local value = mystyle == "raid" and "RCCName" or "CCName"
	local colorTag = C.db["UFs"][value] and "[color]" or ""

	if mystyle == "player" then
		self:Tag(name, " "..colorTag.."[name]")
	elseif mystyle == "target" then
		self:Tag(name, "[fulllevel] "..colorTag.."[name][afkdnd]")
	elseif mystyle == "focus" then
		self:Tag(name, colorTag.."[name][afkdnd]")
	elseif mystyle == "arena" then
		self:Tag(name, "[arenaspec] "..colorTag.."[name]")
	elseif self.raidType == "simple" and C.db["UFs"]["TeamIndex"] then
		self:Tag(name, "[group] "..colorTag.."[name]")
	else
		self:Tag(name, colorTag.."[name]")
	end
	name:UpdateTag()
end

function UF:UpdateRaidNameAnchor(name)
	if self.raidType == "pet" then
		name:ClearAllPoints()
		if C.db["UFs"]["RaidHPMode"] == 1 then
			name:SetWidth(self:GetWidth()*.95)
			name:SetJustifyH("CENTER")
			name:SetPoint("CENTER")
		else
			name:SetWidth(self:GetWidth()*.65)
			name:SetJustifyH("LEFT")
			name:SetPoint("LEFT", 3, -1)
		end
	elseif self.raidType == "simple" then
		if C.db["UFs"]["RaidHPMode"] == 1 then
			name:SetWidth(self:GetWidth()*.95)
		else
			name:SetWidth(self:GetWidth()*.65)
		end
	else
		name:ClearAllPoints()
		name:SetWidth(self:GetWidth()*.95)
		name:SetJustifyH("CENTER")
		if C.db["UFs"]["RaidHPMode"] == 1 then
			name:SetPoint("CENTER")
		else
			name:SetPoint("TOP", 0, -3)
		end
	end
end

function UF:CreateNameText(self)
	local mystyle = self.mystyle

	local name = B.CreateFS(self.textFrame, self.db.nameTextSize)
	name:SetJustifyH(self.db.nameJustifyH)
	if mystyle == "raid" then
		UF.UpdateRaidNameAnchor(self, name)
	elseif mystyle == "nameplate" then
		name:ClearAllPoints()
		name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, self.db.nameYOffset)
		name:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, self.db.nameYOffset)
		self:Tag(name, "[nplevel][name]")
	else
		name:ClearAllPoints()
		name:SetPoint(self.db.nameAnchor, self.db.nameXOffset, self.db.nameYOffset)
		name:SetWidth(self:GetWidth()*(self.db.nameYOffset == 0 and .55 or 1))
	end

	self.nameText = name
	UF.UpdateFrameNameTag(self)
end

-- HealthText
UF.VariousTagIndex = {
	[1] = "",
	[2] = "currentpercent",
	[3] = "currentmax",
	[4] = "current",
	[5] = "percent",
	[6] = "loss",
	[7] = "losspercent",
}

function UF:UpdateFrameHealthTag()
	local mystyle = self.mystyle
	local valueType = self.db.healthTag or UF.VariousTagIndex[self.db.healthTagIndex]
	--[=[if mystyle == "player" or mystyle == "target" then
		valueType = UF.VariousTagIndex[C.db["UFs"]["PlayerHPTag"]]
	elseif mystyle == "focus" then
		valueType = UF.VariousTagIndex[C.db["UFs"]["FocusHPTag"]]
	elseif mystyle == "boss" or mystyle == "arena" then
		valueType = UF.VariousTagIndex[C.db["UFs"]["BossHPTag"]]
	else
		valueType = UF.VariousTagIndex[C.db["UFs"]["PetHPTag"]]
	end]=]

	local showValue = C.db["UFs"]["PlayerAbsorb"] and mystyle == "player" and "[curAbsorb] " or ""
	self:Tag(self.healthText, showValue.."[VariousHP("..valueType..")]")
	self.healthText:UpdateTag()
end

function UF:HealthText_Config(self)
	local hpval = self.healthText
	if not hpval then return end

	B.SetFontSize(hpval, self.db.healthTextSize)
	hpval:SetJustifyH(self.db.healthJustifyH)
	hpval:ClearAllPoints()
	hpval:SetPoint(self.db.healthTextAnchor, self.db.healthTextXOffset, self.db.healthTextYOffset)
end

function UF:CreateHealthText(self)
	self.healthText = B.CreateFS(self.textFrame, self.db.hpTextSize)

	UF:HealthText_Config(self)
	UF.UpdateFrameHealthTag(self)
	--[=[if mystyle == "raid" then
		self:Tag(self.healthText, "[raidhp]")
	elseif mystyle == "nameplate" then
		self:Tag(self.healthText, "[VariousHP(currentpercent)]")
	else
		UF.UpdateFrameHealthTag(self)
	end]=]
end
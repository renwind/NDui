local _, ns = ...
local B, C, L, DB = unpack(ns)

local oUF = ns.oUF
local UF = B:GetModule("UnitFrames")

function UF.PostCreateIcon(element, button)
	local fontSize = element.fontSize or element.size*.6

	local parentFrame = CreateFrame("Frame", nil, button)
	parentFrame:SetAllPoints()
	parentFrame:SetFrameLevel(button:GetFrameLevel() + 3)
	button.count = B.CreateFS(parentFrame, fontSize, "", false, "BOTTOMRIGHT", 6, -3)
	button.cd:SetReverse(true)

	local needShadow = true
	if element.__owner.mystyle == "raid" and not C.db["UFs"]["RaidBuffIndicator"] then
		needShadow = false
	end
	button.iconbg = B.ReskinIcon(button.icon, needShadow)

	button.HL = button:CreateTexture(nil, "HIGHLIGHT")
	button.HL:SetColorTexture(1, 1, 1, .25)
	button.HL:SetAllPoints()

	button.overlay:SetTexture(nil)
	button.stealable:SetAtlas("bags-newitem")
	button:HookScript("OnMouseDown", AURA.RemoveSpellFromIgnoreList)

	if element.disableCooldown then button.timer = B.CreateFS(button, 12, "") end
end

UF.DesaturatedStyles = {
	["target"] = true,
	["nameplate"] = true,
	["boss"] = true,
	["arena"] = true,
}

UF.ReplacedAuraIcons = {
	[368078] = 348567, -- 移速
	[368079] = 348567, -- 移速
	[368103] = 648208, -- 急速
	[368243] = 237538, -- CD
}

UF.DispellableType = {
	[""] = true, -- enrage
	["Magic"] = true,
}

function UF.PostUpdateIcon(element, _, button, _, _, duration, expiration, debuffType)
	if duration then button.iconbg:Show() end

	local style = element.__owner.mystyle
	if style == "nameplate" then
		button:SetSize(element.size, element.size - 4)
	else
		button:SetSize(element.size, element.size)
	end

	local fontSize = element.fontSize or element.size*.6
	B.SetFontSize(button.count, fontSize)

	if element.desaturateDebuff and button.isDebuff and UF.DesaturatedStyles[style] and not button.isPlayer then
		button.icon:SetDesaturated(true)
	else
		button.icon:SetDesaturated(false)
	end

	if element.showDebuffType and button.isDebuff then
		local color = oUF.colors.debuff[debuffType] or oUF.colors.debuff.none
		button.iconbg:SetBackdropBorderColor(color[1], color[2], color[3])
	else
		button.iconbg:SetBackdropBorderColor(0, 0, 0)
	end

	if element.alwaysShowStealable and UF.DispellableType[debuffType] and not UnitIsPlayer(unit) and (not button.isDebuff) then
		button.stealable:Show()
	end

	if element.disableCooldown then
		if duration and duration > 0 then
			button.expiration = expiration
			button:SetScript("OnUpdate", B.CooldownOnUpdate)
			button.timer:Show()
		else
			button:SetScript("OnUpdate", nil)
			button.timer:Hide()
		end
	end

	local newTexture = UF.ReplacedAuraIcons[button.spellID]
	if newTexture then
		button.icon:SetTexture(newTexture)
	end
end

-- bolsterPreUpdate
function UF.Auras_PreUpdate(element)
	element.bolster = 0
	element.bolsterIndex = nil
	element.hasTheDot = nil
end

-- bolsterPostUpdate
function UF.Auras_PostUpdate(element)
	local button = element.bolsterIndex
	if button then
		button.count:SetText(element.bolster)
	end
end

function UF.PostUpdateGapIcon(_, _, icon)
	if icon.iconbg and icon.iconbg:IsShown() then
		icon.iconbg:Hide()
	end
end

local isCasterPlayer = {
	["player"] = true,
	["pet"] = true,
	["vehicle"] = true,
}
function UF.CustomFilter(element, unit, button, name, _, _, debuffType, _, _, caster, isStealable, _, spellID, _, _, _, nameplateShowAll)
	local style = element.__owner.mystyle

	if C.db["Nameplate"]["ColorByDot"] and style == "nameplate" and caster == "player" and C.db["Nameplate"]["DotSpells"][spellID] then
		element.hasTheDot = true
	end

	if name and spellID == 209859 then
		element.bolster = element.bolster + 1
		if not element.bolsterIndex then
			element.bolsterIndex = button
			return true
		end
	elseif style == "raid" then
		if C.RaidBuffs["ALL"][spellID] or NDuiADB["RaidAuraWatch"][spellID] then
			element.__owner.rawSpellID = spellID
			return true
		else
			element.__owner.rawSpellID = nil
		end
	elseif style == "nameplate" or style == "boss" or style == "arena" then
		if element.__owner.plateType == "NameOnly" then
			return UF.NameplateFilter[1][spellID]
		elseif UF.NameplateFilter[2][spellID] then
			return false
		elseif (element.showStealableBuffs and isStealable or element.alwaysShowStealable and dispellType[debuffType]) and not UnitIsPlayer(unit) and (not button.isDebuff) then
			return true
		elseif UF.NameplateFilter[1][spellID] then
			return true
		else
			local auraFilter = C.db["Nameplate"]["AuraFilter"]
			return (auraFilter == 3 and nameplateShowAll) or (auraFilter ~= 1 and isCasterPlayer[caster])
		end
	else
		return (element.onlyShowPlayer and button.isPlayer) or (not element.onlyShowPlayer and name)
	end
end

function UF.UnitCustomFilter(element, _, button, name, _, _, _, _, _, _, isStealable)
	local value = element.__value
	if button.isDebuff then
		if C.db["UFs"][value.."DebuffType"] == 2 then
			return name
		elseif C.db["UFs"][value.."DebuffType"] == 3 then
			return button.isPlayer
		end
	else
		if C.db["UFs"][value.."BuffType"] == 2 then
			return name
		elseif C.db["UFs"][value.."BuffType"] == 3 then
			return isStealable
		end
	end
end

function UF.RaidBuffFilter(_, _, _, _, _, _, _, _, _, caster, _, _, spellID, canApplyAura, isBossAura)
	if isBossAura then
		return true
	else
		local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellID, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT")
		local isPlayerSpell = (caster == "player" or caster == "pet" or caster == "vehicle")
		if hasCustom then
			return showForMySpec or (alwaysShowMine and isPlayerSpell)
		else
			return isPlayerSpell and canApplyAura and not SpellIsSelfBuff(spellID)
		end
	end
end

local debuffBlackList = {
	[206151] = true,
	[296847] = true,
	[338906] = true,
}
function UF.RaidDebuffFilter(element, _, _, _, _, _, _, _, _, caster, _, _, spellID, _, isBossAura)
	local parent = element.__owner
	if debuffBlackList[spellID] then
		return false
	elseif (C.db["UFs"]["RaidBuffIndicator"] and UF.CornerSpells[spellID]) or parent.RaidDebuffs.spellID == spellID or parent.rawSpellID == spellID then
		return false
	elseif isBossAura or SpellIsPriorityAura(spellID) then
		return true
	else
		local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellID, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT")
		if hasCustom then
			return showForMySpec or (alwaysShowMine and (caster == "player" or caster == "pet" or caster == "vehicle"))
		else
			return true
		end
	end
end

local function auraIconSize(w, n, s)
	return (w-(n-1)*s)/n
end

function UF:UpdateAuraContainer(parent, element, maxAuras)
	local width = parent:GetWidth()
	local iconsPerRow = element.iconsPerRow
	local maxLines = iconsPerRow and B:Round(maxAuras/iconsPerRow) or 2
	element.size = iconsPerRow and auraIconSize(width, iconsPerRow, element.spacing) or element.size
	element:SetWidth(width)
	element:SetHeight((element.size + element.spacing) * maxLines)
end

function UF:ConfigureAuras(element)
	local value = element.__value
	element.numBuffs = C.db["UFs"][value.."BuffType"] ~= 1 and C.db["UFs"][value.."NumBuff"] or 0
	element.numDebuffs = C.db["UFs"][value.."DebuffType"] ~= 1 and C.db["UFs"][value.."NumDebuff"] or 0
	element.iconsPerRow = C.db["UFs"][value.."AurasPerRow"]
	element.showDebuffType = C.db["UFs"]["DebuffColor"]
	element.desaturateDebuff = C.db["UFs"]["Desaturate"]
end

function UF:RefreshUFAuras(frame)
	if not frame then return end
	local element = frame.Auras
	if not element then return end

	UF:ConfigureAuras(element)
	UF:UpdateAuraContainer(frame, element, element.numBuffs + element.numDebuffs)
	element:ForceUpdate()
end

function UF:ConfigureBuffAndDebuff(element, isDebuff)
	local value = element.__value
	local vType = isDebuff and "Debuff" or "Buff"
	element.num = C.db["UFs"][value..vType.."Type"] ~= 1 and C.db["UFs"][value.."Num"..vType] or 0
	element.iconsPerRow = C.db["UFs"][value..vType.."PerRow"]
	element.showDebuffType = C.db["UFs"]["DebuffColor"]
	element.desaturateDebuff = C.db["UFs"]["Desaturate"]
end

function UF:RefreshBuffAndDebuff(frame)
	if not frame then return end

	local element = frame.Buffs
	if element then
		UF:ConfigureBuffAndDebuff(element)
		UF:UpdateAuraContainer(frame, element, element.num)
		element:ForceUpdate()
	end

	local element = frame.Debuffs
	if element then
		UF:ConfigureBuffAndDebuff(element, true)
		UF:UpdateAuraContainer(frame, element, element.num)
		element:ForceUpdate()
	end
end

function UF:UpdateUFAuras()
	UF:RefreshUFAuras(_G.oUF_Player)
	UF:RefreshUFAuras(_G.oUF_Target)
	UF:RefreshUFAuras(_G.oUF_Focus)
	UF:RefreshUFAuras(_G.oUF_ToT)
	UF:RefreshUFAuras(_G.oUF_Pet)

	for i = 1, 5 do
		UF:RefreshBuffAndDebuff(_G["oUF_Boss"..i])
		UF:RefreshBuffAndDebuff(_G["oUF_Arena"..i])
	end
end

function UF:ToggleUFAuras(frame, enable)
	if not frame then return end
	if enable then
		if not frame:IsElementEnabled("Auras") then
			frame:EnableElement("Auras")
		end
	else
		if frame:IsElementEnabled("Auras") then
			frame:DisableElement("Auras")
			frame.Auras:ForceUpdate()
		end
	end
end

function UF:ToggleAllAuras()
	local enable = C.db["UFs"]["ShowAuras"]
	UF:ToggleUFAuras(_G.oUF_Player, enable)
	UF:ToggleUFAuras(_G.oUF_Target, enable)
	UF:ToggleUFAuras(_G.oUF_Focus, enable)
	UF:ToggleUFAuras(_G.oUF_ToT, enable)
end

function UF:CreateAuras(self)
	local mystyle = self.mystyle
	local bu = CreateFrame("Frame", nil, self)
	bu:SetFrameLevel(self:GetFrameLevel() + 2)
	bu.gap = true
	bu.initialAnchor = "TOPLEFT"
	bu["growth-y"] = "DOWN"
	bu.spacing = 3
	bu.tooltipAnchor = "ANCHOR_BOTTOMLEFT"
	if mystyle == "player" then
		bu.initialAnchor = "TOPRIGHT"
		bu["growth-x"] = "LEFT"
		bu:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, -10)
		bu.__value = "Player"
		UF:ConfigureAuras(bu)
		bu.CustomFilter = UF.UnitCustomFilter
	elseif mystyle == "target" then
		bu:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -10)
		bu.__value = "Target"
		UF:ConfigureAuras(bu)
		bu.CustomFilter = UF.UnitCustomFilter
	elseif mystyle == "tot" then
		bu:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -5)
		bu.__value = "ToT"
		UF:ConfigureAuras(bu)
		bu.CustomFilter = UF.UnitCustomFilter
	elseif mystyle == "pet" then
		bu.initialAnchor = "TOPRIGHT"
		bu["growth-x"] = "LEFT"
		bu:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, -5)
		bu.__value = "Pet"
		UF:ConfigureAuras(bu)
		bu.CustomFilter = UF.UnitCustomFilter
	elseif mystyle == "focus" then
		bu:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -10)
		bu.numTotal = 23
		bu.iconsPerRow = 8
		bu.__value = "Focus"
		UF:ConfigureAuras(bu)
		bu.CustomFilter = UF.UnitCustomFilter
	elseif mystyle == "raid" then
		bu.initialAnchor = "LEFT"
		bu:SetPoint("LEFT", self, 15, 0)
		bu.size = 18*C.db["UFs"]["SMRScale"]/10
		bu.numTotal = 1
		bu.disableCooldown = true
		bu.gap = false
		bu.disableMouse = true
		bu.showDebuffType = nil
		bu.CustomFilter = UF.CustomFilter
	elseif mystyle == "nameplate" then
		bu.initialAnchor = "BOTTOMLEFT"
		bu["growth-y"] = "UP"
		if C.db["Nameplate"]["TargetPower"] then
			bu:SetPoint("BOTTOMLEFT", self.nameText, "TOPLEFT", 0, 10 + C.db["Nameplate"]["PPBarHeight"])
		else
			bu:SetPoint("BOTTOMLEFT", self.nameText, "TOPLEFT", 0, 5)
		end
		bu.numTotal = C.db["Nameplate"]["maxAuras"]
		bu.size = C.db["Nameplate"]["AuraSize"]
		bu.showDebuffType = C.db["Nameplate"]["DebuffColor"]
		bu.desaturateDebuff = C.db["Nameplate"]["Desaturate"]
		bu.gap = false
		bu.disableMouse = true
		bu.CustomFilter = UF.CustomFilter
	end

	UF:UpdateAuraContainer(self, bu, bu.numTotal or bu.numBuffs + bu.numDebuffs)
	bu.showStealableBuffs = true
	bu.PostCreateIcon = UF.PostCreateIcon
	bu.PostUpdateIcon = UF.PostUpdateIcon
	bu.PostUpdateGapIcon = UF.PostUpdateGapIcon
	bu.PreUpdate = bolsterPreUpdate
	bu.PostUpdate = bolsterPostUpdate

	self.Auras = bu
end

function UF:CreateBuffs(self)
	local bu = CreateFrame("Frame", nil, self)
	bu:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 5)
	bu.initialAnchor = "BOTTOMLEFT"
	bu["growth-x"] = "RIGHT"
	bu["growth-y"] = "UP"
	bu.spacing = 3

	if self.mystyle == "raid" then
		bu.initialAnchor = "BOTTOMRIGHT"
		bu["growth-x"] = "LEFT"
		bu:ClearAllPoints()
		bu:SetPoint("BOTTOMRIGHT", self.Health, -C.mult, C.mult)
		bu.num = (self.raidType == "simple" or not C.db["UFs"]["ShowRaidBuff"]) and 0 or 3
		bu.size = C.db["UFs"]["RaidBuffSize"]
		bu.CustomFilter = UF.RaidBuffFilter
		bu.disableMouse = C.db["UFs"]["BuffClickThru"]
		bu.fontSize = C.db["UFs"]["RaidBuffSize"]-2
	else -- boss and arena
		bu.__value = "Boss"
		UF:ConfigureBuffAndDebuff(bu)
		bu.CustomFilter = UF.UnitCustomFilter
	end

	UF:UpdateAuraContainer(self, bu, bu.num)
	bu.showStealableBuffs = true
	bu.PostCreateIcon = UF.PostCreateIcon
	bu.PostUpdateIcon = UF.PostUpdateIcon

	self.Buffs = bu
end

function UF:CreateDebuffs(self)
	local mystyle = self.mystyle
	local bu = CreateFrame("Frame", nil, self)
	bu.spacing = 3
	bu.initialAnchor = "TOPRIGHT"
	bu["growth-x"] = "LEFT"
	bu["growth-y"] = "DOWN"
	bu.tooltipAnchor = "ANCHOR_BOTTOMLEFT"
	bu.showDebuffType = true
	if mystyle == "raid" then
		bu.initialAnchor = "BOTTOMLEFT"
		bu["growth-x"] = "RIGHT"
		bu:SetPoint("BOTTOMLEFT", self.Health, C.mult, C.mult)
		bu.num = (self.raidType == "simple" or not C.db["UFs"]["ShowRaidDebuff"]) and 0 or 3
		bu.size = C.db["UFs"]["RaidDebuffSize"]
		bu.CustomFilter = UF.RaidDebuffFilter
		bu.disableMouse = C.db["UFs"]["DebuffClickThru"]
		bu.fontSize = C.db["UFs"]["RaidDebuffSize"]-2
	else -- boss and arena
		bu:SetPoint("TOPRIGHT", self, "TOPLEFT", -5, 0)
		bu.__value = "Boss"
		UF:ConfigureBuffAndDebuff(bu, true)
		bu.CustomFilter = UF.UnitCustomFilter
	end

	UF:UpdateAuraContainer(self, bu, bu.num)
	bu.PostCreateIcon = UF.PostCreateIcon
	bu.PostUpdateIcon = UF.PostUpdateIcon

	self.Debuffs = bu
end

function UF:UpdateRaidAuras()
	for _, frame in pairs(oUF.objects) do
		if frame.mystyle == "raid" then
			local debuffs = frame.Debuffs
			if debuffs then
				debuffs.num = (frame.raidType == "simple" or not C.db["UFs"]["ShowRaidDebuff"]) and 0 or 3
				debuffs.size = C.db["UFs"]["RaidDebuffSize"]
				debuffs.fontSize = C.db["UFs"]["RaidDebuffSize"]-2
				debuffs.disableMouse = C.db["UFs"]["DebuffClickThru"]
				UF:UpdateAuraContainer(frame, debuffs, debuffs.num)
				debuffs:ForceUpdate()
			end

			local buffs = frame.Buffs
			if buffs then
				buffs.num = (frame.raidType == "simple" or not C.db["UFs"]["ShowRaidBuff"]) and 0 or 3
				buffs.size = C.db["UFs"]["RaidBuffSize"]
				buffs.fontSize = C.db["UFs"]["RaidBuffSize"]-2
				buffs.disableMouse = C.db["UFs"]["BuffClickThru"]
				UF:UpdateAuraContainer(frame, buffs, buffs.num)
				buffs:ForceUpdate()
			end
		end
	end
end

local function refreshAurasElements(self)
	local buffs = self.Buffs
	if buffs then buffs:ForceUpdate() end

	local debuffs = self.Debuffs
	if debuffs then debuffs:ForceUpdate() end
end

function UF:RefreshAurasByCombat(self)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", refreshAurasElements, true)
	self:RegisterEvent("PLAYER_REGEN_DISABLED", refreshAurasElements, true)
end
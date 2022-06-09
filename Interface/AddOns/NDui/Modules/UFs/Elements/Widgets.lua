local _, ns = ...
local B, C, L, DB = unpack(ns)

local oUF = ns.oUF
local UF = B:RegisterModule("UnitFrames")

-- Header
local UnitFrame_OnEnter = _G.UnitFrame_OnEnter
local UnitFrame_OnLeave = _G.UnitFrame_OnLeave

function UF:UnitFrame_OnEnter()
	if not self.disableTooltip then
		UnitFrame_OnEnter(self)
	end
	self.Highlight:Show()
end

function UF:UnitFrame_OnLeave()
	if not self.disableTooltip then
		UnitFrame_OnLeave(self)
	end
	self.Highlight:Hide()
end

function UF:CreateHeader(self, onKeyDown)
	local highlight = self:CreateTexture(nil, "OVERLAY")
	highlight:SetAllPoints()
	highlight:SetTexture("Interface\\PETBATTLES\\PetBattle-SelectedPetGlow")
	highlight:SetTexCoord(0, 1, .5, 1)
	highlight:SetVertexColor(.6, .6, .6)
	highlight:SetBlendMode("ADD")
	highlight:Hide()
	self.Highlight = highlight

	self:RegisterForClicks(onKeyDown and "AnyDown" or "AnyUp")
	self:HookScript("OnEnter", UF.UnitFrame_OnEnter)
	self:HookScript("OnLeave", UF.UnitFrame_OnLeave)
end

-- Portrait
function UF:Portrait_Config(self)
	local portrait = self.Portrait
	if not portrait then return end

	portrait:SetAlpha(self.db.portraitAlpha)
end

function UF:CreatePortrait(self)
	if not C.db["UFs"]["Portrait"] then return end

	local portrait = CreateFrame("PlayerModel", nil, self.Health)
	portrait:SetInside()
	portrait:SetAlpha(.2)
	self.Portrait = portrait

	local healthBg = self.Health and self.Health.bg
	if healthBg then
		healthBg:ClearAllPoints()
		healthBg:SetPoint("BOTTOMLEFT", self.Health:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
		healthBg:SetPoint("TOPRIGHT", self.Health)
		healthBg:SetParent(self)
	end
end

-- GroupRoleIndicator
function UF.GroupRole_PostUpdate(element, role)
	if element:IsShown() then
		B.ReskinSmallRole(element, role)
	end
end

function UF:GroupRole_Config(self)
	local icon = self.GroupRoleIndicator
	if not icon then return end

	icon:SetPoint(self.db.roleAnchor, self, self.db.roleXOffset, self.db.roleYOffset)
	icon:SetSize(self.db.roleSize, self.db.roleSize)
end

function UF:CreateGroupRole(self)
	local icon = self:CreateTexture(nil, "OVERLAY")
	icon:SetPoint("TOPRIGHT", self, 0, 8)
	icon:SetSize(15, 15)
	icon.PostUpdate = UF.GroupRole_PostUpdate

	self.GroupRoleIndicator = icon
end

-- LeaderIndicator, AssistantIndicator
function UF:LeaderIcon_Config(self)
	local leader = self.LeaderIndicator
	if not leader then return end

	leader:SetPoint(self.db.leaderAnchor, self, self.db.leaderXOffset, self.db.leaderYOffset)
	leader:SetSize(self.db.leaderSize, self.db.leaderSize)

	local assist = self.AssistantIndicator
	assist:SetPoint(self.db.leaderAnchor, self, self.db.leaderXOffset, self.db.leaderYOffset)
	assist:SetSize(self.db.leaderSize, self.db.leaderSize)
end

function UF:CreateLeaderIcon(self)
	local leader = self:CreateTexture(nil, "OVERLAY")
	leader:SetPoint("TOPLEFT", self, 0, 8)
	leader:SetSize(12, 12)
	self.LeaderIndicator = leader

	local assist = self:CreateTexture(nil, "OVERLAY")
	assist:SetPoint("TOPLEFT", self, 0, 8)
	assist:SetSize(12, 12)
	self.AssistantIndicator = assist
end

-- PhaseIndicator
function UF:PhaseIcon_Config(self)
	local phase = self.PhaseIndicator
	if not phase then return end

	phase:SetPoint(self.db.phaseAnchor, self.Health, self.db.phaseXOffset, self.db.phaseYOffset)
	phase:SetSize(self.db.phaseSize, self.db.phaseSize)
end

function UF:CreatePhaseIcon()
	local phase = CreateFrame("Frame", nil, self)
	phase:SetSize(24, 24)
	phase:SetPoint("CENTER", self.Health)
	phase:SetFrameLevel(5)
	phase:EnableMouse(true)
	local icon = phase:CreateTexture(nil, "OVERLAY")
	icon:SetAllPoints()
	phase.Icon = icon

	self.PhaseIndicator = phase
end

-- CombatIndicator
function UF:CombatIcon_Config(self)
	local combat = self.CombatIndicator
	if not combat then return end

	combat:SetPoint(self.db.combatAnchor, self.Health, self.db.combatXOffset, self.db.combatYOffset)
	combat:SetSize(self.db.combatSize, self.db.combatSize)
end

function UF:CreateCombatIcon(self)
	local combat = self:CreateTexture(nil, "OVERLAY")
	combat:SetPoint("BOTTOMLEFT", self)
	combat:SetSize(28, 28)
	combat:SetAtlas(DB.objectTex)
	self.CombatIndicator = combat
end

-- RestingIndicator
function UF:RestingIcon_Config(self)
	local rest = self.RestingIndicator
	if not rest then return end

	rest:SetPoint(self.db.restingAnchor, self, self.db.restingXOffset, self.db.restingYOffset)
	rest:SetSize(self.db.restingSize, self.db.restingSize)
end

function UF:CreateRestingIcon(self)
	local rest = self:CreateTexture(nil, "OVERLAY")
	rest:SetPoint("LEFT", self, -2, 4)
	rest:SetSize(18, 18)
	rest:SetTexture("Interface\\PLAYERFRAME\\DruidEclipse")
	rest:SetTexCoord(.445, .55, .648, .905)
	rest:SetVertexColor(.6, .8, 1)
	rest:SetAlpha(.7)
	self.RestingIndicator = rest
end

-- QuestIndicator
function UF:QuestIcon_Config(self)
	local quest = self.QuestIndicator
	if not quest then return end

	quest:SetPoint(self.db.questAnchor, self, self.db.questXOffset, self.db.questYOffset)
	quest:SetSize(self.db.questSize, self.db.questSize)
end

function UF:CreateQuestIcon(self)
	local quest = self:CreateTexture(nil, "OVERLAY")
	quest:SetPoint("TOPLEFT", self, 0, 8)
	quest:SetSize(16, 16)
	self.QuestIndicator = quest
end

-- RaidTargetIndicator
function UF:RaidTarget_Config(self)
	local raidTarget = self.RaidTargetIndicator
	if not raidTarget then return end

	raidTarget:SetPoint(self.db.raidTargetAnchor, self, self.db.raidTargetXOffset, self.db.raidTargetYOffset)
	raidTarget:SetSize(self.db.raidTargetSize, self.db.raidTargetSize)
end

function UF:CreateRaidTarget(self)
	local raidTarget = self:CreateTexture(nil, "OVERLAY")
	raidTarget:SetPoint("TOPLEFT", self, 0, 10)
	raidTarget:SetSize(12, 12)
	self.RaidTargetIndicator = raidTarget
end

-- PvPClassificationIndicator
function UF:PVPClassify_Config()
	local pvpClassify = self.PvPClassificationIndicator
	if not pvpClassify then return end

	pvpClassify:SetPoint(self.db.pvpClassifyAnchor, self, self.db.pvpClassifyXOffset, self.db.pvpClassifyYOffset)
	pvpClassify:SetSize(self.db.pvpClassifySize, self.db.pvpClassifySize)
end

function UF:CreatePVPClassify(self)
	local pvpClassify = self:CreateTexture(nil, "ARTWORK")
	pvpClassify:SetSize(30, 30)
	pvpClassify:SetPoint("LEFT", self, "RIGHT", 5, -2)

	self.PvPClassificationIndicator = pvpClassify
end

-- QuestSyncIndicator
function UF:QuestSync_Config(self)
	local sync = self.QuestSyncIndicator
	if not sync then return end

	sync:SetPoint(self.db.syncAnchor, self, self.db.syncXOffset, self.db.syncYOffset)
	sync:SetSize(self.db.syncSize, self.db.syncSize)
end

function UF:QuestSync_Update()
	self.QuestSyncIndicator:SetShown(C_QuestSession.HasJoined())
end

function UF:CreateQuestSync(self)
	local sync = self:CreateTexture(nil, "OVERLAY")
	sync:SetPoint("CENTER", self, "BOTTOMLEFT", 16, 0)
	sync:SetSize(28, 28)
	sync:SetAtlas("QuestSharing-DialogIcon")
	sync:Hide()

	self.QuestSyncIndicator = sync
	self:RegisterEvent("QUEST_SESSION_LEFT", UF.QuestSync_Update, true)
	self:RegisterEvent("QUEST_SESSION_JOINED", UF.QuestSync_Update, true)
	self:RegisterEvent("PLAYER_ENTERING_WORLD", UF.QuestSync_Update, true)
end

-- Demonic Gateway, no config atm
local GatewayTexs = {
	[59262] = 607512, -- green
	[59271] = 607513, -- purple
}
local function DGI_UpdateGlow()
	local frame = _G.oUF_Focus
	if not frame then return end

	local element = frame.DemonicGatewayIndicator
	if element:IsShown() and IsItemInRange(37727, "focus") then
		B.ShowOverlayGlow(element.glowFrame)
	else
		B.HideOverlayGlow(element.glowFrame)
	end
end

local function DGI_Visibility()
	local frame = _G.oUF_Focus
	if not frame then return end

	local element = frame.DemonicGatewayIndicator
	local guid = UnitGUID("focus")
	local npcID = guid and B.GetNPCID(guid)
	local isGate = npcID and GatewayTexs[npcID]

	element:SetTexture(isGate)
	element:SetShown(isGate)
	element.updater:SetShown(isGate)
	DGI_UpdateGlow()
end

local function DGI_OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > .1 then
		DGI_UpdateGlow()

		self.elapsed = 0
	end
end

function UF:DemonicGatewayIcon(self)
	local icon = self:CreateTexture(nil, "ARTWORK")
	icon:SetPoint("CENTER")
	icon:SetSize(22, 22)
	icon:SetTexture(607512) -- 607513 for purple
	icon:SetTexCoord(unpack(DB.TexCoord))
	icon.glowFrame = B.CreateGlowFrame(self, 22)

	local updater = CreateFrame("Frame")
	updater:SetScript("OnUpdate", DGI_OnUpdate)
	updater:Hide()

	self.DemonicGatewayIndicator = icon
	self.DemonicGatewayIndicator.updater = updater
	B:RegisterEvent("PLAYER_FOCUS_CHANGED", DGI_Visibility)
end

-- Experience and Reputation bar
function UF:CreateExpRepBar(self)
	local bar = CreateFrame("StatusBar", nil, self)
	bar:SetPoint("TOPLEFT", self, "TOPRIGHT", 5, 0)
	bar:SetPoint("BOTTOMRIGHT", self.Power, "BOTTOMRIGHT", 10, 0)
	bar:SetOrientation("VERTICAL")
	B.CreateSB(bar)

	local rest = CreateFrame("StatusBar", nil, bar)
	rest:SetAllPoints(bar)
	rest:SetStatusBarTexture(DB.normTex)
	rest:SetStatusBarColor(0, .4, 1, .6)
	rest:SetFrameLevel(bar:GetFrameLevel() - 1)
	rest:SetOrientation("VERTICAL")
	bar.restBar = rest

	B:GetModule("Misc"):SetupScript(bar)
end

-- TODO: move the mirrorbar and time tracker into SKINS
local function reskinTimerBar(bar)
	bar:SetSize(280, 15)
	B.StripTextures(bar)

	local statusbar = _G[bar:GetName().."StatusBar"]
	if statusbar then
		statusbar:SetAllPoints()
		statusbar:SetStatusBarTexture(DB.normTex)
	else
		bar:SetStatusBarTexture(DB.normTex)
	end

	B.SetBD(bar)
end

function UF:ReskinMirrorBars()
	local previous
	for i = 1, 3 do
		local bar = _G["MirrorTimer"..i]
		reskinTimerBar(bar)

		if previous then
			bar:SetPoint("TOP", previous, "BOTTOM", 0, -5)
		end
		previous = bar
	end
end

function UF:ReskinTimerTrakcer(self)
	local function updateTimerTracker()
		for _, timer in pairs(TimerTracker.timerList) do
			if timer.bar and not timer.bar.styled then
				reskinTimerBar(timer.bar)

				timer.bar.styled = true
			end
		end
	end
	self:RegisterEvent("START_TIMER", updateTimerTracker, true)
end
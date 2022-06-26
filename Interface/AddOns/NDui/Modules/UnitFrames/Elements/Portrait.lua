local _, ns = ...
local B, C, L, DB = unpack(ns)
local UF = B:GetModule("UnitFrames")

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
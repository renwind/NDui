local _, ns = ...
local B, C, L, DB = unpack(ns)

local oUF = ns.oUF
local UF = B:GetModule("UnitFrames")

function UF.AltPower_PostUpdate(element, _, cur, _, max)
	if cur and max then
		local perc = floor(cur/max)
		if perc < .35 then
			element:SetStatusBarColor(0, 1, 0)
		elseif perc < .7 then
			element:SetStatusBarColor(1, 1, 0)
		else
			element:SetStatusBarColor(1, 0, 0)
		end
	end
end

function UF:CreateAltPower(self)
	local bar = CreateFrame("StatusBar", nil, self)
	bar:SetStatusBarTexture(DB.normTex)
	bar:SetPoint("TOPLEFT", self, "TOPRIGHT", 5, 0)
	bar:SetPoint("BOTTOMLEFT", self.Power, "BOTTOMRIGHT", 5, 0)
	bar:SetOrientation("VERTICAL")
	bar:SetWidth(5)
	B.SetBD(bar, 0)

	local text = B.CreateFS(bar, 14)
	text:SetJustifyH("LEFT")
	text:ClearAllPoints()
	text:SetPoint("LEFT", bar, "RIGHT")
	self:Tag(text, "[altpower]")
	bar.text = text

	self.AlternativePower = bar
	self.AlternativePower.PostUpdate = UF.AltPower_PostUpdate
end

function UF:AltPower_Config(self)
	local bar = self.AlternativePower
	if not bar then return end

	local db = self.db.altpower
	bar:SetWidth(db.width)
	B.SetFontSize(bar.text, db.fontSize)
end
local _, ns = ...
local B, C, L, DB = unpack(ns)

-- Credit: ElvUI
local ipairs = ipairs
local UIWidgetSetLayoutDirection = Enum.UIWidgetSetLayoutDirection
local UIWidgetLayoutDirection = Enum.UIWidgetLayoutDirection

local function reskinWidgetBar(bar)
	if bar and bar.BGLeft and not bar.styled then
		bar.BGLeft:SetAlpha(0)
		bar.BGRight:SetAlpha(0)
		bar.BGCenter:SetAlpha(0)
		bar.BorderLeft:SetAlpha(0)
		bar.BorderRight:SetAlpha(0)
		bar.BorderCenter:SetAlpha(0)
		bar.Spark:SetAlpha(0)
		B.SetBD(bar)

		bar.styled = true
	end
end

function B:Widget_DefaultLayout(sortedWidgets)
	local widgetContainerFrame = self
	local horizontalRowContainer = nil
	local horizontalRowHeight = 0
	local horizontalRowWidth = 0
	local totalWidth = 0
	local totalHeight = 0

	widgetContainerFrame.horizontalRowContainerPool:ReleaseAll()

	for index, widgetFrame in ipairs(sortedWidgets) do
		widgetFrame:ClearAllPoints()
		reskinWidgetBar(widgetFrame.Bar)

		local widgetSetUsesVertical = widgetContainerFrame.widgetSetLayoutDirection == UIWidgetSetLayoutDirection.Vertical
		local widgetUsesVertical = widgetFrame.layoutDirection == UIWidgetLayoutDirection.Vertical

		local useOverlapLayout = widgetFrame.layoutDirection == UIWidgetLayoutDirection.Overlap
		local useVerticalLayout = widgetUsesVertical or (widgetFrame.layoutDirection == UIWidgetLayoutDirection.Default and widgetSetUsesVertical)

		if useOverlapLayout then
			local anchor = widgetContainerFrame[widgetSetUsesVertical and 'verticalAnchorPoint' or 'horizontalAnchorPoint']

			widgetFrame:SetPoint(anchor, index == 1 and widgetContainerFrame or sortedWidgets[index - 1], anchor, 0, 0)

			local width, height = widgetFrame:GetSize()
			if width > totalWidth then totalWidth = width end
			if height > totalHeight then totalHeight = height end

			widgetFrame:SetParent(widgetContainerFrame)
		elseif useVerticalLayout then
			if index == 1 then
				widgetFrame:SetPoint(widgetContainerFrame.verticalAnchorPoint, widgetContainerFrame)
			else
				local relative = horizontalRowContainer or sortedWidgets[index - 1]
				widgetFrame:SetPoint(widgetContainerFrame.verticalAnchorPoint, relative, widgetContainerFrame.verticalRelativePoint, 0, widgetContainerFrame.verticalAnchorYOffset)

				if horizontalRowContainer then
					horizontalRowContainer:SetSize(horizontalRowWidth, horizontalRowHeight)
					totalWidth = totalWidth + horizontalRowWidth
					totalHeight = totalHeight + horizontalRowHeight
					horizontalRowHeight, horizontalRowWidth = 0, 0
					horizontalRowContainer = nil
				end

				totalHeight = totalHeight + widgetContainerFrame.verticalAnchorYOffset
			end

			widgetFrame:SetParent(widgetContainerFrame)

			local width, height = widgetFrame:GetSize()
			if width > totalWidth then
				totalWidth = width
			end
			totalHeight = totalHeight + height
		else
			local forceNewRow = widgetFrame.layoutDirection == UIWidgetLayoutDirection.HorizontalForceNewRow
			local needNewRowContainer = not horizontalRowContainer or forceNewRow
			if needNewRowContainer then
				if horizontalRowContainer then
					horizontalRowContainer:SetSize(horizontalRowWidth, horizontalRowHeight)
					totalWidth = totalWidth + horizontalRowWidth
					totalHeight = totalHeight + horizontalRowHeight
					horizontalRowHeight = 0
					horizontalRowWidth = 0
				end

				local newHorizontalRowContainer = widgetContainerFrame.horizontalRowContainerPool:Acquire()
				newHorizontalRowContainer:Show()

				if index == 1 then
					newHorizontalRowContainer:SetPoint(widgetContainerFrame.verticalAnchorPoint, widgetContainerFrame, widgetContainerFrame.verticalAnchorPoint)
				else
					local relative = horizontalRowContainer or sortedWidgets[index - 1]
					newHorizontalRowContainer:SetPoint(widgetContainerFrame.verticalAnchorPoint, relative, widgetContainerFrame.verticalRelativePoint, 0, widgetContainerFrame.verticalAnchorYOffset)

					totalHeight = totalHeight + widgetContainerFrame.verticalAnchorYOffset
				end
				widgetFrame:SetPoint("TOPLEFT", newHorizontalRowContainer)
				widgetFrame:SetParent(newHorizontalRowContainer)

				horizontalRowWidth = horizontalRowWidth + widgetFrame:GetWidth()
				horizontalRowContainer = newHorizontalRowContainer
			else
				local relative = sortedWidgets[index - 1]
				widgetFrame:SetParent(horizontalRowContainer)
				widgetFrame:SetPoint(widgetContainerFrame.horizontalAnchorPoint, relative, widgetContainerFrame.horizontalRelativePoint, widgetContainerFrame.horizontalAnchorXOffset, 0)

				horizontalRowWidth = horizontalRowWidth + widgetFrame:GetWidth() + widgetContainerFrame.horizontalAnchorXOffset
			end

			local widgetHeight = widgetFrame:GetHeight()
			if widgetHeight > horizontalRowHeight then
				horizontalRowHeight = widgetHeight
			end
		end
	end

	if horizontalRowContainer then
		horizontalRowContainer:SetSize(horizontalRowWidth, horizontalRowHeight)
		totalWidth = totalWidth + horizontalRowWidth
		totalHeight = totalHeight + horizontalRowHeight
		horizontalRowHeight = 0
		horizontalRowWidth = 0
	end

	widgetContainerFrame:SetSize(totalWidth, totalHeight)
end
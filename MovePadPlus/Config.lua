--------------------------------------------------------------------------------
-- Copyright © 2021								|
-- All Rights Reserved.								|
-- 										|
-- Permission to use, copy, modify, and distribute this software in any way	|
-- is not granted without expressed written agreement. This copyright applies	|
-- to the all code, data and artwork related to this project and all associated	|
-- projects published by the author.						|
--										|
-- More information on copyright is available from sources on-line.		|
-- Use an actual factual one!							|
--------------------------------------------------------------------------------

local _, NS = ...

------------ Local Functions ----------------------------------------------------

local function CheckBox_Init(self)
	self:SetChecked(self.data[self.index])
end

local function SetToolTip(self, tip, anchor)
	local setAnchor = anchor or "ANCHOR_LEFT"
	if self and tip then
		GameTooltip:SetOwner(self, setAnchor)
		GameTooltip:SetText(tip)			
	else
		GameTooltip:Hide()
	end
end

local function CreateFontString(frame, name, font, text, layer, frompoint, topoint, xoffset, yoffset, justifyH, justifyY, size, red, green, blue, alpha)
	local x = xoffset or 0
	local y = yoffset or 0
	local s = size or 12
	local r = red or 1
	local g = green or 1
	local b = blue or 1
	local a = alpha or 1
	local f = frame:CreateFontString(name, layer)
	if type(font) == "string" then
		f:SetFont(font, s)
	else
		f:SetFontObject(font)
	end
	f:SetTextColor(r, g, b, a)
	f:SetText(text)
	f:SetJustifyH(justifyH or "LEFT")
--	f:SetJustifyV(justifyY or "CENTER")
	f:SetJustifyV(justifyY or "MIDDLE")
	f:ClearAllPoints()
	f:SetPoint(frompoint, frame, topoint, x, y)
	return f
end

local function CreateCheckBox(name, parent, label, data, index, tip, width, height)
 	local w = width or 24 
 	local h = heigh or 24
	local f = CreateFrame("CheckButton", name, parent, "UICheckButtonTemplate")
	f.data = data
	f.index = index
	f.tip = tip
	f:SetSize(w, h)	
	f.initfunc = CheckBox_Init
	f.initfunc(f)
	local FromPoint, ToPoint, xoffset = "LEFT", "RIGHT", 5
	f:SetScript("OnClick", function(self, button)
			local checked = self:GetChecked()
			self.data[index] = checked
			if self.updatefunc then -- Yes, this is needed
				self.updatefunc(self, data, index, button)
			end
			if self.clickextra then
				self.clickextra(self, checked)
			end
		end)
	f:SetScript("OnEnter", function(self)
			SetToolTip(self, self.tip)
		end)
	f:SetScript("OnLeave", function(self)
			SetToolTip()
		end)
	f:SetScript("OnDisable", function(self)
		self:SetAlpha(0.5)
	end)
	f:SetScript("OnEnable", function(self)
		self:SetAlpha(1)
	end)
	f.label = CreateFontString(f, name .. "Label", "Fonts\\ARIALN.ttf", label, "ARTWORK", FromPoint, ToPoint, xoffset, 1, "LEFT", "MIDDLE", 12, 1, 1, 1)
	return f
end

---------------------------Colour Picker Button--------------------------------------------
local function SetPickerColour(self, r, g, b)
	if self.LED then
		self.LED:SetVertexColor(r, g, b)
	else
		self:SetBackdropColor(r, g, b)
	end
end

local function ColourPicker_Init(self)
	local colour = self.Data[self.Index]
	if not colour then
		colour = {r=1, g=1, b=1}
	end
	SetPickerColour(self, colour.r, colour.g, colour.b)
end

local function ColourPicker_Cancelled(self)
	local colour = ColorPickerFrame.previousValues
	ColorPickerFrame.colourBox.Data[ColorPickerFrame.colourBox.Index] = colour
	SetPickerColour(ColorPickerFrame.colourBox, colour.r, colour.g, colour.b)
	if ColorPickerFrame.colourBox.PostUpdate then
		ColorPickerFrame.colourBox:PostUpdate()
	end
end

local function ColourPicker_Changed(self)
	local r, g, b = ColorPickerFrame:GetColorRGB()
	local colour = { r=r, g=g, b=b }
	ColorPickerFrame.colourBox.Data[ColorPickerFrame.colourBox.Index] = colour
	SetPickerColour(ColorPickerFrame.colourBox, colour.r, colour.g, colour.b)
	if ColorPickerFrame.colourBox.PostUpdate then
		ColorPickerFrame.colourBox:PostUpdate()
	end
end

local function ColourPicker_OnClick(self)
	local basecolour = self.Data[self.Index]
	local colour = {}
	colour.r = basecolour.r
	colour.g = basecolour.g
	colour.b = basecolour.b
	ColorPickerFrame.previousValues = colour
	ColorPickerFrame.colourBox = self
	if ColorPickerFrame.SetupColorPickerAndShow then  -- 10.2.5 fix ColorSelect widget moved from top level to "Frame".Content.ColorPicker
		local info = UIDropDownMenu_CreateInfo()
		info.r, info.g, info.b = colour.r, colour.g, colour.b
		info.swatchFunc = ColourPicker_Changed
		info.cancelFunc = ColourPicker_Cancelled
		ColorPickerFrame:SetupColorPickerAndShow(info)
		if ColorPickerFrame.Content then
			ColorPickerFrame.Content.ColorPicker:SetColorRGB(colour.r, colour.g, colour.b)
		else
			ColorPickerFrame:SetColorRGB(colour.r, colour.g, colour.b)
		end
	else
		ColorPickerFrame.cancelFunc = ColourPicker_Cancelled
--		ColorPickerFrame.opacityFunc = ColourPicker_Changed
		ColorPickerFrame.func = ColourPicker_Changed
		ColorPickerFrame:SetColorRGB(colour.r, colour.g, colour.b)
	end
	ColorPickerFrame:ClearAllPoints()
	if self:GetRight() < UIParent:GetWidth() / 2 then
		ColorPickerFrame:SetPoint("LEFT", self, "RIGHT", 10, 0)
	else
		ColorPickerFrame:SetPoint("RIGHT", self, "LEFT", -10, 0)
	end
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	ColorPickerFrame:Show()
end

local function SetColourPickerOnClick(self)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	self:SetScript("OnClick", function(self, button, down)
		if button == "RightButton" then
			if self.DefaultColor then
				SetPickerColour(self, self.DefaultColor.r, self.DefaultColor.g, self.DefaultColor.b)
				self.Data[self.Index].r = self.DefaultColor.r
				self.Data[self.Index].g = self.DefaultColor.g
				self.Data[self.Index].b = self.DefaultColor.b
				ColourPicker_Init(self)
				if self.PostUpdate then
					self:PostUpdate()
				end
			end
			return
		end
		ColourPicker_OnClick(self, button, down)
	end)
end

local function CreateColorPickerButton(name, parent, label, data, index, tip, width, height)
 	local w = width or 24 
 	local h = heigh or 24
	local f = CreateFrame("Button", "$parent"..name, parent, BackdropTemplateMixin and "BackdropTemplate")
	f:SetBackdrop({ bgFile="Interface/BUTTONS/WHITE8X8", edgeFile="Interface/Tooltips/UI-Tooltip-Border", tile=true, edgeSize=7, tileSize=7, insets = { left=2, right=2, top=2, bottom=2, }, })
	f:SetSize(w, h)
	local FromPoint, ToPoint, xoffset = "LEFT", "RIGHT", 5
	f.label = CreateFontString(f, name .. "Label", "Fonts\\ARIALN.ttf", label, "ARTWORK", FromPoint, ToPoint, xoffset, 1, "LEFT", "MIDDLE", 12, 1, 1, 1)
	f.Data = data
	f.Index = index
	f.tip = tip
	f:SetSize(w, h)	
	f.InitFunc = ColourPicker_Init
	f.Init = function(self, value)
		if value ~= nil then
			self.Data[self.Index] = value
		end
		self:InitFunc()
		if self.UpdateOnInit and self.PostUpdate then
			self:PostUpdate()
		end
	end
	f:Init()
--	f.initfunc(f)
	f:SetScript("OnEnter", function(self)
		SetToolTip(self, self.tip)
	end)
	f:SetScript("OnLeave", function(self)
		SetToolTip()
	end)
	f:SetScript("OnDisable", function(self)
		self:SetAlpha(0.5)
	end)
	f:SetScript("OnEnable", function(self)
		self:SetAlpha(1)
	end)
	SetColourPickerOnClick(f)
	return f
end
---------------------------Colour Picker Button--------------------------------------------

local function GetWidth(frame, currentwidth)
	local width = frame.label:GetWidth()
	if width > currentwidth then
		return width
	else
		return currentwidth
	end
end

---------------------------------------------------------------------------------

function NS:CreateConfig()
	local width = 0
	NS.configFrame = CreateFrame("Frame", "MovePadPlus_Config", MovePadFrame, BackdropTemplateMixin and "BackdropTemplate")
	NS.configFrame:Hide()
	NS.configFrame:SetWidth(165)
	NS.configFrame:SetHeight(280)
	local bg = { bgFile="Interface\\toolTips\\UI-toolTip-Background", edgeFile="Interface\\toolTips\\UI-toolTip-Border", tile="true", tileSize=16, edgeSize=16, insets={ left=5, right=5, top=5, bottom=5 } }
	NS.configFrame:SetBackdrop(bg)
	NS.configFrame:SetBackdropColor(.09, .09, .19, .7)
	NS.configFrame:SetBackdropBorderColor(1, 1, 1)
	NS.configFrame:SetPoint("TOP", MovePadFrame, "BOTTOM")
	NS.configFrame.C2M = CreateCheckBox("MovePadPlus_Config_C2M", NS.configFrame, NS.Texts.HideC2M, MovePadPlus.Buttons, "HideClick2Move", "", 30, 15)
	NS.configFrame.C2M.updatefunc = NS.SetShown
	NS.configFrame.C2M:SetPoint("TOPLEFT", NS.configFrame, "TOPLEFT", 5, -5)
	width = GetWidth(NS.configFrame.C2M, width)
	NS.configFrame.Rotate = CreateCheckBox("MovePadClick2Move_Config_Rotate", NS.configFrame, NS.Texts.HideRotate, MovePadPlus.Buttons, "HideRotate", "", 30, 15)
	NS.configFrame.Rotate.updatefunc = NS.SetShown
	NS.configFrame.Rotate:SetPoint("TOPLEFT", NS.configFrame.C2M, "BOTTOMLEFT", 0, -5)
	width = GetWidth(NS.configFrame.Rotate, width)
	NS.configFrame.HoldRotate = CreateCheckBox("MovePadPluse_Config_HoldRotate", NS.configFrame, NS.Texts.HideHoldRotate, MovePadPlus.Buttons, "HideHoldRotate", "", 30, 15)
	NS.configFrame.HoldRotate.updatefunc = NS.SetShown
	NS.configFrame.HoldRotate:SetPoint("TOPLEFT", NS.configFrame.Rotate, "BOTTOMLEFT", 0, -5)
	width = GetWidth(NS.configFrame.HoldRotate, width)
	NS.configFrame.SwapRotates = CreateCheckBox("MovePadPlus_Config_SwapRotates", NS.configFrame, NS.Texts.SwapRotates, MovePadPlus, "SwapRotates", "", 30, 15)
	NS.configFrame.SwapRotates.updatefunc = NS.AnchorRotateButtons
	NS.configFrame.SwapRotates:SetPoint("TOPLEFT", NS.configFrame.HoldRotate, "BOTTOMLEFT", 0, -5)
	width = GetWidth(NS.configFrame.SwapRotates, width)
	NS.configFrame.Tooltips = CreateCheckBox("MovePadPlus_Config_Tooltip", NS.configFrame, NS.Texts.HideTooltips, MovePadPlus, "HideTooltips", "", 30, 15)
	NS.configFrame.Tooltips:SetPoint("TOPLEFT", NS.configFrame.SwapRotates, "BOTTOMLEFT", 0, -5)
	width = GetWidth(NS.configFrame.Tooltips, width)
	NS.configFrame.Targeting = CreateCheckBox("MovePadPlus_Config_Targeting", NS.configFrame, NS.Texts.Targeting, MovePadPlus, "GroundTargeting", NS.Texts.TargetingTip, 30, 15)
	NS.configFrame.Targeting:SetPoint("TOPLEFT", NS.configFrame.Tooltips, "BOTTOMLEFT", 0, -5)
	width = GetWidth(NS.configFrame.Targeting, width)
	NS.configFrame.PositionList = NS:CreateDropList("MovePadPlus_Config_Position", NS.configFrame, NS.Texts.Position, NS.ButtonPos, #NS.ButtonPos, MovePadPlus, "Position", 80, 24, true, true) --, labelright, override, strata)
	NS.configFrame.PositionList:SetPoint("TOPLEFT", NS.configFrame.Targeting, "BOTTOMLEFT", 1, 0)
	NS.configFrame.PositionList.updatefunc = NS.AnchorRotateButtons
	NS.configFrame.PositionList:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, setAnchor)
			GameTooltip:SetText(NS.Texts.PositionTip)
		end)
	NS.configFrame.PositionList:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)


	local _, _, _, x = NS.configFrame.C2M:GetPoint(1)
	local _, _, _, x2 = NS.configFrame.C2M.label:GetPoint(1)
	NS.configFrame:SetWidth(51 + width)
	MovePadLock:Show()
	MovePadLock:SetParent(NS.configFrame)
	MovePadLock:ClearAllPoints()
	MovePadLock:SetPoint("TOPRIGHT", NS.configFrame, "TOPRIGHT")


	local function CursorShown(self)
		NS.CursorShown()
		local parent = self:GetParent()
		NS.configFrame.MLCursorAnimate:SetEnabled(MovePadPlus.Cursor.show)
		NS.configFrame.MLCursorColor:SetEnabled(MovePadPlus.Cursor.show)
	end
	
	NS.configFrame.Separator = NS.configFrame:CreateLine()
	NS.configFrame.Separator:SetThickness(1)
	NS.configFrame.Separator:SetColorTexture(0.5, 0.5, 0.3)
	NS.configFrame.Separator:SetStartPoint("BOTTOMLEFT", NS.configFrame, 15, 78)
	NS.configFrame.Separator:SetEndPoint("BOTTOMRIGHT", NS.configFrame, -15, 78)
	
	NS.configFrame.MLCursorColor = CreateColorPickerButton("MovePadPlusMouseLookCursor_Color", NS.configFrame, NS.Texts.MLCursorColor, MovePadPlus.Cursor, "color")
	NS.configFrame.MLCursorColor.PostUpdate = function(self)
		NS.MouseLookCursor:SetCursorColor()
	end
	NS.configFrame.MLCursorColor:SetPoint("BOTTOMLEFT", NS.configFrame, "BOTTOMLEFT", 10, 8)

	NS.configFrame.MLCursorAnimate = CreateCheckBox("MovePadPlusMouseLookCursor_Animate", NS.configFrame, NS.Texts.MLCursorAnimate, MovePadPlus.Cursor, "animate", "", 30, 15)
--	NS.configFrame.MLCursorAnimate.updatefunc = NS.SetShown
	NS.configFrame.MLCursorAnimate:SetPoint("BOTTOMLEFT", NS.configFrame.MLCursorColor, "TOPLEFT", -7, -2)

	NS.configFrame.MLCursor = CreateCheckBox("MovePadPlusMouseLookCursor", NS.configFrame, NS.Texts.MLCursorShow, MovePadPlus.Cursor, "show", "", 30, 15)
	NS.configFrame.MLCursor.updatefunc = CursorShown
	NS.configFrame.MLCursor:SetPoint("BOTTOMLEFT", NS.configFrame.MLCursorAnimate, "TOPLEFT", 0, -5)

	if not MovePadPlus.Cursor.show then
		NS.configFrame.MLCursorAnimate:SetEnabled(false)
		NS.configFrame.MLCursorColor:SetEnabled(false)
	end
end


local Events, Scale, AddonName, NS = {}, 1, ...

local function CreateCursor()
	if NS.MouseLookCursor then return end
	local f = CreateFrame("FRAME", "MovePadPlusMouseLookCursor", UIParent)
	NS.MouseLookCursor = f
	f:SetSize(32, 32)
	f:Hide()
	f:SetFrameStrata("TOOLTIP")
	f.cursor = f:CreateTexture(nil, "OVERLAY")
	f.cursor:SetAllPoints()
	f.cursor:SetTexture("Interface/Cursor/Point")
	f.AG = f:CreateAnimationGroup()
	f.AG:SetToFinalAlpha(true)
	f.AG:SetLooping("REPEAT")
	f.AG:SetScript("OnFinished", function() f.cursor:SetScale(1) end)
	
	local anim = f.AG:CreateAnimation("Alpha")
	anim:SetChildKey("cursor")
	anim:SetOrder(1)
	anim:SetDuration(1)
	anim:SetFromAlpha(1)
	anim:SetToAlpha(0.3)
	anim:SetSmoothing("NONE")

	anim = f.AG:CreateAnimation("Scale")
	anim:SetChildKey("cursor")
	anim:SetOrder(1)
	anim:SetDuration(1)
	if anim.SetFromScale then
		anim:SetFromScale(1, 1)
		anim:SetToScale(0.6, 0.6)
	else
		anim:SetScaleFrom(1, 1)
		anim:SetScaleTo(0.6, 0.6)
	end
	anim:SetSmoothing("NONE")
	f.MinScale = anim

	anim = f.AG:CreateAnimation("Alpha")
	anim:SetChildKey("cursor")
	anim:SetOrder(2)
	anim:SetDuration(1)
	anim:SetFromAlpha(0.3)
	anim:SetToAlpha(1)

	anim = f.AG:CreateAnimation("Scale")
	anim:SetChildKey("cursor")
	anim:SetOrder(2)
	anim:SetDuration(1)
	if anim.SetFromScale then
		anim:SetFromScale(1, 1)
		anim:SetToScale(1.7, 1.7)
	else
		anim:SetScaleFrom(1, 1)
		anim:SetScaleTo(1.7, 1.7)
	end
	anim:SetSmoothing("NONE")
	f.MaxScale = anim
	
	Scale = UIParent:GetScale()
	local IsLooking, IsTurning, Show = 1, 2, 1
	local State = {
		[IsLooking] = true,
		[IsTurning] = true,
	}
	local function OnStateChange(state, action)
		if action == Show then
			State[state] = false
			local x, y = GetCursorPosition()
			f:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x / Scale, y / Scale)
			if MovePadPlus.Cursor.animate then
				f.AG:Play()
			end
			f:Show()
		else
			State[state] = true
			if State[IsLooking] and State[IsTurning] then 
				if MovePadPlus.Cursor.animate then
					f.AG:Stop()
				end
				f:Hide()
			end
		end
	end
	function Events.PLAYER_STARTED_LOOKING()
		OnStateChange(IsLooking, Show)
	end
	function Events.PLAYER_STARTED_TURNING()
		OnStateChange(IsTurning, Show)
	end
	function Events.PLAYER_STOPPED_LOOKING()
		OnStateChange(IsLooking)
	end
	function Events.PLAYER_STOPPED_TURNING()
		OnStateChange(IsTurning)
	end
	function Events.UI_SCALE_CHANGED()
		Scale = UIParent:GetScale()
	end
	f:SetScript("OnEvent", function(self, event) 
		Events[event]() 
	end)
	function f:SetCursorColor()
		self.cursor:SetVertexColor(MovePadPlus.Cursor.color.r, MovePadPlus.Cursor.color.g, MovePadPlus.Cursor.color.b)
	end
	if anim.SetFromScale then
		function f:SetCursorScale()
			self.MinScale:SetToScale(MovePadPlus.Cursor.minscale, MovePadPlus.Cursor.minscale)
			self.MaxScale:SetToScale(MovePadPlus.Cursor.maxscale, MovePadPlus.Cursor.maxscale)
		end
	else
		function f:SetCursorScale()
			self.MinScale:SetScaleTo(MovePadPlus.Cursor.minscale, MovePadPlus.Cursor.minscale)
			self.MaxScale:SetScaleTo(MovePadPlus.Cursor.maxscale, MovePadPlus.Cursor.maxscale)
		end
	end
	f:SetCursorColor()
	f:SetCursorScale()
end

function NS.CursorShown()
	if MovePadPlus.Cursor.show then
		CreateCursor()
	else
		if not NS.MouseLookCursor then return end
	end
	if MovePadPlus.Cursor.show then
		for k, v in pairs(Events) do
			NS.MouseLookCursor:RegisterEvent(k)
		end
	else
		NS.MouseLookCursor:UnregisterAllEvents()
	end
	
end

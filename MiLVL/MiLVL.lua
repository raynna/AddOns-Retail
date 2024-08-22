MiLVL_Current_iLVL = 0
MiLVL_Estimated_iLVL = 0
MiLVL_IsUpgrade = false

MiLVL_UpgradeAnswer = "Yes"
MiLVL_CurrentBase = 0
MiLVL_EstimatedBase= 0
MiLVL_iEquipLoc = ""
MiLVL_ItemTypeBeingCompared = 0
MiLVL_IsEquippable = 0

function MiLVL_OnLoad()
	overall, equipped = GetAverageItemLevel()
	MiLVL_Current_iLVL = equipped
	MiLVL_Estimated_iLVL = 0
	MiLVL_IsUpgrade = false
	MiLVL_IsEquippable = 0
end

--Everything below this line is showing up in the tooltip
local lineAdded = false

local function OnTooltipSetItem(tooltip, ...)

	if not lineAdded then
		overall, equipped = GetAverageItemLevel()
		MiLVL_Current_iLVL = equipped

	prevItem = nil
		if prevItem ~= GameTooltip:GetItem() then
			itemName, itemLink = GameTooltip:GetItem()
			local sName, sLink, iRarity, iLevel, iMinLevel, sType, sSubType, iStackCount, iEquipLoc = GetItemInfo(itemLink)
			MiLVL_ItemTypeBeingCompared = iLevel
			MiLVL_iEquipLoc = iEquipLoc
			MiLVL_IsEquippable = IsEquippableItem(itemLink)
		end

		if MiLVL_IsEquippable then
   			if MiLVL_ItemTypeBeingCompared < MiLVL_Current_iLVL then
				MiLVL_UpgradeAnswer = "No"
			else
				MiLVL_UpgradeAnswer = "Yes"
			end

		

		
		 
			if IsEquippedItemType("Off-Hand Weapon") then
				MiLVL_CurrentBase = (MiLVL_Current_iLVL/16)
				MiLVL_EstimatedBase = (MiLVL_ItemTypeBeingCompared/16)
				MiLVL_Estimated_iLVL = (MiLVL_CurrentBase*15)+MiLVL_EstimatedBase
				tooltip:AddLine("divided by 16  "..(MiLVL_Current_iLVL))
			else
				MiLVL_CurrentBase = (MiLVL_Current_iLVL/15)
				MiLVL_EstimatedBase = (MiLVL_ItemTypeBeingCompared/15)
				MiLVL_Estimated_iLVL = (MiLVL_CurrentBase*14)+MiLVL_EstimatedBase
			end


		

			shift = 10 ^ 1
			result1 = floor( MiLVL_Current_iLVL*shift + 0.5 ) / shift
			result2 = floor( MiLVL_Estimated_iLVL*shift + 0.5 ) / shift

			
				tooltip:AddLine("Current Equipped iLVL is  "..(result1))
				tooltip:AddLine("Upgrade?  "..(MiLVL_UpgradeAnswer))
				tooltip:AddLine("After Upgrade would be  "..(result2))
				lineAdded = true
			end
	end

end
 

local function OnTooltipCleared(tooltip, ...)

   lineAdded = false
   prevItem = GameTooltip:GetItem()
end


GameTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)

GameTooltip:HookScript("OnTooltipCleared", OnTooltipCleared)
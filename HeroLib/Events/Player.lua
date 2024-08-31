--- ============================ HEADER ============================
--- ======= LOCALIZE =======
-- Addon
local addonName, HL         = ...
-- HeroLib
local Cache                 = HeroCache
local Unit                  = HL.Unit
local Player                = Unit.Player
local Pet                   = Unit.Pet
local Target                = Unit.Target
local Spell                 = HL.Spell
local Item                  = HL.Item

-- Enum locals
local SpellBookSpellBank    = Enum.SpellBookSpellBank

-- Constant locals
local SPELL_FAILED_UNIT_NOT_INFRONT = SPELL_FAILED_UNIT_NOT_INFRONT

-- Base API locals
local C_Timer               = C_Timer
local GetSpecialization     = GetSpecialization
-- Accepts: isInspect, isPet, specGroup; Returns: currentSpec (number)
local GetSpecializationInfo = GetSpecializationInfo
-- Accepts: specIndex, isInspect, isPet, inspectTarget, sex
-- Returns: id (number), name (string), description (string) icon (fileID), role (string), primaryStat (number)
local GetFlyoutInfo         = GetFlyoutInfo
-- Accepts: flyoutID; Returns: name (string), description (string) numSlots (number), isKnown (bool)
local GetFlyoutSlotInfo     = GetFlyoutSlotInfo
-- Accepts: flyoutID, slot; Returns: flyoutSpellID (number), overrideSpellID (number), isKnown (bool), spellName (string), slotSpecID (number)
local GetNumFlyouts         = GetNumFlyouts
-- Accepts: nil; Returns: count (number)
local GetFlyoutID           = GetFlyoutID
-- Accepts: index; Returns: id (number)
local UnitClass             = UnitClass
-- Accepts: unitID; Returns: className (string), classFilename (string), classId (number)

-- C_ClassTalents locals
local GetActiveConfigID     = C_ClassTalents.GetActiveConfigID

-- C_Spell locals
local GetSpellInfo          = C_Spell.GetSpellInfo

-- C_SpellBook locals
local GetNumSpellBookSkillLines = C_SpellBook.GetNumSpellBookSkillLines
local GetSpellBookItemInfo      = C_SpellBook.GetSpellBookItemInfo
local GetSpellBookSkillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo
local HasPetSpells              = C_SpellBook.HasPetSpells

-- C_Traits locals
local GetConfigInfo             = C_Traits.GetConfigInfo
local GetDefinitionInfo         = C_Traits.GetDefinitionInfo
local GetEntryInfo              = C_Traits.GetEntryInfo
local GetNodeInfo               = C_Traits.GetNodeInfo
local GetSubTreeInfo            = C_Traits.GetSubTreeInfo
local GetTreeNodes              = C_Traits.GetTreeNodes

-- Lua locals
local GetTime               = GetTime
local stringfind            = string.find
local stringsub             = string.sub
local tinsert               = table.insert
local wipe                  = wipe

-- File Locals


--- ============================ CONTENT ============================
-- Scan the Book to cache every Spell Learned.
local function BookScan(BlankScan)
  -- Pet Book
  do
    local NumPetSpells = HasPetSpells()
    if NumPetSpells then
      local SpellLearned = Cache.Persistent.SpellLearned.Pet
      local PetSpellBook = SpellBookSpellBank.Pet
      for i = 1, NumPetSpells do
        local SpellData = GetSpellBookItemInfo(i, PetSpellBook)
        local CurrentSpellID = SpellData.spellID
        if CurrentSpellID then
          local CurrentSpell = Spell(CurrentSpellID, "Pet")
          if CurrentSpell:IsAvailable(true) then
            if not BlankScan then
              SpellLearned[CurrentSpell:ID()] = true
            end
          end
        end
      end
    end
  end
  -- Player Book
  do
    local SpellLearned = Cache.Persistent.SpellLearned.Player

    for i = 1, GetNumSpellBookSkillLines() do
      local SkillLineInfo = GetSpellBookSkillLineInfo(i)
      local OffSpec = SkillLineInfo.offSpecID
      local Offset = SkillLineInfo.itemIndexOffset
      local NumSpells = SkillLineInfo.numSpellBookItems
      local PlayerSpellBook = SpellBookSpellBank.Player
      -- If the OffSpec ID is nil, then it's the Main Spec.
      if not OffSpec then
        for j = 1, (Offset + NumSpells) do
          local CurrentSpellInfo = GetSpellBookItemInfo(j, PlayerSpellBook)
          local CurrentSpellID = CurrentSpellInfo.spellID
          if CurrentSpellID then
            if not BlankScan then
              SpellLearned[CurrentSpellID] = true
            end
          end
        end
      end
    end

    -- Flyout Spells
    for i = 1, GetNumFlyouts() do
      local FlyoutID = GetFlyoutID(i)
      local NumSlots, IsKnown = select(3, GetFlyoutInfo(FlyoutID))
      if IsKnown and NumSlots > 0 then
        for j = 1, NumSlots do
          local CurrentSpellID, _, IsKnownSpell = GetFlyoutSlotInfo(FlyoutID, j)
          if CurrentSpellID and IsKnownSpell then
            SpellLearned[CurrentSpellID] = true
          end
        end
      end
    end
  end
end

-- Avoid creating garbage for pcall calls
local function BlankBookScan ()
  BookScan(true)
end

-- PLAYER_REGEN_DISABLED
HL.CombatStarted = 0
HL.CombatEnded = 1
-- Entering Combat
HL:RegisterForEvent(
  function()
    HL.CombatStarted = GetTime()
    HL.CombatEnded = 0
  end,
  "PLAYER_REGEN_DISABLED"
)

-- PLAYER_REGEN_ENABLED
-- Leaving Combat
HL:RegisterForEvent(
  function()
    HL.CombatStarted = 0
    HL.CombatEnded = GetTime()
  end,
  "PLAYER_REGEN_ENABLED"
)

-- CHAT_MSG_ADDON
-- DBM/BW Pull Timer
HL:RegisterForEvent(
  function(Event, Prefix, Message)
    if Prefix == "D4" and stringfind(Message, "PT") then
      HL.BossModTime = tonumber(stringsub(Message, 4, 5))
      HL.BossModEndTime = GetTime() + HL.BossModTime
    elseif Prefix == "BigWigs" and string.find(Message, "Pull") then
      HL.BossModTime = tonumber(stringsub(Message, 8, 9))
      HL.BossModEndTime = GetTime() + HL.BossModTime
    end
  end,
  "CHAT_MSG_ADDON"
)

-- Player Inspector
HL:RegisterForEvent(
  function(Event, Arg1)
    -- Prevent execute if not initiated by the player
    if Event == "PLAYER_SPECIALIZATION_CHANGED" and Arg1 ~= "player" then
      return
    end

    -- Update Player
    Cache.Persistent.Player.Class = { UnitClass("player") }
    Cache.Persistent.Player.Spec = { GetSpecializationInfo(GetSpecialization()) }

    -- Wipe the texture from Persistent Cache
    wipe(Cache.Persistent.Texture.Spell)
    wipe(Cache.Persistent.Texture.Item)

    -- Update Equipment
    Player:UpdateEquipment()
    local Equip = Player:GetEquipment()
    for i=1,16 do
      if slot ~= 4 and not Equip[slot] then
        C_Timer.After(2, function()
            Player:UpdateEquipment()
          end
        )
      end
    end

    -- Load / Refresh Core Overrides
    if Event == "PLAYER_SPECIALIZATION_CHANGED" then
      local UpdateOverrides
      UpdateOverrides = function()
        if Cache.Persistent.Player.Spec[1] ~= nil then
          HL.LoadRestores()
          HL.LoadOverrides(Cache.Persistent.Player.Spec[1])
        else
          C_Timer.After(2, UpdateOverrides)
        end
      end
      UpdateOverrides()
    end

    if Event == "PLAYER_SPECIALIZATION_CHANGED" or Event == "PLAYER_TALENT_UPDATE" or Event == "TRAIT_CONFIG_UPDATED" or Event == "TRAIT_SUB_TREE_CHANGED" then
      UpdateTalents = function()
        wipe(Cache.Persistent.Talents)
        local TalentConfigID = GetActiveConfigID()
        local TalentConfigInfo
        if TalentConfigID then
          TalentConfigInfo = GetConfigInfo(TalentConfigID)
        end
        if TalentConfigID ~= nil and TalentConfigInfo ~= nil then
          local TalentTreeIDs = TalentConfigInfo["treeIDs"]
          for i = 1, #TalentTreeIDs do
            for _, NodeID in pairs(GetTreeNodes(TalentTreeIDs[i])) do
              local NodeInfo = GetNodeInfo(TalentConfigID, NodeID)
              local ActiveTalent = NodeInfo.activeEntry
              local SubTreeID = NodeInfo.subTreeID
              local TalentRank = NodeInfo.activeRank
              if SubTreeID then
                local SubTreeInfo = GetSubTreeInfo(TalentConfigID, SubTreeID)
                if SubTreeInfo then
                  local SubTreeName = SubTreeInfo.name
                  Cache.Persistent.Player.HeroTrees[SubTreeID] = SubTreeName
                  if SubTreeInfo.isActive then
                    Cache.Persistent.Player.ActiveHeroTree = SubTreeName
                    Cache.Persistent.Player.ActiveHeroTreeID = SubTreeID
                  end
                end
              end
              if (ActiveTalent and TalentRank > 0) then
                local TalentEntryID = ActiveTalent.entryID
                local TalentEntryInfo = GetEntryInfo(TalentConfigID, TalentEntryID)
                -- There are entries for SubTree (Hero Talents) items, as of TWW.
                -- These are separate from the TalentEntryID of the nodes within the SubTree.
                -- Nodes and entries for SubTree talents are already processed through this code, so we can safely ignore the SubTree entries without a definitionID.
                if TalentEntryInfo and TalentEntryInfo["definitionID"] then
                  local DefinitionID = TalentEntryInfo["definitionID"]
                  local DefinitionInfo = GetDefinitionInfo(DefinitionID)
                  local SpellID = DefinitionInfo["spellID"]
                  local SpellName = GetSpellInfo(SpellID)
                  Cache.Persistent.Talents[SpellID] = (Cache.Persistent.Talents[SpellID]) and (Cache.Persistent.Talents[SpellID] + TalentRank) or TalentRank
                end
              end
            end
          end
        else
          C_Timer.After(2, UpdateTalents)
        end
      end
      UpdateTalents()
    end
  end,
  "PLAYER_LOGIN", "ZONE_CHANGED_NEW_AREA", "PLAYER_SPECIALIZATION_CHANGED", "PLAYER_TALENT_UPDATE", "PLAYER_EQUIPMENT_CHANGED", "TRAIT_CONFIG_UPDATED", "TRAIT_SUB_TREE_CHANGED"
)

-- Player Unit Cache
HL:RegisterForEvent(
  function(Event, Arg1)
    Player:Cache()
    -- TODO: fix timing issue via event?
    C_Timer.After(3, function() Player:Cache() end)
  end,
  "PLAYER_LOGIN"
)

-- Spell Book Scanner
-- Checks the same event as Blizzard Spell Book, from SpellBookFrame_OnLoad in SpellBookFrame.lua
HL:RegisterForEvent(
  function(Event, Arg1)
    -- Prevent execute if not initiated by the player
    if Event == "PLAYER_SPECIALIZATION_CHANGED" and Arg1 ~= "player" then
      return
    end

    -- FIXME: workaround to prevent Lua errors when Blizz do some shenanigans with book in Arena/Timewalking
    if pcall(BlankBookScan) then
      wipe(Cache.Persistent.BookIndex.Player)
      wipe(Cache.Persistent.BookIndex.Pet)
      wipe(Cache.Persistent.SpellLearned.Player)
      wipe(Cache.Persistent.SpellLearned.Pet)
      BookScan()
    end
  end,
  "SPELLS_CHANGED", "LEARNED_SPELL_IN_TAB", "SKILL_LINES_CHANGED", "PLAYER_GUILD_UPDATE", "PLAYER_SPECIALIZATION_CHANGED", "USE_GLYPH", "CANCEL_GLYPH_CAST", "ACTIVATE_GLYPH"
)

-- Not Facing Unit Blacklist
HL.UnitNotInFront = Player
HL.UnitNotInFrontTime = 0
HL.LastUnitCycled = Player
HL.LastUnitCycledTime = 0
HL:RegisterForEvent(
  function(Event, MessageType, Message)
    if MessageType == 50 and Message == SPELL_FAILED_UNIT_NOT_INFRONT then
      HL.UnitNotInFront = HL.LastUnitCycled
      HL.UnitNotInFrontTime = HL.LastUnitCycledTime
    end
  end,
  "UI_ERROR_MESSAGE"
)

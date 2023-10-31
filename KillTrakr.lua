-- KillTrakr by Varyth-Misha
-- KillTrakr © 2023 by Olivia Galizia is licensed under CC BY-NC-SA 4.0.
-- To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/

-- Set up slash commands
SLASH_KILLTRAKR1, SLASH_KILLTRAKR2 = '/ktr', '/killtrakr'
SlashCmdList["KILLTRAKR"] = function()
  if KillTrakr:IsShown() then
    KillTrakr:Hide()
    return
  else
    KillTrakr:Show()
    return
  end
end

-- Helper function for getting the index of a specific value
function KillTrakr_GetIndex(tbl, value)
  for k, v in ipairs(tbl) do
    if v.name == value then
      return k
    end
  end
end

KillTrakrMixin = {}

function KillTrakrMixin:Print(...)
  local prefix = string.format("|cff%s%s|r", "E91E63", "KillTrakr:")
  DEFAULT_CHAT_FRAME:AddMessage(string.join(" ", prefix, ...))
end

function KillTrakrMixin:Init()
  if KillTrakrDB == nil then
    KillTrakrDB = {}
  end
end

function KillTrakrMixin:HandleCombatEvent()
  local _, subevent, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _ =
      CombatLogGetCurrentEventInfo()

  -- Filter for party kill events
  if subevent and subevent == 'PARTY_KILL' then
    local key = KillTrakr_GetIndex(KillTrakrDB, destName)
    if key then
      -- KillTrakr:Print("Found key " .. key)
      local record = KillTrakrDB[key]
      record.kills = record.kills + 1
      self:Print(destName .. " - " .. record.kills .. " kills")
    else
      local record = {
        name = destName,
        kills = 1
      }
      tinsert(KillTrakrDB, record)
      self:Print(destName .. " - " .. record.kills .. " kills")
    end
    self.Table:SetData(KillTrakrDB)
  end
end

function KillTrakrMixin:OnLoad()
  self:RegisterEvent("ADDON_LOADED")
  self:RegisterEvent("PLAYER_LOGIN")
  self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function KillTrakrMixin:OnEvent(event, arg1, ...)
  if event == "ADDON_LOADED" and arg1 == "KillTrakr" then
    self:Init()
  elseif event == "PLAYER_LOGIN" then
    if KillTrakrDB ~= nil then
      self.Table:SetData(KillTrakrDB)
    end
  elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
    self:HandleCombatEvent()
  end
end

KillTrakrTableMixin = {}

function KillTrakrTableMixin:OnLoad()
  self:SetPoint("CENTER", KillTrakr)
  self:CreateHeader("Name", "Name", 200, "KillTrakrCellTemplate", function(row)
    return row.name
  end)
  self:CreateHeader("Kills", "Kills", 50, "TextCellTemplate", function(row)
    return row.kills
  end)

  -- Add a few test rows
  self:CreateRow()
  self:CreateRow()
  self:CreateRow()
  self:CreateRow()
  self:CreateRow()
  self:CreateRow()
  self:CreateRow()
  self:CreateRow()
  self:CreateRow()
  self:CreateRow()
end

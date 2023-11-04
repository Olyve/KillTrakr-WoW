-- KillTrakr by Varyth-Misha
-- KillTrakr © 2023 by Olivia Galizia is licensed under CC BY-NC-SA 4.0.
-- To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/

local function ToggleWindow()
  if KillTrakr:IsShown() then
    KillTrakr:Hide()
    return
  else
    KillTrakr:Show()
    return
  end
end

-- Set up slash commands
SLASH_KILLTRAKR1, SLASH_KILLTRAKR2 = '/ktr', '/killtrakr'
SlashCmdList["KILLTRAKR"] = function(msg)
  local cmd, rest = msg:match("^(%S*)%s*(.-)$")
  if cmd == "show" or cmd == "" then
    ToggleWindow()
  elseif cmd == "sortAsc" then
    KillTrakr.Table:SortData(rest)
  elseif cmd == "sortDesc" then
    KillTrakr.Table:SortData(rest, true)
  elseif cmd == "wipe" then
    KillTrakr:Wipe()
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

function KillTrakrMixin:Wipe()
  table.wipe(KillTrakrDB)
end

function KillTrakrMixin:HandleCombatEvent()
  local _, subevent, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _ =
      CombatLogGetCurrentEventInfo()

  -- Filter for party kill events
  if subevent and subevent == 'PARTY_KILL' then
    -- self:Print("SourceGUID: " .. sourceGUID)
    -- self:Print("DestinationGUID: " .. destGUID)

    local key = self.Table:GetIndex(destName)
    local record
    if key then
      record = KillTrakrDB[key]
      record.kills = record.kills + 1
      if record.type == nil then
        record.type = UnitCreatureType("target") or nil
      end
    else
      record = {
        name = destName,
        kills = 1,
        type = UnitCreatureType("target") or nil
      }
      tinsert(KillTrakrDB, record)
    end
    self:Print(destName .. "(" .. record.type .. ") - " .. record.kills .. " kills")
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

KillTrakrTableMixin = {
  sortDirection = {
    ASC = 1,
    DSC = 2,
  }
}

function KillTrakrTableMixin:OnLoad()
  self:CreateHeader("Name", "Name", 200, "KillTrakrCellTemplate", function(row)
    return row.name
  end)
  self:CreateHeader("Kills", "Kills", 50, "TextCellTemplate", function(row)
    return row.kills
  end)
  self:CreateHeader("Type", "Type", 100, "KillTrakrCellTemplate", function(row)
    return row.type or ""
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

-- Helper function for getting the index of a specific value
function KillTrakrTableMixin:GetIndex(value)
  for key, record in ipairs(KillTrakrDB) do
    if record.name == value then
      return key
    end
  end
end

function KillTrakrTableMixin:Sort(colName)
  table.sort(KillTrakrDB, function(a, b)
    return a[colName] < b[colName]
  end)

  -- Make sure to trigger an update on the table by setting the data
  -- ** Double check if there is a better way to update the table data
  self:SetData(KillTrakrDB)
end

KillTrakrHeaderMixin = {}

function KillTrakrHeaderMixin:OnClick()
  KillTrakr:Print(self)
end

KillTrakrPaginationMixin = {}

function KillTrakrPaginationMixin:PreviousPage()
  local table = KillTrakr.Table

  if table.offset - 10 < 0 then
    table.offset = 0
  else
    table.offset = table.offset - 10
  end
  table:UpdateRows();
end

function KillTrakrPaginationMixin:NextPage()
  local table = KillTrakr.Table

  if table.offset + 10 > #table.data then
    return
  else
    table.offset = table.offset + 10
  end
  table:UpdateRows();
end

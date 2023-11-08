-- KillTrakr by Varyth-Misha
-- KillTrakr © 2023 by Olivia Galizia is licensed under CC BY-NC-SA 4.0.
-- To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/

local defaultOptions = {
  isShown = false,
}

local function ToggleWindow()
  if KillTrakr:IsShown() then
    KillTrakr:Hide()
  else
    KillTrakr:Show()
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
  end
end

-- ================================
-- Main Window Mixin
-- ================================

KillTrakrMixin = {}

function KillTrakrMixin:Print(...)
  local prefix = string.format("|cff%s%s|r", "E91E63", "KillTrakr:")
  DEFAULT_CHAT_FRAME:AddMessage(string.join(" ", prefix, ...))
end

function KillTrakrMixin:Init()
  self.data = KillTrakrDB or {}
  self.options = KillTrakrOptions or defaultOptions
  self.currentPage = 1

  if self.options.isShown then
    self:Show()
  end

  self:SetPages()
end

function KillTrakrMixin:Commit()
  KillTrakrDB = self.data
  KillTrakrOptions = self.options
end

function KillTrakrMixin:OnLoad()
  self:RegisterEvent("ADDON_LOADED")
  self:RegisterEvent("PLAYER_LOGIN")
  self:RegisterEvent("PLAYER_LOGOUT")
  self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function KillTrakrMixin:OnShow()
  KillTrakrOptions.isShown = true
end

function KillTrakrMixin:OnHide()
  KillTrakrOptions.isShown = false
end

function KillTrakrMixin:OnEvent(event, arg0, ...)
  if event == "ADDON_LOADED" and arg0 == "KillTrakr" then
    self:Init()
  elseif event == "PLAYER_LOGIN" then
    self.Table:SetData(self.data)
  elseif event == "PLAYER_LOGOUT" then
    self:Commit()
  elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
    self:HandleCombatEvent()
  end
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
    self:Print(destName .. "(" .. (record.type or "unknown") .. ") - " .. record.kills .. " kills")
    self.Table:SetData(KillTrakrDB)
  end
end

function KillTrakrMixin:SetPages()
  local totalPages = math.floor(#self.data / 10) + 1
  local currentPage = self.currentPage or 1

  self.Pages.PagesText:SetText(string.format("Page %i/%i", currentPage, totalPages))
end

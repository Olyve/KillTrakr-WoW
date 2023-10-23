-- KillTrakr by Varyth-Misha
-- KillTrakr © 2023 by Olivia Galizia is licensed under CC BY-NC-SA 4.0.
-- To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/

local KillTrakr = {
  frame = CreateFrame("Frame", "KillTrakrUI", UIParent, "BasicFrameTemplateWithInset")
}

function KillTrakr_OnEvent(self, event, arg1, ...)
  if event == "ADDON_LOADED" and arg1 == "KillTrakr" then
    KillTrakr:Init()
  elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
    KillTrakr:HandleCombatEvent()
  end
end

-- Register for Events
KillTrakr.frame:RegisterEvent("ADDON_LOADED")
KillTrakr.frame:RegisterEvent("PLAYER_LOGIN")
KillTrakr.frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
KillTrakr.frame:SetScript("OnEvent", KillTrakr_OnEvent)

function KillTrakr:Init()
  -- Set up initial SVs if we don't have any
  if KillTrakr_Kills == nil then
    KillTrakr.kills = {}
  else
    KillTrakr.kills = KillTrakr_Kills
  end

  -- Set up UI Window
  KillTrakr:InitWindow()
end

function KillTrakr:Print(...)
  local prefix = string.format("|cff%s%s|r", "E91E63", "KillTrakr:")
  DEFAULT_CHAT_FRAME:AddMessage(string.join(" ", prefix, ...))
end

function KillTrakr:HandleCombatEvent()
  local _, subevent, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _ =
      CombatLogGetCurrentEventInfo()

  -- Filter for party kill events
  if subevent and subevent == 'PARTY_KILL' then
    if KillTrakr.kills[destName] then
      KillTrakr.kills[destName] = KillTrakr.kills[destName] + 1
    else
      KillTrakr.kills[destName] = 1
    end
    self:Print(destName .. " - " .. KillTrakr.kills[destName] .. " kills")
  end
end

function KillTrakr:InitWindow()
  local f = KillTrakr.frame
  f:SetPoint("CENTER")
  f:SetSize(500, 500)
  f:SetClampedToScreen(true)
  f:SetMovable(true)
  f:SetScript("OnMouseDown", function(self, button)
    self:StartMoving()
  end)
  f:SetScript("OnMouseUp", function(self, button)
    self:StopMovingOrSizing()
  end)
end

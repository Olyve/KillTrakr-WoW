-- ------------------------------------------------------------------------------ --
-- KillTrakr by Varyth-Misha
-- © 2023 Olivia Galizia
-- ------------------------------------------------------------------------------ --


---@class AceAddon
KillTrakr = LibStub("AceAddon-3.0"):NewAddon(
  "KillTrakr",
  "AceConsole-3.0",
  "AceEvent-3.0"
)

-- ============================================================================
-- Lifecycle Methods for an Ace3 Addon
-- ============================================================================

--- Called when the addon is loaded
function KillTrakr:OnInitialize()
  KillTrakr:InitDB()
end

--- Called when the addon is enabled
function KillTrakr:OnEnable()
  self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "HandleCombatEvent")

  if self.db.profile.setting == true then
    self.db.profile.playerName = UnitName("player")
  end
end

---Called when the addon is disabled
function KillTrakr:OnDisable()
  -- Not sure if I will need to add anything here yet
end

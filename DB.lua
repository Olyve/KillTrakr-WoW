-- Author      : Olyve
-- Create Date : 10/19/2023 6:29:04 PM

local defaults = {
  char = {
    settting = true,
    kills = {}
  }
}

function KillTrakr:InitDB()
  self.db = LibStub("AceDB-3.0"):New("KillTrakrDB", defaults, true)
end
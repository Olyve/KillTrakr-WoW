function KillTrakr:HandleCombatEvent()
  local timestamp,
  subevent,
  hideCaster,
  sourceGUID,
  sourceName,
  sourceFlags,
  sourceRaidFlags,
  destGUID,
  destName,
  destFlags,
  destRaidFlags = CombatLogGetCurrentEventInfo()

  -- Filter for party kill events
  if subevent and subevent == 'PARTY_KILL' then
    local kills = self.db.char.kills

    if kills[destName] then
      kills[destName] = kills[destName] + 1
    else
      kills[destName] = 1
    end
    self:Print(destName .. ": " .. kills[destName] .. " kills")
  end
end

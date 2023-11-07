-- KillTrakr by Varyth-Misha
-- KillTrakr © 2023 by Olivia Galizia is licensed under CC BY-NC-SA 4.0.
-- To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/

-- ================================
-- Table Mixin
-- ================================

KillTrakrTableMixin = {}

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

-- ================================
-- Pagination Buttons Mixin
-- ================================

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

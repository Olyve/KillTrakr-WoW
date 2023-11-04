-- All credit for this goes to @chippz
-- http://safehex.chipzz.be/ListTable/ListTable.lua

function GetParentArrayIndex(self, parentArray)
  local parent, f, frame = self:GetParent()
  for f, frame in ipairs(parent[parentArray]) do
    if frame == self then
      return f
    end
  end
end

function SetIDFromParentArray(self, parentArray, cb)
  local i = GetParentArrayIndex(self, parentArray)
  if i then
    self:SetID(i)
    return cb(self)
  end
end

-- local
function HandleKeyValues(self, keyHandlers)
  for k, h in pairs(keyHandlers) do
    if self[k] then
      h(self, self[k])
    end
  end
end

ListTableMixin = {}

function ListTableMixin:OnLoad()
end

function ListTableMixin:SetData(data)
  self.data = data
  self.offset = self.offset or 0
  self:UpdateRows()
end

function ListTableMixin:UpdateRows()
  local i
  for i = 1, #self.rows do
    local row, row_data = self.rows[i], self.data[i + self.offset]
    row:SetShown(row_data)
    if row_data then
      row:Set(row_data)
    end
  end
end

-- should sort asecdening by default based on the header name
-- which should correspond to the data field in the table value
-- Ex: if header is `name`, should look for a.name and compare
-- to b.name
function ListTableMixin:SortData(header, desc)
  if desc == nil or desc == false then
    table.sort(self.data, function(a, b)
      return a[header] < b[header]
    end)
  else
    table.sort(self.data, function(a, b)
      return a[header] > b[header]
    end)
  end
  self:UpdateRows()
end

function ListTableMixin:CreateHeader(text, nameInfix, width, cellTemplate, selector, sorter)
  local header = CreateFrame("Button", nameInfix and self:GetName() and self:GetName() .. nameInfix .. "Header", self,
    self.headerTemplate or "ListHeaderTemplate")
  if text then header:SetText(text) end
  if width and not header:IsUserPlaced() then header:SetWidth(width) end
  header.cellTemplate = header.cellTemplate or cellTemplate
  header.selector = header.selector or selector
  header.sorter = header.sorter or sorter
  local spacer = CreateFrame("Frame", nil, self, "ListHeaderSpacerTemplate")
end

function ListTableMixin:CreateRow(rowTemplate)
  local row = CreateFrame("Frame", nil, self, rowTemplate or "ListRowTemplate")
end

ListHeaderMixin = {}

local function ListHeader_Anchor(self)
  local parent, id = self:GetParent(), self:GetID()
  if id == 1 then
    self:SetPoint("LEFT")
  else
    self:SetPoint("LEFT", parent.headers[id - 1], "RIGHT")
  end
end

function ListHeaderMixin:OnLoad()
  SetIDFromParentArray(self, "headers", ListHeader_Anchor)
  -- Make sure height isn't overwritten by saved layout
  local height = self:GetHeight()
  self:SetScript("OnUpdate", function(self)
    self:SetHeight(height)
    self:SetScript("OnUpdate", nil)
  end)
end

ListHeaderSpacerMixin = {}

function ListHeaderSpacerMixin:OnLoad()
  SetIDFromParentArray(self, "spacers", function(self)
    local parent, id = self:GetParent(), self:GetID()
    self:SetPoint("LEFT", parent.headers[id], "RIGHT", -1)
  end)
end

function ListHeaderSpacerMixin:OnMouseDown(button)
  local parent, id = self:GetParent(), self:GetID()
  local left, right = parent.headers[id], parent.headers[id + 1]

  local function GetScaledX()
    return GetCursorPosition() / parent:GetEffectiveScale()
  end
  local startX = GetScaledX()
  local startLeftWidth = left:GetWidth()
  local startRightWidth
  if right and button ~= "LeftButton" then
    startRightWidth = right and right:GetWidth()
  end
  local minWidth = left.left:GetWidth() + left.right:GetWidth()
  self:SetScript("OnUpdate", function(self)
    local function ListHeader_SetWidth(header, width)
      if width > minWidth then
        header:SetWidth(width)
      end
    end
    local delta = GetScaledX() - startX
    ListHeader_SetWidth(left, startLeftWidth + delta)
    if startRightWidth then
      ListHeader_SetWidth(right, startRightWidth - delta)
    end
  end)
end

function ListHeaderSpacerMixin:OnMouseUp(button)
  self:SetScript("OnUpdate", nil)
end

function ListHeaderSpacerMixin:OnEnter()
  SetCursor("UI_RESIZE_CURSOR")
end

function ListHeaderSpacerMixin:OnLeave()
  SetCursor(nil)
end

ListRowMixin = {}

function ListRowMixin:OnLoad()
  SetIDFromParentArray(self, "rows", function(self)
    local parent, id = self:GetParent(), self:GetID()
    if id == 1 then
      self:SetPoint("TOP", parent.headers[1], "BOTTOM")
    else
      self:SetPoint("TOP", parent.rows[id - 1], "BOTTOM")
    end
  end)
  local parent = self:GetParent()
  local _, header
  for _, header in ipairs(parent.headers) do
    local cell = CreateFrame("Frame", nil, self, header.cellTemplate or "ListCellTemplate")
  end
end

function ListRowMixin:Set(row)
  for _, cell in ipairs(self.cells) do
    cell:SetRow(row)
  end
end

ListCellMixin = {}

function ListCellMixin:OnLoad()
  SetIDFromParentArray(self, "cells", function(self)
    local header = self:GetHeader()
    self:SetPoint("LEFT", header)
    self:SetPoint("RIGHT", header)
  end)
end

function ListCellMixin:GetHeader()
  return self:GetParent():GetParent().headers[self:GetID()]
end

function ListCellMixin:SelectData(row)
  return self:GetHeader().selector(row)
end

function ListCellMixin:SetRow(row)
  self:Set(self:SelectData(row))
end

TextCellMixin = {}

function TextCellMixin:OnLoad()
  ListCellMixin.OnLoad(self)
  HandleKeyValues(self,
    {
      font = function(self, font) self.text:SetFontObject(font) end,
      justifyH = function(self, justifyH) self.text:SetJustifyH(justifyH) end,
      justifyV = function(self, justifyV) self.text:SetJustifyV(justifyV) end,
      numLines = function(self, numLines) self.text:SetNumLines(numLines) end,
    })
end

function TextCellMixin:Set(text)
  self.text:SetText(text)
end

function ItemButtonSetItem(button, label, id, min, max)
  SetItemButtonTexture(button, GetItemIcon(id) or "Interface\\Icons\\INV_Misc_QuestionMark")
  button.Count:Hide()
  if max and max ~= min then
    local Count = button.Count
    Count:SetText(min .. "-" .. max)
    Count:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
    Count:Show()
  else
    if min ~= 1 then
      SetItemButtonCount(button, min)
    end
  end
  local function ItemButtonSetItemCb(name, quality)
    local r, g, b = GetItemQualityColor(quality)
    if label then label:SetText("|Hitem:" .. id .. "|h" .. name .. "|h") end
    if r and g and b then
      if label then label:SetVertexColor(r, g, b) end
      button.IconBorder:SetVertexColor(r, g, b)
    end
  end
  local name, _, quality = GetItemInfo(id)
  if name then
    ItemButtonSetItemCb(name, quality)
  else
    button:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    button:SetScript("OnEvent", function(self, event, event_id)
      if event_id == id then
        local name, _, quality = GetItemInfo(event_id)
        button:SetScript("OnEvent", nil)
        ItemButtonSetItemCb(name, quality)
      end
    end)
  end
end

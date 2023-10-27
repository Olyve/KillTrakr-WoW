ItemButtonCellMixin = {}

function ItemButtonCellMixin:SetRow(row)
	ItemButtonSetItem(self.button, self.label, unpack(self:SelectData(row)))
end

ItemsMixin = {}

function ItemsMixin:ButtonSetItem(button, ...)
	self.buttons = self.buttons or {}
	if not self.buttons[button] then
		local s = 3
		for b = #self.buttons + 1, button do
			self.buttons[b] = CreateFrame("ItemButton", nil, self)
			if b == 1 then
				self.buttons[b]:SetPoint("LEFT")
				self:SetHeight(self.buttons[b]:GetHeight())
			else
				self.buttons[b]:SetPoint("LEFT", self.buttons[b - 1], "RIGHT", s, 0)
			end
		end
		local width = 0
		for b = 1, #self.buttons do
			width = width + self.buttons[b]:GetWidth()
			if b > 1 then
				width = width + s
			end
		end
		self:SetWidth(width)
	end
	ItemButtonSetItem(self.buttons[button], nil, ...)
end

ItemsCellMixin = {}

function ItemsCellMixin:Set(items)
	local i, itemData
	for i, itemData in ipairs(items) do
		self.items:ButtonSetItem(i, unpack(itemData))
	end
end

SkillCellMixin = {}

function SkillCellFliter(row)
	return row.skill[1], row.learnedat, unpack(row.colors)
end

local skill_dificulty_colors = { "ff7f3f", "ffff00", "3f7f3f", "7f7f7f" }

function SkillCellMixin:Set(skill, learnedat, ...)
	local colored_levels = {}
	local c, level
	for c, level in ipairs({...}) do
		if c == 4 or c < 4 and level ~= select(c + 1, ...) then
			tinsert(colored_levels, "|cff"..skill_dificulty_colors[c]..level.."|r")
		end
	end
	TextCellMixin.Set(self, ((WoWHeaderData.Skills or {})[skill] or { name="Unknown Skill" }).name..'('..learnedat..')|n'..table.concat(colored_levels, ' '))
end

LocationsCellMixin = {}

function LocationsCellMixin:Set(locations)
	zone_names = {}
	for _, z in ipairs(locations or {}) do
		tinsert(zone_names, "|Hzone:"..z.."|h"..((WoWHeaderData.Zones or {})[z] or { name="Unknown Zone" }).name.."|h")
	end
	TextCellMixin.Set(self, table.concat(zone_names, ", "))
end

ObjectCellMixin = {}

function ObjectCellMixin:Set(id, name)
	TextCellMixin.Set(self, "|Hobject:"..id.."|h"..name.."|h")
end

CountCellMixin = {}

function CountCellMixin:Set(count, outof)
	self.count:SetText(count)
	self.outof:SetText("out of "..outof)
end

PercentCellMixin = {}

--[[
-- Doesn't seem to work anyway
function PercentCellMixin:OnLoad()
	TextCellMixin.OnLoad(self)
	self.text:ClearAllPoints()
	self.text:SetPoint("CENTER")
end
]]--

function PercentCellMixin:Set(count, outof)
	self.text:SetFormattedText("%i", count * 100 / outof)
end

NPCCellMixin = {}

function NPCCellMixin:Set(id, name, tag, boss, hasQuests)
	self.name:SetText(
	(hasQuests and "|TInterface\\GossipFrame\\AvailableQuestIcon:0|t " or "")..
	(boss and "|TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:0|t " or "")..
	"|Hnpc:"..id.."|h"..name.."|h"
	)
	self.name:ClearAllPoints()
	self.name:SetPoint("LEFT", 2, 0)
	self.tag:SetShown(tag)
	if tag then
		self.name:SetPoint("BOTTOM", self, "CENTER")
		self.tag:SetText('<'..tag..'>')
	else
		self.name:SetPoint("CENTER")
	end
end

ReactCellMixin = {}

local reactionIndex = ({ Alliance = 1, Horde = 2 })[UnitFactionGroup("player")]

function ReactCellMixin:Set(reactions)
	local reaction = (reactions or {})[reactionIndex]
	local text = ""
	if reaction ~= nil then
		local reactionTexts = {
			[-1] = '|cffff0000H|r',
			[0] = '|cffffff00N|r',
			[1] = '|cff00ff00F|r'
		}
		text = reactionTexts[reaction]
	end
	TextCellMixin.Set(self, text)
end

NPCLevelCellMixin = {}

function NPCLevelCellMixin:Set(minlevel, maxlevel, classification)
	self.level:SetText(maxlevel and maxlevel > minlevel and minlevel..' - '..maxlevel or minlevel)
	self.level:ClearAllPoints()
	self.classification:SetShown(classification > 0)
	if classification > 0 then
		self.level:SetPoint("BOTTOM", self, "CENTER")
		local classificationTexts = {
			[1] = 'Elite',
			[2] = 'Rare Elite',
			[4] = 'Rare',
		}
		self.classification:SetText(classificationTexts[classification])
	else
		self.level:SetPoint("CENTER")
	end
end

QuestCellMixin = {}

function QuestCellMixin:Set(id, name, tag)
	self.name:SetText("|Hquest:"..id.."|h"..name.."|h")
	self.name:ClearAllPoints()
	self.name:SetPoint("LEFT", 2, 0)
	self.tag:SetShown(tag)
	if tag then
		self.name:SetPoint("BOTTOM", self, "CENTER")
		self.tag:SetText('<'..tag..'>')
	else
		self.name:SetPoint("CENTER")
	end
end

QuestLevelCellMixin = {}

function QuestLevelCellMixin:Set(level, classification)
	self.level:SetText(level)
	self.level:ClearAllPoints()
	self.classification:SetShown(classification)
	if classification then -- classification > 0 then
		self.level:SetPoint("BOTTOM", self, "CENTER")
		local classificationTexts = {
			[1] = 'Elite',
			[2] = 'Rare Elite',
			[4] = 'Rare',
		}
		self.classification:SetText(classificationTexts[classification])
	else
		self.level:SetPoint("CENTER")
	end
end

MoneyCellMixin = {}

--[[
function MoneyCellMixin:OnLoad()
end
]]--

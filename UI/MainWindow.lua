-- MainWindow.lua
-- Author: Olyve

-- Setting up the MainFrame for the Addon
---@class frame
local frame = CreateFrame("Frame", "KillTrakr_Main", UIParent, "BasicFrameTemplateWithInset")
frame:SetSize(300, 360)
frame:SetPoint("CENTER", UIParent, "CENTER")
frame.title = frame:CreateFontString(nil, "OVERLAY")
frame.title:SetFontObject("GameFontHighlight")
frame.title:SetPoint("LEFT", frame.TitleBg, "LEFT", 5, 0)
frame.title:SetText("KillTrakr")

frame.saveButton = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
frame.saveButton:SetPoint("CENTER", frame, "TOP", 0, -70)
frame.saveButton:SetSize(80, 30)
frame.saveButton:SetText("Save")
frame.saveButton:SetNormalFontObject("GameFontNormalLarge")
frame.saveButton:SetHighlightFontObject("GameFontHighlightLarge")

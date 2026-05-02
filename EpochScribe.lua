tinsert(UISpecialFrames, "EpochScribeFrame")

-- 1. Create the Main Frame
local f = CreateFrame("Frame", "EpochScribeFrame", UIParent)
f:SetSize(300, 400)
f:SetPoint("BOTTOMLEFT", ChatFrame1, "BOTTOMRIGHT", 20, 0)
f:SetMovable(true)
f:SetResizable(true)
f:SetMinResize(250, 200)
f:SetMaxResize(600, 800)
f:EnableMouse(true)
f:RegisterForDrag("LeftButton")
f:SetScript("OnDragStart", f.StartMoving)
f:SetScript("OnDragStop", f.StopMovingOrSizing)

f:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground", 
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
f:SetBackdropColor(0, 0, 0, 0.8)
f:Hide()

-- 2. NEW: The Close Button (X)
local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", -2, -2)
close:SetScript("OnClick", function() f:Hide() end)

-- 3. Release Keyboard Logic
local function ReleaseKeyboard()
    if EpochScribeScrollChild:HasFocus() then
        EpochScribeScrollChild:ClearFocus()
    end
end

f:SetScript("OnMouseDown", ReleaseKeyboard)
WorldFrame:HookScript("OnMouseDown", ReleaseKeyboard)

-- 4. Resize Handle (Bottom Right)
local rb = CreateFrame("Button", nil, f)
rb:SetPoint("BOTTOMRIGHT", -6, 6)
rb:SetSize(16, 16)
rb:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
rb:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
rb:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
rb:SetScript("OnMouseDown", function() f:StartSizing("BOTTOMRIGHT") end)
rb:SetScript("OnMouseUp", function() f:StopMovingOrSizing() end)

-- 5. Chat Tab Button
local tabBtn = CreateFrame("Button", "EpochScribeTab", GeneralChatWindowTab)
tabBtn:SetSize(64, 24)
tabBtn:SetPoint("LEFT", ChatFrame2Tab, "RIGHT", 0, 0) 
local tabTex = tabBtn:CreateTexture(nil, "BACKGROUND")
tabTex:SetAllPoints()
tabTex:SetTexture("Interface\\ChatFrame\\ChatFrameTab")
local tabText = tabBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
tabText:SetPoint("CENTER", 0, -3)
tabText:SetText("Notes")
tabBtn:SetScript("OnClick", function()
    if f:IsShown() then f:Hide() else f:Show() end
end)

-- 6. Scroll Area
local sf = CreateFrame("ScrollFrame", "EpochScribeScroll", f, "UIPanelScrollFrameTemplate")
sf:SetPoint("TOPLEFT", 10, -25) -- Nudged down slightly to clear the X button
sf:SetPoint("BOTTOMRIGHT", -30, 45)
sf:SetScript("OnMouseDown", ReleaseKeyboard)

-- 7. The EditBox
local eb = CreateFrame("EditBox", "EpochScribeScrollChild", sf)
eb:SetMultiLine(true)
eb:SetMaxLetters(0)
eb:SetFontObject(ChatFontNormal)
eb:SetWidth(260)
eb:SetAutoFocus(false)
eb:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
sf:SetScrollChild(eb)

f:SetScript("OnSizeChanged", function(self, width, height)
    eb:SetWidth(width - 45)
end)

-- 8. "New Note" Button
local btn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
btn:SetSize(110, 22)
btn:SetPoint("BOTTOMLEFT", 12, 12)
btn:SetText("New Note")

btn:SetScript("OnClick", function()
    local posX, posY = GetPlayerMapPosition("player")
    local zone = GetRealZoneText()
    local coords = string.format("(%.1f, %.1f)", posX * 100, posY * 100)
    local timeStr = date("%H:%M:%S")
    local header = "\n\n-----------------------\n" .. "[" .. timeStr .. "] " .. zone .. " " .. coords .. "\n> "
    eb:SetText(eb:GetText() .. header)
    eb:SetFocus()
    sf:SetVerticalScroll(sf:GetVerticalScrollRange())
end)

-- 9. Clear Button
local clear = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
clear:SetSize(70, 22)
clear:SetPoint("BOTTOMRIGHT", -25, 12)
clear:SetText("Clear")
clear:SetScript("OnClick", function() 
    eb:SetText("") 
    EpochScribeDB = "" 
end)

-- 10. Save/Load Logic
eb:SetScript("OnTextChanged", function(self) EpochScribeDB = self:GetText() end)
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, arg1)
    if arg1 == "EpochScribe" then
        eb:SetText(EpochScribeDB or "Adventurer's Log Ready...")
    end
end)

SLASH_EPOCHSCRIBE1 = "/scribe"
SlashCmdList["EPOCHSCRIBE"] = function() tabBtn:Click() end
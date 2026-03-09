-- Cache frequently used globals for performance
local tonumber = tonumber
local format = string.format
local match = string.match
local find = string.find
local lower = string.lower
local CreateFrame = CreateFrame

local helpers = {};

helpers.writeToChat = function(text)
    DEFAULT_CHAT_FRAME:AddMessage(text)
end

helpers.questComplete = function(questId)
    return C_QuestLog.IsQuestFlaggedCompleted(questId)
end

-- Reusable edit box frame (created once on first use)
local editBoxFrame, editBox

helpers.renderEditBox = function(text)
    if not editBoxFrame then
        local f = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
        f:SetPoint("CENTER")
        f:SetSize(340, 60)
        f:SetFrameStrata("DIALOG")
        f:SetClipsChildren(true)
        f:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", -- this one is neat
            edgeSize = 16,
            insets = {
                left = 5,
                right = 5,
                top = 5,
                bottom = 5
            }
        })
        f:SetBackdropBorderColor(0, .44, .87, 0.5) -- darkblue

        local eb = CreateFrame("EditBox", nil, f)
        eb:SetSize(300, 40)
        eb:SetPoint("LEFT", f, "LEFT", 10, 0)
        eb:SetMultiLine(true)
        eb:SetAutoFocus(false) -- dont automatically focus
        eb:SetFontObject("ChatFontNormal")
        eb:SetScript("OnEscapePressed", function()
            f:Hide()
        end)

        local c = CreateFrame("Button", nil, f)
        c:SetNormalTexture(130832) -- "Interface\\Buttons\\UI-Panel-MinimizeButton-Up"
        c:SetPushedTexture(130830) -- "Interface\\Buttons\\UI-Panel-MinimizeButton-Down"
        c:SetHighlightTexture(130831) -- "Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight"
        c:SetSize(32, 32)
        c:SetPoint("RIGHT", f, "RIGHT", -5, 0)
        c:SetScript("OnClick", function()
            f:Hide()
        end)

        editBoxFrame = f
        editBox = eb
    end

    editBox:SetText(text)
    editBox:HighlightText(0)
    editBoxFrame:Show()
end

helpers.howToUse = function()
    local write = helpers.writeToChat
    write('Usage:')
    write('/quest <QuestLink or QuestId>')
    write('When using a numeric questid, add "link" after for a popup with wowhead link')
    write('Example:')
    write('/quest \124cffffff00\124Hquest:41368:110\124h[Lost Mail]\124h\124r')
    write('/quest 41368')
    write('/quest 41368 link')
end

local wowheadUrl = 'https://www.wowhead.com/'
local wowheadQuestUrl = wowheadUrl .. 'quest='
local wowheadAchievementUrl = wowheadUrl .. 'achievement='

local function WriteQuestStatus(questId)
    if helpers.questComplete(questId) then
        helpers.writeToChat(format("QuestId: %d has been completed", questId))
    else
        helpers.writeToChat(format("QuestId: %d has NOT been completed", questId))
    end
end

local function HandleQuestLink(questId)
    WriteQuestStatus(questId)
    helpers.renderEditBox(wowheadQuestUrl .. questId)
end

local function HandleAchievementLink(achievementId)
    helpers.renderEditBox(wowheadAchievementUrl .. achievementId)
end

local function QuestInfo(msg, editbox)
    local _, _, cmd, flag = find(msg, "%s?(%w+)%s?(.*)")
    if flag then
        flag = lower(flag)
    end

    -- Handles quest links
    local questId = tonumber(match(msg, 'quest:(%d+):'))
    if questId then
        HandleQuestLink(questId)
        return
    end

    -- Handles achievement links
    local achievementId = tonumber(match(msg, 'achievement:(%d+):'))
    if achievementId then
        HandleAchievementLink(achievementId)
        return
    end

    -- Handles normal text input
    local cmdNum = tonumber(cmd)
    if not cmdNum or cmd == 'help' then
        helpers.howToUse()
        return
    end

    WriteQuestStatus(cmdNum)

    local questLink = GetQuestLink(cmdNum)
    if questLink then
        helpers.writeToChat(questLink)
    end

    if flag == 'link' then
        helpers.renderEditBox(wowheadQuestUrl .. cmdNum)
    end
end

SLASH_QUEST1, SLASH_QUEST2 = '/quest', '/questinfo';
SlashCmdList["QUEST"] = QuestInfo

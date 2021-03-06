local helpers = {};

helpers.isEmpty = function(string)
    return string == nil or string == ''
end

helpers.isNumber = function(string)
    return tonumber(string) ~= nil
end

helpers.writeToChat = function(string)
    DEFAULT_CHAT_FRAME:AddMessage(string)
end

helpers.questComplete = function(questId)
    local parsed = tonumber(questId)
    return C_QuestLog.IsQuestFlaggedCompleted(parsed)
end

helpers.renderEditBox = function(text)

    local f = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
    f:SetPoint("CENTER")
    f:SetSize(340, 60)
    f:SetFrameStrata("DIALOG")
    f:SetClipsChildren(true)
    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", -- this one is neat
        edgeSize = 16,
        insets = { left = 5, right = 5, top = 5, bottom = 5 },
    })
    f:SetBackdropBorderColor(0, .44, .87, 0.5) -- darkblue

    local eb = CreateFrame("EditBox", nil, f)
    eb:SetSize(300, 40)
    eb:SetPoint("LEFT", f, "LEFT", 10, 0)
    eb:SetMultiLine(true)
    eb:SetAutoFocus(false) -- dont automatically focus
    eb:SetFontObject("ChatFontNormal")
    eb:SetText(text)
    eb:HighlightText(0)
    eb:SetScript("OnEscapePressed", function() f:Hide() end)

    local c = CreateFrame("Button", nil, f)
    c:SetNormalTexture(130832) --"Interface\\Buttons\\UI-Panel-MinimizeButton-Up"
    c:SetPushedTexture(130830) --"Interface\\Buttons\\UI-Panel-MinimizeButton-Down"
    c:SetHighlightTexture(130831) --"Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight"
    c:SetSize(32, 32)
    c:SetPoint("RIGHT", f, "RIGHT", -5, 0)
    c:SetScript("OnClick", function() f:Hide() end)

    f:Show()

    -- if text then
    --     f:Show()
    -- end
end

helpers.howToUse = function ()
    helpers.writeToChat('Usage:')
    helpers.writeToChat('/quest <QuestLink or QuestId>')
    helpers.writeToChat('When using a numeric questid, add "link" after for a popup with wowhead link')
    helpers.writeToChat('Example:')
    helpers.writeToChat('/quest \124cffffff00\124Hquest:41368:110\124h[Lost Mail]\124h\124r')
    helpers.writeToChat('/quest 41368')
    helpers.writeToChat('/quest 41368 link')
end

local wowheadUrl = 'https://www.wowhead.com/'
local wowheadQuestUrl = wowheadUrl .. 'quest='
local wowheadAchievementUrl = wowheadUrl .. 'achievement='

local function HandleQuestLink(questId)
    if helpers.questComplete(questId) then
        helpers.writeToChat("QuestId: " .. questId .. " has been completed")
    else 
        helpers.writeToChat("QuestId: " .. questId .. " has NOT been completed")
    end

    helpers.renderEditBox(wowheadQuestUrl..questId)
end

local function HandleAchievementLink(achievementId)
    helpers.renderEditBox(wowheadAchievementUrl..achievementId)
end

local function QuestInfo(msg, editbox)
    local _, _, cmd, flag = string.find(msg, "%s?(%w+)%s?(.*)")
    local QuestId
    if flag then
        flag = flag:lower()
    end

    --Handles quest links
    QuestId = tonumber(string.match(msg, 'quest:(%d+):'))
    if helpers.isNumber(QuestId) then
        HandleQuestLink(QuestId)
        return
    end

    --Handles achievement links
    AchievementId = tonumber(string.match(msg, 'achievement:(%d+):'))
    if helpers.isNumber(AchievementId) then
        HandleAchievementLink(AchievementId)
        return
    end
    
    --Handles normal text input
    if helpers.isEmpty(cmd) then
        helpers.howToUse()
    elseif cmd == 'help' then
        helpers.howToUse()
    elseif not helpers.isNumber(cmd) then
        helpers.howToUse()
    else
        QuestId = tonumber(cmd);
        
        if helpers.questComplete(QuestId) then
            helpers.writeToChat("QuestId " .. QuestId .. " has been completed")
        else 
            helpers.writeToChat("QuestId " .. QuestId .. " has NOT been completed")
        end
        
        questLink = GetQuestLink(QuestId)
        helpers.writeToChat(questLink)
        
        if flag == 'link' then
            helpers.renderEditBox(wowheadQuestUrl..QuestId)
        end

    end
end

SLASH_QUEST1, SLASH_QUEST2 = '/quest', '/questinfo';
SlashCmdList["QUEST"] = QuestInfo

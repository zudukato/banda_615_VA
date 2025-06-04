--[[
*******************************************************************************
Firmware:       2.5.0.0 or higher
Date:           2023-12-21
Customer:       Juan Alberto Hernandez
Owner:          Basculas Revuelta Maza
Description:
*******************************************************************************
]]

--Reqs
local brmVariables = require("Reqs.brmVariables")
require("Reqs.brmAppMenu")
require("Reqs.brmScaleKeys")
local brmUtilities = require("Reqs.brmUtilities")

------------------------------------ Setup ----------------------------------------
------------------- Persistent variables for normal application -------------------
--default values
local minWt = 4*awtx.weight.getCurrent(0).curDivision
PersistentVars = PersistentVars or {}
PersistentVars.currentMode = "NormalWeight"--provisional
PersistentVars.minWt = minWt or 200 --min weight
PersistentVars.supportPasswords = "762" --support password
PersistentVars.userPassword = "1793" --user password
PersistentVars.shortCuts = {["0000"] = "PrintConf"}--user Password
PersistentVars.headers = {"header1", "header2"}-- ticket headers
PersistentVars.ticketNumber = 1--ticket number
PersistentVars.zeroThreshold = 100
PersistentVars.zeroTareClear = false
PersistentVars.backToZeroActive = true
PersistentVars.language = "$"
PersistentVars.printer = "EscPos"
PersistentVars.interLineTime = 100

-- persistent value assignation recalling last saved value
-- to access "persistentVariable.nameOfVariable.value"
PersistentVars = brmVariables.SavedVariableTable("PersistentVars", PersistentVars, true)
local languageSelected
---@type boolean, language
languageSelected, Language = pcall(require,"Languages."..PersistentVars.language)
if not languageSelected then
    while not brmUtilities.changeLanguage() do  end
end



-------------------------------Configuration Modules----------------------------------
BackToZero = {}
EventsHandle = EventsHandle or {
    events = {},
    eventList = {
        notBackToZero = "notBackToZero",
        noMinWt = "minWt",
    }
}

Databases = {}
MenusTree = require("menus")
-------Application Events---------

function EventsHandle.checkEvents(listOfEvents)
    if listOfEvents then
        for _, v in pairs(listOfEvents) do
            if EventsHandle.events[v] then return v end
        end
    end
    for event, v in pairs(EventsHandle.events) do
        if v then return event end
    end
end

EventsHandle.events.notBackToZero = false
function BackToZero.notZero()
    if PersistentVars.backToZeroActive then
        EventsHandle.events[EventsHandle.eventList.notBackToZero] = true
    else 
        EventsHandle.events[EventsHandle.eventList.notBackToZero] = nil
    end
end
function BackToZero.checkZero()
    return not EventsHandle.events[EventsHandle.eventList.notBackToZero]
end

function BackToZero.zero(_, setpointActive)
    EventsHandle.events.notBackToZero = false
end
_MinWt = PersistentVars.minWt

local function onMinWt(_, setpointActive)
    EventsHandle.events[EventsHandle.eventList.noMinWt] = not setpointActive
end

--------------------------------------Modules--------------------------------------
local brmChain = require("Reqs.brmChain")
CurrentMode = require("operationModes.EPI.main") or {}

local brmUtilities = require("Reqs.brmUtilities")
local awtxConstants = require("Reqs.awtxReqConstants")
local brmScaleKeys = require("Reqs.brmScaleKeys")
local brmScreen = require("Reqs.brmScreenRAD6015")

local appName = "EPI615"
local appVersion = "VER 2.0.0.0"
local appDate =  "BRM20250416" ---last modification

local startUp = brmScreen.newScreen("startUp")
if startUp then
    startUp:newLabel("title")
    startUp.labels.title:setText(appName)
    startUp.labels.title:setLocation({x=0, y =1})
    startUp.labels.title:reSize({width=200,height=42})
    startUp.labels.title:setFont(awtxConstants.graphics.FONT_LUCIDA_CON_40)
    startUp.labels.title:setVisible(true)

    startUp:newLabel("version")
    startUp.labels.version:setText(appVersion)
    startUp.labels.version:setLocation({x=200, y =20})
    startUp.labels.version:reSize({width=120,height=18})
    startUp.labels.version:setFont(awtxConstants.graphics.FONT_LUCIDA_CON_16)
    startUp.labels.version:setVisible(true)

    startUp:newLabel("appDate")
    startUp.labels.appDate:setText(appDate)
    startUp.labels.appDate:setLocation({x=200, y =1})
    startUp.labels.appDate:reSize({width=120,height=18})
    startUp.labels.appDate:setFont(awtxConstants.graphics.FONT_LUCIDA_CON_16)
    startUp.labels.appDate:setVisible(true)

    startUp:newPicturebox("logo", "C:\\Apps\\Graphics\\Logo_Basculas.bmp",{x = 0, y= 80})
end
    -- firstScreen:show()
local function onStart()

    awtx.setpoint.registerOutputEvent(39, onMinWt)
    awtx.setpoint.registerOutputEvent(38, BackToZero.zero)
    onMinWt(nil, false)
    brmChain.onStart()
    if type(CurrentMode.onStart) == 'function' then CurrentMode.onStart() end

    if startUp then
        startUp:show()
    end
end
onStart()


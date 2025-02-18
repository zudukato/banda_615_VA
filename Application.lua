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
require("Reqs.brmScaleKeys")
local brmUtilities = require("Reqs.brmUtilities")

------------------------------------ Setup ----------------------------------------
------------------- Persistent variables for normal application -------------------
--default values
PersistentVars = PersistentVars or {}
PersistentVars.currentMode = "NormalWeight"--provisional
PersistentVars.minWt = 200--min weight
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

Databases = require("databases")
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

function BackToZero.zero(_, setpointActive)
    EventsHandle.events.notBackToZero = false
end
_MinWt = PersistentVars.minWt

local function onMinWt(_, setpointActive)
    EventsHandle.events[EventsHandle.eventList.noMinWt] = not setpointActive
end

--------------------------------------Modules--------------------------------------
OperationModes = {}
local brmChain = require("Reqs.brmChain")
local peripherals = require("Peripherals.brmPeripherals")
local function getModes()
    local path = "C:\\Apps\\operationModes\\"
    local modes = brmUtilities.getFolders(path)
    for _, mode in pairs(modes) do
        local a = "OperationModes."..mode..".".."main"
        print(a)
        OperationModes[mode] = require(a)
    end
    CurrentMode = OperationModes[PersistentVars.currentMode]
end



local function onStart()
    awtx.setpoint.registerOutputEvent(39, onMinWt)
    awtx.setpoint.registerOutputEvent(38, BackToZero.zero)
    onMinWt(nil, false)
end
onStart()
brmChain.onStart()
getModes()


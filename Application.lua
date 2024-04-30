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
local brmAppMenu = require("Reqs.brmAppMenu")
require("Reqs.brmScaleKeys")
local brmUtilities = require("Reqs.brmUtilities")

------------------------------------ Setup ----------------------------------------
------------------- Persistent variables for normal application ------------------- 
--default values
PersistentVars = PersistentVars or {}
PersistentVars.currentMode = "main"--provisional
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
Databases = require("databases")
MenusTree = require("menus")
BackToZero = {}
EventsHandle = EventsHandle or {}
EventsHandle.events = EventsHandle.events or {}

-------Application Events---------

function EventsHandle.checkEvents(listOfEvents)
    if listOfEvents then 
        for _,v in pairs(listOfEvents) do
            if EventsHandle.events[v] then return v end
            if type(EventsHandle.events[v]) =="nil" then print(v," Event do not exist") end
        end
    end
    for event,v in pairs(EventsHandle.events) do
        if v then return event end
    end
end

EventsHandle.events.notBackToZero = false
function BackToZero.notZero()
    if PersistentVars.backToZeroActive then EventsHandle.events.notBackToZero = true end
end

function BackToZero.zero(_, setpointActive)
    EventsHandle.events.notBackToZero = false
end


--------------------------------------Modules--------------------------------------
local brmChain = require("Peripherals.brmChain")
local peripherals = require("Peripherals.brmPeripherals")

CurrentMode = require("operationModes.normalWeight.main")


local function onStart()
    awtx.setpoint.registerOutputEvent(27, BackToZero.zero)
end
onStart()
brmChain.onStart()
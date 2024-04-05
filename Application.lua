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

------------------------------------ Setup ----------------------------------------
------------------------------- Global variables ----------------------------------
Databases = require("databases")
MenusTree = require("menus")
PersistentVars = PersistentVars or {}
ModuleEvents = ModuleEvents or {} ----provitional
BackToZero = {}
ModuleEvents = ModuleEvents or {}

-------Application Events---------

function EventsCheck(listOfEvents)
    if listOfEvents then 
        for _,v in pairs(listOfEvents) do
            if ModuleEvents[v] then return v end
            if type(ModuleEvents[v]) =="nil" then print(v," Event do not exist") end
        end
    end
    for event,v in pairs(ModuleEvents) do
        if v then return event end
    end
end

ModuleEvents.notBackToZero = false
function BackToZero.notZero()
    if PersistentVars.backToZeroActive then ModuleEvents.notBackToZero = true end
end

function BackToZero.zero(_, setpointActive)
    ModuleEvents.notBackToZero = false
end


--------------------------------------Modules--------------------------------------
local brmChain = require("Peripherals.brmChain")
local peripherals = require("Peripherals.brmPeripherals")
------------------- Persistent variables for normal application ------------------- 
--default values
PersistentVars.currentMode = "main"--provisional
PersistentVars.minWt = 200--min weight
PersistentVars.supportPasswords = "762" --support password
PersistentVars.userPassword = "1793" --user password
PersistentVars.shortCuts = {["0000"] = "PrintConf"}--user Password
PersistentVars.headers = {"header1", "header2"}-- ticket headers
PersistentVars.ticketNumber = 0--ticket number
PersistentVars.zeroThreshold = 100
PersistentVars.zeroTareClear = false
PersistentVars.backToZeroActive = true
PersistentVars.language = "ES"

    -- persistent value assignation recalling last saved value
    -- to access "persistentVariable.nameOfVariable.value"
PersistentVars = brmVariables.SavedVariableTable("PersistentVars", PersistentVars, true)

CurrentMode = require("operationModes.normalWeight.main")


local function onStart()
    awtx.setpoint.registerOutputEvent(27, BackToZero.zero)
end
onStart()
brmChain.onStart()
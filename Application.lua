--[[
*******************************************************************************

Filename:      Application.lua
Firmware:      2.5.0.0 or higher
Date:          2023-12-21
Customer:      Juan Alberto Hernandez
Description:
*******************************************************************************
]]
--Reqs
local awtxConstants = require("Reqs.awtxReqConstants")
local awtxVariables = require("Reqs.awtxReqVariables")
local brmUtilities = require("Reqs.brmUtilities")
require("Reqs.awtxReqScaleKeys")


Databases = require("Reqs.brmDatabases")
--------------Setup------------------------
------------------- Persistent variables for normal application -------------------
--default values
PersistentVars = PersistentVars or {}
PersistentVars.currentMode = {value = "main"}--provisional
PersistentVars.minWt = {value = 200}--min weight
PersistentVars.userPassword = {value = 1793}--user Password
PersistentVars.headers = {value = {"header1", "header2"}}-- ticket headers
PersistentVars.ticketNumber = {value = 0}--ticket number
PersistentVars.zeroThreshold = {value = 100}
PersistentVars.zeroTareClear = {value = false}
CurrentMode = require("operationModes.normalWeight.main")

local function onStart()
    -- persistent value assignation recalling last saved value
    -- to access "persistentVariable.nameOfVariable.value"
    for name, defaultValue in pairs(PersistentVars) do
        PersistentVars[name] = awtxVariables.SavedVariable(name, defaultValue, true)
    end

end

onStart()

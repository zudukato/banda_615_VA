--[[
    Application to transmit continuos data 
    to active it you need to select a print format that you are not using
]]

local awtxConstants = require("Reqs.awtxReqConstants")
local brmUtilities = require("Reqs.brmUtilities")
local brmChain = {}
brmChain._chain = "{A.1.1},{A.2.1},{T.GWTAS.1[W8Z1p3]}{T.UNIT.1}#CR#LF" --Estructure of the brm chain

---When the scale motion tis function change the letters stability for the chain
function brmChain.changeStabilityState(num, state)
    awtx.setpoint.unregisterOutputEvent(num) -- To not run again until the function is completed
    awtx.os.systemEvents(70) -- Do not remove it, it is to wait for status updating
    -- Change letters U,O,M,S -> US, OL, US, ST, using the dictionary
    local statusDictionary = {U = "US", O = "OL", M = "US", S = "ST"} 
    local tokenizedStability = "{T.WSTAT.1[S1]},{T.WSTAT.1[S2]},{T.WSTAT.1[S3]}" -- Tokenized string to to get information of scales
    local stabilityStatus =awtx.fmtPrint.printBuffer(tokenizedStability)
    stabilityStatus = stabilityStatus:match("[UOMS]") 
    _StabilityStatus = statusDictionary[stabilityStatus]
    awtx.setpoint.registerOutputEvent(num, brmChain.changeStabilityState) --Enable again setpoint
end

---When the status of a scale change this function change the status of brm chain
function brmChain.changeModeStatus()
    awtx.os.systemEvents(70) -- Do not remove it, it is to wait for status updating
    -- Change N,T,G -> NT, TA, GS  using the dictionary
    local statusDictionary = {N = "NT", T = "TA", G = "GS" }
    local tokenizedModeStatus = "{T.ACT.2[S1]},{T.ACT.2[S2]},{T.ACT.2[S3]}"-- Tokenized string to to get information of scales
    local modeStatus= awtx.fmtPrint.printBuffer(tokenizedModeStatus)
    modeStatus = modeStatus:match("[NTG]")
    _ModeStatus = statusDictionary[modeStatus]
end

function brmChain.onStart()
    -- Defining global vars to update the brm chain
    _StabilityStatus = "ST"
    _ModeStatus = "GS"
    awtx.fmtPrint.varSet(1,"_StabilityStatus","stability status", awtxConstants.fmtPrint.TYPE_STRING_VAR)
    awtx.fmtPrint.varSet(2,"_ModeStatus","mode status", awtxConstants.fmtPrint.TYPE_STRING_VAR)
    awtx.fmtPrint.set(1,brmChain._chain)
    awtx.setpoint.registerOutputEvent(40,brmChain.changeStabilityState)
    awtx.weight.registerSelectCompleteEvent(brmChain.changeModeStatus)
end


return brmChain
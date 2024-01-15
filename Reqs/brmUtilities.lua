local brmUtilities = {}
local awtxConstants = require("Reqs.awtxReqConstants")

function brmUtilities.split(inputString, sep)
    if inputString[#inputString] ~= sep then inputString = inputString..sep end
    inputString = inputString or ""
    sep = sep or "%S"
    local tab = {}
    for subString in string.gmatch(inputString, "(.-)"..sep) do
        table.insert(tab,subString)
    end
    return tab
end

function brmUtilities.doScroll(inputString, stepTime)
    inputString = type(inputString)=="string" and inputString or ""
    stepTime = type(stepTime) and stepTime or 125
    local scaleInfo= awtx.hardware.getSystem()
    local stepLength = string.find(scaleInfo.modelStr, "ZM6") and 30 or 7
    local currentMode = awtx.display.setMode(awtxConstants.display.MODE_USER)
    if #inputString<=stepLength then awtx.display.writeLine(inputString,stepTime) return end
    awtx.display.writeLine(inputString,stepTime)
    local steps = #inputString
    inputString = inputString..string.rep(" ",stepLength)
    for step = 0, steps  do
        awtx.display.writeLine(inputString:sub(step,stepLength+step), stepTime)
    end
    awtx.display.setMode(currentMode)
end

return brmUtilities
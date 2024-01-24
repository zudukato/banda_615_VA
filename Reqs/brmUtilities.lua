local brmUtilities = {}
local awtxConstants = require("Reqs.awtxReqConstants")

--- The 'split' function is used to break a string into smaller parts based on a specific delimiter. 
---@param inputString string --string to break
---@param delimiter? string --delimiter
---@return table <integer,string> --table with the parts
function brmUtilities.split(inputString, delimiter)
    delimiter = delimiter or "%S"
    if type(inputString) ~= "string" then print("not input string") return {} end
    if inputString[#inputString] ~= delimiter then inputString = inputString..delimiter end
    local tab = {}
    for subString in string.gmatch(inputString, "(.-)"..delimiter) do
        table.insert(tab,subString)
    end
    return tab
end

---function to do scroll a string or number in the indicator screen when the string is to long
---@param inputString string|number -- string or number to do scroll
---@param stepTime? integer --time to wait for each steps
function brmUtilities.doScroll(inputString, stepTime)
    inputString = type(inputString)=="string" and inputString or ""
    stepTime = type(stepTime)=="integer" and stepTime or 200
    local scaleInfo= awtx.hardware.getSystem()
    local stepLength = string.find(scaleInfo.modelStr, "ZM6") and 30 or 7
    local currentDisplayMode = awtx.display.setMode(awtxConstants.display.MODE_USER)
    if #inputString<=stepLength then
        awtx.display.writeLine(inputString,stepTime)
        awtx.display.setMode(currentDisplayMode)
        return
    end
    inputString = "  "..inputString
    local steps = #inputString
    inputString = inputString..string.rep(" ",stepLength)
    for step = 0, steps  do
        awtx.display.writeLine(inputString:sub(step,stepLength+step))
        awtx.os.systemEvents(stepTime)
    end
    awtx.display.setMode(currentDisplayMode)
end

---function to format a Date
---@param year integer
---@param month integer
---@param day integer
---@param format? string --name of format string
---@return string|nil --format
function brmUtilities.dateFormat(year, month, day, format)
    local formats = {
        iso = "%4s-%2s-%2s",
    }
    if not year or not month or  not day then print("nil Value") return end
    format = format or "iso"
    if not formats[format] then print("format do not exist") return end
    return string.format(formats[format], year, month, day)
end

---function to format time
---@param hour any
---@param minute any
---@param second any
---@param format? string --name of format string
---@return string|nil --format
function brmUtilities.timeFormat(hour, minute, second, format)
    local formats = {
        iso = string.format("%s:%s:%s", hour, minute, second),
    }
    format = format or "iso"
    if not hour or not minute or not second then print("nil value") end
    if not formats[format] then print("formant do not exist") return end
    return formats[format]
end

---Function to wait scale stability and write "Inestable" while scale motion
---@param scale integer --number of scale
function brmUtilities.waitStability(scale)
    if type(scale) ~= "number" then print("scale should be a number") return end
    local currentDisplayMode = awtx.display.setMode(awtxConstants.display.MODE_USER)
    awtx.display.writeLine("Inestable")
    while awtx.weight.getCurrent(scale).motion do awtx.os.systemEvents(200) end
    awtx.display.setMode(currentDisplayMode)
end

---Function to get kes, values of a table
---@param tab table 
---@return table, table
function brmUtilities.keysValues(tab)
    if type(tab) ~= "table" then return {}, {} end
    local keys, values = {}, {}
    for key, value in pairs(tab) do
        table.insert(keys,key)
        table.insert(values,value)
    end
    return keys,values
end

---function to extract params of each table in a tableList
---@param list table<integer,table<string,any>> --list of tables
---@param paramName string|number -- name of param
---@return table<integer,any> paramList --table list whit params
function brmUtilities.extractParam(list, paramName)
    if type(list) ~= "table" then return {} end
    local paramList = {}
    for _ , tab in pairs(list) do
        table.insert(paramList, tab[paramName])
    end
    return paramList
end

return brmUtilities
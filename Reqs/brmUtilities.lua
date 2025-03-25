local brmUtilities = {}
local awtxConstants = require("Reqs.awtxReqConstants")

--- The 'split' function is used to break a string into smaller parts based on a specific delimiter. 
---@param inputString string --string to break
---@param delimiter? string --delimiter
---@return table <integer,string> --table with the parts
function string.split(inputString, delimiter)
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
    stepTime = type(stepTime)=="number" and stepTime or 200
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
        awtx.display.writeLine(inputString:sub(step,stepLength+step), stepTime)
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
    local preCurrentMode = CurrentMode
    local waitStability = {_name = "waitStability" ,keypad = {} }
    CurrentMode = waitStability
    if type(scale) ~= "number" then print("scale should be a number") return end
    local currentDisplayMode = awtx.display.setMode(awtxConstants.display.MODE_USER)
    awtx.display.writeLine("Inestable")
    while awtx.weight.getCurrent(scale).motion do awtx.os.systemEvents(200) end
    awtx.display.writeLine("Inestable",10)
    awtx.display.setMode(currentDisplayMode)
    CurrentMode = preCurrentMode
end

---Function to get kes, values of a table
---@param tab table 
---@return table, table
function table.keysValues(tab)
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
function table.extractParam(list, paramName)
    if type(list) ~= "table" then return {} end
    local paramList = {}
    for _ , tab in pairs(list) do
        table.insert(paramList, tab[paramName])
    end
    return paramList
end

---function to count number of elements in a table
---@param tableToCount table 
---@return integer -- number of elements
function table.count(tableToCount)
    local count
    for i, _ in tableToCount do
        count = (count or 0) + 1
    end
    return count
end

--- Generates a range of numbers.
---@param start number --Initial number of the range.
---@param stop number --Final number of the range.
---@param step number --Step between numbers in the range. If not specified, defaults to 1. Must be a positive number.
---@return table<integer,number>  --containing the numbers in the specified range.
function math.range(start, stop, step)
    local rangeTable = {}
    local sign = start>stop and -1 or 1
    step = (step and step ~=0) and math.abs(step) or 1 -- to discard 0 an nil
    for i = start, stop, step*sign do
        table.insert(rangeTable, i)
    end
    return (rangeTable)
end

--- Its a function to find the index of a value
---@param table table
---@param valueToFind any
---@return string|number|nil
function table.find(table, valueToFind)
    for key, value in pairs(table) do
        if value == valueToFind then return key end
    end
    return nil
end

--- function to copy a table
---@param from any
---@return table?
function table.copy(from)
    if type(from) ~= "table" then return print("its not a table") end
    local to = {}
    for i,v in pairs(from) do
        to[i] = v
    end
    return to
end


---function to select a file
---@param path string --the path of files "c:\\something\\...\\"
---@param extension? string --filter files wite extension
---@param title? string --The entry title string.
---@param help? string --The entry help string.
---@return string
---@return boolean
function brmUtilities.selectFile(path, extension, title, help)
    title = title or ""
    help = help or ""
    extension = extension or "*"
    local tempFiles= awtx.os.getFiles(path.."*."..extension)
    local files = {}
    for _,value in pairs(tempFiles) do
        local extract = value:gsub(path,""):gsub("."..extension,"")
        table.insert(files, extract)
    end
    local stringFiles = table.concat(files,",") 
    local choice,isEnterKey =awtx.keypad.selectList(stringFiles,1,-1,title,help)
    return files[choice+1], isEnterKey
end

---Function to change 
---@return true|false
function brmUtilities.changeLanguage()
    local languagesPath= "c:\\Apps\\Languages\\"
    local extension = "lua"
    local selectString = (Language and Language.select) and Language.select or "Select"
    local languageString = (Language and Language.language) and Language.language or "Language"
    local language, isEnterKey = brmUtilities.selectFile(languagesPath,extension,selectString, languageString)
    if isEnterKey then 
        PersistentVars.language = language
        Language = require("Languages."..language)
    end
    return isEnterKey
end
---function to reboot the system
function brmUtilities.reboot()
    brmUtilities.doScroll("rebooting", 1000)
    awtx.hardware.reboot()
end


---DO NOT USE IT, IT'S PROBABLY BROKEN
-- ---function who return a table list of folders in a path
-- ---@param path string --the path of files "c:\\something\\...\\"
-- ---@return table
-- function brmUtilities.getFolders(path)
--     local files = awtx.os.getFiles(path,true)
--     local aux = {}
--     local folders = {}
--     for _,value in pairs(files) do
--         local txt = string.gsub(value,path,""):match("%w+\\")
--         if txt then
--             txt = txt:gsub("\\","")
--             aux[txt] = true
--         end
--     end
--     for key,_ in pairs(aux) do
--         table.insert(folders,key)
--     end
--     return folders
-- end

brmUtilities.tableCopy = table.copy
brmUtilities.tableFind = table.find
brmUtilities.keysValues = table.keysValues
brmUtilities.extractParam = table.extractParam
brmUtilities.split = string.split
brmUtilities.range = math.range
return brmUtilities
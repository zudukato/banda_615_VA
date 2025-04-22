local f = {}
local brmUtilities = require("Reqs.brmUtilities")
local brmVariables = require("Reqs.brmVariables")

---function to change headers of tickets
---@param headerNum integer number of header to change
function f.changeHeaders(headerNum)
    local headersList = {}
    --if you change headers, PersistentVars.headers changes to
    local headers = PersistentVars.headers
    local newHeader, isEnterKey = awtx.keypad.enterString(headers[headerNum], 20, -1)
    if not isEnterKey then return end
    PersistentVars.headers[headerNum] = newHeader
    PersistentVars:store("headers")
    brmUtilities.doScroll("OK", 500)
end

function f.changeTicketNumber()
    local number, isEnterKey = awtx.keypad.enterInteger(PersistentVars.ticketNumber, 1, 99999, -1, Language.enter,
        Language._phrases.ticketNumber)
    if not isEnterKey then return end
    PersistentVars.ticketNumber = number
end

---function to change the user password
function f.changeUserPassword()
    local selection, newPassword, isEnterKey
    local options = Language.yes .. ',' .. Language.no
    selection, isEnterKey = awtx.keypad.selectList(options, 1, -1, Language.change, Language.password)
    if not isEnterKey or selection ~= 0 then return end
    newPassword, isEnterKey = awtx.keypad.enterInteger(0, 4, 4, -1, Language.new, Language.password)
    if not isEnterKey then return brmUtilities.doScroll(Language._phrases.noPassword) end
    PersistentVars.userPassword = tostring(newPassword)
end

--- To select a database table
---@return tableClass|nil
function f._selectTable()
    local options = { "productos", "empresas", "taras" }
    local databaseTableName = nil
    local choice, isEnterKey
    choice, isEnterKey = awtx.keypad.selectList(table.concat(options, ","), 0, -1, Language.select, Language.catalogs)
    if not isEnterKey then return end
    databaseTableName = options[choice + 1]
    local databaseTable = Databases.catalogos[databaseTableName]
    return databaseTable
end

function f.changeLanguage()
    if brmUtilities.changeLanguage() then brmUtilities.reboot() end
end

function f.resetDatabases()
    local options = { Language.no, Language.yes }
    local choice, isEnterKey = awtx.keypad.selectList(table.concat(options, ","), 0, -1, Language.reset,
        Language.databases)
    if not isEnterKey then return end
    if options[choice + 1] == Language.no then return end
    for _, database in pairs(Databases) do
        database:close()
        awtx.os.deleteFile(database.path .. database.databaseName)
    end
    awtx.os.deleteFile('c://Databases//*.db')
end

function f.resetWeights()
    local options = { Language.no, Language.yes }
    local choice, isEnterKey = awtx.keypad.selectList(table.concat(options, ","), 0, -1, Language.reset, Language
    .weights)
    if not isEnterKey then return end
    if options[choice + 1] == Language.no then return end
    Databases.pesadas:close()
    awtx.os.deleteFile(Databases.pesadas.path .. Databases.pesadas.databaseName)
end

function f.resetVariables()
    local options = { Language.no, Language.yes }
    local choice, isEnterKey = awtx.keypad.selectList(table.concat(options, ","), 0, -1, Language.reset,
        Language.variables)
    if not isEnterKey then return end
    if options[choice + 1] == Language.no then return end
    brmVariables.deleteAllTables()
end

function f.resetAll()
    local options = { Language.no, Language.yes }
    local choice, isEnterKey = awtx.keypad.selectList(table.concat(options, ","), 0, -1, Language.reset, Language.all)
    if not isEnterKey then return end
    if options[choice + 1] == Language.no then return end
    brmVariables.deleteAllTables()
    for _, database in pairs(Databases) do
        database:close()
        awtx.os.deleteFile(database.path .. database.databaseName)
    end
    awtx.os.deleteFile('c://Databases//*.db')
    brmUtilities.reboot()
end

function f.changeMinWt()
    local minWt
    local isEnterKey
    local wt = awtx.weight.getCurrent(0)
    minWt, isEnterKey = awtx.keypad.enterWeightWithUnits(PersistentVars.minWt, wt.curDivision, wt.curDivision,"kg",0)
    if not isEnterKey then return end
    brmUtilities.doScroll(Language.ok)
    PersistentVars.minWt = minWt
end

local menusTree =
{
    topMenu = {
        { text = Language.ticket,              action = "MENU", value = "ticketsMenu" },
        { text = Language.config,              action = "MENU", value = "config" },
        { text = Language.language,            action = "FUNC", value = f.changeLanguage },
        { text = Language._phrases.chPassword, action = "FUNC", value = f.changeUserPassword },
        { text = Language.reset,               action = "MENU", value = "reset" },
    },
    ticketsMenu = {
        { text = Language.headers,               action = "MENU", value = "headers" },
        { text = Language._phrases.ticketNumber, action = "FUNC", value = f.changeTicketNumber },
    },
    headers = {
        { text = Language.header1, action = "FUNC", value = f.changeHeaders, params = { 1 } },
        { text = Language.header2, action = "FUNC", value = f.changeHeaders, params = { 2 } },
    },
    config = {
        { text = Language._phrases.minWt, action = "FUNC", value = f.changeMinWt },
    },
    reset = {
        { text = Language._phrases.resetAll, action = "FUNC", value = f.resetAll },
        { text = Language.variables,         action = "FUNC", value = f.resetVariables },
        { text = Language.databases,         action = "FUNC", value = f.resetDatabases },
        { text = Language.weights,           action = "FUNC", value = f.resetWeights, onlySupport = true },
    },
}

return menusTree, f

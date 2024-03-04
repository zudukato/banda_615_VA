local f = {}
local brmUtilities = require("Reqs.brmUtilities")

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
end

---function to change the user password
function f.changeUserPassword()
    local selection, newPassword, isEnterKey
    selection, isEnterKey = awtx.keypad.selectList("SI,NO", 1, -1, "Cambiar", "Pass?")
    if not isEnterKey or selection ~= 0 then return end
    newPassword, isEnterKey = awtx.keypad.enterInteger(0, 4, 4, -1, "nueva", "pass")
    if not isEnterKey then return brmUtilities.doScroll("No Password") end
    PersistentVars.userPassword = tostring(newPassword)
end

---function to add a element ito a database 'catalogos'
---@return nil
function f.databaseAdd()
    local value, id, isEnterKey
    local databaseTable = f._selectTable()
    if not databaseTable then return end
    id, isEnterKey = awtx.keypad.enterString("", 10, -1, "enterId", "Enter", "ID")
    if not isEnterKey then return end
    if #databaseTable:find("id", id) >= 1 then return brmUtilities.doScroll("Already exist", 100) end
    value, isEnterKey = awtx.keypad.enterString("", 10, -1, "enterValue", "Enter", "Name")
    databaseTable:addRow({ id, value })
    brmUtilities.doScroll("OK", 500)
end

---function to delete a element ito a database 'catalogos'
function f.databaseDelete()
    local value, id, isEnterKey
    local databaseTable = f._selectTable()
    if not databaseTable then return end
    id, isEnterKey = awtx.keypad.enterString("", 10, -1, "enterId", "ENTER", "ID")
    if not isEnterKey then return end
    if #databaseTable:find("id", id) == 0 then return brmUtilities.doScroll("Not exist", 100) end
    local _, result = databaseTable:deleteRow("id", id)
    if not result or result.valuesExec ~= 0 then return brmUtilities.doScroll("Error", 1000) end
    brmUtilities.doScroll("OK", 500)
end

---function to delete a element ito a database 'catalogos'
function f.databaseEdit()
    local value, id, isEnterKey
    local databaseTable = f._selectTable()
    if not databaseTable then return end
    id, isEnterKey = awtx.keypad.enterString("", 10, -1, "enterId", "ENTER", "ID")
    if not isEnterKey then return end
    if #databaseTable:find("id", id) == 0 then return brmUtilities.doScroll("Not exist", 100) end
    value, isEnterKey = awtx.keypad.enterString("", 10, -1, "enterValue", "Enter", "Name")
    local _, result = databaseTable:updateRow({ value = value }, "id", id)
    if not result or result.valuesExec ~= 0 then return brmUtilities.doScroll("Error", 1000) end
    brmUtilities.doScroll("OK", 500)
end

--- To select a database table
---@return tableClass|nil
function f._selectTable()
    local options = { "productos", "empresas", "taras" }
    local databaseTableName = nil
    local choice, isEnterKey
    choice, isEnterKey = awtx.keypad.selectList(table.concat(options, ","), 0, -1, "SELECCIONE", "CAT.")
    if not isEnterKey then return end
    databaseTableName = options[choice + 1]
    local databaseTable = Databases.catalogos[databaseTableName]
    return databaseTable
end

local menusTree = 
{
    topMenu = {
        { text = "BOLETOS",   action = "MENU",   value = "ticketsMenu" },
        { text = "CONFIG",    action = "MENU",   value = "config" },
        { text = "CATALOGOS", action = "MENU",   value = "catalogos" },
        { text = "PRINT",     action = "FUNC",   value = print, params = { 1, 2, 4 } },
        { text = "CH.PASS",   action = "FUNC",   value = f.changeUserPassword },
        { onlySupport = true, text = "SENTINEL", action = "MENU", value = "password" },
        { onlySupport = true, text = "PESADASDB", action = "MENU", value = "pesadas" },
    },
    ticketsMenu = {
        { text = "HEADERS", action = "MENU", value = "headers" },
        { text = "BOL.NUM", action = "FUNC", value = f.changeTicketNumber},
    },
    headers = {
        { text = "HEADER1", action = "FUNC", value = f.changeHeaders, params = { 1 } },
        { text = "HEADER2", action = "FUNC", value = f.changeHeaders, params = { 2 } },
    },
    catalogos = {
        { text = "AGREGAR",  action = "FUNC", value = f.databaseAdd },
        { text = "ELIMINAR", action = "FUNC", value = f.databaseDelete },
        { text = "EDITAR",   action = "FUNC", value = f.databaseEdit },
    },
    config = {
    },
    pesadas = {
        { text = "CONTAR",  action = "FUNC", value = function ()
            brmUtilities.doScroll(Databases.pesadas.segundaPesada:countRecord())
            print(awtx.os.memoryMaxUsage())
        end },
    }

}

return menusTree

local brmScreenRAD6015     = require("Reqs.brmScreenRAD6015")
local database = require("operationModes.EPI.epiDatabase")
local brmUtilities = require("Reqs.brmUtilities")
local importProducts  = {keypad = {}}
local exitFlag = true
---@type string[]

importProducts.screen = brmScreenRAD6015.newScreen("importProducts")
importProducts.screen:newLabel("title", "Importar Productos", { x = 0, y = 0 },
    { width = 400, height = 30 },
    0, 30, true, false)
importProducts.screen:newLabel("info","" , { x = 0, y = 40 },
    { width = 100, height = 30 },
    0,31, true, false)
importProducts.screen:newLabel("count", "", { x = 120, y = 110 }, { width = 39, height = 20 }, 5, 4, true, false)
importProducts.screen:newLabel("total", "", { x = 160, y = 110 }, { width = 39, height = 20 }, 4, 4, true, false)
importProducts.screen:newLabel("statusBar", "", { x = 0, y = 135 },
    { width = 319, height = 10 },
    10, 4, true, true)

importProducts.screen:newButton("enter", "Enter", { x = 130, y = 148 }, { width = 60, height = 30 }, 2, 4, true,
    false)
importProducts.screen:newButton("exit", "EXIT", { x = 258, y = 148 }, { width = 60, height = 20 }, 2, 4, true, false)
local PrevMode

importProducts.init = function (prevMode)
    PrevMode = prevMode
    importProducts.screen.labels.count:setText("")
    importProducts.screen.labels.total:setText("")
    importProducts.screen.labels.info:setText("")
    CurrentMode = importProducts
    importProducts.screen:show()
end


---This function should be changed; we should use a function in brmSqlClass, but it does not exist yet. 
importProducts.import = function ()
    exitFlag = false
    local path = importProducts.getPath()
    if not path then exitFlag = true; return end
    importProducts.screen.labels.info:setText("ESPERE")
    local tr = table.csvToTable(path)
    importProducts.screen.labels.info:setText("")
    ---@diagnostic disable-next-line: invisible
    local dbHandle = database.tables.products._dbHandle
    local total = #tr
    importProducts.screen.labels.total:setText(("/%d"):format(total))
    importProducts.screen.labels.total:setVisible(true)
    importProducts.screen.labels.count:setVisible(true)
    dbHandle:exec("BEGIN TRANSACTION")
    for i, row in pairs(tr) do
        if #row >= 11 then
            local result, query = pcall(function()
                return string.format("REPLACE INTO products VALUES(%d,'%s','%s',%f,%f,%f,%f,%f,%f,%f,'%s')",
                    tonumber(row[1]), row[2], row[3], tonumber(row[4]), tonumber(row[5]),
                    tonumber(row[6]), tonumber(row[7]), tonumber(row[8]), tonumber(row[9]), tonumber(row[10]), row[11])
            end)
            if result then
                dbHandle:exec(query)
            end
            importProducts.screen.labels.count:setText(("%d"):format(i))
            local prop = math.floor((i * 300) / total)
            awtx.graphics.fillRect(10, 90, prop, 10, 0)
        end
    end
    dbHandle:exec("COMMIT")
    exitFlag = true
    print("done")
end

importProducts.getPath = function ()
    local path = awtx.os.amISimulator() and "c:\\Apps\\Reqs\\" or "g:\\"
    local pathList = awtx.os.getFiles(path)
    _, pathList = brmUtilities.keysValues(pathList)
    if not type(pathList) then return brmUtilities.doScroll('No USB', 1000) end
    local newPathList = {}
    local i = 1
    for _, path in pairs(pathList) do
        if path:find(".csv") then table.insert(newPathList,path) end
    end
    if #newPathList == 0 then return brmUtilities.doScroll("No File") end
    local choice, isEnterKey = awtx.keypad.selectList(table.concat(newPathList,','), 1, -1, "select file")
    if not isEnterKey then return end
    return newPathList[choice+1]
end

importProducts.keypad.onF3KeyUp =function ()
    if not exitFlag then return end
    importProducts.import()
end 
importProducts.keypad.onF5KeyUp = function()
    if not exitFlag  then return end
    PrevMode.init()
end
return importProducts
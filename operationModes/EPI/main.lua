local brmUtilities = require("Reqs.brmUtilities")
local brmAppMenu = require("Reqs.brmAppMenu")
local awtxConstants = require("Reqs.awtxReqConstants")
local brmScaleKeys = require("Reqs.brmScaleKeys")
local brmScreen = require("Reqs.brmScreenRAD6015")
local modeEpi = require("operationModes.EPI.epi")
local database = require("operationModes.EPI.epiDatabase")
local epiMenu = require("EPI.menu")
local brmVariables = require("Reqs.brmVariables")

---@alias EpiVars.operationMode
---|"ONLINE"
---|"OFFLINE"

EpiVars = {}
EpiVars.serialId = 1
EpiVars.classification = 0
EpiVars.serialNumber = 0
EpiVars.scaleId = 0
---@type EpiVars.operationMode
EpiVars.operationMode = "ONLINE"
EpiVars.staticWeightRange = 0
EpiVars.variableWeightRange = 0

EpiVars = brmVariables.SavedVariableTable("EpiVars", EpiVars, true)

local home = {}
local modeVpt = {}
home.operationActive = false
---@type brmScaleKeys.KeypadEvents
home.keypad = {}


home.screen = brmScreen.newScreen("firstScreen")
if not home.screen then return end
home.screen:newScale("mainScale", 0, 2, { x = 0, y = 15 })
------labels
home.screen:newLabel("header", "PLANTA VALOR AGREGADO", { x = 0, y = 0 }, { width = 320, height = 12 }, 10, 4, true, true)
home.screen:newLabel("vpt", "VALIDAR PRODUCTO TERMINADO..........[F1]", { x = 0, y = 75 }, { height = 10, width = 320 })
home.screen:newLabel("ema", "ENVIAR MOVIMIENTOS ALMACENADOS......[F2]", { x = 0, y = 90 }, { height = 10, width = 320 })
home.screen:newLabel("cdi", "CONFIGURACION DEL INDICADOR.........[F3]", { x = 0, y = 105 }, { height = 10, width = 320 })
home.screen:newLabel("epi", "EMPACAR PRODUCTO INDIVIDUAL.........[F4]", { x = 0, y = 120 }, { height = 10, width = 320 })
home.screen:newLabel("statusBar", "", { x = 0, y = 135 }, { width = 320, height = 10 }, 9, 4, true, true)
for _, label in pairs(home.screen.labels) do
    label:setFont(awtxConstants.graphics.FONT_LUCIDA_CON_10)
end

------buttons
home.screen:newButton("vpt", "VPT", { x = 2, y = 148 }, { width = 60, height = 30 }, 2, 4)
home.screen:newButton("send", "SEND", { x = 66, y = 148 }, { width = 60, height = 30 }, 2, 4)
home.screen:newButton("config", "CONFIG", { x = 130, y = 148 }, { width = 60, height = 30 }, 2, 4)
home.screen:newButton("epi", "EPI", { x = 194, y = 148 }, { width = 60, height = 30 }, 2, 4)

--keys assignations
home.keypad = brmScaleKeys.defaultKeypad
home.rpn = brmScaleKeys.defaultRpn
home.keypad.onF3KeyDown = function(...)
    local value, isEnterKey = awtx.keypad.enterInteger(0, 0, 999999, 3000, "Enter Password:")
    if not isEnterKey then return end
    brmAppMenu.onPasswordEntered(tostring(value))
end

home.keypad.onF1KeyDown = function()
    CurrentMode = modeVpt
    if CurrentMode.screen then CurrentMode.screen:show() end
end

home.keypad.onF4KeyDown = function()
    local value, isEnterKey = awtx.keypad.enterInteger(0, 0, 9999, -1, "Enter", "Orden T")
    if not isEnterKey then return end
    modeEpi.init(value)
    CurrentMode = modeEpi
end

home.keypad.onQwertyKeyUp = function(...)
    print(...)
end

function home.keypad.onClearKeyUp(...)
    print()
end

function home.keypad.onPrintKeyDown()
    -- Printer.doPrint(Printer.printers.EscPos.firstW)
    -- local file = io.open("C:\\Apps\\PrintFormats\\firstW.txt")
    -- local dato = file:read('*all')
    -- local datos = brmUtilities.split(dato,'\r\n')
    -- file:close()
    -- for _,line in pairs(datos) do
    --     awtx.fmtPrint.set(1,line.."\r\n")
    --     awtx.weight.getRefreshLastPrint(1)
    --     awtx.printer.printFmt(1)
    --     awtx.os.systemEvents(1000)
    -- end
end

home.onStart = function()
    local prevKeypad = home.keypad
    home.keypad = {}
    awtx.os.enhancedTimer.new(1, function()
        home.keypad = prevKeypad
        home.screen:show()
    end, 3000, 1)
end
----ModeVPT
modeVpt.operationActive = true
---@type brmScaleKeys.KeypadEvents
modeVpt.keypad = {}
modeVpt.screen = brmScreen.newScreen("VPT")
modeVpt.screen:newLabel("header", "PLANTA VALOR AGREGADO", { x = 0, y = 0 }, { width = 320, height = 12 }, 10, 4, true,
    true)
modeVpt.screen:newLabel("label1", "VALIDAR PRODUCTO TERMINADO", { x = 0, y = 80 }, { width = 320, height = 18 }, 10, 4,
    true, true)
modeVpt.screen:newLabel("label2", "INIT TRANSMISSION [ENTER]", { x = 0, y = 100 }, { width = 320, height = 18 }, 10, 4,
    true)
modeVpt.screen:newButton("enter", "ENTER", { x = 66, y = 148 }, { width = 60, height = 30 }, 2, 4)
modeVpt.screen:newButton("stop", "STOP", { x = 130, y = 148 }, { width = 60, height = 30 }, 2, 4)
modeVpt.screen:newButton("back", "BACK", { x = 258, y = 148 }, { width = 60, height = 30 }, 2, 4)
modeVpt.screen:newScale("mainScale", 0, 2, { x = 0, y = 15 })
function modeVpt.keypad.onF5KeyDown()
    CurrentMode = home
    CurrentMode.screen:show()
end

function modeVpt.keypad.onQwertyKeyUp(char)
end

modeVpt.onStart = function()
    modeVpt.screen:show()
end


function home.keypad.onTargetKeyHold()
    local tr = table.csvToTable("C:\\Apps\\Reqs\\New CA.csv")
    local dbHandle = database.products._dbHandle
    dbHandle:exec("BEGIN TRANSACTION")

    for _, row in pairs(tr) do
        if #row >= 11 then
            local result, query = pcall(function()
                return string.format("REPLACE INTO products VALUES(%d,'%s','%s',%f,%f,%f,%f,%f,%f,%f,'%s')",
                    tonumber(row[1]), row[2], row[3], tonumber(row[4]), tonumber(row[5]),
                    tonumber(row[6]), tonumber(row[7]), tonumber(row[8]), tonumber(row[9]), tonumber(row[10]), row[11])
            end)
            if result then
                dbHandle:exec(query)
            end
        end
    end
    dbHandle:exec("COMMIT")
end

return home

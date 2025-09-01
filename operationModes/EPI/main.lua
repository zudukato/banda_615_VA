local brmUtilities = require("Reqs.brmUtilities")
local brmAppMenu = require("Reqs.brmAppMenu")
local awtxConstants = require("Reqs.awtxReqConstants")
local brmScaleKeys = require("Reqs.brmScaleKeys")
local brmScreen = require("Reqs.brmScreenRAD6015")
local modeEpi = require("operationModes.EPI.epi")
local database = require("operationModes.EPI.epiDatabase")
local epiMenu = require("EPI.menu")
local brmVariables = require("Reqs.brmVariables")
local brmChain = require("Reqs.brmChain")

---@alias EpiVars.operationMode
---|"ONLINE"
---|"OFFLINE"

EpiVars = {}
EpiVars.date = os.date("%Y-%m-%d")
EpiVars.serialId = "R1"
EpiVars.classification = 1
EpiVars.scaleId = 1
EpiVars.operationNumber = 1
EpiVars.bandSpeed = 0
---@type EpiVars.operationMode
EpiVars.operationMode = "ONLINE"
EpiVars.boxWeight = false
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
home.screen:newLabel("vpt", Language._phrases.validateFinishedProductMenu, { x = 0, y = 75 }, { height = 10, width = 320 })
home.screen:newLabel("ema", Language._phrases.sendStoredMovementsMenu, { x = 0, y = 90 },{ height = 10, width = 320 })
home.screen:newLabel("cdi", Language._phrases.indicatorConfigurationMenu, { x = 0, y = 105 },{ height = 10, width = 320 })
home.screen:newLabel("epi", Language._phrases.packIndividualProductMenu, { x = 0, y = 120 },{ height = 10, width = 320 })
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
home.keypad = table.copy(brmScaleKeys.defaultKeypad) or {}
home.rpn = table.copy(brmScaleKeys.defaultRpn) or {}
home.keypad.onF3KeyDown = function(...)
    local value, isEnterKey = awtx.keypad.enterInteger(0, 0, 999999, 3000, Language.enter.." "..Language.password)
    if not isEnterKey then return end
    brmAppMenu.onPasswordEntered(tostring(value))
end

home.keypad.onF1KeyDown = function()
    home.exit()
    modeVpt.init()
end

home.keypad.onF4KeyDown = function()
    local value, isEnterKey = awtx.keypad.enterInteger(0, 0, 9999, -1, Language.enter, Language._phrases.orderT)
    if not isEnterKey then return end
    home.exit()
    modeEpi.init(value, home)
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
    _BandSpeed = EpiVars.bandSpeed
    awtx.fmtPrint.varSet(60, "_BandSpeed","Band speed (hz)",awtxConstants.fmtPrint.TYPE_FLOAT_VAR )
    awtx.fmtPrint.set(2,"{A.60.1}")
    CurrentMode = { keypad = {} }
    awtx.os.enhancedTimer.new(1, function()
        home.init()
    end, 3000, 1)
end

home.init = function()
    awtx.keypad.setRpnMode(1)
    CurrentMode = home
    awtx.weight.requestTareClear()
    home.screen:show()
end

home.exit = function()
    awtx.keypad.setRpnMode(0)
end
----ModeVPT
modeVpt.operationActive = true
---@type brmScaleKeys.KeypadEvents
modeVpt.keypad = {}
modeVpt.screen = brmScreen.newScreen("VPT")
modeVpt.screen:newLabel("header", "PLANTA VALOR AGREGADO", { x = 0, y = 0 }, { width = 320, height = 12 }, 10, 4, true,
    true)
modeVpt.screen:newLabel("label1",Language._phrases.validateFinishedProduct, { x = 0, y = 80 }, { width = 320, height = 18 }, 10, 4,
    true, true)
modeVpt.screen:newLabel("label2", Language._phrases.initTransmission, { x = 0, y = 100 }, { width = 320, height = 18 }, 10, 4,
    true)
modeVpt.screen:newButton("enter", "ENTER", { x = 130, y = 148 }, { width = 60, height = 30 }, 2, 4)
modeVpt.screen:newButton("stop", "STOP", { x = 194, y = 148 }, { width = 60, height = 30 }, 2, 4, false)
modeVpt.screen:newButton("back", "BACK", { x = 258, y = 148 }, { width = 60, height = 30 }, 2, 4)
modeVpt.screen:newScale("mainScale", 0, 2, { x = 0, y = 15 })
function modeVpt.keypad.onF5KeyDown()
    modeVpt.exit()
    home.init()
end

function modeVpt.keypad.onF3KeyUp()
    if not modeVpt.screen.buttons.enter.visible then return end
    modeVpt.screen.buttons.enter:setVisible(false)
    modeVpt.screen.buttons.stop:setVisible(true)
    awtx.system.protocol.setRate(1, 10)
end

function modeVpt.keypad.onF4KeyUp()
    if not modeVpt.screen.buttons.stop.visible then return end
    modeVpt.screen.buttons.stop:setVisible(false)
    modeVpt.screen.buttons.enter:setVisible(true)
    awtx.system.protocol.setRate(1, 0)
end

modeVpt.rpn = table.copy(brmScaleKeys.defaultRpn) or {}
modeVpt.init = function()
    CurrentMode = modeVpt
    awtx.keypad.setRpnMode(1)
    brmChain.onStart()
    modeVpt.screen.labels.label2:setText(Language._phrases.initTransmission)
    modeVpt.screen.buttons.enter:setVisible(true)
    modeVpt.screen.buttons.stop:setVisible(false)
    modeVpt.screen:show()
end

modeVpt.exit = function()
    awtx.system.protocol.setRate(1, 0)
end


function home.keypad.onTargetKeyHold()
    local tr = table.csvToTable("C:\\Apps\\Reqs\\New CA.csv")
    ---@diagnostic disable-next-line: invisible
    local dbHandle = database.tables.products._dbHandle
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
    print("done")
end

return home

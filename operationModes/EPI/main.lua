local brmUtilities = require("Reqs.brmUtilities")
local brmAppMenu = require("Reqs.brmAppMenu")
local awtxConstants = require("Reqs.awtxReqConstants")
local brmScaleKeys = require("Reqs.brmScaleKeys")
local brmScreen = require("Reqs.brmScreenRAD6015")
---@type language

local home = {}
local modeVPT = {}
home.operationActive = true
home.keypad = {}


home.screen = brmScreen.newScreen("firstScreen")
if not home.screen then return end
home.screen:newScale("mainScale",0, 2,{x=0,y=15})
------labels
home.screen:newLabel("header", "PLANTA VALOR AGREGADO", {x=0,y=0},{width=320, height=12},10,4,true,true)
home.screen:newLabel("vpt","VALIDAR PRODUCTO TERMINADO..........[F1]",{x=0,y=75},{height=10,width=320})
home.screen:newLabel("ema","ENVIAR MOVIMIENTOS ALMACENADOS......[F2]",{x=0, y=90},{height=10, width=320})
home.screen:newLabel("cdi","CONFIGURACION DEL INDICADOR.........[F3]", {x=0,y=105},{height=10, width=320})
home.screen:newLabel("epi","EMPACAR PRODUCTO INDIVIDUAL.........[F4]",{x=0,y=120},{height=10, width=320})
home.screen:newLabel("statusBar","",{x=0,y=135},{width=320, height=10},nil,nil,true,true)
for _,label in pairs(home.screen.labels) do
    label:setFont(awtxConstants.graphics.FONT_LUCIDA_CON_10)
end

    ------buttons
home.screen:newButton("vpt","VPT",{x=2,y=148}, {width=60, height=30}, 2,4)
home.screen:newButton("send","SEND",{x=66,y=148}, {width=60, height=30}, 2,4)
home.screen:newButton("config","CONFIG",{x=130,y=148}, {width=60, height=30}, 2,4)
home.screen:newButton("epi","EPI",{x=194,y=148}, {width=60, height=30}, 2,4)

--keys assignations
home.keypad = brmScaleKeys.defaultKeypad
home.rpn= brmScaleKeys.defaultRpn
home.keypad.onF3KeyDown = function (...)
    local value, isEnterKey = awtx.keypad.enterInteger(0,0,999999,3000,"Enter Password:")
    if not isEnterKey then return end
    brmAppMenu.onPasswordEntered(tostring(value))
end

home.keypad.onF1KeyDown = function ()
    CurrentMode = modeVPT
    if CurrentMode.screen then CurrentMode.screen:show() end
end

home.keypad.onKeyQwertyUp = function (...)
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
home.onStart = function ()
    awtx.os.enhancedTimer.new(1,function () home.screen:show()  end, 3000,1)
end

modeVPT.operationActive = true
modeVPT.keypad = {}
modeVPT.screen = brmScreen.newScreen("VPT")
modeVPT.screen:newLabel("header", "PLANTA VALOR AGREGADO", {x=0,y=0},{width=320, height=12},10,4,true,true)
modeVPT.screen:newLabel("label1", "VALIDAR PRODUCTO TERMINADO", {x=0,y=80},{width=320, height=18},10,4,true,true)
modeVPT.screen:newLabel("label2", "INIT TRANSMISSION [ENTER]", {x=0,y=100},{width=320, height=18},10,4,true)
modeVPT.screen:newButton("enter","ENTER",{x=66,y=148}, {width=60, height=30}, 2,4)
modeVPT.screen:newButton("stop","STOP",{x=130,y=148}, {width=60, height=30}, 2,4)
modeVPT.screen:newButton("back","BACK",{x=194,y=148}, {width=60, height=30}, 2,4)
modeVPT.screen:newScale("mainScale",0, 2,{x=0,y=15})

function modeVPT.keypad.onF4KeyDown()
    CurrentMode = home
    CurrentMode.screen:show()
end

function modeVPT.keypad.onKeyQwertyUp(...)
    print(...)
end


modeVPT.onStart = function ()
    modeVPT.screen:show()
end


return home
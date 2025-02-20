local brmUtilities = require("Reqs.brmUtilities")
local awtxConstants = require("Reqs.awtxReqConstants")
local screen405 = require("Reqs.brmScreenRAD405Class")
local brmScaleKeys = require("Reqs.brmScaleKeys")
---@type language

local normalMode = {}
normalMode.operationActive = true
normalMode.keypad = {}
local screens = {
    weightOk = screen405:new("weightOk", Language.weight, Language.ok..Language.questionSign,nil,false)
}

function normalMode.firstWt(plate)
    local chofer = awtx.keypad.enterString("", 1000,-1,Language.enter,Language.driver)
    local requiredFields = {Databases.catalogos.empresas,
                            Databases.catalogos.productos}
    local values = normalMode._requiereFields(requiredFields)
    if values == nil then return brmUtilities.doScroll(Language.cancel) end
    local requiereEventList = {EventsHandle.eventList.noMinWt,
                                EventsHandle.eventList.DAP1, EventsHandle.eventList.DAP2,
                                EventsHandle.eventList.DAP3,EventsHandle.eventList.DAP4,}
    local wt = normalMode._takeWeight(requiereEventList)
    if not wt then return end
    local year, month, day, hour, minute, second = awtx.os.readDateAndTime()
    local date = brmUtilities.dateFormat(year, month,day)
    local time = brmUtilities.dateFormat(hour, minute, second)
    ---save weight
    local response = Databases.pesadas.primeraPesada:addRow({
    1, plate, chofer, wt.gross, wt.unitsStr, date, time,
    values.empresas.Id, values.empresas.Value,
    values.productos.Id, values.productos.Value})
    brmUtilities.doScroll(Language.saved, 500)
    print(response)
    BackToZero.notZero()
end

function normalMode.secondWt(plate)
    local requiereEventList = {EventsHandle.eventList.noMinWt,
                                EventsHandle.eventList.DAP1, EventsHandle.eventList.DAP2,
                                EventsHandle.eventList.DAP3,EventsHandle.eventList.DAP4,}
    local wt = normalMode._takeWeight(requiereEventList)
    if not wt then return end
    local year, month, day, hour, minute, second = awtx.os.readDateAndTime()
    local date = brmUtilities.dateFormat(year, month,day)
    local time = brmUtilities.dateFormat(hour, minute, second)
    local response = Databases.pesadas.primeraPesada:find("Placas",plate)
    local primeraPesada = response[1]
    local gross = wt.gross>primeraPesada.PesoIn and wt.gross or primeraPesada.PesoIn
    local net = math.abs(wt.gross-primeraPesada.PesoIn)
    local tare = gross - net
    Databases.pesadas.segundaPesada:addRow({
        primeraPesada.Folio,
        primeraPesada.Placas,
        primeraPesada.Chofer,
        primeraPesada.PesoIn,
        primeraPesada.UnitsIn,
        primeraPesada.FechaIn,
        primeraPesada.HoraIn,
        wt.gross,
        wt.unitsStr,
        date, time,
        gross, tare, net,
        primeraPesada.IdEmpresa,
        primeraPesada.Empresa,
        primeraPesada.IdProducto,
        primeraPesada.Producto
    })
    Databases.pesadas.primeraPesada:deleteRow("Placas", plate)
    brmUtilities.doScroll(Language.saved, 500)
    EventsHandle.events.notBackToZero="No zero"
end

function normalMode._takeFullPlates()
    if not normalMode.operationActive then return end
end

function normalMode.fullFirstWt(plates)
end

function normalMode.fullSecondWt(plates)
end

function normalMode.simpleWt()
end

function normalMode._takePlates()
    if not normalMode.operationActive then return end
    -- if not ModuleEvents.notBackToZero then brmUtilities.doScroll(language._phrases.noZero) end
    local value, isEnterKey = awtx.keypad.enterString("", 1000,-1,Language.enter,Language.plates)
    if not isEnterKey then return end
    local response = Databases.pesadas.primeraPesada:countRecord("placas",value)
    if response == 0 then return normalMode.firstWt(value) end
    return normalMode.secondWt(value)
end

function normalMode._takeWeight(requiereEventList)
    while true do
        screens.weightOk:clear()
        screens.weightOk:show()
        if not brmScaleKeys.waitKey(awtxConstants.keys.onZeroKeyUp, true) then return screens.weightOk:clear() end
        if not EventsHandle.checkEvents(requiereEventList) then
            screens.weightOk:clear()
            brmUtilities.doScroll(Language.done)
            break
        -- if event then return brmUtilities.doScroll(ModuleEvents[event]) end
        end
     end
     return awtx.weight.getCurrent(1)
end
------------------------------------------------------------pleas check later to change the form of language---------------------------------------------------------------


-- function to take requiere files id and if it exist returns Ids
---@param requiredFields table <number ,tableClass> -- Database class
---@returns table<string,table>|nil idValues --list with values
function normalMode._requiereFields(requiredFields)
    local values, isEnterKey = {}, nil
    local tempId
    local tempValue
    for _, field in pairs(requiredFields) do
        tempId, isEnterKey = awtx.keypad.enterInteger(0,0,10000,-1,Language.enter,field.tableName.." id")
        if not isEnterKey then brmUtilities.doScroll(field.tableName..Language._phrases.isRequired,100) return end
        tempValue = field:find("id", tostring(tempId))
        if #tempValue == 0 then
            brmUtilities.doScroll(Language._phrases.idDoNotExist,100)
            return
        end
        values[field.tableName] = tempValue[1]
        brmUtilities.doScroll(Language.ok,500)
    end
    return values
end

--keys assignations
normalMode.keypad = brmScaleKeys.defaultKeypad
normalMode.rpn= brmScaleKeys.defaultRpn
function normalMode.keypad.onStartKeyDown()
    return normalMode._takePlates()
end
function normalMode.keypad.onPrintKeyDown()
    Printer.doPrint(Printer.printers.EscPos.firstW)
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
normalMode.onStart = function ()
    print('starting')
end
return normalMode
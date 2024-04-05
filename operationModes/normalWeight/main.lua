local brmUtilities = require("Reqs.brmUtilities")
local awtxConstants = require("Reqs.awtxReqConstants")
local screen405 = require("Reqs.brmScreenRAD405Class")
local brmScaleKeys = require("Reqs.brmScaleKeys")
---@type language
local language = require(PersistentVars.language)

local normalMode = {}
normalMode.operationsActive = true
normalMode.keypad = {}
local screens = {
    weightOk = screen405:new("weightOk", language.weight, language.ok..language.questionSign,nil,"nos"),
}

function normalMode.firstWt(plate)
    local chofer = awtx.keypad.enterString("", 1000,-1,language.enter,language.driver)
    local requiredFields = {Databases.catalogos.empresas,
                            Databases.catalogos.productos}
    local values = normalMode._requiereFields(requiredFields)
    if values == nil then return brmUtilities.doScroll(language.cancel) end
    local wt
    screens.weightOk:show()
    while true do
        if not brmScaleKeys.waitKey(awtxConstants.keys.onZeroKeyUp) then break end
        wt = awtx.weight.getCurrent().gross
        if wt>=PersistentVars.minWt then 
            screens.weightOk:clear()
            brmUtilities.doScroll(language.done)
            break
        end
     end
    
    -- local wt = awtx.weight.getCurrent(0)
    -- if values == nil then return end
    -- ---get weight
    -- brmUtilities.waitStability(0)
    -- if PersistentVars.minWt> wt.gross then return brmUtilities.doScroll(language._phrases.noMinWeight) end --cambiar
    -- local event = CheckActiveModuleEvents({"DAP1","DAP2","DAP3","DAP4","notBackToZero"})
    -- if event then return brmUtilities.doScroll(ModuleEvents[event]) end
    -- local year, month, day, hour, minute, second = awtx.os.readDateAndTime()
    -- local date = brmUtilities.dateFormat(year, month,day)
    -- local time = brmUtilities.dateFormat(hour, minute, second)
    -- ---save weight
    -- local response = Databases.pesadas.primeraPesada:addRow({
    -- 1, plate, chofer, wt.gross, wt.unitsStr, date, time,
    -- values.empresas.Id, values.empresas.Value,
    -- values.productos.Id, values.productos.Value})
    -- brmUtilities.doScroll(language.saved, 500)
    -- ModuleEvents.notBackToZero="Not zero"
end

function normalMode.secondWt(plate)
    brmUtilities.waitStability(0)
    local wt = awtx.weight.getCurrent(0)
    if PersistentVars.minWt> wt.gross then return brmUtilities.doScroll(language._phrases.noMinWeight) end --cambiar
    local event = CheckActiveModuleEvents({"DAP1","DAP2","DAP3","DAP4","notBackToZero"})
    if event then return brmUtilities.doScroll(ModuleEvents[event]) end
    local year, month, day, hour, minute, second = awtx.os.readDateAndTime()
    local date = brmUtilities.dateFormat(year, month,day)
    local time = brmUtilities.dateFormat(hour, minute, second)
    local response = Databases.pesadas.primeraPesada:find("Placas",plate)
    if #response<1 then return print(" Second weight No plates found") end
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
    brmUtilities.doScroll(language.saved, 500)
    ModuleEvents.notBackToZero="No zero"
end

function normalMode._takeFullPlates()
    if not normalMode.operationsActive then return end
end

function normalMode.fullFirstWt(plates)
end

function normalMode.fullSecondWt(plates)
end

function normalMode.simpleWt()
end

function normalMode._takePlates()
    if not normalMode.operationsActive then return end
    -- if not ModuleEvents.notBackToZero then brmUtilities.doScroll(language._phrases.noZero) end
    local value, isEnterKey = awtx.keypad.enterString("", 1000,-1,language.enter,language.plates)
    if not isEnterKey then return end
    local response = Databases.pesadas.primeraPesada:countRecord("placas",value)
    if response == 0 then return normalMode.firstWt(value) end
    return normalMode.secondWt(value)

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
        tempId, isEnterKey = awtx.keypad.enterInteger(0,0,10000,-1,language.enter,field.tableName.." id")
        if not isEnterKey then brmUtilities.doScroll(field.tableName..language._phrases.isRequired,100) return end
        tempValue = field:find("id", tostring(tempId))
        if #tempValue == 0 then
            brmUtilities.doScroll(language._phrases.idNotExist,100)
            return
        end
        values[field.tableName] = tempValue[1]
        brmUtilities.doScroll(language.ok,500)
    end
    return values
end

--keys assignations
function normalMode.keypad.onStartKeyDown()
    return normalMode._takePlates()
end
return normalMode
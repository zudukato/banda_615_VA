local brmUtilities = require("Reqs.brmUtilities")

local normalMode = {}
normalMode.keypad = {}

function normalMode.firstWt(plate)
    local chofer = awtx.keypad.enterString("", 1000,-1,"ENTER","CHOFER")
    local requiredFields = {Databases.catalogos.empresas,
                            Databases.catalogos.productos}
    local values = normalMode._requiereFields(requiredFields)
    print(values)
    local wt = awtx.weight.getCurrent(0)
    awtx.os.systemEvents(200)
    if values == nil then return end
    ---get weight
    brmUtilities.waitStability(0)
    if PersistentVars.minWt.value> wt.gross then return brmUtilities.doScroll('Cant min weight',0) end --cambiar
    -- if Events ~= {} then brmUtilities.doScroll(Events[0].message) return end ----provitional
    local year, month, day, hour, minute, second = awtx.os.readDateAndTime()
    local date = brmUtilities.dateFormat(year, month,day)
    local time = brmUtilities.dateFormat(hour, minute, second)
    ---save weight
    local response = Databases.pesadas.primeraPesada:addRow({
    1, plate, chofer, wt.gross, wt.unitsStr, date, time,
    values.empresas.Id, values.empresas.Value,
    values.productos.Id, values.productos.Value})
    brmUtilities.doScroll("saved", 500)
    Events.backToZero="backToZero"
end

function normalMode.secondWt(plate)
    brmUtilities.waitStability(0)
    local wt = awtx.weight.getCurrent(0)
    if PersistentVars.minWt.value> wt.gross then return brmUtilities.doScroll('Cant min weight',0) end --cambiar
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
    brmUtilities.doScroll("saved", 500)
    Events.backToZero="backToZero"
end

function normalMode.fullFirstWt(plates)
end

function normalMode.fullSecondWt(plates)
end

function normalMode.simpleWt()
end

function normalMode._takePlates()
    local value, isEnterKey = awtx.keypad.enterString("", 1000,-1,"ENTER","PLATES")
    if not isEnterKey then return end
    local response = Databases.pesadas.primeraPesada:countRecord("placas",value)
    if response == 0 then return normalMode.firstWt(value) end
    return normalMode.secondWt(value)

end

-- function to take requiere files id and if it exist returns Ids
---@param requiredFields table <number ,tableClass> -- Database class
---@returns table<string,table>|nil idValues --list with values
function normalMode._requiereFields(requiredFields)
    local values, isEnterKey = {}, nil
    local tempId
    local tempValue
    for _, field in pairs(requiredFields) do
        tempId, isEnterKey = awtx.keypad.enterInteger(0,0,10000,-1,"enter",field.tableName.." id")
        if not isEnterKey then brmUtilities.doScroll(field.tableName.." is required",100) return end
        tempValue = field:find("id", tostring(tempId))
        if #tempValue == 0 then
            brmUtilities.doScroll(" id "..tempId.." in "..field.tableName.." do not exist",100)
            return
        end
        values[field.tableName] = tempValue[1]
        brmUtilities.doScroll("OK",500)
    end
    return values
end

--keys assignations
function normalMode.keypad.onStartKeyDown()
    return normalMode._takePlates()
end
return normalMode
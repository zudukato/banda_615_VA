local brmScreen = require("Reqs.brmScreenRAD6015")
local brmScaleKeys = require("Reqs.brmScaleKeys")
local brmUtilities = require("Reqs.brmUtilities")
local awtxReqConstants = require("Reqs.awtxReqConstants")
local dataComm = require("modules.dataComm")
local lightControl = require("modules.lightControl")
local date
local epiMode = {}
local module = {}
_PrintFormat = ""
---@type epiDatabase.productRow
local productRow
local previousMode


epiMode.operationActive = true
---@type brmScaleKeys.KeypadEvents
epiMode.keypad = {}
epiMode.screen = brmScreen.newScreen("EPI")

epiMode.screen:newLabel("header", "", { x = 0, y = 0 }, { width = 320, height = 12 }, 10, 4, true,
    true)
epiMode.screen:newScale("mainScale", 0, 2, { x = 0, y = 15 })
epiMode.screen:newLabel("classificationLabel", "CLASSIFICATION", { x = 0, y = 64 }, { width = 120, height = 10 }, 8, 4,
    true, false)
epiMode.screen:newLabel("classificationValue", "", { x = 120, y = 64 }, { width = 30, height = 10 }, 8, 4, true, false)
epiMode.screen:newLabel("loteLabel", Language.batch, { x = 155, y = 64 }, { width = 45, height = 10 }, 8, 4, true, false)
epiMode.screen:newLabel("loteValue", "", { x = 200, y = 64 }, { width = 64, height = 10 }, 8, 4, true, false)
epiMode.screen:newLabel("productLabel", Language.product, { x = 0, y = 80 }, { width = 80, height = 10 }, 8, 4, true,
    false)
epiMode.screen:newLabel("productValue", "", { x = 80, y = 80 }, { width = 40, height = 10 }, 8, 4, true, true)
epiMode.screen:newLabel("orderLabel", Language._phrases.orderT, { x = 130, y = 80 }, { width = 70, height = 10 }, 8, 4,
    true, false)
epiMode.screen:newLabel("orderValue", "", { x = 200, y = 80 }, { width = 120, height = 10 }, 8, 4, true, false)
epiMode.screen:newLabel("serialNumberLabel", Language._phrases.seralNumber, { x = 0, y = 96 },
    { width = 80, height = 10 }, 8, 4, true,
    false)
epiMode.screen:newLabel("serialNumberValue", "", { x = 80, y = 96 }, { width = 120, height = 10 }, 8, 4, true, false)
epiMode.screen:newLabel("productDescription", "", { x = 0, y = 110 }, { width = 320, height = 20 }, 9, 6, true, false)
epiMode.screen:newLabel("online", "", { x = 0, y = 135 }, { width = 64, height = 10 }, 10, 4, true, true)
epiMode.screen:newLabel("statusBar", Language._phrases.packIndividualProduct, { x = 64, y = 135 },
    { width = 254, height = 10 },
    10, 4, true, true)

epiMode.screen:newButton("enter", "ENTER", { x = 130, y = 148 }, { width = 60, height = 30 }, 2, 4, true, false)
epiMode.screen:newButton("back", "BACK", { x = 194, y = 148 }, { width = 60, height = 30 }, 2, 4, false, false)
epiMode.screen:newButton("exit", "EXIT", { x = 258, y = 148 }, { width = 60, height = 30 }, 2, 4, true, false)


local index = 1
local fields = {
    { label = epiMode.screen.labels.productLabel, value = epiMode.screen.labels.productValue, maxValueSize = 4, numeric = true },
}
local field = fields[index]

function module.onQwertyKeyUp(char)
    local text = field.value.text
    if #text >= field.maxValueSize then return end
    if field.numeric and not tonumber(char) then return end
    field.value:setText(text .. char)
end

function epiMode.keypad.onNumericKeyDown(number)
    local response, char = pcall(string.char, number)
    if not response then return end
    if epiMode.keypad.onQwertyKeyUp then epiMode.keypad.onQwertyKeyUp(char) end
end

function module.onClearKeyUp()
    local newString = field.value.text:sub(1, -2) or ""
    field.value:setText(field.value.text:sub(1, -2))
end

---@param dataParams epiMode.dataParams
function module.doPrint(dataParams)
    local path = "c:\\Apps\\PrintFormats\\"
    local printFormatForWeightMode = { "VariableWeight.txt", "StaticWeight.txt", "VariableWeight.txt" }
    local labelType = productRow.label_type or 0
    local mode = productRow.mode
    if labelType == 0 then
        path = path .. printFormatForWeightMode[mode]
    else
        path = path .. "PrintFormat" .. labelType .. ".txt"
    end
    local file = io.open(path, "r")
    if not file then return brmUtilities.doScroll(Language.no .. " " .. Language.file, 1000) end
    ---@type string
    local printFormat = file:read("*all")
    printFormat = printFormat:interpolate(dataParams)
    _PrintFormat = printFormat
    file:close()
    for linea in string.gmatch(printFormat, "([^\n]+)") do
        awtx.serial.send(EpiVars.printPort,linea.."\n")
        awtx.os.systemEvents(EpiVars.interLiner)
    end
end

function epiMode.takeWeight(net)
    local mode = productRow.mode
    if not BackToZero.checkZero() then
        lightControl.setStatus(lightControl.states.red)
        return dataComm.messageStatusBar(Language._phrases.noReturnToZero)
    end
    if not net then
        if EventsHandle.events[EventsHandle.eventList.noMinWt] then
            lightControl.setStatus(lightControl.states.red)
            return dataComm.messageStatusBar(Language._phrases
                .weightToLow)
        end
        brmUtilities.waitStability(0)
        net = awtx.weight.getCurrent(0).net
    end
    if mode == 2 or mode == 1 then
        local percentage = mode == 1 and EpiVars.variableWeightRange or EpiVars.staticWeightRange
        percentage = percentage / 100
        local objectiveWeight = productRow.objective_weight
        local upTolerance = objectiveWeight + objectiveWeight * percentage
        local lowTolerance = objectiveWeight - objectiveWeight * percentage
        if upTolerance < net or lowTolerance > net then
            lightControl.setStatus(lightControl.states.red)
            dataComm.messageStatusBar(Language._phrases.weightOutOfRange, 2000)
            return
        end
    end
    local dataParams = dataComm.getParams(
        epiMode.screen.labels.loteValue.text,
        epiMode.screen.labels.serialNumberValue.text,
        epiMode.screen.labels.orderValue.text,
        productRow
    )
    if EpiVars.operationMode == "ONLINE" then
        local dataString = dataComm.getDataString(dataParams)
        dataComm.setExpectedResponse(epiMode.screen.labels.serialNumberValue.text)
        local response = dataComm.sendDataString(dataString)
        if not response then
            lightControl.setStatus(lightControl.states.red)
            dataComm.messageStatusBar("ERROR DE CONEXION", 10000)
            return
        end
        brmUtilities.doScroll(response,2000)
        if string.find(response:lower(),"error") then
            lightControl.setStatus(lightControl.states.red)
            EpiVars.operationNumber = EpiVars.operationNumber+1
            module.updateSerialAndLote()
            module.updateOperationNumber()
            dataComm.messageStatusBar("SERIE DUPLICADA", 10000)
            return
        end
        if response ~= epiMode.screen.labels.serialNumberValue.text then
            lightControl.setStatus(lightControl.states.green)
            dataComm.messageStatusBar("ERROR DE RESPUESTA", 10000)
            return end
        lightControl.setStatus(lightControl.states.green)
        module.doPrint(dataParams)
    else
        lightControl.setStatus(lightControl.states.green)
        module.doPrint(dataParams)
        local dataParamsJson = awtx.json.encode(dataParams)
        print(dataParamsJson)
        Databases.EPI.tables.offlineWeight:addRow({ nil, dataParamsJson })
    end
    module.updateOperationNumber()
    module.updateSerialAndLote()
    BackToZero.notZero()
end

function module.resetOperationIfNewDay()
    local date = os.date("%Y-%m-%d")
    if EpiVars.date ~= date then
        EpiVars.date = date
        EpiVars.operationNumber = 1
    end
end

function module.updateOperationNumber()
    EpiVars.operationNumber = EpiVars.operationNumber + 1
    module.resetOperationIfNewDay()
end

function module.getProduct()
    local id              = epiMode.screen.labels.productValue.text
    local value, response = Databases.EPI.tables.products:find("id", id)
    if #value == 0 then
        epiMode.screen.labels.statusBar:setText(Language._phrases.productNotFound)
        awtx.os.enhancedTimer.new(1, function()
            epiMode.screen.labels.statusBar:setText("")
        end, 3000, 1
        )
        return
    end
    ---@type epiDatabase.productRow
    local product = value[1]
    epiMode.screen.labels.productDescription:setText(product.name)
    awtx.weight.requestPresetTare(0, product.tare)
    productRow = product
    epiMode.keypad.onQwertyKeyUp = nil
    epiMode.keypad.onClearKeyUp = nil
    epiMode.onEnter = epiMode.takeWeight
    epiMode.screen.buttons.back:setVisible(true)
    epiMode.keypad.onF4KeyDown = function(...)
        module.back()
    end
end

module.back = function()
    local pas, isEnter = awtx.keypad.enterInteger(0,0,9999,"INGRESE","CONTRASENA")
    if not isEnter then return end
    if tostring(pas)  ~= PersistentVars.userPassword then 
      brmUtilities.doScroll("ERROR CONTRASENA",3000)
      return  end
    module.defaultValues(true)
end


epiMode.onEnter = module.getProduct
local function exit()
    awtx.serial.unregisterEomEvent(3)
    if not previousMode then return end
    brmUtilities.doScroll(Language.exit, 1500)
    previousMode.init()
end

function epiMode.keypad.onF3KeyDown()
    epiMode.onEnter()
end

function epiMode.keypad.onEnterKeyUp()
    epiMode.onEnter()
end

function module.updateSerialAndLote()
    date = os.date("*t")
    local serial = string.format("%03d%02d%03d%04d", EpiVars.scaleId, os.date("%y"), date.yday, EpiVars.operationNumber)
    local loteValue = ("%02i%02i%02i"):format(date.day, date.month, os.date("%y"))
    epiMode.screen.labels.loteValue:setText(loteValue)
    epiMode.screen.labels.serialNumberValue:setText(serial)
end

function module.defaultValues(activeExitButton)
    productRow = nil
    awtx.weight.requestTareClear(0)
    epiMode.onEnter = module.getProduct
    epiMode.keypad.onQwertyKeyUp = module.onQwertyKeyUp
    epiMode.keypad.onClearKeyUp = module.onClearKeyUp
    module.resetOperationIfNewDay()
    module.updateSerialAndLote()
    epiMode.screen.labels.classificationValue:setText("" .. EpiVars.classification)
    epiMode.screen.labels.header:setText(PersistentVars.headers[1])
    epiMode.screen.labels.online:setText("" .. EpiVars.operationMode)
    epiMode.screen.labels.statusBar:setText("")
    epiMode.screen.labels.productDescription:setText("")
    epiMode.screen.labels.productValue:setText("")
    epiMode.screen.buttons.back:setVisible(false)
    epiMode.screen.buttons.exit:setVisible(activeExitButton)
    if activeExitButton then
        epiMode.keypad.onF5KeyDown = exit
    else
        epiMode.keypad.onF5KeyDown = nil
    end
end

function module.newBarcode(...)
    awtx.display.doBeep()
    local barcode = awtx.serial.getRx(3)
    barcode = barcode:gsub("[\r\n.]", ""):sub(1, field.maxValueSize)
    if not tonumber(barcode) then return end
    epiMode.screen.labels.productValue:setText(barcode)
    module.getProduct()
end

module.averaging = false
function module.initWeight(setpoint, pulseUp)
    local pulseDown = not pulseUp
    if not pulseDown then return end
    if module.averaging then return end
    awtx.weight.stopAveraging(0)
    awtx.weight.startAveraging(0)
    module.averaging = true
end

function module.endWeight(_, pulseUp)
    if not pulseUp then return end
    if not module.averaging then return end
    if not productRow then return end
    awtx.weight.stopAveraging(0)
    epiMode.takeWeight(awtx.weight.getCurrent().netavg)
    module.averaging = false
end

function epiMode.init(order, prevMode)
    awtx.fmtPrint.set(EpiVars.printPort, "{A.99.1}")
    awtx.fmtPrint.varSet(99, "_PrintFormat", "printFormat", awtxReqConstants.fmtPrint.TYPE_STRING_VAR)
    previousMode = prevMode
    CurrentMode = epiMode
    module.defaultValues(true)
    epiMode.screen.labels.orderValue:setText("" .. order)
    epiMode.screen:show()
    index = 1
    if EpiVars.barcodeMode then
        awtx.serial.setEomChar(3, 13)
        awtx.serial.registerEomEvent(3, module.newBarcode)
    end
    if EpiVars.sensors then
        awtx.setpoint.registerInputEvent(1, module.initWeight)
        awtx.setpoint.registerInputEvent(2, module.endWeight)
    end
end

return epiMode

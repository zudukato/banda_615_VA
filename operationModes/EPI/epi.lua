local brmScreen = require("Reqs.brmScreenRAD6015")
local brmScaleKeys = require("Reqs.brmScaleKeys")
local brmUtilities = require("Reqs.brmUtilities")
local date
local epiMode = {}

---@type epiDatabase.productRow
local productRow
local previousMode

epiMode.operationActive = true
---@type brmScaleKeys.KeypadEvents
epiMode.keypad = {}
epiMode.screen = brmScreen.newScreen("EPI")

epiMode.screen:newLabel("header", "PLANTA VALOR AGREGADO", { x = 0, y = 0 }, { width = 320, height = 12 }, 10, 4, true,
    true)
epiMode.screen:newScale("mainScale", 0, 2, { x = 0, y = 15 })
epiMode.screen:newLabel("classificationLabel", "CLASSIFICATION", { x = 0, y = 64 }, { width = 120, height = 10 }, 8, 4,
    true, false)
epiMode.screen:newLabel("classificationValue", "", { x = 120, y = 64 }, { width = 30, height = 10 }, 8, 4, true, false)
epiMode.screen:newLabel("loteLabel", "LOTE", { x = 155, y = 64 }, { width = 45, height = 10 }, 8, 4, true, false)
epiMode.screen:newLabel("loteValue", "", { x = 200, y = 64 }, { width = 64, height = 10 }, 8, 4, true, false)
epiMode.screen:newLabel("productLabel", "PRODUCT", { x = 0, y = 80 }, { width = 80, height = 10 }, 8, 4, true, false)
epiMode.screen:newLabel("productValue", "", { x = 80, y = 80 }, { width = 40, height = 10 }, 8, 4, true, true)
epiMode.screen:newLabel("orderLabel", "ORDEN-T", { x = 130, y = 80 }, { width = 70, height = 10 }, 8, 4, true, false)
epiMode.screen:newLabel("orderValue", "", { x = 200, y = 80 }, { width = 120, height = 10 }, 8, 4, true, false)
epiMode.screen:newLabel("serialNumberLabel", "SER. NUM.", { x = 0, y = 96 }, { width = 80, height = 10 }, 8, 4, true,
    false)
epiMode.screen:newLabel("serialNumberValue", "", { x = 80, y = 96 }, { width = 120, height = 10 }, 8, 4, true, false)
epiMode.screen:newLabel("productDescription", "", { x = 0, y = 110 }, { width = 320, height = 20 }, 9, 6, true, false)
epiMode.screen:newLabel("statusBar", "EMPAQUE DE PRODUCTO INDIVIDUAL", { x = 0, y = 135 }, { width = 320, height = 10 },
    10, 4, true, true)

epiMode.screen:newButton("enter", "ENTER", { x = 130, y = 148 }, { width = 60, height = 30 }, 2, 4, true, false)
epiMode.screen:newButton("back", "BACK", { x = 194, y = 148 }, { width = 60, height = 30 }, 2, 4, false, false)
epiMode.screen:newButton("exit", "EXIT", { x = 258, y = 148 }, { width = 60, height = 30 }, 2, 4, true, false)

---@type awtx.os.enhancedTimer
local messageTimer

local function messageStatusBar(message, time)
    time = time or 1000
    if messageTimer then messageTimer:pause() end
    epiMode.screen.labels.statusBar:setText(message)
    messageTimer = awtx.os.enhancedTimer.new(2, function()
        epiMode.screen.labels.statusBar:setText("")
    end, time, 1)
end
local index = 1
local fields = {
    { label = epiMode.screen.labels.productLabel, value = epiMode.screen.labels.productValue, maxValueSize = 4, numeric = true },
}
local field = fields[index]

local function onQwertyKeyUp(char)
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

local function onClearKeyUp()
    local newString = field.value.text:sub(1, -2) or ""
    field.value:setText(field.value.text:sub(1, -2))
end

local function getParams()
    local lote            = epiMode.screen.labels.loteValue.text
    local serialNumber    = epiMode.screen.labels.serialNumberValue.text
    local dataTime        = os.time(date)
    local secToExpiration = 3600 * 24 * productRow.expiration ---seconds in a hour * 24 * days to expiration
    local expiration      = os.date("%d%m%y", dataTime + secToExpiration)
    local net             = awtx.weight.getCurrent(0).net
    local netWeight       = productRow.mode == 2 and productRow.objective_weight or net
    local netWeightLb     = awtx.weight.convertWeight(0, 2, netWeight, 1, 1)
    local eanQr           = string.format("010%13s13%06i3103%06i370110%12s  www.ganaderiarevuelta.com.mx",
        productRow.gtin, lote, netWeight * 1000, serialNumber)
    local eanPvCi         = string.format("(01)0%13s(13)%06i(3103)%06i(37)01", productRow.gtin, lote, netWeight * 1000)
    local eanPvSi         = string.format("010%13s13%06i3103%06i3701", productRow.gtin, lote, netWeight * 1000)

    ---@class epiMode.dataParams
    local data            = {
        gtin = ("%13s"):format(productRow.gtin),
        description = productRow.description,
        productId = productRow.product_id,
        productDescription = productRow.name,
        productLine = productRow.product_line,
        tare = productRow.tare,
        tareMg = productRow.tare * 1000,
        pieceCount = productRow.piece_count,
        scaleId = EpiVars.scaleId,
        serialId = EpiVars.serialId,
        classification = EpiVars.classification,
        operationNumber = EpiVars.operationNumber,
        operationMode = EpiVars.operationMode == "ONLINE" and 5 or 6,
        serialNumber = serialNumber,
        realWeight = net,
        netWeight = netWeight,
        netWeightLb = netWeightLb,
        lote = lote,
        order = epiMode.screen.labels.orderValue.text,
        expiration = expiration,
        eanQr = eanQr,
        eanPvCi = eanPvCi,
        eanPvSi = eanPvSi
    }
    return data
end

---@param dataParams epiMode.dataParams
local function doPrint(dataParams)
    local path = "c:\\Apps\\PrintFormats\\"
    local printFormatForWeightMode = { "VariableWeight.txt", "StaticWeight.txt", "VariableWeight.txt" }
    local labelType = productRow.label_type or 0
    local mode = productRow.mode
    if labelType == 0 then
        path = path .. printFormatForWeightMode[mode]
    else
        path = path .. "PrintFormat" .. labelType .. "txt"
    end
    local file = io.open(path, "r")
    if not file then return brmUtilities.doScroll("No File") end
    ---@type string
    local printFormat = file:read("*all")
    printFormat = printFormat:interpolate(dataParams)
    print(printFormat)
    file:close()
end

local Response

local function dataResponse(...)
    local serialNumber = epiMode.screen.labels.serialNumberValue.text
    local serialResponse = awtx.serial.getRx(1)
    local socketResponse = awtx.socket.getRx(1)
    ---@type string
    local response = serialResponse or socketResponse
    response = response:gsub("[\r\n]", "")
    if response == serialNumber then Response = response end
end

local function waitResponse(dataString)
    local pasKeypad = epiMode.keypad
    epiMode.keypad = {}
    local responseFlag = false
    awtx.serial.setEomChar(1, 13)
    awtx.socket.setEomChar(1, 13)
    awtx.serial.registerEomEvent(1, dataResponse)
    awtx.socket.registerEomEvent(1, dataResponse)
    epiMode.screen.labels.statusBar:setText("wait....")
    for i = 1, 10 do
        awtx.serial.send(1, dataString)
        awtx.socket.send(1, dataString)
        awtx.os.systemEvents(3000)
        if Response then
            responseFlag = true
            Response = ""
            messageStatusBar("Done")
            break
        end
    end
    if not responseFlag then messageStatusBar("error") end
    awtx.serial.unregisterEomEvent(1)
    awtx.socket.unregisterEomEvent(1)
    epiMode.keypad = pasKeypad
    return responseFlag
end

---@param dataParams epiMode.dataParams
local function sendDataString(dataParams)
    local data = {
        dataParams.serialId,                        --serialId
        ("%01i"):format(dataParams.operationMode),  --operation mode
        dataParams.serialNumber,                    --serialNumber
        ("%10i"):format(dataParams.productId),      --productCode
        ("%06.3f"):format(dataParams.netWeight),    --netWeight
        dataParams.lote,                            --date
        ("%05i"):format(dataParams.classification), --classification
        dataParams.lote,                            --lote
        ("%13d"):format(dataParams.order),          --order
        dataParams.expiration,                      --expiration
        dataParams.tareMg,                          --tare mili grams
        dataParams.netWeightLb,                     --netWeightLb
        "00000",                                    --zeros
        ("%06.3f"):format(dataParams.realWeight),   --realWeight
        "\r\n",                                     --eom
    }
    local dataString = table.concat(data, "")
    return waitResponse(dataString)
end


-- function modeEpi.keypad.onF2KeyDown()
--     index = index == #fields and 1 or index + 1
--     field = fields[index]
--     field.label:setInverted(true)
--     if index ~= 1 then
--         fields[index - 1].label:setInverted(false)
--     else
--         fields[#fields].label:setInverted(false)
--     end
-- end

-- function modeEpi.keypad.onF1KeyDown()
--     index = index == 1 and #fields or index - 1
--     field = fields[index]
--     field.label:setInverted(true)
--     if index ~= #fields then
--         fields[index + 1].label:setInverted(false)
--     else
--         fields[1].label:setInverted(false)
--     end
-- end

local function takeWeight()
    local mode = productRow.mode
    if not BackToZero.checkZero() then return messageStatusBar("NO REGRESO A CERO") end
    if EventsHandle.events[EventsHandle.eventList.noMinWt] then return messageStatusBar("SUBA PESO") end
    brmUtilities.waitStability(0)
    local net = awtx.weight.getCurrent(0).net
    if mode == 2 or mode == 1 then
        local objectiveWeight = productRow.objective_weight
        local upTolerance = objectiveWeight + objectiveWeight * (0.03)
        local lowTolerance = objectiveWeight - objectiveWeight * (0.03)
        if upTolerance < net or lowTolerance > net then
            messageStatusBar("PESO FUERA DE RANGO")
            return
        end
    end
    local dataParams = getParams()
    if EpiVars.operationMode == "ONLINE" then
        if not sendDataString(dataParams) then return end
    else
        Databases.EPI.tables.offLineWight:addRow(dataParams)
    end
    doPrint(dataParams)
    BackToZero.notZero()
end

local function getProduct()
    local idProduct       = epiMode.screen.labels.productValue.text
    local value, response = Databases.EPI.tables.products:find("product_id", idProduct)
    if #value == 0 then
        epiMode.screen.labels.statusBar:setText("producto no encontrado")
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
    epiMode.onEnter = takeWeight
    epiMode.screen.buttons.back:setVisible(true)
    epiMode.keypad.onF4KeyDown = function(...)
        epiMode.keypad.onQwertyKeyUp = onQwertyKeyUp
        epiMode.keypad.onClearKeyUp = onClearKeyUp
        epiMode.onEnter = getProduct
        epiMode.keypad.onF4KeyDown = nil
    end
end


epiMode.onEnter = getProduct
local function exit()
    if not previousMode then return end
    brmUtilities.doScroll("exit", 1500)
    previousMode.init()
end

function epiMode.keypad.onF3KeyDown()
    epiMode.onEnter()
end

function epiMode.keypad.onEnterKeyUp()
    epiMode.onEnter()
end

local function defaultValues(activeExitButton)
    epiMode.onEnter = getProduct
    epiMode.keypad.onQwertyKeyUp = onQwertyKeyUp
    epiMode.keypad.onClearKeyUp = onClearKeyUp
    date = os.date("*t")
    local dateFormat = os.date("%y-%m-%d")
    local hour = os.date("%I:%M:%S%p")
    local serial = string.format("%03d%02d%03d%04d", EpiVars.scaleId, os.date("%y"), date.yday, EpiVars.operationNumber)
    local loteValue = ("%02i%02i%02i"):format(date.day, date.month, os.date("%y"))
    epiMode.screen.labels.classificationValue:setText("" .. EpiVars.classification)
    epiMode.screen.labels.statusBar:setText("")
    epiMode.screen.labels.productDescription:setText("")
    epiMode.screen.labels.loteValue:setText(loteValue)
    epiMode.screen.labels.productValue:setText("")
    epiMode.screen.labels.serialNumberValue:setText(serial)
    epiMode.screen.buttons.back:setVisible(false)
    epiMode.screen.buttons.exit:setVisible(activeExitButton)
    if activeExitButton then
        epiMode.keypad.onF5KeyDown = exit
    else
        epiMode.keypad.onF5KeyDown = nil
    end
end

function epiMode.init(order, prevMode)
    previousMode = prevMode
    CurrentMode = epiMode
    defaultValues(true)
    epiMode.screen.labels.orderValue:setText("" .. order)
    epiMode.screen:show()
    index = 1
end

return epiMode

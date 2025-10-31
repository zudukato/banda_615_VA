local dataComm = {}
local expectedResponse

function dataComm.setExpectedResponse(response)
    expectedResponse = response
end

---@param lote string
---@param serialNumber string
---@param order string
---@param row epiDatabase.productRow
---@return epiMode.dataParams
function dataComm.getParams(lote, serialNumber, order, row)
    ---@type osdate
    ---@diagnostic disable-next-line: assign-type-mismatch
    local date            = os.date("*t")
    local lote            = lote
    local serialNumber    = serialNumber
    local dataTime        = os.time(date)
    local secToExpiration = 3600 * 24 * row.expiration ---seconds in a hour * 24 * days to expiration
    local expiration      = os.date("%d%m%y", dataTime + secToExpiration)
    local net             = awtx.weight.getCurrent(0).net
    local netWeight       = row.mode == 2 and row.objective_weight or net
    local netWeightLb     = awtx.weight.convertWeight(0, 2, netWeight, 1, 1)
    local eanQr           = string.format("010%13s13%06i3103%06i370110%12s  www.ganaderiarevuelta.com.mx",
        row.gtin, lote, netWeight * 1000, serialNumber)
    local eanPvCi         = string.format("(01)0%13s(13)%06i(3103)%06i(37)01", row.gtin, lote, netWeight * 1000)
    local eanPvSi         = string.format("010%13s13%06i3103%06i3701", row.gtin, lote, netWeight * 1000)

    ---@class epiMode.dataParams
    local data            = {
        gtin = ("%13s"):format(row.gtin),
        description = row.description,
        productId = row.id,
        productDescription = row.name,
        productLine = row.product_line,
        tare = row.tare,
        tareMg = row.tare * 1000,
        pieceCount = row.piece_count,
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
        order = order,
        expiration = expiration,
        eanQr = eanQr,
        eanPvCi = eanPvCi,
        eanPvSi = eanPvSi
    }
    return data
end

local Response

function dataComm.dataResponse(...)
    local responseSerial = awtx.serial.getRx(EpiVars.communicationPort)
    local responseSocket = awtx.socket.getRx(EpiVars.communicationPortSocket)
    local response = responseSerial == "" and responseSocket or responseSerial
    Response = response:gsub("[\r\n]", "")
end

function dataComm.waitResponse()
    for j = 1, 30 do
        awtx.os.systemEvents(100)
        if Response then return Response end
    end
end

function dataComm.sendDataString(dataString)
    Response = nil
    local response
    local pasKeypad = CurrentMode.keypad
    CurrentMode.keypad = {}
    local responseFlag = false
    awtx.serial.setEomChar(EpiVars.communicationPort, 13)
    awtx.socket.setEomChar(EpiVars.communicationPortSocket, 13)
    awtx.serial.registerEomEvent(EpiVars.communicationPort, dataComm.dataResponse)
    awtx.socket.registerEomEvent(EpiVars.communicationPortSocket, dataComm.dataResponse)
    dataComm.messageStatusBar(Language.wait .. "....")


    for i = 1, 10 do
        awtx.serial.send(EpiVars.communicationPort, dataString)
        awtx.socket.send(EpiVars.communicationPortSocket, dataString)
        response = dataComm.waitResponse()
        if response then break end
    end
    if not response then
        dataComm.messageStatusBar(Language.error, 3000)
        Response = nil
    end
    awtx.serial.unregisterEomEvent(EpiVars.communicationPort)
    awtx.socket.unregisterEomEvent(EpiVars.communicationPort)
    CurrentMode.keypad = pasKeypad
    return response
end

---@param dataParams epiMode.dataParams
function dataComm.getDataString(dataParams)
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
        ("%03d"):format(dataParams.pieceCount),      --piece count
        "\r\n",                                     --eom
    }
    local dataString = table.concat(data, "")
    return dataString
end

---@type awtx.os.enhancedTimer
local messageTimer
function dataComm.messageStatusBar(message, time)
    time = time or 1000
    if not CurrentMode.screen.labels.statusBar then return end
    if messageTimer then messageTimer:pause() end
    CurrentMode.screen.labels.statusBar:setText(message)
    if not time then return end
    messageTimer = awtx.os.enhancedTimer.new(2, function()
        CurrentMode.screen.labels.statusBar:setText("")
    end, time, 1)
end

return dataComm

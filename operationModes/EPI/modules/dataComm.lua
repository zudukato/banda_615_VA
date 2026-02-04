local brmUtilities = require("Reqs.brmUtilities")
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
    local charsForHour      = { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
        "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W" }
    ---@type osdate
    ---@diagnostic disable-next-line: assign-type-mismatch
    ---@class epiMode.dataParams
    local data              = {}
    local date              = os.date("*t")
    local hourChar          = charsForHour[date.hour + 1]
    local onlineOfflineChar = EpiVars.operationMode == "ONLINE" and "L" or "F"
    local lote              = lote
    local serialNumber      = serialNumber
    local dataTime          = os.time(date)
    local secToExpiration   = 3600 * 24 * row.expiration ---seconds in a hour * 24 * days to expiration
    local secToRotation     = 3600 * 24 * row.rotation_date
    local expiration        = os.date("*t", dataTime + secToExpiration)
    local rotationDate      = os.date("*t", dataTime + secToRotation)
    local net               = awtx.weight.getCurrent(0).net
    local netWeight         = row.mode == 2 and row.objective_weight or net
    local netWeightLb       = awtx.weight.convertWeight(0, 2, netWeight, 1, 1)
    local frozenLabel       = row.frozen == 1 and "CONGELADO, MANTENGASE EN CONGELACION -18 C" or ""
    local frozenLabelEn     = row.frozen == 1 and "FROZEN KEEP FROZEN AT 0 F" or ""
    local eanQr             = string.format("01%014s13%06i3103%06i370110%12s  www.ganaderiarevuelta.com.mx",
        row.gtin, lote, netWeight * 1000, serialNumber)
    local eanPvCi           = string.format("(01)%s(3102)%06i(3202)%06i(21)%012s",
        ("%14s"):format(row.gtin):gsub(" ", "0"),
        netWeight * 100, netWeightLb * 100, serialNumber)
    local eanPvSi           = string.format("01%s3102%06i3202%06i21%012s", ("%14s"):format(row.gtin):gsub(" ", "0"),
        netWeight * 100, netWeightLb * 100, serialNumber)
    local ean2PvCi          = string.format("(13)%02d%02d%02d(17)%02d%02d%02d(10)%02d%02d%02d(90)%02d(91)%06d",
        date.year %
        100, date.month, date.day, expiration.year % 100,
        expiration.month, expiration.day, date.day, date.month, date.year % 100, '0', row.provider_number)
    local ean2PvSi          = string.format("13%02d%02d%02d17%02d%02d%02d10%02d%02d%02d90%02d91%06d", date.year %
        100, date.month, date.day, expiration.year % 100,
        expiration.month, expiration.day, date.day, date.month, date.year % 100, '0', row.provider_number)
    local descriptions      = string.split(row.description, "|")
    if descriptions and #descriptions > 0 then
        for i, value in pairs(descriptions) do
            data[("description_%d"):format(i)] = value
        end
    end

    data.day = ("%02d"):format(date.day)
    data.month = ("%02d"):format(date.month)
    data.year = ("%04d"):format(date.year)
    data.year2 = ("%02d"):format(date.year % 100)
    data.gtin = row.gtin
    data.description = row.description
    data.productId = row.id_product
    data.productDescription = row.name
    data.productLine = row.product_line
    data.tare = row.tare
    data.tareG = row.tare * 1000
    data.pieceCount = row.piece_count
    data.scaleId = EpiVars.scaleId
    data.serialId = EpiVars.serialId
    data.classification = EpiVars.classification
    data.operationNumber = EpiVars.operationNumber
    data.operationMode = EpiVars.operationMode == "ONLINE" and 5 or 6
    data.serialNumber = serialNumber
    data.realWeight = net
    data.netWeight = netWeight
    data.netWeight2f = ("%05.2f"):format(netWeight)
    data.netWeight3f = ("%06.3f"):format(netWeight)
    data.netWeightLb = netWeightLb
    data.netWeightLb2f = ("%05.2f"):format(netWeightLb)
    data.netWeightLb3f = ("%06.3f"):format(netWeightLb)
    data.lote = lote
    data.order = order
    data.expirationDay = ("%02d"):format(expiration.day)
    data.expirationMonth = ("%02d"):format(expiration.month)
    data.expirationYear = ("%04d"):format(expiration.year)
    data.expirationYear2 = ("%02d"):format(expiration.year % 100)
    data.eanQr = eanQr
    data.eanPvCi = eanPvCi
    data.eanPvSi = eanPvSi
    data.ean2PvCi = ean2PvCi
    data.ean2PvSi = ean2PvSi
    data.frozenLabel = frozenLabel
    data.frozenLabelEn = frozenLabelEn
    data.sku = row.sku
    data.idProductClient = row.id_product_client
    data.providerNumber = row.provider_number
    data.gtin14 = row.gtin14
    data.rotationDay = ("%02d"):format(rotationDate.day)
    data.rotationMonth = ("%02d"):format(rotationDate.month)
    data.rotationYear = ("%04d"):format(rotationDate.year)
    data.rotationYear2 = ("%2d"):format(rotationDate.year % 100)
    data.onlineOfflineChar = onlineOfflineChar
    data.hourChar = hourChar


    return data
end

local Response

function dataComm.dataResponse(...)
    local responseSerial = awtx.serial.getRx(EpiVars.communicationPort)
    local responseSocket = awtx.socket.getRx(EpiVars.communicationPortSocket)
    local response = responseSerial == "" and responseSocket or responseSerial
    local responseList = string.split(response, "\r\n")
    if #responseList < 1 then return end
    Response = responseList[1]:gsub("[%c]", "")
end

function dataComm.waitResponse()
    local preCurrentModeKeypad = CurrentMode.keypad
    local cancel = false
    CurrentMode.keypad = {
        onF5KeyDown = function(...)
            cancel = true
        end
    }
    for j = 1, EpiVars.WaitSeconds * 10 do
        awtx.os.systemEvents(100)
        if cancel then
            CurrentMode.keypad = preCurrentModeKeypad
            return "CANCEL"
        end
        if Response then
            CurrentMode.keypad = preCurrentModeKeypad
            return Response
        end
    end
    CurrentMode.keypad = preCurrentModeKeypad
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
        ("%02d%02d%02d"):format(dataParams.expirationDay,
            dataParams.expirationMonth,
            dataParams.expirationYear2),           --expiration
        ("%04d"):format(dataParams.tareG),         --tare in grams
        ("%06.3f"):format(dataParams.netWeightLb), --netWeightLb
        "00000",                                   --zeros
        ("%06.3f"):format(dataParams.realWeight),  --realWeight
        ("%03d"):format(dataParams.pieceCount),    --piece count
        "\r\n",                                    --eom
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

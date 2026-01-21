local brmScreenRAD6015     = require("Reqs.brmScreenRAD6015")
local awtxReqConstants     = require("Reqs.awtxReqConstants")
local brmScaleKeys         = require("Reqs.brmScaleKeys")
local brmUtilities         = require("Reqs.brmUtilities")
local dataComm             = require("modules.dataComm")
local exitFlag = false
local pendingTransmission  = {}
local prevMode
---@type string[]
local allRows

pendingTransmission.screen = brmScreenRAD6015.newScreen("sendPending")
pendingTransmission.screen:newLabel("title", Language._phrases.pendingTransmission, { x = 0, y = 0 },
    { width = 400, height = 30 },
    0, 30, true, false)
pendingTransmission.screen:newLabel("info","PENDIENTES:" , { x = 0, y = 40 },
    { width = 100, height = 30 },
    0,31, true, false)
pendingTransmission.screen:newLabel("count", "", { x = 120, y = 110 }, { width = 39, height = 20 }, 5, 4, true, false)
pendingTransmission.screen:newLabel("total", "", { x = 160, y = 110 }, { width = 39, height = 20 }, 4, 4, true, false)
pendingTransmission.screen:newLabel("statusBar", "", { x = 0, y = 135 },
    { width = 319, height = 10 },
    10, 4, true, true)

pendingTransmission.screen:newButton("enter", "ENTER", { x = 130, y = 148 }, { width = 60, height = 30 }, 2, 4, true,
    false)
pendingTransmission.screen:newButton("exit", "EXIT", { x = 258, y = 148 }, { width = 60, height = 20 }, 2, 4, true, false)


pendingTransmission.init = function(prev)
    prevMode = prev
    CurrentMode = pendingTransmission
    pendingTransmission.screen:show()
    allRows = Databases.EPI.tables.offlineWeight:find()
    pendingTransmission.screen.labels.info:setText(("PENDIENTES : %d"):format(#allRows))

end

pendingTransmission.initTransmission = function ()
    pendingTransmission.screen.labels.info:setText("")
    local toSend = Databases.EPI.tables.offlineWeight:countRecord()
    pendingTransmission.screen.labels.count:setText(("%d"):format(0))
    pendingTransmission.screen.labels.total:setText(("/%d"):format(toSend))
    if toSend == 0 then return end
    for i = 1, toSend, 1 do
        if exitFlag then break end
        ---@type epiMode.dataParams
        local object =awtx.json.decode(allRows[i]["data_params"])
        local dataString = dataComm.getDataString(object)
        dataComm.setExpectedResponse(object.serialNumber)
        local response = dataComm.sendDataString(dataString)
        if response == object.serialNumber or response == "SERIE DUPLICADA" then
            print(allRows[i])
            Databases.EPI.tables.offlineWeight:deleteRow("id",allRows[i]["id"])
        end
        pendingTransmission.screen.labels.count:setText(("%d"):format(i))
        local prop = math.floor((i * 300) / toSend)
        awtx.graphics.fillRect(10, 90, prop, 10, 0)
    end
end

---@type brmScaleKeys.KeypadEvents
pendingTransmission.keypad ={}

pendingTransmission.keypad.onF3KeyUp = function ()
    pendingTransmission.initTransmission()
end
pendingTransmission.keypad.onF5KeyUp = function()
    local choice, isEnterKey = awtx.keypad.selectList("SI,NO",1, -1,"salir")
    if not isEnterKey or choice == 2 then return end
    exitFlag = true
    prevMode.init()
end
return pendingTransmission

local epiMenu = {}
function epiMenu.changeSerialId()
    local serialId = tonumber(EpiVars.serialId:sub(2)) or 1
    local serialId, isEnterKey = awtx.keypad.enterInteger(serialId, 1, 9, -1, Language.enter, Language._phrases.serialId)
    if not isEnterKey then return end
    EpiVars.serialId = "R" .. serialId
end

function epiMenu.changeClassification()
    local classification, isEnterKey = awtx.keypad.enterInteger(EpiVars.classification, 1, 9, -1, Language.enter,
        Language.classification)
    if not isEnterKey then return end
    EpiVars.classification = classification
end

function epiMenu.changeScaleId()
    local scaleId, isEnterKey = awtx.keypad.enterInteger(EpiVars.scaleId, 1, 999, -1, Language.enter,
        Language._phrases.scaleId)
    if not isEnterKey then return end
    EpiVars.scaleId = scaleId
end

function epiMenu.changeOperationMode()
    local operationModes = {"ONLINE","OFFLINE"}
    local operationMode, isEnterKey = awtx.keypad.selectList(table.concat(operationModes,","), 0, -1, Language.select)
    if not isEnterKey then return end
    EpiVars.operationMode =operationModes[operationMode+1]
end

function epiMenu.changePrinter()
end

function epiMenu.changeStaticWeightRange()
    local staticWeightRange, isEnterKey = awtx.keypad.enterInteger(EpiVars.scaleId, 0, 99, -1, Language.enter,
        Language._phrases.staticWeightRange)
    if not isEnterKey then return end
    EpiVars.staticWeightRange = staticWeightRange
end

function epiMenu.changeVariableWeightRange()
    local variableWeightRange, isEnterKey = awtx.keypad.enterInteger(EpiVars.scaleId, 0, 99, -1, Language.enter,
        Language._phrases.variableWeightRange)
    if not isEnterKey then return end
    EpiVars.variableWeightRange = variableWeightRange
end

function epiMenu.changeBandSpeed()
    ---@type number, boolean
    local bandSpeed, isEnterKey =  awtx.keypad.enterFloat (EpiVars.bandSpeed, 0, 60, 1, -1, "enter speed (hz)", "", 2)
    if not isEnterKey then return end
    EpiVars.bandSpeed = bandSpeed
    _BandSpeed = bandSpeed
end

MenusTree = MenusTree or {}
table.insert(MenusTree.topMenu, {
    text = "Variables de Operacion", action = "MENU", value = "operationVars"
})
MenusTree.operationVars = {
    { text = Language._phrases.serialId,            action = "FUNC", value = epiMenu.changeSerialId },
    { text = Language.classification,               action = "FUNC", value = epiMenu.changeClassification },
    { text = Language._phrases.scaleId,             action = "FUNC", value = epiMenu.changeScaleId },
    { text = Language._phrases.operationMode,       action = "FUNC", value = epiMenu.changeOperationMode },
    { text = Language.printer,                      action = "FUNC", value = epiMenu.changePrinter },
    { text = Language._phrases.staticWeightRange,   action = "FUNC", value = epiMenu.changeStaticWeightRange },
    { text = Language._phrases.variableWeightRange, action = "FUNC", value = epiMenu.changeVariableWeightRange },
    { text = Language._phrases.bandSpeed, action = "FUNC", value = epiMenu.changeBandSpeed },
    { text = "prueba semaforo", onlySupport=true ,action = "MENU", value = "testLights" },
}

MenusTree.testLights = {
    { text = "Verde", action = "FUNC", value = function ()
       awtx.setpoint.activate(6)
       awtx.setpoint.deactivate(7)
    end },
    { text = "Amarillo", action = "FUNC", value =function ()
       awtx.setpoint.activate(7)
       awtx.setpoint.deactivate(6)
    end },
    { text = "Rojo", action = "FUNC", value = function ()
       awtx.setpoint.deactivate(6)
       awtx.setpoint.deactivate(7)
    end },
}

local epiMenu = {}
function epiMenu.changeSerialId()
    local serialId = tonumber(EpiVars.serialId:sub(2)) or 1
    local serialId, isEnterKey = awtx.keypad.enterInteger(serialId,1,9,-1,Language.enter,"Serial Id")
    if not isEnterKey then return end
    EpiVars.serialId = "R"..serialId
end

function epiMenu.changeClassification()
    local classification, isEnterKey = awtx.keypad.enterInteger(EpiVars.classification,1,9,-1,Language.enter,"Serial Id")
    if not isEnterKey then return end
    EpiVars.classification = classification
end

function epiMenu.changeScaleId()
    local scaleId, isEnterKey = awtx.keypad.enterInteger(EpiVars.scaleId,1,999,-1,Language.enter,"Serial Id")
    if not isEnterKey then return end
    EpiVars.scaleId = scaleId
end

function epiMenu.changeOperationMode()
    local operationMode, isEnterKey = awtx.keypad.selectList("ONLINE,OFFLINE", 0,-1,"SELECT")
    if not isEnterKey then return end
    EpiVars.operationMode = operationMode
end
function epiMenu.changePrinter()
end
function epiMenu.changeStaticWeightRange()
    local staticWeightRange, isEnterKey = awtx.keypad.enterInteger(EpiVars.scaleId,0,99,-1,Language.enter,"Serial Id")
    if not isEnterKey then return end
    EpiVars.staticWeightRange = staticWeightRange
end
function epiMenu.changeVariableWeightRange()
    local variableWeightRange, isEnterKey = awtx.keypad.enterInteger(EpiVars.scaleId,0,99,-1,Language.enter,"Serial Id")
    if not isEnterKey then return end
    EpiVars.variableWeightRange = variableWeightRange
end
MenusTree = MenusTree or {}
table.insert(MenusTree.topMenu, {
    text = "Variables de Operacion", action = "MENU", value = "operationVars"
})
MenusTree.operationVars = {
    { text = "Serial Id", action = "FUNC", value = epiMenu.changeSerialId },
    { text = "Classification",  action = "FUNC", value = epiMenu.changeClassification },
    { text = "Scale Identificador",  action = "FUNC", value = epiMenu.changeScaleId},
    { text = "Operation Mode",  action = "FUNC", value = epiMenu.changeOperationMode },
    { text = "Printer",  action = "FUNC", value = epiMenu.changePrinter },
    { text = "Static Weight Range",  action = "FUNC", value = epiMenu.changeStaticWeightRange},
    { text = "Variable Weight Range",  action = "FUNC", value = epiMenu.changeVariableWeightRange },

}

local brmUtilities = require("Reqs.brmUtilities")
local brmPeripherals = {}
ModuleEvents = ModuleEvents or {}
---@type table <string,number>
brmPeripherals._setpointsNumbers = {
    DAP1 = 39,
    DAP2 = 38,
    DAP3 = 37,
    DAP4 = 36,
    inductorCoil1 = 35,
    inductorCoil2 = 34,
    LCT1= 33,
    LCT2= 32,
    openBarrier1 = 31,
    openBarrier2 = 30,
    closeBarrier1 = 29,
    closeBarrier2 = 28,
}

-------- Persistent Variables ---------
PersistentVars = PersistentVars or {}
PersistentVars.LCTMode = 1
PersistentVars.LCTInverted = false
PersistentVars.LCTBlinkTimeMs = 10000

---
brmPeripherals._blinkActive = false
------------ DAPS -------------
function brmPeripherals._checkDAP(setpointNumber, setpointActive)
    ---@type string
    local DAPName = brmUtilities.tableFind(brmPeripherals._setpointsNumbers,setpointNumber)
    if not setpointActive then ModuleEvents[DAPName] = nil return  end
    ModuleEvents[DAPName]=DAPName.." Active"
end

function brmPeripherals.inductorCoil(setpointNum, setpointActive)
    local wt = awtx.weight.getCurrent()
    if not setpointActive or wt.gross >= PersistentVars.minWt then 
        brmPeripherals._blinkActive = false
        return
    end
    brmPeripherals._blinkActive = true
    if setpointNum == brmPeripherals._setpointsNumbers.inductorCoil1 then
        return brmPeripherals.start1()
    end
    if setpointNum == brmPeripherals._setpointsNumbers.inductorCoil2 then
        return brmPeripherals.start2()
    end
end

function brmPeripherals.start1()
    local operations = {
        [1] = function ()
            brmPeripherals._LCT1blinkTimer = awtx.os.enhancedTimer.new(10,brmPeripherals.LCT1Blink,PersistentVars.LCTBlinkTimeMs,1)
            brmPeripherals.LCT1Green()
        end,
        [2] =function ()
            brmPeripherals._LCT2blinkTimer = awtx.os.enhancedTimer.new(9,brmPeripherals.LCT2Blink,PersistentVars.LCTBlinkTimeMs,1)
            brmPeripherals.LCT2Green()
        end, 
        [3] =function ()
            brmPeripherals._LCT2blinkTimer = awtx.os.enhancedTimer.new(9,brmPeripherals.LCT2Blink,PersistentVars.LCTBlinkTimeMs,1)
            brmPeripherals.LCT2Green()
        end,
    }
    if not operations[PersistentVars.LCTMode] then return brmUtilities.doScroll("Bad LCT mode") end
    operations[PersistentVars.LCTMode]()
    brmPeripherals.openBarrier1()
end

function brmPeripherals.start2(setpointNumber, setpointActive)
     local operations = {
        [1] = function ()
            brmPeripherals._LCT2blinkTimer = awtx.os.enhancedTimer.new(9,brmPeripherals.LCT2Blink,PersistentVars.LCTBlinkTimeMs,1)
            brmPeripherals.LCT2Green()
        end,
        [2] =function ()
            brmPeripherals._LCT1blinkTimer = awtx.os.enhancedTimer.new(10,brmPeripherals.LCT1Blink,PersistentVars.LCTBlinkTimeMs,1)
            brmPeripherals.LCT1Green()
        end, 
        [4] =function ()
            brmPeripherals._LCT1blinkTimer = awtx.os.enhancedTimer.new(10,brmPeripherals.LCT1Blink,PersistentVars.LCTBlinkTimeMs,1)
            brmPeripherals.LCT1Green()
        end,
    }
    if not operations[PersistentVars.LCTMode] then return brmUtilities.doScroll("Bad LCT mode") end
    operations[PersistentVars.LCTMode]()
    brmPeripherals.openBarrier2()
end

function brmPeripherals.end1()
    local operations = {
        [1] = brmPeripherals.LCT2Green,
        [4] = brmPeripherals.LCT2Green,
    }
    operations[PersistentVars.LCTMode]()
    brmPeripherals.openBarrier2()
end

function brmPeripherals.end2()
    local operations = {
        [1] = brmPeripherals.LCT1Green,
        [3] = brmPeripherals.LCT1Green,
    }
    operations[PersistentVars.LCTMode]()
    brmPeripherals.openBarrier2()
end
    
function brmPeripherals.LCT1Green()
    if not PersistentVars.LCTInverted then
        return awtx.setpoint.activate(brmPeripherals._setpointsNumbers.LCT1)
    end
    awtx.setpoint.deactivate(brmPeripherals._setpointsNumbers.LCT1)
    
end

function brmPeripherals.LCT2Green()
    if not PersistentVars.LCTInverted then
        return awtx.setpoint.activate(brmPeripherals._setpointsNumbers.LCT2)
    end
    awtx.setpoint.deactivate(brmPeripherals._setpointsNumbers.LCT2)
end

function brmPeripherals.LCT1Red()
    if not PersistentVars.LCTInverted then
        return awtx.setpoint.deactivate(brmPeripherals._setpointsNumbers.LCT1)
    end
        awtx.setpoint.activate(brmPeripherals._setpointsNumbers.LCT1)
end

function brmPeripherals.LCT2Red()
    if not PersistentVars.LCTInverted then
        return awtx.setpoint.deactivate(brmPeripherals._setpointsNumbers.LCT2)
    end
    awtx.setpoint.activate(brmPeripherals._setpointsNumbers.LCT2)
end

function brmPeripherals.LCT1Blink()
    while brmPeripherals._blinkActive do
        awtx.setpoint.activate(brmPeripherals._setpointsNumbers.LCT1)
        awtx.os.systemEvents(500)
        awtx.setpoint.deactivate(brmPeripherals._setpointsNumbers.LCT1)
        awtx.os.systemEvents(500)
    end
end

function  brmPeripherals.LCT2Blink()
    while brmPeripherals._blinkActive do
        awtx.setpoint.activate(brmPeripherals._setpointsNumbers.LCT2)
        awtx.os.systemEvents(500)
        awtx.setpoint.deactivate(brmPeripherals._setpointsNumbers.LCT2)
        awtx.os.systemEvents(500)
    end
end

function brmPeripherals.openBarrier1()
    awtx.setpoint.activate(brmPeripherals._setpointsNumbers.openBarrier1)
end

function brmPeripherals.openBarrier2()
    awtx.setpoint.activate(brmPeripherals._setpointsNumbers.openBarrier2)
end

function brmPeripherals.closeBarrier1()
    awtx.setpoint.activate(brmPeripherals._setpointsNumbers.openBarrier1)
end

function brmPeripherals.closeBarrier2()
    awtx.setpoint.activate(brmPeripherals._setpointsNumbers.openBarrier2)
end

function brmPeripherals.onStart()
    awtx.setpoint.registerInputEvent(brmPeripherals._setpointsNumbers.DAP1,brmPeripherals._checkDAP)
    awtx.setpoint.registerInputEvent(brmPeripherals._setpointsNumbers.inductorCoil1,brmPeripherals.inductorCoil)
    awtx.setpoint.registerInputEvent(brmPeripherals._setpointsNumbers.inductorCoil2,brmPeripherals.inductorCoil)
end

function brmPeripherals._changeLCTMode()
    local choice, isEnterKey
    choice, isEnterKey = awtx.keypad.selectList("1,2,3,4",PersistentVars.LCTMode-1,-1,"Mode")
    if not isEnterKey then return end
    PersistentVars.LCTMode = choice+1
end

brmPeripherals.onStart()
MenusTree = MenusTree or {}
MenusTree.config = MenusTree.config or {}

MenusTree.peripherals = {
    {text = "ENABLE", action ="FUNC" , value = ""},
    {text = "LCT", action = "MENU", value = "LCT"},
    {text = "DAP", action = "MENU", value = "DAP"},
    {text = "BARRIER", action = "MENU", value = "barrier"},
}
MenusTree.LCT = {
    {text = "MODE", action = "FUNC", value = brmPeripherals._changeLCTMode},
    {text = "INVERT", action = "FUNC", value = function () 
        PersistentVars.LCTInverted = not PersistentVars.LCTInverted 
        print(PersistentVars.LCTInverted)
        brmUtilities.doScroll("OK")
    end},
}
MenusTree.DAPS = {
    {text = "INVERT", action = "FUNC", value = ""}
}
MenusTree.barrier = {
    {text = "OPEN.B1", action = "FUNC", value = brmPeripherals.openBarrier1},
    {text = "OPEN.B2", action = "FUNC", value = brmPeripherals.openBarrier2},
    {text = "CLOSE.B1", action = "FUNC", value = brmPeripherals.closeBarrier1},
    {text = "CLOSE.B2", action = "FUNC", value = brmPeripherals.closeBarrier2},
}

table.insert(MenusTree.config,
{text = "PERIPHERALS", action = "MENU", value = "peripherals"})
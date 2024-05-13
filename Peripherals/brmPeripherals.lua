local brmUtilities = require("Reqs.brmUtilities")
local brmPeripherals = {}
EventsHandle = EventsHandle or {events={}, eventList={}}
---@type table <string,number>
local _setpointNumbers = {
    DAP1 = 37,
    DAP2 = 36,
    DAP3 = 35,
    DAP4 = 34,
    inductorCoil1 = 33,
    inductorCoil2 = 32,
    LCT1= 31,
    LCT2= 30,
    openBarrier1 = 29,
    openBarrier2 = 28,
    closeBarrier1 = 27,
    closeBarrier2 = 26,
}
local _RPRProtocol = 8
local timersNum = {
    LCT1Blink   = 10,
    LCT2Blink   = 9,
    RPRMessage  = 8,
}

-------- Persistent Variables ---------
PersistentVars = PersistentVars or {}
PersistentVars.LCTMode = 1
PersistentVars.LCTInverted = false
PersistentVars.LCTBlinkTimeMs = 10000
PersistentVars.RPRPort = 2
PersistentVars.RPRRate = 5
PersistentVars.RPRTime = 5000

------------ DAPS -------------
function brmPeripherals._checkDAP(setpointNumber, setpointActive)
    ---@type string
    local DAPName = brmUtilities.tableFind(_setpointNumbers,setpointNumber)
    if not setpointActive then EventsHandle.events[DAPName] = nil return  end
    EventsHandle.events[DAPName]= true
end

function brmPeripherals.inductorCoil(setpointNum, setpointActive)
    local wt = awtx.weight.getCurrent()
    if not setpointActive or wt.gross >= PersistentVars.minWt then 
        brmPeripherals._blinkActive = false
        return
    end
    brmPeripherals._blinkActive = true
    if setpointNum == _setpointNumbers.inductorCoil1 then
        return brmPeripherals.start1()
    end
    if setpointNum == _setpointNumbers.inductorCoil2 then
        return brmPeripherals.start2()
    end
end

------------ LCTs -------------

brmPeripherals._blinkActive = false

function brmPeripherals.LCT1Green()
    if not PersistentVars.LCTInverted then
        return awtx.setpoint.activate(_setpointNumbers.LCT1)
    end
    awtx.setpoint.deactivate(_setpointNumbers.LCT1)
    
end

function brmPeripherals.LCT2Green()
    if not PersistentVars.LCTInverted then
        return awtx.setpoint.activate(_setpointNumbers.LCT2)
    end
    awtx.setpoint.deactivate(_setpointNumbers.LCT2)
end

function brmPeripherals.LCT1Red()
    if not PersistentVars.LCTInverted then
        return awtx.setpoint.deactivate(_setpointNumbers.LCT1)
    end
        awtx.setpoint.activate(_setpointNumbers.LCT1)
end

function brmPeripherals.LCT2Red()
    if not PersistentVars.LCTInverted then
        return awtx.setpoint.deactivate(_setpointNumbers.LCT2)
    end
    awtx.setpoint.activate(_setpointNumbers.LCT2)
end

function brmPeripherals.LCT1Blink()
    while brmPeripherals._blinkActive do
        awtx.setpoint.activate(_setpointNumbers.LCT1)
        awtx.os.systemEvents(500)
        awtx.setpoint.deactivate(_setpointNumbers.LCT1)
        awtx.os.systemEvents(500)
    end
end

function  brmPeripherals.LCT2Blink()
    while brmPeripherals._blinkActive do
        awtx.setpoint.activate(_setpointNumbers.LCT2)
        awtx.os.systemEvents(500)
        awtx.setpoint.deactivate(_setpointNumbers.LCT2)
        awtx.os.systemEvents(500)
    end
end

------------- Barrier ----------------

function brmPeripherals.openBarrier1()
    awtx.setpoint.activate(_setpointNumbers.openBarrier1)
end

function brmPeripherals.openBarrier2()
    awtx.setpoint.activate(_setpointNumbers.openBarrier2)
end

function brmPeripherals.closeBarrier1()
    awtx.setpoint.activate(_setpointNumbers.openBarrier1)
end

function brmPeripherals.closeBarrier2()
    awtx.setpoint.activate(_setpointNumbers.openBarrier2)
end

-------------RPR--------------------

brmPeripherals.RPR = {}
brmPeripherals.RPR.messages = {}
brmPeripherals.RPR.portNumber = 4


function brmPeripherals.RPR.showWeight()
    awtx.system.protocol.setRate(_RPRProtocol, PersistentVars.RPRRate)
end

---To send a message to the RPR, be sure that the number port be an active port and the same of protocol 8
---@param message string
function brmPeripherals.RPR.sendMessage(message)
    PersistentVars.RPRTime = 5000
    awtx.system.protocol.setRate(_RPRProtocol, 0)
    pcall(awtx.serial.send,PersistentVars.RPRPort, message)
    brmPeripherals.RPR._timer:reset()
end

function brmPeripherals.RPR.messages.positionError(positionNumber)
end

function brmPeripherals.RPR.messages.weightOk()
    brmPeripherals.rpr.sendMessage("Weight OK")
end

function brmPeripherals.RPR.messages.getOffScale()
end

function brmPeripherals.RPR.messages.ready()
end


-------------Operations--------------

function brmPeripherals.start1()
    local operations = {
        [1] = function ()
            brmPeripherals._LCT1blinkTimer:reset()
            brmPeripherals.LCT1Green()
        end,
        [2] =function ()
            brmPeripherals._LCT2blinkTimer:reset()
            brmPeripherals.LCT2Green()
        end, 
        [3] =function ()
            brmPeripherals._LCT2blinkTimer:reset()
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
            brmPeripherals._LCT2blinkTimer:reset()
            brmPeripherals.LCT2Green()
        end,
        [2] =function ()
            brmPeripherals._LCT1blinkTimer:reset()
            brmPeripherals.LCT1Green()
        end, 
        [4] =function ()
            brmPeripherals._LCT1blinkTimer:reset()
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


function brmPeripherals.onStart()
    EventsHandle.eventList.DAP1 = "DAP1"
    EventsHandle.eventList.DAP2 = "DAP2"
    EventsHandle.eventList.DAP3 = "DAP3"
    EventsHandle.eventList.DAP4 = "DAP4"
    -------------Setpoints Definition----------------------
    awtx.setpoint.registerInputEvent(_setpointNumbers.DAP1,brmPeripherals._checkDAP)
    awtx.setpoint.registerInputEvent(_setpointNumbers.inductorCoil1,brmPeripherals.inductorCoil)
    awtx.setpoint.registerInputEvent(_setpointNumbers.inductorCoil2,brmPeripherals.inductorCoil)

    ------------Timers Definition--------------------------
    brmPeripherals._LCT1blinkTimer = awtx.os.enhancedTimer.new(timersNum.LCT1Blink,
                                                                brmPeripherals.LCT1Blink,PersistentVars.LCTBlinkTimeMs,1)
    brmPeripherals._LCT2blinkTimer = awtx.os.enhancedTimer.new(timersNum.LCT2Blink,brmPeripherals.LCT2Blink,
                                                                PersistentVars.LCTBlinkTimeMs,1)
    brmPeripherals.RPR._timer = awtx.os.enhancedTimer.new(timersNum.RPRMessage,
                                                                brmPeripherals.RPR.showWeight,PersistentVars.RPRTime,1)
end


-------------Menu Functions---------------

function brmPeripherals._changeLCTMode()
    local choice, isEnterKey
    choice, isEnterKey = awtx.keypad.selectList("1,2,3,4",PersistentVars.LCTMode-1,-1,"Mode")
    if not isEnterKey then return end
    PersistentVars.LCTMode = choice+1
end

brmPeripherals.onStart()
MenusTree = MenusTree or {}
MenusTree.config = MenusTree.config or {}


--------MenusTree-----------
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
local lightControl = {}
lightControl.states = {
    green = "green",
    yellow = "yellow",
    red = "red",
}

local timer = 10

local setpoint = { 6, 7 }

local setpointDefinition = {
    green  = { true, false },
    yellow = { false, true },
    red    = { false, false },
}

local ChangeSetpointState = function(setpointNumber, activate)
    if activate then awtx.setpoint.activate(setpointNumber)
    else awtx.setpoint.deactivate(setpointNumber) end
end

lightControl.defaultLight = lightControl.states.yellow

lightControl._changeLight = function(color)
    if not setpointDefinition[color] then return end
    ChangeSetpointState(setpoint[1], setpointDefinition[color][1])
    ChangeSetpointState(setpoint[2], setpointDefinition[color][2])
end

lightControl.setStatus = function (color,time)
    if not setpointDefinition[color] then return end
    lightControl._changeLight(color)
    awtx.os.enhancedTimer.new(timer,function () lightControl._changeLight(lightControl.defaultLight)
    end, time or 3000,1)
end
lightControl._changeLight(lightControl.defaultLight)
return lightControl

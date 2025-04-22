--[[
*******************************************************************************

Filename:     awtxReqScaleKeys.lua
Version:      1.0.1.0
Date:         2015-09-01
Customer:     Avery Weigh-Tronix
Description:
This file provides basic general key functionality for the ZM405 indicator.
The default handled event keys may or may not exist on other hardware.

*******************************************************************************

Functions:
-- These create the default functionality for the keys.
-- Redefine the function to change the default functionality.
  return brmScaleKeys.keyHandle("onXXXKeyDown")
  return brmScaleKeys.keyHandle("onXXXKeyHold")
  return brmScaleKeys.keyHandle("onXXXKeyUp")

Event Handlers:
-- Leave these as-is as they create your hold events.
-- Redefine them if you want to change or use the REPEAT event for each key
  awtx.keypad.KEY_XXX_DOWN()
  awtx.keypad.KEY_XXX_REPEAT()
  awtx.keypad.KEY_XXX_UP()


*******************************************************************************
Change History:
1.0.0.0 - Initial Release
1.0.1.0 - Added the zeroHoldFlag declaration that was missed.
*******************************************************************************
]]

-- create the keypad namespace
local brmScaleKeys            = {}
local awtxReqConstants        = require("Reqs.awtxReqConstants")
local brmUtilities            = require("Reqs.brmUtilities")

-- define how many repeat events create a HOLD event for the keys
local HowManyRepeatsMakeAHold = 3

-- Flags for counting the number of hold events for each key.
local tareHoldFlag            = 0
local selectHoldFlag          = 0
local printHoldFlag           = 0
local unitsHoldFlag           = 0
local sampleHoldFlag          = 0
local startHoldFlag           = 0
local stopHoldFlag            = 0
local f1HoldFlag              = 0
local f2HoldFlag              = 0
local f3HoldFlag              = 0
local f4HoldFlag              = 0
local f5HoldFlag              = 0
local scaleSelectHoldFlag     = 0
local setupHoldFlag           = 0
local targetHoldFlag          = 0
local numericHoldFlag         = 0
local clearHoldFlag           = 0
local decimalHoldFlag         = 0
local zeroHoldFlag            = 0


brmScaleKeys.evensNames = {
  "onStartKeyDown"
}

---Function to wait to press a key
---caution! it function block all the keys except setup, but another function event how change the screen can be activated
---@param key string --key to press
---@param waitMotion? boolean -- if you want to wait for stability
function brmScaleKeys.waitKey(key, waitMotion)
  local preCurrentMode = CurrentMode
  local waitK = { _name = "waitKey", keypad = {} }
  local flag = nil
  waitK.keypad.onF1KeyUp = function() flag = false end
  waitK.keypad[key] = function() flag = true end
  CurrentMode = waitK
  while type(flag) == "nil" do awtx.os.systemEvents(200) end
  if waitMotion == true then brmUtilities.waitStability(1) end
  CurrentMode = preCurrentMode
  return flag
end

---comment
---@param keyEvent brmScaleKeys.evensNames
---@param ... unknown
---@return nil
function brmScaleKeys.keyHandle(keyEvent, ...)
  if type(CurrentMode.keypad) == "nil" then return end
  ---@diagnostic disable-next-line: redundant-parameter
  if CurrentMode.keypad[keyEvent] then return CurrentMode.keypad[keyEvent](...) end
end

function brmScaleKeys.rpnHandle(keyEvent, number, ...)
  if type(CurrentMode.rpn) == "nil" then return end
  if CurrentMode.rpn[keyEvent] then
    return
        CurrentMode.rpn[keyEvent](number)
  end
end

function brmScaleKeys.usbKeyHandle(keycode, ...)
  ---@class brmScaleKeys.usbKeyHandle.call
  ---@field func brmScaleKeys.evensNames
  ---@field args any

  ---@type table<integer,brmScaleKeys.usbKeyHandle.call>
  local calls = {
    [4109] = { func = "onEscapeKeyUp" },
    [4110] = { func = "onClearKeyUp" },
  }

  local call = calls[keycode]
  if call then return brmScaleKeys.keyHandle(call.func, call.args) end
  local status, char = pcall(string.char, keycode)
  if status then
    return brmScaleKeys.keyHandle("onQwertyKeyUp", char)
  end
  print(keycode, arg)
end

---@class brmScaleKeys.KeypadEvents
---@field onTareKeyDown? fun(...)
---@field onTareKeyUp? fun(...)
---@field onTareKeyHold? fun(...)
---@field onSelectKeyDown? fun(...)
---@field onSelectKeyUp? fun(...)
---@field onSelectKeyHold? fun(...)
---@field onPrintKeyDown? fun(...)
---@field onPrintKeyUp? fun(...)
---@field onPrintKeyHold? fun(...)
---@field onUnitsKeyDown? fun(...)
---@field onUnitsKeyUp? fun(...)
---@field onUnitsKeyHold? fun(...)
---@field onZeroKeyDown? fun(...)
---@field onZeroKeyUp? fun(...)
---@field onZeroKeyHold? fun(...)
---@field onSampleKeyDown? fun(...)
---@field onSampleKeyUp? fun(...)
---@field onSampleKeyHold? fun(...)
---@field onStartKeyDown? fun(...)
---@field onStartKeyUp? fun(...)
---@field onStartKeyHold? fun(...)
---@field onStopKeyDown? fun(...)
---@field onStopKeyUp? fun(...)
---@field onStopKeyHold? fun(...)
---@field onF1KeyDown? fun(...)
---@field onF1KeyUp? fun(...)
---@field onF1KeyHold? fun(...)
---@field onF2KeyDown? fun(...)
---@field onF2KeyUp? fun(...)
---@field onF2KeyHold? fun(...)
---@field onF3KeyDown? fun(...)
---@field onF3KeyUp? fun(...)
---@field onF3KeyHold? fun(...)
---@field onF4KeyDown? fun(...)
---@field onF4KeyUp? fun(...)
---@field onF4KeyHold? fun(...)
---@field onF5KeyDown? fun(...)
---@field onF5KeyUp? fun(...)
---@field onF5KeyHold? fun(...)
---@field onScaleSelectKeyDown? fun(...)
---@field onScaleSelectKeyUp? fun(...)
---@field onScaleSelectKeyHold? fun(...)
---@field onSetupKeyDown? fun(...)
---@field onSetupKeyUp? fun(...)
---@field onSetupKeyHold? fun(...)
---@field onTargetKeyDown? fun(...)
---@field onTargetKeyUp? fun(...)
---@field onTargetKeyHold? fun(...)
---@field onNumericKeyDown? fun(...)
---@field onNumericKeyUp? fun(...)
---@field onNumericKeyHold? fun(...)
---@field onClearKeyDown? fun(...)
---@field onClearKeyUp? fun(...)
---@field onClearKeyHold? fun(...)
---@field onDecimalKeyDown? fun(...)
---@field onDecimalKeyUp? fun(...)
---@field onDecimalKeyHold? fun(...)
---@field onQwertyKeyUp? fun(...)
---@field onIdKeyDown? fun(...)
---@field onIdKeyUp? fun(...)
---@field onIdKeyHold? fun(...)
---@field onEscapeKeyUp? fun(...)

---@enum(key) brmScaleKeys.evensNames
brmScaleKeys.defaultKeypad = {
  onTareKeyDown = nil,
  onTareKeyUp = nil,
  onTareKeyHold = function()
    awtx.weight.requestTareClear()
    brmUtilities.doScroll(Language.done)
  end,
  onSelectKeyDown = function()
    awtx.weight.cycleActiveScale()
  end,
  onSelectKeyUp = function()
    awtx.weight.cycleActiveValue()
  end,
  onSelectKeyHold = nil,
  onPrintKeyDown = function()
    awtx.weight.requestPrint()
  end,
  onPrintKeyUp = nil,
  onPrintKeyHold = nil,
  onUnitsKeyDown = nil,
  onUnitsKeyUp = nil,
  onUnitsKeyHold = nil,
  onZeroKeyDown = function()
    awtx.weight.requestZero()
  end,
  onZeroKeyUp = nil,
  onZeroKeyHold = nil,
  onSampleKeyDown = nil,
  onSampleKeyUp = nil,
  onSampleKeyHold = nil,
  onStartKeyDown = nil,
  onStartKeyUp = nil,
  onStartKeyHold = nil,
  onStopKeyDown = nil,
  onStopKeyUp = nil,
  onStopKeyHold = nil,
  onF1KeyDown = nil,
  onF1KeyUp = nil,
  onF1KeyHold = nil,
  onF2KeyDown = nil,
  onF2KeyUp = nil,
  onF2KeyHold = nil,
  onF3KeyDown = nil,
  onF3KeyUp = nil,
  onF3KeyHold = nil,
  onF4KeyDown = nil,
  onF4KeyUp = nil,
  onF4KeyHold = nil,
  onF5KeyDown = nil,
  onF5KeyUp = nil,
  onF5KeyHold = nil,
  onScaleSelectKeyUp = nil,
  onScaleSelectKeyDown = nil,
  onScaleSelectKeyHold = nil,
  onSetupKeyDown = nil,
  onSetupKeyUp = nil,
  onSetupKeyHold = nil,
  onTargetKeyDown = nil,
  onTargetKeyUp = nil,
  onTargetKeyHold = nil,
  onNumericKeyDown = nil,
  onNumericKeyUp = nil,
  onNumericKeyHold = nil,
  onClearKeyUp = nil,
  onClearKeyDown = nil,
  onClearKeyHold = nil,
  onDecimalKeyDown = nil,
  onDecimalKeyUp = nil,
  onDecimalKeyHold = nil,
  onQwertyKeyUp = nil,
  onIdKeyDown = nil,
  onIdKeyUp = nil,
  onIdKeyHold = nil,
  onEscapeKeyUp = nil,
}
brmScaleKeys.defaultRpn = {
  TARE = function(number)
    local newTare = tonumber(number)
    awtx.weight.requestKeyboardTare(newTare)
  end,
  ZERO = function(number)
    local newZero = tonumber(number)
    awtx.weight.requestKeyboardZero(newZero)
  end
}


function brmScaleKeys.onStart()
  -- awtx.keypad.setRpnMode(1) -- 1 for enable
  awtx.keypad.registerRpnEvent(brmScaleKeys.rpnHandle) -- 1 for enable
  awtx.keypad.registerUsbKeyboardEvent(brmScaleKeys.usbKeyHandle)
  -------------------------------------Definition of keys---------------------------------------
  ---------------------------------- Tare Key Default Functions ----------------------------------
  ------------------------------------------------------------------------------------------------
  function awtx.keypad.KEY_TARE_DOWN()
    tareHoldFlag = 0
    return brmScaleKeys.keyHandle("onTareKeyDown")
  end

  function awtx.keypad.KEY_TARE_REPEAT()
    tareHoldFlag = tareHoldFlag + 1
    if tareHoldFlag == HowManyRepeatsMakeAHold then
      return brmScaleKeys.keyHandle("onTareKeyHold")
    end
  end

  function awtx.keypad.KEY_TARE_UP()
    if tareHoldFlag < HowManyRepeatsMakeAHold then
      return brmScaleKeys.keyHandle("onTareKeyUp")
    end
    tareHoldFlag = 0
  end

  -----------------------------------------------------------------------------------------------
  -- Select Key Event Handlers
  -----------------------------------------------------------------------------------------------
  function awtx.keypad.KEY_SELECT_DOWN()
    selectHoldFlag = 0
    return brmScaleKeys.keyHandle("onSelectKeyDown")
  end

  function awtx.keypad.KEY_SELECT_REPEAT()
    selectHoldFlag = selectHoldFlag + 1
    if selectHoldFlag == HowManyRepeatsMakeAHold then
      return brmScaleKeys.keyHandle("onSelectKeyHold")
    end
  end

  function awtx.keypad.KEY_SELECT_UP()
    if selectHoldFlag < HowManyRepeatsMakeAHold then
      return brmScaleKeys.keyHandle("onSelectKeyUp")
    end
    selectHoldFlag = 0
  end

  -----------------------------------------------------------------------------------------------
  -- Print Key Event Handlers
  -----------------------------------------------------------------------------------------------
  function awtx.keypad.KEY_PRINT_DOWN()
    printHoldFlag = 0
    return brmScaleKeys.keyHandle("onPrintKeyDown")
  end

  function awtx.keypad.KEY_PRINT_REPEAT()
    printHoldFlag = printHoldFlag + 1
    if printHoldFlag == HowManyRepeatsMakeAHold then
      return brmScaleKeys.keyHandle("onPrintKeyHold")
    end
  end

  function awtx.keypad.KEY_PRINT_UP()
    if printHoldFlag < HowManyRepeatsMakeAHold then
      return brmScaleKeys.keyHandle("onPrintKeyUp")
    end
    printHoldFlag = 0
  end

  -----------------------------------------------------------------------------------------------
  -- Units Key Event Handlers
  -----------------------------------------------------------------------------------------------
  function awtx.keypad.KEY_UNITS_DOWN()
    unitsHoldFlag = 0
    return brmScaleKeys.keyHandle("onUnitsKeyDown")
  end

  function awtx.keypad.KEY_UNITS_REPEAT()
    unitsHoldFlag = unitsHoldFlag + 1
    if unitsHoldFlag == HowManyRepeatsMakeAHold then
      return brmScaleKeys.keyHandle("onUnitsKeyHold")
    end
  end

  function awtx.keypad.KEY_UNITS_UP()
    if unitsHoldFlag < HowManyRepeatsMakeAHold then
      return brmScaleKeys.keyHandle("onUnitsKeyUp")
    end
    unitsHoldFlag = 0
  end

  -----------------------------------------------------------------------------------------------
  -- Zero Key Event Handlers
  -----------------------------------------------------------------------------------------------
  function awtx.keypad.KEY_ZERO_DOWN()
    zeroHoldFlag = 0
    return brmScaleKeys.keyHandle("onZeroKeyDown")
  end

  function awtx.keypad.KEY_ZERO_REPEAT()
    zeroHoldFlag = zeroHoldFlag + 1
    if zeroHoldFlag == HowManyRepeatsMakeAHold then
      return brmScaleKeys.keyHandle("onZeroKeyHold")
    end
  end

  function awtx.keypad.KEY_ZERO_UP()
    if zeroHoldFlag < HowManyRepeatsMakeAHold then
      return brmScaleKeys.keyHandle("onZeroKeyUp")
    end
    zeroHoldFlag = 0
  end

  -----------------------------------------------------------------------------------------------
  -- Sample Key Event Handlers
  -----------------------------------------------------------------------------------------------
  function awtx.keypad.KEY_SAMPLE_DOWN()
    sampleHoldFlag = 0
    return brmScaleKeys.keyHandle("onSampleKeyDown")
  end

  function awtx.keypad.KEY_SAMPLE_REPEAT()
    sampleHoldFlag = sampleHoldFlag + 1
    if sampleHoldFlag == HowManyRepeatsMakeAHold then
      return brmScaleKeys.keyHandle("onSampleKeyHold")
    end
  end

  function awtx.keypad.KEY_SAMPLE_UP()
    if sampleHoldFlag < HowManyRepeatsMakeAHold then
      return brmScaleKeys.keyHandle("onSampleKeyUp")
    end
    sampleHoldFlag = 0
  end

  -----------------------------------------------------------------------------------------------
  -- Start Key Event Handlers
  -----------------------------------------------------------------------------------------------
  function awtx.keypad.KEY_START_DOWN()
    startHoldFlag = 0
    return brmScaleKeys.keyHandle("onStartKeyDown")
  end

  function awtx.keypad.KEY_START_REPEAT()
    startHoldFlag = startHoldFlag + 1
    if startHoldFlag == HowManyRepeatsMakeAHold then
      return brmScaleKeys.keyHandle("onStartKeyHold")
    end
  end

  function awtx.keypad.KEY_START_UP()
    if startHoldFlag < HowManyRepeatsMakeAHold then
      return brmScaleKeys.keyHandle("onStartKeyUp")
    end
    startHoldFlag = 0
  end

  -----------------------------------------------------------------------------------------------
  -- Stop Key Event Handlers
  -----------------------------------------------------------------------------------------------
  function awtx.keypad.KEY_STOP_DOWN()
    stopHoldFlag = 0
    return brmScaleKeys.keyHandle("onStopKeyDown")
  end

  function awtx.keypad.KEY_STOP_REPEAT()
    stopHoldFlag = stopHoldFlag + 1
    if stopHoldFlag == HowManyRepeatsMakeAHold then
      return brmScaleKeys.keyHandle("onStopKeyHold")
    end
  end

  function awtx.keypad.KEY_STOP_UP()
    if stopHoldFlag < HowManyRepeatsMakeAHold then
      return brmScaleKeys.keyHandle("onStopKeyUp")
    end
    stopHoldFlag = 0
  end

  -----------------------------------------------------------------------------------------------
  -- F1 Key Event Handlers
  -----------------------------------------------------------------------------------------------
  function awtx.keypad.KEY_F1_DOWN()
    f1HoldFlag = 0
    return brmScaleKeys.keyHandle("onF1KeyDown")
  end

  function awtx.keypad.KEY_F1_REPEAT()
    f1HoldFlag = f1HoldFlag + 1
    if f1HoldFlag == HowManyRepeatsMakeAHold then
      return brmScaleKeys.keyHandle("onF1KeyHold")
    end
  end

  function awtx.keypad.KEY_F1_UP()
    if f1HoldFlag < HowManyRepeatsMakeAHold then
      return brmScaleKeys.keyHandle("onF1KeyUp")
    end
    f1HoldFlag = 0
  end

  function awtx.keypad.KEY_F2_DOWN()
    f2HoldFlag = 0
    return brmScaleKeys.keyHandle("onF2KeyDown")
  end

  function awtx.keypad.KEY_F2_REPEAT()
    f2HoldFlag = f2HoldFlag + 1
    if f2HoldFlag == HowManyRepeatsMakeAHold then
      return brmScaleKeys.keyHandle("onF2KeyHold")
    end
  end

  function awtx.keypad.KEY_F2_UP()
    if f2HoldFlag < HowManyRepeatsMakeAHold then
      return brmScaleKeys.keyHandle("onF2KeyUp")
    end
    f2HoldFlag = 0
  end

  function awtx.keypad.KEY_F3_DOWN()
    f3HoldFlag = 0
    return brmScaleKeys.keyHandle("onF3KeyDown")
  end

  function awtx.keypad.KEY_F3_REPEAT()
    f3HoldFlag = f3HoldFlag + 1
    if f3HoldFlag == HowManyRepeatsMakeAHold then
      return brmScaleKeys.keyHandle("onF3KeyHold")
    end
  end

  function awtx.keypad.KEY_F3_UP()
    if f3HoldFlag < HowManyRepeatsMakeAHold then
      return brmScaleKeys.keyHandle("onF3KeyUp")
    end
    f3HoldFlag = 0
  end

  function awtx.keypad.KEY_F4_DOWN()
    f4HoldFlag = 0
    return brmScaleKeys.keyHandle("onF4KeyDown")
  end

  function awtx.keypad.KEY_F4_REPEAT()
    f4HoldFlag = f4HoldFlag + 1
    if f4HoldFlag == HowManyRepeatsMakeAHold then
      return brmScaleKeys.keyHandle("onF4KeyHold")
    end
  end

  function awtx.keypad.KEY_F4_UP()
    if f4HoldFlag < HowManyRepeatsMakeAHold then
      return brmScaleKeys.keyHandle("onF4KeyUp")
    end
    f4HoldFlag = 0
  end

  function awtx.keypad.KEY_F5_DOWN()
    f5HoldFlag = 0
    return brmScaleKeys.keyHandle("onF5KeyDown")
  end

  function awtx.keypad.KEY_F5_REPEAT()
    f5HoldFlag = f5HoldFlag + 1
    if f5HoldFlag == HowManyRepeatsMakeAHold then
      return brmScaleKeys.keyHandle("onF5KeyHold")
    end
  end

  function awtx.keypad.KEY_F5_UP()
    if f5HoldFlag < HowManyRepeatsMakeAHold then
      return brmScaleKeys.keyHandle("onF5KeyUp")
    end
    f5HoldFlag = 0
  end

  -----------------------------------------------------------------------------------------------
  -- Scale Select Key Event Handlers
  -----------------------------------------------------------------------------------------------
  function awtx.keypad.KEY_SCALE_SELECT_DOWN()
    scaleSelectHoldFlag = 0
    return brmScaleKeys.keyHandle("onScaleSelectKeyDown")
  end

  function awtx.keypad.KEY_SCALE_SELECT_REPEAT()
    scaleSelectHoldFlag = scaleSelectHoldFlag + 1
    if scaleSelectHoldFlag == HowManyRepeatsMakeAHold then
      return brmScaleKeys.keyHandle("onScaleSelectKeyHold")
    end
  end

  function awtx.keypad.KEY_SCALE_SELECT_UP()
    if scaleSelectHoldFlag < HowManyRepeatsMakeAHold then
      return brmScaleKeys.keyHandle("onScaleSelectKeyUp")
    end
    scaleSelectHoldFlag = 0
  end

  -----------------------------------------------------------------------------------------------
  -- Setup Key Event Handlers
  -----------------------------------------------------------------------------------------------
  function awtx.keypad.KEY_SETUP_DOWN()
    setupHoldFlag = 0
    return brmScaleKeys.keyHandle("onSetupKeyDown")
  end

  function awtx.keypad.KEY_SETUP_REPEAT()
    setupHoldFlag = setupHoldFlag + 1
    if setupHoldFlag == HowManyRepeatsMakeAHold then
      return brmScaleKeys.keyHandle("onSetupKeyHold")
    end
  end

  function awtx.keypad.KEY_SETUP_UP()
    if setupHoldFlag < HowManyRepeatsMakeAHold then
      return brmScaleKeys.keyHandle("onSetupKeyUp")
    end
    setupHoldFlag = 0
  end

  -----------------------------------------------------------------------------------------------
  -- Target Key Event Handlers
  -----------------------------------------------------------------------------------------------
  function awtx.keypad.KEY_TARGET_DOWN()
    targetHoldFlag = 0
    return brmScaleKeys.keyHandle("onTargetKeyDown")
  end

  function awtx.keypad.KEY_TARGET_REPEAT()
    targetHoldFlag = targetHoldFlag + 1
    if targetHoldFlag == HowManyRepeatsMakeAHold then
      return brmScaleKeys.keyHandle("onTargetKeyHold")
    end
  end

  function awtx.keypad.KEY_TARGET_UP()
    if targetHoldFlag < HowManyRepeatsMakeAHold then
      return brmScaleKeys.keyHandle("onTargetKeyUp")
    end
    targetHoldFlag = 0
  end

  -----------------------------------------------------------------------------------------------
  -- Numeric Key Event Handlers
  -----------------------------------------------------------------------------------------------
  function awtx.keypad.KEY_NUMERIC_DOWN(numChar)
    numericHoldFlag = 0
    return brmScaleKeys.keyHandle("onNumericKeyDown", numChar)
  end

  function awtx.keypad.KEY_NUMERIC_REPEAT(numChar)
    numericHoldFlag = numericHoldFlag + 1
    if numericHoldFlag == HowManyRepeatsMakeAHold then
      return brmScaleKeys.keyHandle("onNumericKeyHold", numChar)
    end
  end

  function awtx.keypad.KEY_NUMERIC_UP(numChar)
    if numericHoldFlag < HowManyRepeatsMakeAHold then
      return brmScaleKeys.keyHandle("onNumericKeyUp", numChar)
    end
    numericHoldFlag = 0
  end

  -----------------------------------------------------------------------------------------------
  -- Clear Key Event Handlers
  -----------------------------------------------------------------------------------------------
  function awtx.keypad.KEY_CLEAR_DOWN()
    clearHoldFlag = 0
    return brmScaleKeys.keyHandle("onClearKeyDown")
  end

  function awtx.keypad.KEY_CLEAR_REPEAT()
    clearHoldFlag = clearHoldFlag + 1
    if clearHoldFlag == HowManyRepeatsMakeAHold then
      return brmScaleKeys.keyHandle("onClearKeyHold")
    end
  end

  function awtx.keypad.KEY_CLEAR_UP()
    if clearHoldFlag < HowManyRepeatsMakeAHold then
      return brmScaleKeys.keyHandle("onClearKeyUp")
    end
    clearHoldFlag = 0
  end

  -----------------------------------------------------------------------------------------------
  -- Decimal Key Event Handlers
  -----------------------------------------------------------------------------------------------
  function awtx.keypad.KEY_DECIMAL_DOWN()
    decimalHoldFlag = 0
    return brmScaleKeys.keyHandle("onDecimalKeyDown")
  end

  function awtx.keypad.KEY_DECIMAL_REPEAT()
    decimalHoldFlag = decimalHoldFlag + 1
    if decimalHoldFlag == HowManyRepeatsMakeAHold then
      return brmScaleKeys.keyHandle("onDecimalKeyHold")
    end
  end

  function awtx.keypad.KEY_DECIMAL_UP()
    if decimalHoldFlag < HowManyRepeatsMakeAHold then
      return brmScaleKeys.keyHandle("onDecimalKeyUp")
    end
    decimalHoldFlag = 0
  end
end

function awtx.keypad.KEY_QWERTY_UP(releasedChar)
  return brmScaleKeys.keyHandle("onQwertyKeyUp", releasedChar)
end

function awtx.keypad.KEY_ID_UP()
  return brmScaleKeys.keyHandle("onIdKeyUp")
end

brmScaleKeys.onStart()
return brmScaleKeys

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
  if CurrentMode.keypad.onXXXKeyDown then return CurrentMode.keypad.onXXXKeyDown() end
  if CurrentMode.keypad.onXXXKeyHold then return CurrentMode.keypad.onXXXKeyHold() end
  if CurrentMode.keypad.onXXXKeyUp then return CurrentMode.keypad.onXXXKeyUp() end
  
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
local brmScaleKeys = {}

-- define how many repeat events create a HOLD event for the keys
local HowManyRepeatsMakeAHold = 3

-- Flags for counting the number of hold events for each key.
local tareHoldFlag = 0
local selectHoldFlag = 0
local printHoldFlag = 0
local unitsHoldFlag = 0
local sampleHoldFlag = 0
local startHoldFlag = 0
local stopHoldFlag = 0
local f1HoldFlag = 0
local scaleSelectHoldFlag = 0
local setupHoldFlag = 0
local targetHoldFlag = 0
local numericHoldFlag = 0
local clearHoldFlag = 0
local decimalHoldFlag = 0
local zeroHoldFlag = 0
local keys = {f1 = 1, f2 = 2, f3 = 3,
        f4 = 4, f5 = 5,
        key_0 = 6, key_1 = 7,
        key_2 = 8, key_3 = 9,
        key_4 = 10, key_5 = 11,
        key_6 = 12, key_7 = 13,
        key_8 = 14, key_9 = 15,
        clear = 16, decimal = 17,
        id = 19, print = 22,
        sample = 24, scale_select = 25,
        select = 26, setup = 27,
        start = 28, stop = 29,
        tare = 30, target = 31,
        units = 33, zero = 34,
    }


---function to wait to press a key
---@param keyName string
function brmScaleKeys.witKey(keyName)
  keyName = type(keyName) == "string" and keyName or "zero"
  local key = keys[keyName]
  if not key then return print("not key") end
  local passOperation = CurrentMode.operationsActive -- To save a before status of operationsActive
  CurrentMode.operationsActive = false --Deactivating operationsActive

  awtx.keypad.registerAlternateKeyEvent(function(key_code) --the unique key whit use is the selected
      if key_code == key then brmUtilities._alternativeKeyPress = true end
  end)
  awtx.keypad.useAlternateLuaKeyboardEvents()
  while not brmUtilities._alternativeKeyPress do
      awtx.os.systemEvents(200)
  end
  brmUtilities._alternativeKeyPress = false
  CurrentMode.operationsActive = passOperation -- To set the before status of operationsActive
end

function brmScaleKeys.onStart()
  -------------------------------------Definition of keys---------------------------------------
---------------------------------- Tare Key Default Functions ----------------------------------
------------------------------------------------------------------------------------------------
  function awtx.keypad.KEY_TARE_DOWN()
    tareHoldFlag = 0
    if CurrentMode.keypad.onTareKeyDown then return CurrentMode.keypad.onTareKeyDown() end
  end

  function awtx.keypad.KEY_TARE_REPEAT()
    tareHoldFlag = tareHoldFlag + 1
    if tareHoldFlag == HowManyRepeatsMakeAHold then
      if CurrentMode.keypad.onTareKeyHold then return CurrentMode.keypad.onTareKeyHold() end
    end
  end

  function awtx.keypad.KEY_TARE_UP()
    if tareHoldFlag < HowManyRepeatsMakeAHold then
      if CurrentMode.keypad.onTareKeyUp then return CurrentMode.keypad.onTareKeyUp() end
    end
    tareHoldFlag = 0
  end


  -----------------------------------------------------------------------------------------------
  -- Select Key Event Handlers
  -----------------------------------------------------------------------------------------------
  function awtx.keypad.KEY_SELECT_DOWN()
    selectHoldFlag = 0
    if CurrentMode.keypad.onSelectKeyDown then return CurrentMode.keypad.onSelectKeyDown() end
    awtx.weight.cycleActiveValue()
  end

  function awtx.keypad.KEY_SELECT_REPEAT()
    selectHoldFlag = selectHoldFlag + 1
    if selectHoldFlag == HowManyRepeatsMakeAHold then
      if CurrentMode.keypad.onSelectKeyHold then return CurrentMode.keypad.onSelectKeyHold() end
    end
  end

  function awtx.keypad.KEY_SELECT_UP()
    if selectHoldFlag < HowManyRepeatsMakeAHold then
      if CurrentMode.keypad.onSelectKeyUp then return CurrentMode.keypad.onSelectKeyUp() end
    end
    selectHoldFlag = 0
  end


  -----------------------------------------------------------------------------------------------
  -- Print Key Event Handlers
  -----------------------------------------------------------------------------------------------
  function awtx.keypad.KEY_PRINT_DOWN()
    printHoldFlag = 0
    if CurrentMode.keypad.onPrintKeyDown then return CurrentMode.keypad.onPrintKeyDown() end
  end

  function awtx.keypad.KEY_PRINT_REPEAT()
    printHoldFlag = printHoldFlag + 1
    if printHoldFlag == HowManyRepeatsMakeAHold then
      if CurrentMode.keypad.onPrintKeyHold then return CurrentMode.keypad.onPrintKeyHold() end
    end
  end

  function awtx.keypad.KEY_PRINT_UP()
    if printHoldFlag < HowManyRepeatsMakeAHold then
      if CurrentMode.keypad.onPrintKeyUp then return CurrentMode.keypad.onPrintKeyUp() end
    end
    printHoldFlag = 0
  end


  -----------------------------------------------------------------------------------------------
  -- Units Key Event Handlers
  -----------------------------------------------------------------------------------------------
  function awtx.keypad.KEY_UNITS_DOWN()
    unitsHoldFlag = 0
    if CurrentMode.keypad.onUnitsKeyDown then return CurrentMode.keypad.onUnitsKeyDown() end
  end

  function awtx.keypad.KEY_UNITS_REPEAT()
    unitsHoldFlag = unitsHoldFlag + 1
    if unitsHoldFlag == HowManyRepeatsMakeAHold then
      if CurrentMode.keypad.onUnitsKeyHold then return CurrentMode.keypad.onUnitsKeyHold() end
    end
  end

  function awtx.keypad.KEY_UNITS_UP()
    if unitsHoldFlag < HowManyRepeatsMakeAHold then
      if CurrentMode.keypad.onUnitsKeyUp then return CurrentMode.keypad.onUnitsKeyUp() end
    end
    unitsHoldFlag = 0
  end


  -----------------------------------------------------------------------------------------------
  -- Zero Key Event Handlers
  -----------------------------------------------------------------------------------------------
  function awtx.keypad.KEY_ZERO_DOWN()
    zeroHoldFlag = 0
    if CurrentMode.keypad.onZeroKeyDown then return CurrentMode.keypad.onZeroKeyDown() end
  end

  function awtx.keypad.KEY_ZERO_REPEAT()
    zeroHoldFlag = zeroHoldFlag + 1
    if zeroHoldFlag == HowManyRepeatsMakeAHold then
      if CurrentMode.keypad.onZeroKeyHold then return CurrentMode.keypad.onZeroKeyHold() end
    end
  end

  function awtx.keypad.KEY_ZERO_UP()
    if zeroHoldFlag < HowManyRepeatsMakeAHold then
      if CurrentMode.keypad.onZeroKeyUp then return CurrentMode.keypad.onZeroKeyUp() end
    end
    zeroHoldFlag = 0
  end


  -----------------------------------------------------------------------------------------------
  -- Sample Key Event Handlers
  -----------------------------------------------------------------------------------------------
  function awtx.keypad.KEY_SAMPLE_DOWN()
    sampleHoldFlag = 0
    if CurrentMode.keypad.onSampleKeyDown then return CurrentMode.keypad.onSampleKeyDown() end
  end

  function awtx.keypad.KEY_SAMPLE_REPEAT()
    sampleHoldFlag = sampleHoldFlag + 1
    if sampleHoldFlag == HowManyRepeatsMakeAHold then
      if CurrentMode.keypad.onSampleKeyHold then return CurrentMode.keypad.onSampleKeyHold() end
    end
  end

  function awtx.keypad.KEY_SAMPLE_UP()
    if sampleHoldFlag < HowManyRepeatsMakeAHold then
      if CurrentMode.keypad.onSampleKeyUp then return CurrentMode.keypad.onSampleKeyUp() end
    end
    sampleHoldFlag = 0
  end


  -----------------------------------------------------------------------------------------------
  -- Start Key Event Handlers
  -----------------------------------------------------------------------------------------------
  function awtx.keypad.KEY_START_DOWN()
    startHoldFlag = 0
    if CurrentMode.keypad.onStartKeyDown then return CurrentMode.keypad.onStartKeyDown() end
  end

  function awtx.keypad.KEY_START_REPEAT()
    startHoldFlag = startHoldFlag + 1
    if startHoldFlag == HowManyRepeatsMakeAHold then
      if CurrentMode.keypad.onStartKeyHold then return CurrentMode.keypad.onStartKeyHold() end
    end
  end

  function awtx.keypad.KEY_START_UP()
    if startHoldFlag < HowManyRepeatsMakeAHold then
      if CurrentMode.keypad.onStartKeyUp then return CurrentMode.keypad.onStartKeyUp() end
    end
    startHoldFlag = 0
  end


  -----------------------------------------------------------------------------------------------
  -- Stop Key Event Handlers
  -----------------------------------------------------------------------------------------------
  function awtx.keypad.KEY_STOP_DOWN()
    stopHoldFlag = 0
    if CurrentMode.keypad.onStopKeyDown then return CurrentMode.keypad.onStopKeyDown() end
  end

  function awtx.keypad.KEY_STOP_REPEAT()
    stopHoldFlag = stopHoldFlag + 1
    if stopHoldFlag == HowManyRepeatsMakeAHold then
      if CurrentMode.keypad.onStopKeyHold then return CurrentMode.keypad.onStopKeyHold() end
    end
  end

  function awtx.keypad.KEY_STOP_UP()
    if stopHoldFlag < HowManyRepeatsMakeAHold then
      if CurrentMode.keypad.onStopKeyUp then return CurrentMode.keypad.onStopKeyUp() end
    end
    stopHoldFlag = 0
  end


  -----------------------------------------------------------------------------------------------
  -- F1 Key Event Handlers
  -----------------------------------------------------------------------------------------------
  function awtx.keypad.KEY_F1_DOWN()
    f1HoldFlag = 0
    if CurrentMode.keypad.onF1KeyDown then return CurrentMode.keypad.onF1KeyDown() end
  end

  function awtx.keypad.KEY_F1_REPEAT()
    f1HoldFlag = f1HoldFlag + 1
    if f1HoldFlag == HowManyRepeatsMakeAHold then
      if CurrentMode.keypad.onF1KeyHold then return CurrentMode.keypad.onF1KeyHold() end
    end
  end

  function awtx.keypad.KEY_F1_UP()
    if f1HoldFlag < HowManyRepeatsMakeAHold then
      if CurrentMode.keypad.onF1KeyUp then return CurrentMode.keypad.onF1KeyUp() end
    end
    f1HoldFlag = 0
  end


  -----------------------------------------------------------------------------------------------
  -- Scale Select Key Event Handlers
  -----------------------------------------------------------------------------------------------
  function awtx.keypad.KEY_SCALE_SELECT_DOWN()
    scaleSelectHoldFlag = 0
    if CurrentMode.keypad.onScaleSelectKeyDown then return CurrentMode.keypad.onScaleSelectKeyDown() end
  end

  function awtx.keypad.KEY_SCALE_SELECT_REPEAT()
    scaleSelectHoldFlag = scaleSelectHoldFlag + 1
    if scaleSelectHoldFlag == HowManyRepeatsMakeAHold then
      if CurrentMode.keypad.onScaleSelectKeyHold then return CurrentMode.keypad.onScaleSelectKeyHold() end
    end
  end

  function awtx.keypad.KEY_SCALE_SELECT_UP()
    if scaleSelectHoldFlag < HowManyRepeatsMakeAHold then
      if CurrentMode.keypad.onScaleSelectKeyUp then return CurrentMode.keypad.onScaleSelectKeyUp() end
    end
    scaleSelectHoldFlag = 0
  end


  -----------------------------------------------------------------------------------------------
  -- Setup Key Event Handlers
  -----------------------------------------------------------------------------------------------
  function awtx.keypad.KEY_SETUP_DOWN()
    setupHoldFlag = 0
    if CurrentMode.keypad.onSetupKeyDown then return CurrentMode.keypad.onSetupKeyDown() end
  end

  function awtx.keypad.KEY_SETUP_REPEAT()
    setupHoldFlag = setupHoldFlag + 1
    if setupHoldFlag == HowManyRepeatsMakeAHold then
      if CurrentMode.keypad.onSetupKeyHold then return CurrentMode.keypad.onSetupKeyHold() end
    end
  end

  function awtx.keypad.KEY_SETUP_UP()
    if setupHoldFlag < HowManyRepeatsMakeAHold then
      if CurrentMode.keypad.onSetupKeyUp then return CurrentMode.keypad.onSetupKeyUp() end
    end
    setupHoldFlag = 0
  end


  -----------------------------------------------------------------------------------------------
  -- Target Key Event Handlers
  -----------------------------------------------------------------------------------------------
  function awtx.keypad.KEY_TARGET_DOWN()
    targetHoldFlag = 0
    if CurrentMode.keypad.onTargetKeyDown then return CurrentMode.keypad.onTargetKeyDown() end
  end

  function awtx.keypad.KEY_TARGET_REPEAT()
    targetHoldFlag = targetHoldFlag + 1
    if targetHoldFlag == HowManyRepeatsMakeAHold then
      if CurrentMode.keypad.onTargetKeyHold then return CurrentMode.keypad.onTargetKeyHold() end
    end
  end

  function awtx.keypad.KEY_TARGET_UP()
    if targetHoldFlag < HowManyRepeatsMakeAHold then
      if CurrentMode.keypad.onTargetKeyUp then return CurrentMode.keypad.onTargetKeyUp() end
    end
    targetHoldFlag = 0
  end


  -----------------------------------------------------------------------------------------------
  -- Numeric Key Event Handlers
  -----------------------------------------------------------------------------------------------
  function awtx.keypad.KEY_NUMERIC_DOWN(numChar)
    numericHoldFlag = 0
    -- keypad.onNumericKeyDown(numChar)
  end

  function awtx.keypad.KEY_NUMERIC_REPEAT(numChar)
    numericHoldFlag = numericHoldFlag + 1
    if numericHoldFlag == HowManyRepeatsMakeAHold then
      -- keypad.onNumericKeyHold(numChar)
    end
  end

  function awtx.keypad.KEY_NUMERIC_UP(numChar)
    if numericHoldFlag < HowManyRepeatsMakeAHold then
      -- keypad.onNumericKeyUp(numChar)
    end
    numericHoldFlag = 0
  end


  -----------------------------------------------------------------------------------------------
  -- Clear Key Event Handlers
  -----------------------------------------------------------------------------------------------
  function awtx.keypad.KEY_CLEAR_DOWN()
    clearHoldFlag = 0
    if CurrentMode.keypad.onClearKeyDown then return CurrentMode.keypad.onClearKeyDown() end
  end

  function awtx.keypad.KEY_CLEAR_REPEAT()
    clearHoldFlag = clearHoldFlag + 1
    if clearHoldFlag == HowManyRepeatsMakeAHold then
      if CurrentMode.keypad.onClearKeyHold then return CurrentMode.keypad.onClearKeyHold() end
    end
  end

  function awtx.keypad.KEY_CLEAR_UP()
    if clearHoldFlag < HowManyRepeatsMakeAHold then
      if CurrentMode.keypad.onClearKeyUp then return CurrentMode.keypad.onClearKeyUp() end
    end
    clearHoldFlag = 0
  end


  -----------------------------------------------------------------------------------------------
  -- Decimal Key Event Handlers
  -----------------------------------------------------------------------------------------------
  function awtx.keypad.KEY_DECIMAL_DOWN()
    decimalHoldFlag = 0
    if CurrentMode.keypad.onDecimalKeyDown then return CurrentMode.keypad.onDecimalKeyDown() end
  end

  function awtx.keypad.KEY_DECIMAL_REPEAT()
    decimalHoldFlag = decimalHoldFlag + 1
    if decimalHoldFlag == HowManyRepeatsMakeAHold then
      if CurrentMode.keypad.onDecimalKeyHold then return CurrentMode.keypad.onDecimalKeyHold() end
    end
  end

  function awtx.keypad.KEY_DECIMAL_UP()
    if decimalHoldFlag < HowManyRepeatsMakeAHold then
      if CurrentMode.keypad.onDecimalKeyUp then return CurrentMode.keypad.onDecimalKeyUp() end
    end
    decimalHoldFlag = 0
  end

end

brmScaleKeys.onStart()
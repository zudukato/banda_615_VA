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
  if CurrentMode.keypad.onXXXKeyDown then CurrentMode.keypad.onXXXKeyDown() end
  if CurrentMode.keypad.onXXXKeyHold then CurrentMode.keypad.onXXXKeyHold() end
  if CurrentMode.keypad.onXXXKeyUp then CurrentMode.keypad.onXXXKeyUp() end
  
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


---------------------------------- Tare Key Default Functions ----------------------------------
---------------------------------------------------------------------------------------------
function awtx.keypad.KEY_TARE_DOWN()
  tareHoldFlag = 0
  if CurrentMode.keypad.onTareKeyDown then CurrentMode.keypad.onTareKeyDown() end
end

function awtx.keypad.KEY_TARE_REPEAT()
  tareHoldFlag = tareHoldFlag + 1
  if tareHoldFlag == HowManyRepeatsMakeAHold then
    if CurrentMode.keypad.onTareKeyHold then CurrentMode.keypad.onTareKeyHold() end
  end
end

function awtx.keypad.KEY_TARE_UP()
  if tareHoldFlag < HowManyRepeatsMakeAHold then
    if CurrentMode.keypad.onTareKeyUp then CurrentMode.keypad.onTareKeyUp() end
  end
  tareHoldFlag = 0
end


-----------------------------------------------------------------------------------------------
-- Select Key Event Handlers
-----------------------------------------------------------------------------------------------
function awtx.keypad.KEY_SELECT_DOWN()
  selectHoldFlag = 0
  if CurrentMode.keypad.onSelectKeyDown then CurrentMode.keypad.onSelectKeyDown() end
 end

function awtx.keypad.KEY_SELECT_REPEAT()
  selectHoldFlag = selectHoldFlag + 1
  if selectHoldFlag == HowManyRepeatsMakeAHold then
    if CurrentMode.keypad.onSelectKeyHold then CurrentMode.keypad.onSelectKeyHold() end
  end
end

function awtx.keypad.KEY_SELECT_UP()
  if selectHoldFlag < HowManyRepeatsMakeAHold then
    if CurrentMode.keypad.onSelectKeyUp then CurrentMode.keypad.onSelectKeyUp() end
  end
  selectHoldFlag = 0
end


-----------------------------------------------------------------------------------------------
-- Print Key Event Handlers
-----------------------------------------------------------------------------------------------
function awtx.keypad.KEY_PRINT_DOWN()
  printHoldFlag = 0
  if CurrentMode.keypad.onPrintKeyDown then CurrentMode.keypad.onPrintKeyDown() end
end

function awtx.keypad.KEY_PRINT_REPEAT()
  printHoldFlag = printHoldFlag + 1
  if printHoldFlag == HowManyRepeatsMakeAHold then
    if CurrentMode.keypad.onPrintKeyHold then CurrentMode.keypad.onPrintKeyHold() end
  end
end

function awtx.keypad.KEY_PRINT_UP()
  if printHoldFlag < HowManyRepeatsMakeAHold then
    if CurrentMode.keypad.onPrintKeyUp then CurrentMode.keypad.onPrintKeyUp() end
  end
  printHoldFlag = 0
end


-----------------------------------------------------------------------------------------------
-- Units Key Event Handlers
-----------------------------------------------------------------------------------------------
function awtx.keypad.KEY_UNITS_DOWN()
  unitsHoldFlag = 0
  if CurrentMode.keypad.onUnitsKeyDown then CurrentMode.keypad.onUnitsKeyDown() end
end

function awtx.keypad.KEY_UNITS_REPEAT()
  unitsHoldFlag = unitsHoldFlag + 1
  if unitsHoldFlag == HowManyRepeatsMakeAHold then
    if CurrentMode.keypad.onUnitsKeyHold then CurrentMode.keypad.onUnitsKeyHold() end
  end
end

function awtx.keypad.KEY_UNITS_UP()
  if unitsHoldFlag < HowManyRepeatsMakeAHold then
    if CurrentMode.keypad.onUnitsKeyUp then CurrentMode.keypad.onUnitsKeyUp() end
  end
  unitsHoldFlag = 0
end


-----------------------------------------------------------------------------------------------
-- Zero Key Event Handlers
-----------------------------------------------------------------------------------------------
function awtx.keypad.KEY_ZERO_DOWN()
  zeroHoldFlag = 0
  if CurrentMode.keypad.onZeroKeyDown then CurrentMode.keypad.onZeroKeyDown() end
end

function awtx.keypad.KEY_ZERO_REPEAT()
  zeroHoldFlag = zeroHoldFlag + 1
  if zeroHoldFlag == HowManyRepeatsMakeAHold then
    if CurrentMode.keypad.onZeroKeyHold then CurrentMode.keypad.onZeroKeyHold() end
  end
end

function awtx.keypad.KEY_ZERO_UP()
  if zeroHoldFlag < HowManyRepeatsMakeAHold then
    if CurrentMode.keypad.onZeroKeyUp then CurrentMode.keypad.onZeroKeyUp() end
  end
  zeroHoldFlag = 0
end


-----------------------------------------------------------------------------------------------
-- Sample Key Event Handlers
-----------------------------------------------------------------------------------------------
function awtx.keypad.KEY_SAMPLE_DOWN()
  sampleHoldFlag = 0
  if CurrentMode.keypad.onSampleKeyDown then CurrentMode.keypad.onSampleKeyDown() end
end

function awtx.keypad.KEY_SAMPLE_REPEAT()
  sampleHoldFlag = sampleHoldFlag + 1
  if sampleHoldFlag == HowManyRepeatsMakeAHold then
    if CurrentMode.keypad.onSampleKeyHold then CurrentMode.keypad.onSampleKeyHold() end
  end
end

function awtx.keypad.KEY_SAMPLE_UP()
  if sampleHoldFlag < HowManyRepeatsMakeAHold then
    if CurrentMode.keypad.onSampleKeyUp then CurrentMode.keypad.onSampleKeyUp() end
  end
  sampleHoldFlag = 0
end


-----------------------------------------------------------------------------------------------
-- Start Key Event Handlers
-----------------------------------------------------------------------------------------------
function awtx.keypad.KEY_START_DOWN()
  startHoldFlag = 0
  if CurrentMode.keypad.onStartKeyDown then CurrentMode.keypad.onStartKeyDown() end
end

function awtx.keypad.KEY_START_REPEAT()
  startHoldFlag = startHoldFlag + 1
  if startHoldFlag == HowManyRepeatsMakeAHold then
    if CurrentMode.keypad.onStartKeyHold then CurrentMode.keypad.onStartKeyHold() end
  end
end

function awtx.keypad.KEY_START_UP()
  if startHoldFlag < HowManyRepeatsMakeAHold then
    if CurrentMode.keypad.onStartKeyUp then CurrentMode.keypad.onStartKeyUp() end
  end
  startHoldFlag = 0
end


-----------------------------------------------------------------------------------------------
-- Stop Key Event Handlers
-----------------------------------------------------------------------------------------------
function awtx.keypad.KEY_STOP_DOWN()
  stopHoldFlag = 0
  if CurrentMode.keypad.onStopKeyDown then CurrentMode.keypad.onStopKeyDown() end
end

function awtx.keypad.KEY_STOP_REPEAT()
  stopHoldFlag = stopHoldFlag + 1
  if stopHoldFlag == HowManyRepeatsMakeAHold then
    if CurrentMode.keypad.onStopKeyHold then CurrentMode.keypad.onStopKeyHold() end
  end
end

function awtx.keypad.KEY_STOP_UP()
  if stopHoldFlag < HowManyRepeatsMakeAHold then
    if CurrentMode.keypad.onStopKeyUp then CurrentMode.keypad.onStopKeyUp() end
  end
  stopHoldFlag = 0
end


-----------------------------------------------------------------------------------------------
-- F1 Key Event Handlers
-----------------------------------------------------------------------------------------------
function awtx.keypad.KEY_F1_DOWN()
  f1HoldFlag = 0
  if CurrentMode.keypad.onF1KeyDown then CurrentMode.keypad.onF1KeyDown() end
end

function awtx.keypad.KEY_F1_REPEAT()
  f1HoldFlag = f1HoldFlag + 1
  if f1HoldFlag == HowManyRepeatsMakeAHold then
    if CurrentMode.keypad.onF1KeyHold then CurrentMode.keypad.onF1KeyHold() end
  end
end

function awtx.keypad.KEY_F1_UP()
  if f1HoldFlag < HowManyRepeatsMakeAHold then
    if CurrentMode.keypad.onF1KeyUp then CurrentMode.keypad.onF1KeyUp() end
  end
  f1HoldFlag = 0
end


-----------------------------------------------------------------------------------------------
-- Scale Select Key Event Handlers
-----------------------------------------------------------------------------------------------
function awtx.keypad.KEY_SCALE_SELECT_DOWN()
  scaleSelectHoldFlag = 0
   if CurrentMode.keypad.onScaleSelectKeyDown then CurrentMode.keypad.onScaleSelectKeyDown() end
end

function awtx.keypad.KEY_SCALE_SELECT_REPEAT()
  scaleSelectHoldFlag = scaleSelectHoldFlag + 1
  if scaleSelectHoldFlag == HowManyRepeatsMakeAHold then
    if CurrentMode.keypad.onScaleSelectKeyHold then CurrentMode.keypad.onScaleSelectKeyHold() end
  end
end

function awtx.keypad.KEY_SCALE_SELECT_UP()
  if scaleSelectHoldFlag < HowManyRepeatsMakeAHold then
    if CurrentMode.keypad.onScaleSelectKeyUp then CurrentMode.keypad.onScaleSelectKeyUp() end
  end
  scaleSelectHoldFlag = 0
end


-----------------------------------------------------------------------------------------------
-- Setup Key Event Handlers
-----------------------------------------------------------------------------------------------
function awtx.keypad.KEY_SETUP_DOWN()
  setupHoldFlag = 0
  if CurrentMode.keypad.onSetupKeyDown then CurrentMode.keypad.onSetupKeyDown() end
end

function awtx.keypad.KEY_SETUP_REPEAT()
  setupHoldFlag = setupHoldFlag + 1
  if setupHoldFlag == HowManyRepeatsMakeAHold then
    if CurrentMode.keypad.onSetupKeyHold then CurrentMode.keypad.onSetupKeyHold() end
  end
end

function awtx.keypad.KEY_SETUP_UP()
  if setupHoldFlag < HowManyRepeatsMakeAHold then
    if CurrentMode.keypad.onSetupKeyUp then CurrentMode.keypad.onSetupKeyUp() end
  end
  setupHoldFlag = 0
end


-----------------------------------------------------------------------------------------------
-- Target Key Event Handlers
-----------------------------------------------------------------------------------------------
function awtx.keypad.KEY_TARGET_DOWN()
  targetHoldFlag = 0
  if CurrentMode.keypad.onTargetKeyDown then CurrentMode.keypad.onTargetKeyDown() end
end

function awtx.keypad.KEY_TARGET_REPEAT()
  targetHoldFlag = targetHoldFlag + 1
  if targetHoldFlag == HowManyRepeatsMakeAHold then
    if CurrentMode.keypad.onTargetKeyHold then CurrentMode.keypad.onTargetKeyHold() end
  end
end

function awtx.keypad.KEY_TARGET_UP()
  if targetHoldFlag < HowManyRepeatsMakeAHold then
    if CurrentMode.keypad.onTargetKeyUp then CurrentMode.keypad.onTargetKeyUp() end
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
  if CurrentMode.keypad.onClearKeyDown then CurrentMode.keypad.onClearKeyDown() end
end

function awtx.keypad.KEY_CLEAR_REPEAT()
  clearHoldFlag = clearHoldFlag + 1
  if clearHoldFlag == HowManyRepeatsMakeAHold then
    if CurrentMode.keypad.onClearKeyHold then CurrentMode.keypad.onClearKeyHold() end
  end
end

function awtx.keypad.KEY_CLEAR_UP()
  if clearHoldFlag < HowManyRepeatsMakeAHold then
    if CurrentMode.keypad.onClearKeyUp then CurrentMode.keypad.onClearKeyUp() end
  end
  clearHoldFlag = 0
end


-----------------------------------------------------------------------------------------------
-- Decimal Key Event Handlers
-----------------------------------------------------------------------------------------------
function awtx.keypad.KEY_DECIMAL_DOWN()
  decimalHoldFlag = 0
  if CurrentMode.keypad.onDecimalKeyDown then CurrentMode.keypad.onDecimalKeyDown() end
end

function awtx.keypad.KEY_DECIMAL_REPEAT()
  decimalHoldFlag = decimalHoldFlag + 1
  if decimalHoldFlag == HowManyRepeatsMakeAHold then
    if CurrentMode.keypad.onDecimalKeyHold then CurrentMode.keypad.onDecimalKeyHold() end
  end
end

function awtx.keypad.KEY_DECIMAL_UP()
  if decimalHoldFlag < HowManyRepeatsMakeAHold then
    if CurrentMode.keypad.onDecimalKeyUp then CurrentMode.keypad.onDecimalKeyUp() end
  end
  decimalHoldFlag = 0
end
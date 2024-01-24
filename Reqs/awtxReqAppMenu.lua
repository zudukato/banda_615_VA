--[[
*******************************************************************************

Filename:      awtxReqAppMenu.lua
Version:       1.2.0.0
Date:          2019-05-28

Description:
This file provides menu functionality for the ZM405 indicator.  With this file
included, other require files may add additional sections to the super menu or
create their own.

*******************************************************************************
History:
1.0.0.0 = Initial Release
1.1.0.0 = Added ADMIN Access Code and Pass Reset functions
1.2.0.0 = Added Print Version details function by Access Code "0000"

*******************************************************************************

Global Data:
  supervisor

*******************************************************************************
]]

require("awtxReqConstants")

PASSWORD = {}
PASSWORD.BAS      = "762"   -- Basculas Revuelta ADMIN Access code 
PASSWORD.SUPER    = "1793"  -- General access code (custom)
PASSWORD.INFO     = "0000"  -- Print version details
PASSWORD.APPVIEW  = "0"     -- Shows app info

-- PASSWORD = awtxReq.variables.SavedVariable('PASSWORD', PASSWORD, true)
PASSWORD.value = PASSWORD

local system = awtx.hardware.getSystem(1)

supervisor = {} --Global Table
supervisor.AvailableMenus = {}  -- This table is filled with available menu passwords
                                --   and entry functions for each specific menu.

supervisor.flag         = false
supervisor.menuing      = false
supervisor.menuCurrent  = 1
supervisor.menuLevel    = topMenuDefault
supervisor.menuCircular = resolveCircular1Default


  --[[
Description:
  This Function is called to initialize things for this Require file 
Parameters:
  None
  
Returns:
  None
]]--
local function create()
  awtx.os.registerPasswordEnteredEvent(supervisor.onPasswordEntered)
end


-- Function stub to be overridden by current application if any actions need to be
--  performed before entering the menus.
function appEnterSuperMenu()
end


-- Function stub to be overridden by current application if any actions need to be
--  performed after exiting the menus.
function appExitSuperMenu()
end

function appViewEntry()
end

-- decide whether menu level should be shown or not
function supervisor.menuVisible(menuItem)
  local retVal = false
  local found = false
  local variable, Compare, val
  if menuItem.show == nil then
    retVal = true
  elseif type(menuItem.show) == "boolean" and menuItem.show == true then
    retVal = true
  elseif type(menuItem.show) == "string" then
    retVal = true
  elseif type(menuItem.show) == "table" then
    Compare = menuItem.show

    if Compare.callThis == nil or Compare.val1 == nil then
      retVal = true
    elseif type(Compare.callThis) == "function" then
      val = tonumber(Compare.callThis())
      if val == Compare.val1 then
        retVal = true
      else
        retVal = false
      end
    end
  else
    retVal = false
  end
  return retVal
end


-- handle the menu when its action type is function
function supervisor.handleMenuActionFunction(menuItem)
  if type(menuItem.callThis) == "function" then
    if menuItem.text == nil then
      menuItem.callThis()
    else
      menuItem.callThis(menuItem.text)
    end
  end
end


-- show available menus on the display
function supervisor.showMenus()
  local menuStr = ""
  local menuSelection
  local menuActive = 1 -- this is the current menu(visible) the list of menus is longer
  local menuKey={}
  local a, b, i
  local numItems = 0
  -- format a string representing this menu struct
  for i = 1, #supervisor.menuLevel do
    if supervisor.menuVisible(supervisor.menuLevel[i]) then
      menuStr = menuStr .. string.format("%s}", supervisor.menuLevel[i].text)
      table.insert(menuKey, supervisor.menuLevel[i].key)
      if supervisor.menuLevel[i].key == supervisor.menuCurrent then
        menuActive = #menuKey
      end
      numItems = numItems + 1
    end
  end
  --display via "C" driver
  if numItems == 1 then   -- the one is the back menu!!
    -- no items to display so empty menu
    a = menuKey [1]
    b = nil
  else
    menuSelection = awtx.setupMenu.selectMenu(menuStr, menuActive)
    a = menuKey [tonumber(menuSelection)]
    b = nil
  end
  collectgarbage()
  return a, b
end


function doMenuLoop()
  local aKey
  local bKey
  local j
  local menuIndex
  local myTable
  
  awtx.keypad.disableLuaKeyboardEvents()

  while supervisor.menuing == true do
    -- Show menus
    aKey, bKey = supervisor.showMenus()
    if bKey == nil then
      -- Find the menu the user selected
      menuIndex = -1
      for j=1, #supervisor.menuLevel do
        if supervisor.menuLevel[j].key == aKey then
          menuIndex = j
          break
        end
      end
    else
      menuIndex = -1
    end
    if(menuIndex == -1) then
    else
      supervisor.menuCurrent = supervisor.menuLevel[menuIndex].key
      if supervisor.menuLevel[menuIndex].action == nil then
        -- Nothing to do
      elseif supervisor.menuLevel[menuIndex].action == "MENU" then
        -- Ok the action is menu so select menu and if defined submenu
        if type(supervisor.menuLevel[menuIndex].variable) == "string" then
          myTable = supervisor.menuCircular[supervisor.menuLevel[menuIndex].variable]
          if supervisor.menuLevel[menuIndex].subMenu ~= nil then
            supervisor.menuCurrent = supervisor.menuLevel[menuIndex].subMenu
          else
            supervisor.menuCurrent = 1
          end
          supervisor.menuLevel = myTable
        end
      elseif supervisor.menuLevel[menuIndex].action == "FUNC" then
        supervisor.handleMenuActionFunction(supervisor.menuLevel[menuIndex])
      else
      end
    end
  end
  -- avoid double tap of tare key
  awtx.os.sleep (500)
  awtx.keypad.clearKeyBuffer()
  awtx.keypad.enableLuaKeyboardEvents()
end


-- Event handler to occur after the firmware has tested the entered password against
--  all internal menu passwords
function supervisor.onPasswordEntered(passwordString)
  local validPass = false
  supervisor.flag = false
  for entry in pairs (supervisor.AvailableMenus) do
    if passwordString == supervisor.AvailableMenus[entry].entryPassword and supervisor.flag == false then
      validPass = true
      supervisor.AvailableMenus[entry].entryFunction()
    end
  end

  if validPass == false then
    -- Invalid Password
    awtx.display.writeLine("Invalid", 1000)
  end

  awtx.keypad.clearKeyBuffer()
end


-- exit from menu system
function supervisor.SupervisorMenuExit(param)
  -- kill the menu system
  supervisor.menuing = false
  -- run this when exiting the Menu
  appExitSuperMenu()
end


-----------------------------------------------------------------------------------
--  Default Menus
-----------------------------------------------------------------------------------

-- Default Supervisor Menu if specific app doesn't declare it's own.
-- Top level Menu
T1Default = {text = "Super",   key = 1, action = "FUNC", callThis = nil}
T2Default = {text = "EXIT",    key = 2, action = "FUNC", callThis = supervisor.SupervisorMenuExit}
topMenuDefault = {T1Default, T2Default}

resolveCircular1Default =
{
  topMenuDefault = topMenuDefault
}


-----------------------------------------------------------------------------------

function supervisor.PasswordReset()
  local isEnterKey
  local tmpPass
  local choice
  local currentPass = PASSWORD.SUPER
  
  if system.modelStr == "ZM401" or system.modelStr == "ZM405" then
    choice, isEnterKey = awtx.keypad.selectList("NO, YES", 0, -1, "Reset", "Pass?")
  else
    choice, isEnterKey = awtx.keypad.selectList("NO,YES", 1, -1, "Cambiar codigo?")
  end
  
  if not isEnterKey then
    awtx.display.writeLine("Cancel", 500)
    
  elseif choice == 1 then
    if system.modelStr == "ZM401" or system.modelStr == "ZM405" then
      choice, isEnterKey = awtx.keypad.enterInteger(0,0,999999,5000,"Enter", "Pass:")
    else
      choice, isEnterKey = awtx.keypad.enterInteger(0,0,999999,5000,"Ingresar codigo anterior:")
    end
    
    choice = tostring(choice)
    
    if not isEnterKey then
      awtx.display.writeLine("Cancel", 500)
    else
      -- Se debe ingresar contraseña anterior O contraseña de Básculas Revuelta.
      -- Ésta última se usará en caso de que se desconozca la contraseña anterior.
      if choice == currentPass or choice == PASSWORD.BAS and choice ~= PASSWORD.INFO then
        if system.modelStr == "ZM401" or system.modelStr == "ZM405" then
          tmpPass, isEnterKey = awtx.keypad.enterInteger(0,0,999999,-1,"Nuevo", "Pass:")
        else
          tmpPass, isEnterKey = awtx.keypad.enterInteger(0,0,999999,-1,"Ingresar nuevo codigo:")
        end
        
        tmpPass = tostring(tmpPass)
        
        if not isEnterKey then
          awtx.display.writeLine("Cancel", 500)
        elseif isEnterKey then
          if system.modelStr == "ZM401" or system.modelStr == "ZM405" then
            awtx.display.writeLine("Confirm", 1000)
            choice, isEnterKey = awtx.keypad.enterInteger(0,0,999999,-1,"Nuevo", "Pass:")
          else
            choice, isEnterKey = awtx.keypad.enterInteger(0,0,999999,-1,"Confirmar nuevo codigo:")
          end
          
          choice = tostring(choice)
          
          if not isEnterKey then
            awtx.display.writeLine("Cancel", 500)
          else
            if choice == tmpPass then
              PASSWORD.SUPER = tmpPass
              supervisor.AvailableMenus["Super"] = {
                entryPassword = PASSWORD.SUPER,
                entryFunction = supervisor.SupervisorMenuEntry}

              awtx.display.writeLine("DONE", 500)
            else
              if system.modelStr == "ZM401" or system.modelStr == "ZM405" then
                awtx.display.writeLine("INVALID", 500)
                awtx.display.writeLine("PASS", 500)
              else
                awtx.display.writeLine("CODIGO", 500)
                awtx.display.writeLine("NO VALIDO", 500)
                awtx.display.writeLine("INTENTE DE NUEVO", 1000)
              end
            end
          end
        end
      else
        
        
        if system.modelStr == "ZM401" or system.modelStr == "ZM405" then
          awtx.display.writeLine("INVALID", 500)
          awtx.display.writeLine("PASS", 500)
        else
          awtx.display.writeLine("CODIGO", 500)
          awtx.display.writeLine("NO VALIDO", 500)
          awtx.display.writeLine("INTENTE DE NUEVO", 1000)
        end
      end
    end
  end
end

-----------------------------------------------------------------------------------

function supervisor.SupervisorMenuEntry()
  local usermode
  -- do this before entering Menu
  appEnterSuperMenu()
  supervisor.menuing = true
  supervisor.menuCurrent = 1
  doMenuLoop()
end
supervisor.AvailableMenus["Super"] = {entryPassword = PASSWORD.SUPER,
                                      entryFunction = supervisor.SupervisorMenuEntry}


function supervisor.SoporteTecnicoEntry()
  if system.modelStr == "ZM401" or system.modelStr == "ZM405" then
    awtx.display.writeLine("SOPORTE", 1000)
  else
    awtx.display.writeLine("Soporte Tecnico", 1000)
  end
  
  appEnterSuperMenu()
  supervisor.menuing = true
  supervisor.menuCurrent = 1
  doMenuLoop()
  supervisor.flag = true
end
supervisor.AvailableMenus["Soporte Tecnico"] = {entryPassword = PASSWORD.BAS,
                                                entryFunction = supervisor.SoporteTecnicoEntry}

function supervisor.PrintInfo()
  local versionString = ""
  local vti = awtx.os.getVersionInfo("*all")
  local fw = vti[10]
  local ap = vti[13]
  local vt = awtx.hardware.getSystem(1)
  local gc = awtx.weight.getConfig(1)
  local dt = os.date("*t")
  local fmtDt = string.format("%02d-%02d-%02d", dt.year, dt.month, dt.day)
  local fmtTm = string.format("%02d:%02d", dt.hour, dt.min)
  local ip = awtx.os.getIpAddress()
  
  if savedModelPrinter.value == 0 then
    endFmt = "\r\n\f"
  else
    endFmt = "\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n←m"
  end 
  
  versionString = string.format(
    "Modelo RAD:   \t%s\r\n" ..
    "Nombre de App:\t%s\r\n" ..
    "Vers. de App: \t%s\r\n" ..
    "Firmware:     \t%s\r\n" ..
    "Cap. Max x d: \t%d x %g\r\n" .. 
    "Unidades:     \t%s\r\n" ..
    "Direccion IP: \t%s\r\n" ..
    "Fecha:        \t%s\r\n" ..
    "Hora:         \t%s\r\n\f",
    vt.modelStr, AppName,ap.version, fw.version,gc.capacity,gc.division,gc.calwtunitStr, ip, fmtDt, fmtTm,endFmt)
  
  local tmpFmt = awtx.fmtPrint.get(1)
  awtx.fmtPrint.set(1, versionString)
  awtx.printer.printFmt(1)
  awtx.fmtPrint.set(1, tmpFmt)
end
supervisor.AvailableMenus["PrintInfo"] = {entryPassword = PASSWORD.INFO,
                                          entryFunction = supervisor.PrintInfo}

function resetPrintFmt(tmpFmt)
end

function supervisor.AppViewMenuEntry()
  -- do this before entering Menu
  if AppName ~= nil then
    appViewEntry()
  end
end

supervisor.AvailableMenus["AppView"] = {entryPassword = PASSWORD.APPVIEW,
                                        entryFunction = supervisor.AppViewMenuEntry}


create()
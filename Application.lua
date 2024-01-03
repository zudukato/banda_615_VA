--[[
*******************************************************************************

Filename:      Application.lua
Version:       1.0.3.0
Firmware:      2.5.0.0 or higher

Date:          2023-12-21
Customer:      Bascu
Description:
This application provides basic general weighing functionality.
Includes 50 Tare registers (Preset Tare must be enabled)
ID Entry - choice in Super menu for Numeric or Alphanumeric ID - 7 digits
*******************************************************************************
]]
--create the awtxReq namespace
BrmReqSql = require("brmReqSql")

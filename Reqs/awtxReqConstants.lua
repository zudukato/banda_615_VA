--[[
*******************************************************************************

Filename:     awtxReqConstants.lua
Version:      1.0.1.0
Date:         2017-02-01
Customer:     Avery Weigh-Tronix
Description:
This file provides some constant number definitions.

*******************************************************************************
History:
1.0.0.0 - Initial Release
1.0.1.0 - Removed Invalid Fonts
*******************************************************************************
]]


--
-- DISPLAY
--
local awtxConstants  = {
    display = {},
    graphics = {},
    keypad = {},
    fmtPrint = {},
    printer = {},
    weight = {}
}
awtxConstants.display.MODE_SCALE = 0
awtxConstants.display.MODE_USER  = 1
awtxConstants.display.MODE_MENU  = 2


--
-- DISPLAY
--
awtxConstants.graphics.FONT_SYSTEM              = 0  --  23 pixels tall 10 pixels wide
awtxConstants.graphics.FONT_LUCIDA_CON_8        = 3  --   8 pixels tall
awtxConstants.graphics.FONT_LUCIDA_CON_10       = 4  --  10 pixels tall
awtxConstants.graphics.FONT_LUCIDA_CON_12       = 5  --  12 pixels tall
awtxConstants.graphics.FONT_LUCIDA_CON_16       = 6  --  16 pixels tall
awtxConstants.graphics.FONT_LUCIDA_CON_20       = 7  --  20 pixels tall
awtxConstants.graphics.FONT_LUCIDA_CON_40       = 8  --  40 pixels tall
awtxConstants.graphics.FONT_SMALL_ICONS         = 9  --  16 pixels tall
awtxConstants.graphics.FONT_DIS_TEXT            = 10 --  10 pixels tall
awtxConstants.graphics.FONT_ICONS               = 11 --  Old Evo Font
awtxConstants.graphics.FONT_TAHOMA_15           = 13 --  15 pixels tall
awtxConstants.graphics.FONT_VERDANA_15          = 14 --  15 pixels tall
awtxConstants.graphics.FONT_TAHOMA_22           = 19 --  22 pixels tall
awtxConstants.graphics.FONT_VERDANA_22          = 20 --  22 pixels tall
awtxConstants.graphics.FONT_ARIAL_80            = 25 --  80 pixels tall
awtxConstants.graphics.FONT_COOPER_11           = 26 --  11 pixels tall
awtxConstants.graphics.FONT_ARIAL_56            = 28 --  56 pixels tall
awtxConstants.graphics.FONT_ARIAL_31            = 29 --  35 pixels tall
awtxConstants.graphics.FONT_ARIAL_25            = 30 --  25 pixels tall
awtxConstants.graphics.FONT_ARIAL_16            = 31 --  16 pixels tall
awtxConstants.graphics.FONT_WTBASIC_1           = 32 --  ?? pixels tall
awtxConstants.graphics.FONT_WTBASIC_2           = 33 --  ?? pixels tall
awtxConstants.graphics.FONT_WTBASIC_3           = 34 --  ?? pixels tall
awtxConstants.graphics.FONT_WTBASIC_4           = 35 --  ?? pixels tall
awtxConstants.graphics.FONT_WTBASIC_5           = 36 --  ?? pixels tall
awtxConstants.graphics.FONT_ARIAL_BOLD_12       = 37 --  12 pixels tall
awtxConstants.graphics.FONT_ARIAL_BOLD_16       = 38 --  16 pixels tall
awtxConstants.graphics.FONT_COURIER_NEW_BOLD_12 = 42 --  12 pixels tall
awtxConstants.graphics.FONT_COURIER_NEW_BOLD_16 = 43 --  16 pixels tall
awtxConstants.graphics.FONT_LARGE_WT_120        = 47 -- 120 pixels tall
awtxConstants.graphics.FONT_LARGE_WT_160        = 48 -- 160 pixels tall

--
-- KEYPAD
--
awtxConstants.keypad.RPN_MODE_DISABLED          = 0
awtxConstants.keypad.RPN_MODE_ENABLED           = 1


--
-- TOKEN TYPES
--
awtxConstants.fmtPrint.TYPE_UNDEFINED          = 0
awtxConstants.fmtPrint.TYPE_WEIGHT             = 1
awtxConstants.fmtPrint.TYPE_STRING             = 2
awtxConstants.fmtPrint.TYPE_DATE               = 3
awtxConstants.fmtPrint.TYPE_TIME               = 4
awtxConstants.fmtPrint.TYPE_FLOAT              = 5
awtxConstants.fmtPrint.TYPE_INTEGER            = 6
awtxConstants.fmtPrint.TYPE_BOOLEAN            = 7
awtxConstants.fmtPrint.TYPE_WEIGHT_VAR         = 8
awtxConstants.fmtPrint.TYPE_STRING_VAR         = 9
awtxConstants.fmtPrint.TYPE_DATE_VAR           = 10
awtxConstants.fmtPrint.TYPE_TIME_VAR           = 11
awtxConstants.fmtPrint.TYPE_FLOAT_VAR          = 12
awtxConstants.fmtPrint.TYPE_INTEGER_VAR        = 13
awtxConstants.fmtPrint.TYPE_BOOLEAN_VAR        = 14

--
-- PRINTER STATUS
--
awtxConstants.printer.STATUS_OFFLINE           = 1
awtxConstants.printer.STATUS_ONLINE            = 2
awtxConstants.printer.STATUS_OK                = 3
awtxConstants.printer.STATUS_NOT_OK            = 4
awtxConstants.printer.STATUS_PAPER_LOW         = 5
awtxConstants.printer.STATUS_NOT_PAPER_LOW     = 6
awtxConstants.printer.STATUS_SELECTED          = 7
awtxConstants.printer.STATUS_NOT_SELECTED      = 8
awtxConstants.printer.STATUS_GENERAL_ERROR     = 9
awtxConstants.printer.STATUS_NOT_GENERAL_ERROR = 10

awtxConstants.printer.JOB_STATUS_DONE          = 1
awtxConstants.printer.JOB_STATUS_ABORTED       = 2
awtxConstants.printer.JOB_STATUS_CREATE_FAILED = 3

--
-- SCALE VALUES
--
awtxConstants.weight.VAL_GROSS                 = 0
awtxConstants.weight.VAL_NET                   = 1
awtxConstants.weight.VAL_TARE                  = 2
awtxConstants.weight.VAL_MIN                   = 3
awtxConstants.weight.VAL_MAX                   = 4
awtxConstants.weight.VAL_ROC                   = 5
awtxConstants.weight.VAL_GTOTAL                = 6
awtxConstants.weight.VAL_NTOTAL                = 7
awtxConstants.weight.VAL_TTOTAL                = 8
awtxConstants.weight.VAL_CTOTAL                = 9
awtxConstants.weight.VAL_TRANS                 = 10
awtxConstants.weight.VAL_COUNT                 = 11
awtxConstants.weight.VAL_VAR                   = 12
awtxConstants.weight.VAL_PCWT                  = 13
awtxConstants.weight.VAL_ADCCOUNTS             = 14
awtxConstants.weight.VAL_STD_DEV               = 15
awtxConstants.weight.VAL_TREND                 = 16
awtxConstants.weight.VAL_X_BAR_R               = 17
awtxConstants.weight.VAL_PERCENT               = 18
awtxConstants.weight.VAL_NET_MINUS_ANNUN       = 19
awtxConstants.weight.VAL_BLANK                 = 20
awtxConstants.weight.VAL_INMOTION              = 21
awtxConstants.weight.VAL_TARGET                = 22
awtxConstants.weight.VAL_GTOT_PLUS_CURRENT     = 23
awtxConstants.weight.VAL_GTOT_MINUS_CURRENT    = 24
awtxConstants.weight.VAL_NTOT_PLUS_CURRENT     = 25
awtxConstants.weight.VAL_NTOT_MINUS_CURRENT    = 26
awtxConstants.weight.VAL_CTOT_PLUS_CURRENT     = 27
awtxConstants.weight.VAL_CTOT_MINUS_CURRENT    = 28
awtxConstants.weight.VAL_ACCUMULATIONS         = 29
awtxConstants.weight.VAL_GAVERAGE              = 30
awtxConstants.weight.VAL_NAVERAGE              = 31
awtxConstants.weight.VAL_CAVERAGE              = 32
awtxConstants.weight.VAL_NMIN                  = 33
awtxConstants.weight.VAL_NMAX                  = 34
awtxConstants.weight.VAL_RATE                  = 35
awtxConstants.weight.VAL_FREEFALL_1            = 36
awtxConstants.weight.VAL_GFUTURE_1             = 37
awtxConstants.weight.VAL_NFUTURE_1             = 38
awtxConstants.weight.VAL_FREEFALL_2            = 39
awtxConstants.weight.VAL_GFUTURE_2             = 40
awtxConstants.weight.VAL_NFUTURE_2             = 41
awtxConstants.weight.VAL_PCWT_1000             = 42
awtxConstants.weight.VAL_PERCENT_ACCURACY      = 43
awtxConstants.weight.VAL_LAST_SAMPLE           = 44
awtxConstants.weight.VAL_GROSS_ALL_SCALES      = 45
awtxConstants.weight.VAL_NET_ALL_SCALES        = 46
awtxConstants.weight.VAL_TARE_ALL_SCALES       = 47
awtxConstants.weight.VAL_COUNT_ALL_SCALES      = 48
awtxConstants.weight.VAL_GTOT_ALL_SCALES       = 49
awtxConstants.weight.VAL_NTOT_ALL_SCALES       = 50
awtxConstants.weight.VAL_CTOT_ALL_SCALES       = 51
awtxConstants.weight.VAL_USER_MESSAGE          = 52

return awtxConstants
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
    
    display = {
        MODE_SCALE = 0,
        MODE_USER  = 1,
        MODE_MENU  = 2
    },
    
    graphics = {
        FONT_SYSTEM              = 0,  --  23 pixels tall 10 pixels wide
        FONT_LUCIDA_CON_8        = 3,  --   8 pixels tall
        FONT_LUCIDA_CON_10       = 4,  --  10 pixels tall
        FONT_LUCIDA_CON_12       = 5,  --  12 pixels tall
        FONT_LUCIDA_CON_16       = 6,  --  16 pixels tall
        FONT_LUCIDA_CON_20       = 7,  --  20 pixels tall
        FONT_LUCIDA_CON_40       = 8,  --  40 pixels tall
        FONT_SMALL_ICONS         = 9,  --  16 pixels tall
        FONT_DIS_TEXT            = 10, --  10 pixels tall
        FONT_ICONS               = 11, --  Old Evo Font
        FONT_TAHOMA_15           = 13, --  15 pixels tall
        FONT_VERDANA_15          = 14, --  15 pixels tall
        FONT_TAHOMA_22           = 19, --  22 pixels tall
        FONT_VERDANA_22          = 20, --  22 pixels tall
        FONT_ARIAL_80            = 25, --  80 pixels tall
        FONT_COOPER_11           = 26, --  11 pixels tall
        FONT_ARIAL_56            = 28, --  56 pixels tall
        FONT_ARIAL_31            = 29, --  35 pixels tall
        FONT_ARIAL_25            = 30, --  25 pixels tall
        FONT_ARIAL_16            = 31, --  16 pixels tall
        FONT_WTBASIC_1           = 32, --  ?? pixels tall
        FONT_WTBASIC_2           = 33, --  ?? pixels tall
        FONT_WTBASIC_3           = 34, --  ?? pixels tall
        FONT_WTBASIC_4           = 35, --  ?? pixels tall
        FONT_WTBASIC_5           = 36, --  ?? pixels tall
        FONT_ARIAL_BOLD_12       = 37, --  12 pixels tall
        FONT_ARIAL_BOLD_16       = 38, --  16 pixels tall
        FONT_COURIER_NEW_BOLD_12 = 42, --  12 pixels tall
        FONT_COURIER_NEW_BOLD_16 = 43, --  16 pixels tall
        FONT_LARGE_WT_120        = 47, -- 120 pixels tall
        FONT_LARGE_WT_160        = 48, -- 160 pixels tall
    },
    
    keypad = {
        RPN_MODE_DISABLED          = 0,
        RPN_MODE_ENABLED           = 1,
    },
    
    fmtPrint = {
        TYPE_UNDEFINED          = 0,
        TYPE_WEIGHT             = 1,
        TYPE_STRING             = 2,
        TYPE_DATE               = 3,
        TYPE_TIME               = 4,
        TYPE_FLOAT              = 5,
        TYPE_INTEGER            = 6,
        TYPE_BOOLEAN            = 7,
        TYPE_WEIGHT_VAR         = 8,
        TYPE_STRING_VAR         = 9,
        TYPE_DATE_VAR           = 10,
        TYPE_TIME_VAR           = 11,
        TYPE_FLOAT_VAR          = 12,
        TYPE_INTEGER_VAR        = 13,
        TYPE_BOOLEAN_VAR        = 14,
    },
    
    printer = {
        STATUS_OFFLINE           = 1,
        STATUS_ONLINE            = 2,
        STATUS_OK                = 3,
        STATUS_NOT_OK            = 4,
        STATUS_PAPER_LOW         = 5,
        STATUS_NOT_PAPER_LOW     = 6,
        STATUS_SELECTED          = 7,
        STATUS_NOT_SELECTED      = 8,
        STATUS_GENERAL_ERROR     = 9,
        STATUS_NOT_GENERAL_ERROR = 10,

        JOB_STATUS_DONE          = 1,
        JOB_STATUS_ABORTED       = 2,
        JOB_STATUS_CREATE_FAILED = 3,
    },
    
    weight= {
        VAL_GROSS                 = 0,
        VAL_NET                   = 1,
        VAL_TARE                  = 2,
        VAL_MIN                   = 3,
        VAL_MAX                   = 4,
        VAL_ROC                   = 5,
        VAL_GTOTAL                = 6,
        VAL_NTOTAL                = 7,
        VAL_TTOTAL                = 8,
        VAL_CTOTAL                = 9,
        VAL_TRANS                 = 10,
        VAL_COUNT                 = 11,
        VAL_VAR                   = 12,
        VAL_PCWT                  = 13,
        VAL_ADCCOUNTS             = 14,
        VAL_STD_DEV               = 15,
        VAL_TREND                 = 16,
        VAL_X_BAR_R               = 17,
        VAL_PERCENT               = 18,
        VAL_NET_MINUS_ANNUN       = 19,
        VAL_BLANK                 = 20,
        VAL_INMOTION              = 21,
        VAL_TARGET                = 22,
        VAL_GTOT_PLUS_CURRENT     = 23,
        VAL_GTOT_MINUS_CURRENT    = 24,
        VAL_NTOT_PLUS_CURRENT     = 25,
        VAL_NTOT_MINUS_CURRENT    = 26,
        VAL_CTOT_PLUS_CURRENT     = 27,
        VAL_CTOT_MINUS_CURRENT    = 28,
        VAL_ACCUMULATIONS         = 29,
        VAL_GAVERAGE              = 30,
        VAL_NAVERAGE              = 31,
        VAL_CAVERAGE              = 32,
        VAL_NMIN                  = 33,
        VAL_NMAX                  = 34,
        VAL_RATE                  = 35,
        VAL_FREEFALL_1            = 36,
        VAL_GFUTURE_1             = 37,
        VAL_NFUTURE_1             = 38,
        VAL_FREEFALL_2            = 39,
        VAL_GFUTURE_2             = 40,
        VAL_NFUTURE_2             = 41,
        VAL_PCWT_1000             = 42,
        VAL_PERCENT_ACCURACY      = 43,
        VAL_LAST_SAMPLE           = 44,
        VAL_GROSS_ALL_SCALES      = 45,
        VAL_NET_ALL_SCALES        = 46,
        VAL_TARE_ALL_SCALES       = 47,
        VAL_COUNT_ALL_SCALES      = 48,
        VAL_GTOT_ALL_SCALES       = 49,
        VAL_NTOT_ALL_SCALES       = 50,
        VAL_CTOT_ALL_SCALES       = 51,
        VAL_USER_MESSAGE          = 52,
    }
}

return awtxConstants
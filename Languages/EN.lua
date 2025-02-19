---@class language
local language = {
    _name = "ENGLISH",
    ready = "READY",
    new = "NEW",
    enter = "ENTER",
    driver = "DRIVER",
    name = "NAME",
    cant = "CANT",
    plates = "PLATES",
    saved = "SAVED",
    ["in"] = "IN",
    id = "ID",
    ok = "OK",
    active = "ACTIVE",
    change = "CHANGE",
    peripherals = "PERIPHERALS",
    exit = "EXIT",
    ticket = "TICKET",
    config = "CONFIG",
    catalogs = "CATALOGS",
    print = "PRINT",
    password = "PASSWORD",
    headers = "HEADERS",
    header1 = "HEADER1",
    header2 = "HEADER2",
    add = "ADD",
    delete = "DELETE",
    edit = "EDIT",
    count = "COUNT",
    weight = "WEIGHT",
    weights = "WEIGHTS",
    databases = "databases",
    questionSign = "?",
    done = "DONE",
    cancel = "CANCEL",
    select = "SELECT",
    language = "LANGUAGE",
    sentinel = "SENTINEL",
    variables = "VARIABLES",
    all = "ALL",
    reset = "RESET",
    reboot = "REBOOT",
    no = "NO",
    yes = "YES",
    error = "ERROR",
    printing = "PRINTING",
    format = "FORMAT",
    operation = "OPERATION",
    mode = "MODE",

    --------phrases--------
    ---@class _phrases
    _phrases = {
        resetAll = "RESET ALL",
        noPassword = "NO PASSWORD",
        isRequired = " IS REQUIRED",
        noZero = "NO ZERO",
        noMinWeight = "CANT, NO MIN WEIGHT",
        doNotExist = " DO NOT EXIST",
        weightOk = "WEIGHT OK",
        positionError = "POSITION ERROR",
        getOffScale = "GET OFF SCALE",
        badLctMode = "BAD LCT MODE",
        chPassword = "CH.CHPASSWORD",
        ticketNumber = " TICK.NUM",
        idDoNotExist = "ID DO NOT EXIST",
        alreadyExist= "ALREADY EXIST",
        enterValue= "ENTERVALUE",
        pesadasDB = "PESADASDB",
        enterId = "ENTERID",
        operationMode = "Oper.Mod",
        formatDoNotExist= "FORMAT DO NOT EXIT",
    }


}
local notReturnNull = {
    __index = function(self, key)
        return rawget(self, key) or string.format("$%s", key)
    end
}
setmetatable(language._phrases, notReturnNull)
setmetatable(language, notReturnNull)


return language

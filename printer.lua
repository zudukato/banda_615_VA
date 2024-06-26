local brmUtilities = require('Reqs.brmUtilities')
local printer = {}
printer._printing = false
local printersPath = "c:\\apps\\printFormats\\"
printer.printers = {
    EscPos = {},
    ZPL = {},
    EPL = {},
}
function printer.updatePrintFormats()
    local filesPath = printersPath
    local files = awtx.os.getFiles(filesPath, true)
    local printerType, fileName
    for _, path in pairs(files) do
        printerType, fileName = unpack(brmUtilities.split(path:gsub(filesPath, ""):gsub("%.%w*", ""), "\\"))
        local file = io.open(path, 'r')
        if type(file) ~= 'nil' then
            printer.printers[printerType][fileName] = file:read('*all')
            file:close()
        end
    end
end

function printer.doPrint(printFormat)
    if printer._printing then return print("actually printing") end
    brmUtilities.doScroll(Language.printing)
    if type(printFormat) ~= "string" then return brmUtilities.doScroll(Language._phrases.formatDoNotExist) end
    if printer._printing then return end
    local lines = brmUtilities.split(printFormat, "\r\n")
    awtx.weight.getRefreshLastPrint()
    for _, line in pairs(lines) do
        awtx.fmtPrint.set(1, line .. "\r\n")
        awtx.os.systemEvents(PersistentVars.interLineTime)
        awtx.printer.printFmt(1)
    end
end

function printer.onStart()
    printer.updatePrintFormats()
    printer.actuallyFormats = printer.printers[PersistentVars.printer]
end
printer.onStart()


return printer
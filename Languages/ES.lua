local language = {
    _name = "Espanol-La",
    ready = "Listo",


    _phrases = {}



}
local notReturnNull = {__index = function (self,key)
    return rawget(self,key) or string.format("$%s",key)
end}
setmetatable(language._phrases, notReturnNull)
setmetatable(language, notReturnNull)
return language
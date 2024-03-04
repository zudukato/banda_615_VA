---@diagnostic disable: param-type-mismatch, missing-parameter
---@class brmClassVariables
local brmClassVariables = {}
---@class brmClassVariableTables
local brmClassVariableTables = {}

brmClassVariables.__index = function (self, key)
    if key == "value" then return rawget(self,"_value") end
    if rawget(self, key) ~= nil then return rawget(self,key) end 
    return rawget(brmClassVariables, key)
end

brmClassVariables.__newindex = function(self, key, value)
    if key ~= "value" or not rawget(self,"autoSave") then return rawset(self, key, value) end --just change value unless key be "value"
    self._value = value
    self:store()                                                         --when you try to change value it automatically going to save if autoSave its active
end

---Function to create a new instance of brmClassVariables
---@param varName string --Name of variable to store
---@param defaultValue number|string|boolean|table --Default value to saved if not already exist
---@param autoSave any --If when you change the variable saved
---@param tableName any --name of table to store variables
---@return brmClassVariables
function brmClassVariables:new(varName, defaultValue, autoSave, tableName)
    local instance
    setmetatable(instance, self)
    rawset(instance,"_varName",varName)
    rawset(instance,"_defaultValue",defaultValue)
    rawset(instance,"_tableName",tableName)
    rawset(instance,"autoSave",autoSave)
    local savedValue = awtx.variables.recall(varName)
    instance._value = type(savedValue) ~="nil" and savedValue or defaultValue
    instance:store(instance._value)
    return instance 
end

---function to update value of variable
function brmClassVariables:store()
    local value = self._value
    local varName = rawget(self,"_varName")
    if value == nil then return print("value nil") end
    value = value == true and 1 or value
    awtx.variables.store(varName, value)
end

brmClassVariableTables.__index = function (self, key)
    if rawget(self, "_params")[key] ~= nil then return rawget(self, "_params")[key] end --returns the stored value if exist
    return rawget(brmClassVariableTables, key) -- for the class
end

brmClassVariableTables.__newindex = function (self, key, value)
    rawget(self,"_params")[key] = value
    if rawget(self, "_autoSave") then self:store(key) end --To save automatically
end

---Function to create a new instance of brmClassVariables
---@param tableName string --Name of the table to store
---@param defaultValues number|string|boolean|table --Default value to saved if not already exist
---@param autoSave any --If when you change the variable saved
---@return brmClassVariables
function brmClassVariableTables:new(tableName, defaultValues, autoSave)
    local instance = {}
    setmetatable(instance, self)
    rawset(instance,"_tableName", tableName)
    rawset(instance, "_autoSave", autoSave)
    local savedValue
    awtx.variables.createTable(tableName)
    for key, value in pairs(defaultValues) do
        savedValue = awtx.variables.recall(tableName,key)
        defaultValues[key] = type(savedValue)~="nil" and savedValue or value
    end
    rawset(instance,"_params",defaultValues)
    instance:storeAll()
    return instance
end

function brmClassVariableTables:store(key)
    local tableName = rawget(self, "_tableName")
    local value = rawget(self,"_params")[key]
    if value == nil then return print("value nil") end
    value = value == true and 1 or value
    awtx.variables.store(tableName,key,value)
end

function brmClassVariableTables:storeAll()
    for key, _ in pairs(rawget(self,"_params")) do
        self:store(key)
    end
end
    
return {
    ---Function to create a new saved variable (when saving a table autoSave does not work with internal parameters)
    ---@param varName string --Name of variable to store
    ---@param defaultValue number|string|boolean|table --Default value to saved if not already exist
    ---@param autoSave any --If when you change the variable saved
    ---@param tableName any --name of table to store variables
    ---@return brmClassVariables
    SavedVariable = function(varName, defaultValue, autoSave, tableName)
        return brmClassVariables:new(varName, defaultValue, autoSave, tableName)
    end,

    SavedVariableTable = function (tableName, defaultValues, autoSave)
        return brmClassVariableTables:new(tableName,defaultValues,autoSave)
    end
}

local brmUtilities = require("Reqs.brmUtilities")

---@class brmDatabase
---@field path string
---@field databaseName string
---@field tables table<string, tableClass>
---@field private _dbHandle any
local brmDatabase = {}
brmDatabase.__index = brmDatabase
---@class tableClass
---@field tableName string
---@field private _fieldsDefinition table
---@field private _headers table
---@field private _dbHandle table
local tableClass = {}
tableClass.__index = tableClass

--Constructor of the class brmDatabase
---@param databaseName string --name of database
---@param path? string --path to the store database
---@return brmDatabase
------------------------------------------------------------------------------------------
function brmDatabase:new(databaseName, path)
  local instance = {}
  setmetatable(instance, self)
  instance.path = path or "C:\\Apps\\Database\\"
  instance.tables = {}
  awtx.os.makeDirectory(instance.path)
  instance.databaseName = (databaseName or "Revuelta") .. ".db"
  instance:open()
  return instance
end

--Open database communication
------------------------------------------------------------------------------------------
function brmDatabase:open()
  local executionResult = {}
  self.dbHandle, executionResult["opening"]= sqlite3.open(self.path .. self.databaseName)
  print(executionResult)
end

--Close database communication
------------------------------------------------------------------------------------------
function brmDatabase:close()
  local executionResult = {}
  executionResult["closing"] = self.dbHandle:close()
  print(executionResult)
end

--Method to create a new database Tabla
---@param tableName string --Name of the table
---@param fieldsDefinition table --Initialization of fields ({"Id INTEGER NOT NULL", Name TEXT})
---@return tableClass|nil -- instance of class tableClass
------------------------------------------------------------------------------------------
function brmDatabase:newTable(tableName, fieldsDefinition)
  if not self.dbHandle:isopen() then return print("Database is closed") end
  if type(tableName) ~="string" or type(fieldsDefinition) ~= "table" then print("tableName = nil or fields = nil") return end
  ---@type tableClass|nil
  local newTable = tableClass:new(tableName, fieldsDefinition, self.dbHandle)
  if newTable then
    self.tables[newTable.tableName] = newTable
  end
  return newTable
end

--Handler for database tables
------------------------------------------------------------------------------------------

--Constructor
---@param tableName string --name of the table
---@param fieldsDefinition table --Initialization of fields ({"Id INTEGER NOT NULL", Name TEXT})
---@param dbHandle table --handle of database
---@return tableClass|nil --Instance of class
------------------------------------------------------------------------------------------
function tableClass:new(tableName, fieldsDefinition, dbHandle)
  if not dbHandle then return end
  local instance = {}
  setmetatable(instance, self)
  instance.tableName = tableName
  instance._fieldsDefinition = fieldsDefinition
  instance._headers = {}
  for _, value in ipairs(fieldsDefinition) do
    table.insert(instance._headers, string.match(value, "%s*(%w+)%s*.?"))
  end
  instance._dbHandle = dbHandle

  local query = "CREATE TABLE IF NOT EXISTS " ..
  instance.tableName ..
  " (" .. table.concat(fieldsDefinition, ",") .. ")"

  local executionResult = {
    beginTransaction = instance._dbHandle:execute("BEGIN TRANSACTION"),
    query = instance._dbHandle:execute(query),
    commit = instance._dbHandle:execute("COMMIT")
  }
  print(executionResult)
  return instance
end

-- insert a new row in the table
---@param rowValues table --a table whit values 
---@return table|nil,table|nil --response and result
------------------------------------------------------------------------------------------
function tableClass:addRow(rowValues)
  if not rowValues then print("Not Values") return  end
  if type(rowValues) ~= "table" then print("rowValues not table") end
  if #rowValues ~= #self._headers then print("error number of values") return end

  local query = "REPLACE INTO " .. self.tableName .. " VALUES(?" .. string.rep(',?', #rowValues - 1) .. ")"
  local response, executionResult = self:_exec(query, unpack(rowValues))
  print(executionResult)
  return response, executionResult
end

-- Method to delete a table row
---@param whereField string -- field to find
---@param whereValue string|number -- value of field
---@return table|nil,table|nil --response and result
------------------------------------------------------------------------------------------
function tableClass:deleteRow(whereField, whereValue)
  local whereSentence, whereValue = self:_where(whereField, whereValue)
  if whereSentence == "" then print("Who Row?") return end
  local query = "DELETE FROM " .. self.tableName .. whereSentence
  local response,executionResult =self:_exec(query, whereValue)
  print(executionResult)
  return response, executionResult
end

-- Method to change a database row
---@param fieldsTable table <string, any> --table <key, value> with columns and values to update
---@param whereField string -- field to find
---@param whereValue string|number -- value of field
---@return table|nil,table|nil --response and result
------------------------------------------------------------------------------------------
function tableClass:updateRow(fieldsTable,whereField, whereValue)
  local whereSentence, whereValue = self:_where(whereField, whereValue)
  --exit conditions
  if type(fieldsTable) ~='table' then print("fields not a tables") return end
  if whereSentence == "" then print("Where?") return end
  local keys, values = brmUtilities.keysValues(fieldsTable)
  table.insert(values, whereValue)
  local query = "UPDATE " .. self.tableName .. " SET " .. table.concat(keys,'=?,') .. "=? "..whereSentence
  local response, executionResult = self:_exec(query,unpack(values))
  print(executionResult)
  return response, executionResult
end

-- Method to find rows
---@param whereField? string -- field to find
---@param whereValue? string|number -- value of field
---@param orderBy? string --field to order
---@param asc? boolean -- if order ascending or descending
---@return table,table  --response and result of execution
------------------------------------------------------------------------------------------
function tableClass:find(whereField, whereValue, orderBy, asc)
  local whereSentence, whereValue = self:_where(whereField, whereValue)
  local orderBySentence = self:_orderBy(orderBy, asc)
  local query = "SELECT * FROM " .. self.tableName .. whereSentence .. orderBySentence
  local response, executionResult = self:_exec(query, whereValue)
  print(executionResult)
  return response,executionResult
end

-- Count the result 
---@param whereField? string -- field to find
---@param whereValue? string|number -- value of field
---@return integer,table
------------------------------------------------------------------------------------------
function tableClass:countRecord(whereField, whereValue)
  local whereSentence, whereValue = self:_where(whereField, whereValue)
  local query = "SELECT COUNT(*) FROM " .. self.tableName .. whereSentence
  local response, executionResult = self:_exec(query, whereValue)
  print(executionResult)
  return response[1]["COUNT(*)"],executionResult
end

--Private method to create a sentence to order a execution
---@param orderBy? string --field to order
---@param asc? boolean -- if order ascending or descending
---@return string --sentence
------------------------------------------------------------------------------------------
function tableClass:_orderBy(orderBy, asc)
  if not orderBy then return "" end
  if type(orderBy) ~= "string" then print("orderBy("..orderBy..") Not String") end
  local ascString = asc and "ASC" or "DESC"
  return " ORDER BY " .. orderBy .. " " .. ascString
end

-- Private method to create a sentence to find 
---@param whereField? string -- field to find
---@param whereValue? string|number -u- value of field
---@return string,string|number|nil --sentence
------------------------------------------------------------------------------------------
function tableClass:_where(whereField, whereValue)
  if not whereField or not whereValue then return "" end
  if type(whereField) ~= 'string' then print("whereField ("..whereField..") Not String") return "" end
  return " WHERE " .. whereField .. " = ?", whereValue
end

-- Private method to execute a query
---@param query string --Query to execute 
---@param ... string|number 
---@return table,table --response and result
------------------------------------------------------------------------------------------
function tableClass:_exec(query, ...)
  local response = {}
  local executionResult   = {query = query, values = {...}}
  local stmt     = nil
  if not query or type(query) ~= "string" then return {} , {query = "not string ("..query..")"} end
  if not self._dbHandle:isopen() then return response, { ["open"] = "Database is closed" } end
  stmt, executionResult["queryExec"] = self._dbHandle:prepare(query)
  if not stmt then return {}, executionResult end
  if #{...}>0 then
    executionResult['valuesExec'] = stmt:bind_values(...)
  end
  for row in stmt:nrows() do table.insert(response, row) end
  stmt:finalize()
  return response, executionResult
end

return brmDatabase
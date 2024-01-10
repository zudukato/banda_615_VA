---@class brmDatabase
local brmDatabase = {}
brmDatabase.__index = brmDatabase

---@class dbtable
local dbtable = {}
dbtable.__index = dbtable

--Constructor of the class brmDatabase
---@param databaseName string
---@return brmDatabase
------------------------------------------------------------------------------------------
function brmDatabase:new(databaseName)
  self = setmetatable({}, brmDatabase)
  self.path = "C:\\Apps\\Database\\"
  awtx.os.makeDirectory(self.path)
  self.databaseName = (databaseName or "Revuelta") .. ".db"
  self:open()
  return self
end

--Open database comunication
------------------------------------------------------------------------------------------
function brmDatabase:open()
  local executionResult = {}
  self.dbHandle, executionResult["opening"]= sqlite3.open(self.path .. self.databaseName)
  print(executionResult)
end

--Close database comunication
------------------------------------------------------------------------------------------
function brmDatabase:close()
  local executionResult = {}
  executionResult["closing"] = self.dbHandle:close()
  print(executionResult)
end

--Method to create a new database Tabla
---@param tableName string --Name of the table
---@param fieldsDefinition table --Initialization of fields ({"Id INTEGER NOT NULL", Name TEXT})
---@return dbtable|nil -- instance of class dbtable
------------------------------------------------------------------------------------------
function brmDatabase:newTable(tableName, fieldsDefinition)
  if not self.dbHandle:isopen() then print("Database is closed") return end
  if type(tableName) ~="string" or type(fieldsDefinition) ~= "table" then print("tableName = nil or fields = nil") return end
  tableName = tostring(tableName)
  ---@type dbtable
  return dbtable:new(tableName, fieldsDefinition, self.dbHandle)
end

--Handler for database tables
------------------------------------------------------------------------------------------

--Constructor
---@param tableName string --name of the table
---@param fieldsDefinition table --Initialization of fields ({"Id INTEGER NOT NULL", Name TEXT})
---@param dbHandle table --handle of database
---@return dbtable|nil --Instance of class
------------------------------------------------------------------------------------------
function dbtable:new(tableName, fieldsDefinition, dbHandle)
  if not dbHandle then return end
  self = setmetatable({}, dbtable)
  self.tableName = tableName
  self._fieldsDefinition = fieldsDefinition
  self._headers = {}
  for _, value in ipairs(fieldsDefinition) do
    table.insert(self._headers, string.match(value, "%s*(%w+)%s*.?"))
  end
  self._dbHandle = dbHandle

  local query = "CREATE TABLE IF NOT EXISTS " ..
  self.tableName ..
  " (" .. table.concat(fieldsDefinition, ",") .. ")"

  local executionResult = {
    beginTransaction = self._dbHandle:execute("BEGIN TRANSACTION"),
    query = self._dbHandle:execute(query),
    commit = self._dbHandle:execute("COMMIT")
  }
  print(executionResult)
  return self
end

-- Inserta un nuevo renglon a la base de datos
---@param rowValues table --a table whit values 
---@return table,table --response and result
------------------------------------------------------------------------------------------
function dbtable:addRow(rowValues)
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
---@param whereValue any -- value of field
---@return table|nil,table|nil --response and result
------------------------------------------------------------------------------------------
function dbtable:deleteRow(whereField, whereValue)
  local whereSentence, whereValue = self:_where(whereField, whereValue)
  if whereSentence == "" then print("Who Row?") return end
  local query = "DELETE FROM " .. self.tableName .. whereSentence
  local response,executionResult =self:_exec(query, whereValue)
  print(executionResult)
  return response, executionResult
end

-- Method to change a database row
---@param whereField string -- field to find
---@param whereValue any -- value of field
---@return table|nil,table|nil --response and result
------------------------------------------------------------------------------------------
function dbtable:updateRow(fields, fieldsValues, whereField, whereValue)
  local whereSentence, whereValue = self:_where(whereField, whereValue)
  fields= fields or self._headers
  --exit conditions
  if type(fields) ~='table' or type(fieldsValues) ~='table'then print("fields or fieldsValue not tables") return end
  if not fieldsValues then print("Not values") return end
  if whereSentence == "" then print("Where?") return end
  if #fields ~= #fieldsValues then  print("Error number of values") return end

  table.insert(fieldsValues,whereValue)
  local query = "UPDATE " .. self.tableName .. " SET " .. table.concat(fields,'=?,') .. "=? "..whereSentence
  local response, executionResult = self:_exec(query,unpack(fieldsValues))
  print(executionResult)
  return response, executionResult
end

-- Method to find rows
---@param whereField? string -- field to find
---@param whereValue? any -- value of field
---@param orderBy? string --field to order
---@param asc? boolean -- if order ascending or decending
---@return table,table  --response and result of execution
------------------------------------------------------------------------------------------
function dbtable:find(whereField, whereValue, orderBy, asc)
  local whereSentence, whereValue = self:_where(whereField, whereValue)
  local orderBySentence = self:_orderBy(orderBy, asc)
  local query = "SELECT * FROM " .. self.tableName .. whereSentence .. orderBySentence
  local response, executionResult = self:_exec(query, whereValue)
  print(executionResult)
  return response,executionResult
end

-- Count the result 
---@param whereField? string -- field to find
---@param whereValue? any -- value of field
---@return integer,table
------------------------------------------------------------------------------------------
function dbtable:countRecord(whereField, whereValue)
  local whereSentence, whereValue = self:_where(whereField, whereValue)
  local query = "SELECT COUNT(*) FROM " .. self.tableName .. whereSentence
  local response, executionResult = self:_exec(query, whereValue)
  print(executionResult)
  return response[1]["COUNT(*)"],executionResult
end

--Private method to create a sentence to order a execution
---@param orderBy? string --field to order
---@param asc? boolean -- if order ascending or decending
---@return string --sentence
------------------------------------------------------------------------------------------
function dbtable:_orderBy(orderBy, asc)
  if not orderBy then return "" end
  if type(orderBy) ~= "string" then print("orderBy("..orderBy..") Not String") end
  local ascString = asc and "ASC" or "DESC"
  return " ORDER BY " .. orderBy .. " " .. ascString
end

-- Private method to create a sentece to find 
---@param whereField? string -- field to find
---@param whereValue? any -- value of field
---@return string,any --sentence
------------------------------------------------------------------------------------------
function dbtable:_where(whereField, whereValue)
  if not whereField or not whereValue then return "" end
  if type(whereField) ~= 'string' then print("whereField ("..whereField..") Not String") return "" end
  return " WHERE " .. whereField .. " = ?", whereValue
end

-- Private method to execut a query
---@param query string --Query to execut 
---@return table,table --response and result
------------------------------------------------------------------------------------------
function dbtable:_exec(query, ...)
  local response = {}
  local executionResult   = {query = query, values = {...}}
  local stmt     = nil
  if not query or type(query) ~= "string" then return {} , {query = "not string ("..query..")"} end
  if not self._dbHandle:isopen() then return response, { ["open"] = "Database is closed" } end
  stmt, executionResult["queryExec"] = self._dbHandle:prepare(query)
  if not stmt then return {}, executionResult end
  if ... then executionResult['valuesExec'] = stmt:bind_values(...) end
  for row in stmt:nrows() do table.insert(response, row) end
  return response, executionResult
end

return brmDatabase
local brmDatabase = {}
local dbtable = {}
brmDatabase.__index = brmDatabase
dbtable.__index = dbtable
--Metodos de la clase brmDatabase, clase para controlar una base de datos del tipo SQLite
-----------------------------------------------------------------------------------------

-- Constructor que crea una nueva instancia de una base de datos
-- databaseName :  str --nombre de la base de datos
-- -> instace : table --instancia
function brmDatabase:new(databaseName)
  local instance = setmetatable({}, brmDatabase)
  instance.path = "C:\\Apps\\Database\\"
  awtx.os.makeDirectory(instance.path)
  instance.databaseName = (databaseName or "Revuelta") .. ".db"
  instance:open()
  return instance
end

-- Abre la comunicacion entre el objeto y la base de datos
function brmDatabase:open()
  local errors = {}
  self.dbHandle, errors["opening"]= sqlite3.open(self.path .. self.databaseName)
  print(errors)
end

--Cierra la comunicacion entre el objeto y la base de datos
function brmDatabase:close()
  local errors = {}
  errors["closing"] = self.dbHandle:close()
  print(errors)
end

--Metodo para crear una nueva Tabla
-- tableName : str  --Nombre de la tabla
-- fields: table --Inicializacion de los campos ({"Id INTEGER NOT NULL", Name TEXT})
-- -> errors: table --tabla con el resultado de las ejecuciones
function brmDatabase:newTable(tableName, fields)
  if not self.dbHandle:isopen() then print("Database is closed"); return end
  if not tableName or not fields then print("tableName = nil or fields = nil") return end
  tableName = tostring(tableName)
  local query = "CREATE TABLE IF NOT EXISTS " ..
  tableName ..
  " (" .. table.concat(fields, ",") .. ")"
  local errors = {}
  errors["beginTransaction"] = self.dbHandle:execute("BEGIN TRANSACTION")
  errors["query"] = self.dbHandle:execute(query)
  errors["commit"] = self.dbHandle:execute("COMMIT")
  self[tableName] = dbtable:new(tableName, fields, self.dbHandle)
  print(errors)
  return errors
end

-- Metodos de la clase  dbtable, la cual es un manejador de las tablas de la base de datos
------------------------------------------------------------------------------------------

--Constructor de la calase
-- tableName: str --nombre de la tabla
-- fields: table|lsit --campos que contiene la tabla
-- dbHandle: object --manejador de la base de datos
function dbtable:new(tableName, fieldsDefinition, dbHandle)
  if not dbHandle then return end
  local instance = setmetatable({}, dbtable)
  instance.tableName = tableName
  instance._fieldsDefinition = fieldsDefinition
  instance._headers = {}
  for _, value in ipairs(fieldsDefinition) do
    table.insert(instance._headers, string.match(value, "%s*(%w+)%s*.?"))
  end
  instance._dbHandle = dbHandle
  return instance
end

-- Inserta un nuevo renglon a la base de datos
-- row: table --campos con valores
function dbtable:addRow(rowValues)
  if not rowValues then print("Not Values") return  end
  if type(rowValues) ~= "table" then print("rowValues not table") end
  if #rowValues ~= #self._headers then print("error number of values") return end

  local query = "REPLACE INTO " .. self.tableName .. " VALUES(?" .. string.rep(',?', #rowValues - 1) .. ")"
  local response, errors = self:_exec(query, unpack(rowValues))
  print(errors)
  return response, errors
end

-- Metodo para eliminar un renglon de la base de datos
-- whereField: str -- campo por el cual se quiere buscar
-- whereValue: str\numeric -- valor del campo a buscar
function dbtable:deleteRow(whereField, whereValue)
  local whereSentence, whereValue = self:_where(whereField, whereValue)
  if whereSentence == "" then print("Who Row?") end
  local query = "DELETE FROM " .. self.tableName .. whereSentence
  local response,errors =self:_exec(query, whereValue)
  print(errors)
  return response, errors
end

-- Metodo para editar un renglon
-- whereField: str -- campo por el cual se quiere buscar
-- whereValue: str\numeric -- valor del campo a buscar
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
  local response, errors = self:_exec(query,unpack(fieldsValues))
  print(errors)
  return response, errors
end

-- Metodo para buscar renglones
-- whereField(opcional): str -- campo por el cual se quiere buscar
-- whereValue(opcional): str\numeric -- valor del campo a buscar
-- orderBy(opcional): str -- campo por el cual se quere ordenar
-- asc(opcional): bool -- si se quere ordenar ascendente o decendente
function dbtable:find(whereField, whereValue, orderBy, asc)
  local whereSentence, whereValue = self:_where(whereField, whereValue)
  local orderBySentence = self:_orderBy(orderBy, asc)
  local query = "SELECT * FROM " .. self.tableName .. whereSentence .. orderBySentence
  local response, errors = self:_exec(query, whereValue)
  print(errors)
  return response
end

-- Metodo para contar el resultado de una busqueda
-- whereField(opcional): str -- campo por el cual se quiere buscar
-- whereValue(opcional): str\numeric -- valor del campo a buscar
function dbtable:countRecord(whereField, whereValue)
  local whereSentence, whereValue = self:_where(whereField, whereValue)
  local query = "SELECT COUNT(*) FROM " .. self.tableName .. whereSentence
  local response, errors = self:_exec(query, whereValue)
  print(errors)
  return response[1]["COUNT(*)"]
end

-- Metodo privado para realizar la sentencia de ordenar
-- orderBy(opcional): str -- campo por el cual se quere ordenar
-- asc(opcional): bool -- si se quere ordenar ascendente o decendente
function dbtable:_orderBy(orderBy, asc)
  if not orderBy then return "" end
  if type(orderBy) ~= "string" then print("orderBy("..orderBy..") Not String") end
  asc = asc and "ASC" or "DESC"
  return " ORDER BY " .. orderBy .. " " .. asc
end

-- Metodo privado para realizar la sentencia  al buscar
-- whereField(opcional): str -- campo por el cual se quiere buscar
-- whereValue(opcional): str\numeric -- valor del campo a buscar
function dbtable:_where(whereField, whereValue)
  if not whereField or not whereValue then return "" end
  if type(whereField) ~= 'string' then print("whereField ("..whereField..") Not String") return "" end
  return " WHERE " .. whereField .. " = ?", whereValue
end

-- Metodo privado para realizar la ejecucion de una query
-- query: str -- instruccion para SQLite3
function dbtable:_exec(query, ...)
  local response = {}
  local errors   = {query = query, values = {...}}
  local stmt     = nil
  if not query or type(query) ~= "string" then return {} , {query = "not string ("..query..")"} end
  if not self._dbHandle:isopen() then return response, { ["open"] = "Database is closed" } end
  stmt, errors["queryExec"] = self._dbHandle:prepare(query)
  if not stmt then return {}, errors end
  if ... then errors['valuesExec'] = stmt:bind_values(...) end
  for row in stmt:nrows() do table.insert(response, row) end

  return response, errors
end

return brmDatabase
local brmSqlClasses = require("Reqs.brmSqlClasses")
Databases = Databases or {}
local database
database = brmSqlClasses:new("EPI","C:\\Database\\")
Databases.EPI = database

---@class epiDatabase.productRow
---@field id integer
---@field name string
---@field product_line string
---@field gtin string
---@field objective_weight number
---@field tare number
---@field mode integer
---@field label_type integer
---@field expiration integer
---@field piece_count integer
---@field description string

local products = database:newTable("products",{
    "id INTEGER NOT NULL PRIMARY KEY",
    "id_product NOT NULL",
    "name TEXT",
    "product_line TEXT",
    "gtin TEXT NOT NULL",
    "gtin14 TEXT NOT NULL",
    "objective_weight REAL NOT NULL",
    "tare REAL NOT NULL",
    "mode INTEGER NOT NULL",
    "label_type INTEGER",
    "expiration INTEGER NOT NULL",
    "piece_count INTEGER DEFAULT 1",
    "description TEXT",
    "frozen boolean DEFAULT 1",
    "rotation_date INTEGER DEFAULT 10 ",
    "provider_number integer DEFAULT 216218",
    "sku TEXT",
    "id_product_client TEXT",
}
)
---@class epiDatabase.OfflineWeight.data_params
---@field gtin string
---@field description string
---@field product_id integer
---@field product_description string
---@field product_line string
---@field tare number
---@field tareG number
---@field piece_count integer
---@field scale_id integer
---@field serial_id integer
---@field classification integer
---@field operation_number integer
---@field serial_number string
---@field real_weight number
---@field net_weight number
---@field net_weightLb number
---@field lote string
---@field order integer
---@field expiration string
---@field eanQr string
---@field eanPvCi string
---@field eanPvSi string

local offlineWeight = database:newTable("offlineWeight",{
    "id INTEGER PRIMARY KEY AUTOINCREMENT",
    "data_params TEXT"
})

if products then database.tables.products = products end
if offlineWeight then database.tables.offlineWeight = offlineWeight end
return database
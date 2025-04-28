local brmSqlClasses = require("Reqs.brmSqlClasses")
Databases = Databases or {}
local database
database = brmSqlClasses:new("EPI")
Databases.EPI = database


database.products = database:newTable("products",{
    "id_product INTEGER NOT NULL PRIMARY KEY",
    "product_description  TEXT",
    "production_line TEXT",
    "gtin INTEGER",
    "objective_weight REAL",
    "tare REAL",
    "mode INTEGER",
    "label_type INTEGER",
    "expiration INTEGER",
    "pieces_number INTEGER",
    "description TEXT"
}
)
return database
local BrmReqSql = require("Reqs.brmSql")


-- Databases
local databases = {}
databases.pesadas = BrmReqSql:new("pesadas")
databases.catalogos = BrmReqSql:new("catalogos")
--tables
databases.catalogos.taras = databases.catalogos:newTable("taras", {"Id VARCHAR NOT NULL", "Value INTEGER"})
databases.catalogos.empresas = databases.catalogos:newTable("empresas", {"Id VARCHAR NOT NULL", "Value VARCHAR NOT NULL"})
databases.catalogos.productos = databases.catalogos:newTable("productos", {"Id VARCHAR NOT NULL", "Value VARCHAR NOT NULL"})
databases.pesadas.primeraPesada = databases.pesadas:newTable("primeraPesada", {"Folio INTEGER",
    "Placas VARCHAR NOT NULL",
    "PesoIn INTEGER NOT NULL",
    "UnitsIn VARCHAR NOT NULL",
    "FechaIn DATE NOT NULL",
    "HoraIn TIME NOT NULL",
    "IdEmpresa VARCHAR",
    "Empresa VARCHAR",
    "IdProducto VARCHAR",
    "Producto VARCHAR"})

databases.pesadas.segundaPesada = databases.pesadas:newTable("segundaPesada", {"Folio INTEGER",
    "Placas VARCHAR NOT NULL",
    "Chofer VARCHAR",
    "PesoIn INTEGER NOT NULL",
    "UnitsIn VARCHAR NOT NULL",
    "FechaIn DATE NOT NULL",
    "HoraIn TIME NOT NULL",
    "PesoOut INTEGER NOT NULL",
    "UnitsOut VARCHAR NOT NULL",
    "FechaOut DATE NOT NULL",
    "HoraOut TIME NOT NULL",
    "Bruto INTEGER NOT NULL",
    "Tara INTEGER NOT NULL",
    "Neto INTEGER NOT NULL",
    "IdEmpresa VARCHAR",
    "Empresa VARCHAR",
    "IdProducto VARCHAR",
    "Producto VARCHAR"})

databases.pesadas.primeraPesadaFulles = databases.pesadas:newTable("primeraPesadaFulles", {"Folio INTEGER",
    "Placas1 VARCHAR NOT NULL",
    "Placas2 VARCHAR NOT NULL",
    "PesoIn1 INTEGER NOT NULL",
    "PesoIn2 INTEGER NOT NULL",
    "UnitsIn VARCHAR NOT NULL",
    "FechaIn DATE NOT NULL",
    "HoraIn TIME NOT NULL",
    "IdEmpresa VARCHAR",
    "Empresa VARCHAR",
    "IdProducto VARCHAR",
    "Producto VARCHAR"})

databases.pesadas.segundaPesadaFulles = databases.pesadas:newTable("segundaPesadaFulles", {"Folio INTEGER",
    "Placas1 VARCHAR NOT NULL",
    "Placas2 VARCHAR NOT NULL",
    "Chofer VARCHAR",
    "PesoIn1 INTEGER NOT NULL",
    "PesoIn2 INTEGER NOT NULL",
    "UnitsIn VARCHAR NOT NULL",
    "FechaIn DATE NOT NULL",
    "HoraIn TIME NOT NULL",
    "PesoOut1 INTEGER NOT NULL",
    "PesoOut2 INTEGER NOT NULL",
    "UnitsOut VARCHAR NOT NULL",
    "FechaOut DATE NOT NULL",
    "HoraOut TIME NOT NULL",
    "Bruto INTEGER NOT NULL",
    "Tara INTEGER NOT NULL",
    "Neto INTEGER NOT NULL",
    "IdEmpresa VARCHAR",
    "Empresa VARCHAR",
    "IdProducto VARCHAR",
    "Producto VARCHAR"})

return databases
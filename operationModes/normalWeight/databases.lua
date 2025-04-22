---@diagnostic disable: inject-field
--[[
    If you change the definition of tables remember delete the previos databases 
]]
local BrmReqSql = require("Reqs.brmSqlClasses")


-- Databases
Databases.pesadas = BrmReqSql:new("pesadas")
Databases.catalogos = BrmReqSql:new("catalogos")
--tables
Databases.catalogos.taras = Databases.catalogos:newTable("taras", {"Id VARCHAR NOT NULL", "Value INTEGER"})
Databases.catalogos.empresas = Databases.catalogos:newTable("empresas", {"Id VARCHAR NOT NULL", "Value VARCHAR NOT NULL"})
Databases.catalogos.productos = Databases.catalogos:newTable("productos", {"Id VARCHAR NOT NULL", "Value VARCHAR NOT NULL"})
Databases.pesadas.primeraPesada = Databases.pesadas:newTable("primeraPesada", {"Folio INTEGER",
    "Placas VARCHAR NOT NULL",
    "Chofer VARCHAR",
    "PesoIn INTEGER NOT NULL",
    "UnitsIn VARCHAR NOT NULL",
    "FechaIn DATE NOT NULL",
    "HoraIn TIME NOT NULL",
    "IdEmpresa VARCHAR",
    "Empresa VARCHAR",
    "IdProducto VARCHAR",
    "Producto VARCHAR"})

Databases.pesadas.segundaPesada = Databases.pesadas:newTable("segundaPesada", {"Folio INTEGER",
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

Databases.pesadas.primeraPesadaFulles = Databases.pesadas:newTable("primeraPesadaFulles", {"Folio INTEGER",
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

Databases.pesadas.segundaPesadaFulles = Databases.pesadas:newTable("segundaPesadaFulles", {"Folio INTEGER",
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

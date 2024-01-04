--[[
*******************************************************************************

Filename:      Application.lua
Firmware:      2.5.0.0 or higher
Date:          2023-12-21
Customer:      Juan Alberto Hernandez
Description:
*******************************************************************************
]]
--Reqs
require("awtxReqConstants")
BrmReqSql = require("brmSql")
local brmUtilitis = require("brmUtilitis")


--------------Setup------------------------
--Databases
-- Databases = {}
-- Databases.pesadas = BrmReqSql:new("pesadas")
-- Databases.catalogos = BrmReqSql:new("catalogos")
-- --tables
-- Databases.catalogos:newTable("Taras",{"Id VARCHAR NOT NULL","Peso INTEGER"})
-- Databases.catalogos:newTable("Empresas",{"Id VARCHAR NOT NULL", "Empresa VARCHAR NOT NULL"})
-- Databases.catalogos:newTable("Productos",{"Id VARCHAR NOT NULL", "producto VARCHAR NOT NULL"})
-- Databases.pesadas:newTable("firstWeight", { "Folio INTEGER",
--     "Placas VARCHAR NOT NULL",
--     "PesoIn INTEGER NOT NULL",
--     "UnitsIn VARCHAR NOT NULL",
--     "FechaIn DATE NOT NULL",
--     "HoraIn TIME NOT NULL",
--     "IdEmpresa VARCHAR",
--     "Empresa VARCHAR",
--     "IdProducto VARCHAR",
--     "Producto VARCHAR" })

-- Databases.pesadas:newTable("secondWeight",{"Folio INTEGER",
--     "Placas VARCHAR NOT NULL",
--     "Chofer VARCHAR",
--     "PesoIn INTEGER NOT NULL",
--     "UnitsIn VARCHAR NOT NULL" ,
--     "FechaIn DATE NOT NULL",
--     "HoraIn TIME NOT NULL",
--     "PesoOut INTEGER NOT NULL",
--     "UnitsOut VARCHAR NOT NULL",
--     "FechaOut DATE NOT NULL",
--     "HoraOut TIME NOT NULL",
--     "Bruto INTEGER NOT NULL",
--     "Tara INTEGER NOT NULL",
--     "Neto INTEGER NOT NULL",
--     "IdEmpresa VARCHAR",
--     "Empresa VARCHAR",
--     "IdProducto VARCHAR",
--     "Producto VARCHAR" })

--  Databases.pesadas:newTable("firstFullWeight", { "Folio INTEGER",
--     "Placas1 VARCHAR NOT NULL",
--     "Placas2 VARCHAR NOT NULL",
--     "PesoIn1 INTEGER NOT NULL",
--     "PesoIn2 INTEGER NOT NULL",
--     "UnitsIn VARCHAR NOT NULL",
--     "FechaIn DATE NOT NULL",
--     "HoraIn TIME NOT NULL",
--     "IdEmpresa VARCHAR",
--     "Empresa VARCHAR",
--     "IdProducto VARCHAR",
--     "Producto VARCHAR" })

-- Databases.pesadas:newTable("secondFullWeight",{"Folio INTEGER",
--     "Placas1 VARCHAR NOT NULL",
--     "Placas2 VARCHAR NOT NULL",
--     "Chofer VARCHAR",
--     "PesoIn1 INTEGER NOT NULL",
--     "PesoIn2 INTEGER NOT NULL",
--     "UnitsIn VARCHAR NOT NULL" ,
--     "FechaIn DATE NOT NULL",
--     "HoraIn TIME NOT NULL",
--     "PesoOut1 INTEGER NOT NULL",
--     "PesoOut2 INTEGER NOT NULL",
--     "UnitsOut VARCHAR NOT NULL",
--     "FechaOut DATE NOT NULL",
--     "HoraOut TIME NOT NULL",
--     "Bruto INTEGER NOT NULL",
--     "Tara INTEGER NOT NULL",
--     "Neto INTEGER NOT NULL",
--     "IdEmpresa VARCHAR",
--     "Empresa VARCHAR",
--     "IdProducto VARCHAR",
--     "Producto VARCHAR"})

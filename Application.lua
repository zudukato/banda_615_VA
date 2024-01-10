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
AwtxConstants = require("Reqs.awtxReqConstants")
AwtxVariables = require("Reqs.awtxReqVariables")
BrmReqSql = require("Reqs.brmSql")
BrmUtilitis = require("Reqs.brmUtilitis")
require("Reqs.awtxReqScaleKeys")


--------------Setup------------------------
-- Databases
Databases = {}
Databases.pesadas = BrmReqSql:new("pesadas")
Databases.catalogos = BrmReqSql:new("catalogos")
--tables
Databases.catalogos.taras = Databases.catalogos:newTable("taras", {"Id VARCHAR NOT NULL", "Peso INTEGER"})
Databases.catalogos.empresas = Databases.catalogos:newTable("empresas", {"Id VARCHAR NOT NULL", "Empresa VARCHAR NOT NULL"})
Databases.catalogos.productos = Databases.catalogos:newTable("productos", {"Id VARCHAR NOT NULL", "producto VARCHAR NOT NULL"})
Databases.pesadas.primeraPesada = Databases.pesadas:newTable("primeraPesada", {"Folio INTEGER",
    "Placas VARCHAR NOT NULL",
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
------------------- Persistent variables for normal aplication -------------------
--default values
PresistentVars = PresistentVars or {}
PresistentVars.currentMode = {value = "main"}--provitional
PresistentVars.minWt = {value = 200}--min weight
PresistentVars.userPassword = {value = 1793}--user Pasword
PresistentVars.headers = {value = {"header1", "header2"}}-- ticket headers
PresistentVars.ticketNumber = {value = 0}--ticket number
PresistentVars.zeroThreashold = {value = 100}
PresistentVars.zeroTareClear = {value = false}
CurrentMode = require("operationModes.normalWeight.main")

local function onStart()
    -- persistent value asignation recalling last saved value
    -- to acces "persistentVariable.nameOfVariable.value"
    for name, defaultValue in pairs(PresistentVars) do
        PresistentVars[name] = AwtxVariables.SavedVariable(name, defaultValue, true)
    end

end

onStart()

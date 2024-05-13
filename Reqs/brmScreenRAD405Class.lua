---@diagnostic disable: duplicate-set-field

local brmUtilities = require("Reqs.brmUtilities")
local awtxConstants = require("Reqs.awtxReqConstants")
local _names = {}
if not _ScreenRAD405 then
    ---@class screenRad405
    _ScreenRAD405 = {
        ---@type table
        _names = {},
        ---@type string
        screenName = "",
        ---@type table
        screen = {},
        ---@type label
        _label1  = awtx.graphics.label.new("label1"),
        ---@type label
        _label2  = awtx.graphics.label.new("label2"),
        ---@type label
        _label3  = awtx.graphics.label.new("label3"),
        ---@type label
        _segment = nil,
        ---@type string|nil
        segmentText = nil,
        ---@type string
        textLabel1 = "",
        ---@type string
        textLabel2 = "",
        ---@type string
        textLabel3 = "",
    }
    _ScreenRAD405.__index = _ScreenRAD405
    _ScreenRAD405._label1:setLocation(0,0)
    _ScreenRAD405._label2:setLocation(0,6)
    _ScreenRAD405._label3:setLocation(0,11)
    _ScreenRAD405._label1:reSize(40, 5)
    _ScreenRAD405._label2:reSize(40, 5)
    _ScreenRAD405._label3:reSize(40, 5)
end
---Template of a screen for a RAD405
---@param screenName string
---@param textLabel1? string
---@param textLabel2? string
---@param textLabel3? string
---@param segmentText? string|boolean
---@return screenRad405|nil
function _ScreenRAD405:new(screenName,textLabel1,textLabel2,textLabel3,segmentText)
    if type(screenName) ~= "string" then return print("screenName is not a string") end
    if brmUtilities.tableFind(_names,screenName) then return print("screen already exist") end
    local instance = {}
    setmetatable(instance, self)
    instance.screenName = screenName
    if not (type(segmentText) == "string")then 
        instance._segment = awtx.display.getScaleControl()
    else 
        instance.segmentText = segmentText
        instance._segment = awtx.display.getLabelControl()
    end
    instance.textLabel1 = type(textLabel1)=="string" and textLabel1  or ""
    instance.textLabel2 = type(textLabel2)=="string" and textLabel2  or ""
    instance.textLabel3 = type(textLabel3)=="string" and textLabel3  or ""
    instance.screen = awtx.graphics.screens.new(screenName)
    instance.screen:addControl(instance._label1)
    instance.screen:addControl(instance._label2)
    instance.screen:addControl(instance._label3)
    instance.screen:addControl(instance._segment)
    table.insert(_names, screenName)

    return instance
end

---Show the Screen and return before display mode 
---@return number
function _ScreenRAD405:show()
    local beforeMode = awtx.display.setMode(awtxConstants.display.MODE_USER)
    awtx.graphics.clearScreen()
    self._label1:setVisible(true)
    self._label2:setVisible(true)
    self._label3:setVisible(true)

    self._label1:setText(self.textLabel1)
    self._label2:setText(self.textLabel2)
    self._label3:setText(self.textLabel3)
    if type(self.segmentText) == "string" then self._segment:setText(self.segmentText) end
    self.screen:show()
    return beforeMode
end

---clear all the screens 
function _ScreenRAD405:clear()
    self._label1:setVisible(false)
    self._label2:setVisible(false)
    self._label3:setVisible(false)
    awtx.display.setMode(awtxConstants.display.MODE_SCALE)
end

return _ScreenRAD405
local brmUtilities = require("Reqs.brmUtilities")
local awtxConstants = require("Reqs.awtxReqConstants")
local _names = {}
---@class screenRad405
local screenRAD405 = {
    screenName = "",
    screen = {},
    _label1  = awtx.graphics.label.new("label1"),
    _label2  = awtx.graphics.label.new("label2"),
    _label3  = awtx.graphics.label.new("label3"),
    _segment = nil,
    segmentText = "",
    textLabel1 = "",
    textLabel2 = "",
    textLabel3 = "",
}
screenRAD405.__index = screenRAD405
screenRAD405._label1:setLocation(0,0)
screenRAD405._label2:setLocation(0,6)
screenRAD405._label3:setLocation(0,11)
screenRAD405._label1:reSize(40, 5)
screenRAD405._label2:reSize(40, 5)
screenRAD405._label3:reSize(40, 5)

---Template of a screen for a RAD405
---@param screenName string
---@param textLabel1? string
---@param textLabel2? string
---@param textLabel3? string
---@param segmentText? string|boolean
---@return screenRad405|nil
function screenRAD405:new(screenName,textLabel1,textLabel2,textLabel3,segmentText)
    if type(screenName) ~= "string" then return print("screenName is not a string") end
    if brmUtilities.tableFind(_names,screenName) then return print("screen already exist") end
    local instance = {}
    setmetatable(instance, self)
    instance.screenName = screenName
    if not type(segmentText) == "string" then instance._segment = awtx.display.getScaleControl()
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
function screenRAD405:show()
    local beforeMode = awtx.display.setMode(awtxConstants.display.MODE_USER)
    if not self.segmentText then end
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
function screenRAD405:clear()
    self._label1:setVisible(false)
    self._label2:setVisible(false)
    self._label3:setVisible(false)
    awtx.display.setMode(awtxConstants.display.MODE_SCALE)
end

return screenRAD405
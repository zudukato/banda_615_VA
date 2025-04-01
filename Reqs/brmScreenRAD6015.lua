if _ScreenRAD615 then return _ScreenRAD615 end
local brmUtilities = require("Reqs.brmUtilities")
local awtxConstants = require("Reqs.awtxReqConstants")
local maxLabels = 19
local maxButtons = 4

_ScreenRAD615 = {
    _names = {},
    ---@type table<string, _ScreenRAD615.screen>
    screens = {
    },
    ---@type string |nil
    activeScreen = nil,
}
---There is a limit of 20 tags, so reusing them is required
for i = 1, maxLabels do
    local labelName = "_label" .. i
    ---@type awtx.labelCtrl
    _ScreenRAD615[labelName] = awtx.graphics.label.new(labelName)
end

for i = 1, maxButtons do
    local buttonName = "_button"..i
    ---@type awtx.buttonCtrl
    _ScreenRAD615[buttonName] = awtx.graphics.button.new(buttonName)
end


---@class Vector2D
---@field x number
---@field y number

---@class Size
---@field width number
---@field height number



---@class _ScreenRAD615.screen
---@field labels table<string,_ScreenRAD615.screen.component>
---@field buttons table<string,_ScreenRAD615.screen.component>
---@field private _screen awtx.screenCtrl
---@field private _component _ScreenRAD615.screen.component
_ScreenRAD615.screen = {
    labels = {},
    buttons = {}
}
_ScreenRAD615.screen.__index = _ScreenRAD615.screen

---@class _ScreenRAD615.screen.component
---@field name string
---@field text string
---@field location Vector2D
---@field size Size
---@field alignment AlignmentID
---@field fontNumber FontID
---@field visible boolean
---@field _labelOrButton awtx.labelCtrl|awtx.buttonCtrl
local _component = {}
_component.__index = _component

---function to create new screen
---@param name string  --Name of screen
---@param labels? table<_ScreenRAD615.screen.component>
---@param buttons? _ScreenRAD615.screen.component[]
---@param scaleControlNumber? number
---@return _ScreenRAD615.screen?
function _ScreenRAD615.screen:new(name, labels, buttons, scaleControlNumber)
    local instance = {}
    setmetatable(instance, self)
    if table.find(_ScreenRAD615._names, name) then
        print("screen already exist")
        return
    end
    instance.name = name
    instance._screen = awtx.graphics.screens.new(name)
    table.insert(_ScreenRAD615._names, name)
    return instance
end

---Constructor of a label for a screen
---@param name string
---@param text? string
---@param location? Vector2D
---@param size? Size
---@param alignment? AlignmentID
---@param fontNumber? FontID
---@param visible? boolean
function _ScreenRAD615.screen:newLabel(name, text, location, size, alignment, fontNumber, visible)
    local numberOfLabels = table.count(self.labels)
    if numberOfLabels >= 20 then print("MAX LABELS") end
    if type(name) ~= 'string' then return end
    if self.labels[name] ~= nil then print("label already exist") end
    text = text or ""
    location = location or { x = 0, y = 0 }
    size = size or { width = 0, height = 0 }
    alignment = alignment or 0
    fontNumber = fontNumber or 0
    visible = visible or false
    local label = _component:_new(name, text, location, size, alignment, fontNumber, visible)
    label._labelOrButton = _ScreenRAD615["_label" .. numberOfLabels + 1]
    self._screen:addControl(label._labelOrButton)
    self.labels[name] = label
end

---Constructor of a button for a screen
---@param name string
---@param text? string
---@param location? Vector2D
---@param size? Size
---@param alignment? AlignmentID
---@param fontNumber? FontID
---@param visible? boolean
function _ScreenRAD615.screen:newButton(name, text, location, size, alignment, fontNumber, visible)
    local numberOfButtons = table.count(self.labels)
    if numberOfButtons >= 20 then print("MAX buttons") end
    if type(name) ~= 'string' then return end
    if self.buttons[name] ~= nil then print("button already exist") end
    text = text or ""
    location = location or { x = 0, y = 0 }
    size = size or { width = 0, height = 0 }
    alignment = alignment or 0
    fontNumber = fontNumber or 0
    visible = visible or false
    local button = _component:_new(name, text, location, size, alignment, fontNumber, visible)
    button._labelOrButton = _ScreenRAD615["_button" .. numberOfButtons + 1]
    self.buttons[name] = button
end

function _ScreenRAD615.screen:_initScreen()
    for _, label in pairs(self.labels) do
        self:_initComponent(label)
    end
    for _, button in pairs(self.buttons) do
        self:_initComponent(button)
    end
end

---function to init a component
---@param component _ScreenRAD615.screen.component
function _ScreenRAD615.screen:_initComponent(component)
    component._labelOrButton:setText(component.text)
    component._labelOrButton:setLocation(component.location.x, component.location.y)
    component._labelOrButton:reSize(component.size.width, component.size.height)
    component._labelOrButton:setAlignment(component.alignment)
    component._labelOrButton:setFont(component.fontNumber)
    component._labelOrButton:setVisible(component.visible)
end

function _ScreenRAD615.screen:show()
    self:_initScreen()
    self._screen:show()
end

---Constructor of a component for a screen it can be button or label
---@param name string
---@param text string
---@param location Vector2D
---@param size Size
---@param alignment AlignmentID
---@param fontNumber FontID
---@param visible boolean
---@return _ScreenRAD615.screen.component
function _component:_new(name, text, location, size, alignment, fontNumber, visible)
    local instance = {}
    setmetatable(instance,self)
    instance.name = name
    instance.text = text
    instance.location = location
    instance.size = size
    instance.alignment = alignment
    instance.fontNumber = fontNumber
    instance.visible = visible
    return instance
end

---This function sets the size of the component, you need to redraw the screen
---@param newSize Size
function _component:resize(newSize)
    self.size = newSize
    if self._labelOrButton then self._labelOrButton:reSize(newSize.width, newSize.height) end
end

---This function sets the alignment of the component, you need to redraw the screen
---@param alignment AlignmentID
function _component:setAlignment(alignment)
    self.alignment = alignment
    if self._labelOrButton then self._labelOrButton:setAlignment(alignment) end
end

---This function sets the font of the component, you need to redraw the screen
---@param fontNumber FontID
function _component:setFont(fontNumber)
    self.fontNumber = fontNumber
    if self._labelOrButton then self._labelOrButton:setFont(fontNumber) end
end

---This function sets the location of the component, you need to redraw the screen
---@param location Vector2D
function _component:setLocation(location)
    self.location = location
    if self._labelOrButton then self._labelOrButton:setLocation(location.x, location.y) end
end

---This function sets the text of component, you need to redraw the screen
---@param text string
function _component:setText(text)
    self.text = text
    if self._labelOrButton then self._labelOrButton:setText(text) end
end

---This function sets the visibility of the component, you need to redraw the screen
---@param visible boolean
function _component:setVisible(visible)
    self.visible = visible
    if self._labelOrButton then self._labelOrButton:setVisible(visible) end
end

---To execute function of labelCtrl or buttonCtrl
---@param labelOrButton awtx.labelCtrl|awtx.buttonCtrl
function _component:setLabelOrButton(labelOrButton)
    self._labelOrButton = labelOrButton
end

-- ---Template of a screen for a RAD405
-- ---@param screenName string
-- ---@param textLabel1? string
-- ---@param textLabel2? string
-- ---@param textLabel3? string
-- ---@param segmentText? string|boolean
-- ---@return screenRad615|nil
-- function _ScreenRAD615:new(screenName, textLabel1, textLabel2, textLabel3, segmentText)
--     if type(screenName) ~= "string" then return print("screenName is not a string") end
--     if brmUtilities.tableFind(_names, screenName) then return print("screen already exist") end
--     local instance = {}
--     setmetatable(instance, self)
--     instance.screenName = screenName
--     if not (type(segmentText) == "string") then
--         instance._segment = awtx.display.getScaleControl()
--     else
--         instance.segmentText = segmentText
--         instance._segment = awtx.display.getLabelControl()
--     end
--     instance.textLabel1 = type(textLabel1) == "string" and textLabel1 or ""
--     instance.textLabel2 = type(textLabel2) == "string" and textLabel2 or ""
--     instance.textLabel3 = type(textLabel3) == "string" and textLabel3 or ""
--     instance.screen = awtx.graphics.screens.new(screenName)
--     instance.screen:addControl(instance._label1)
--     instance.screen:addControl(instance._label2)
--     instance.screen:addControl(instance._label3)
--     instance.screen:addControl(instance._segment)
--     table.insert(_names, screenName)

--     return instance
-- end

-- ---Show the Screen and return before display mode
-- ---@return number
-- function _ScreenRAD405:show()
--     local beforeMode = awtx.display.setMode(awtxConstants.display.MODE_USER)
--     awtx.graphics.clearScreen()
--     self._label1:setVisible(true)
--     self._label2:setVisible(true)
--     self._label3:setVisible(true)

--     self._label1:setText(self.textLabel1)
--     self._label2:setText(self.textLabel2)
--     self._label3:setText(self.textLabel3)
--     if type(self.segmentText) == "string" then self._segment:setText(self.segmentText) end
--     self.screen:show()
--     _ActiveScreen = self
--     return beforeMode
-- end

-- ---clear all the screens
-- function _ScreenRAD405:clear()
--     self._label1:setVisible(false)
--     self._label2:setVisible(false)
--     self._label3:setVisible(false)
--     _ActiveScreen = nil
--     awtx.display.setMode(awtxConstants.display.MODE_SCALE)
-- end

return _ScreenRAD615

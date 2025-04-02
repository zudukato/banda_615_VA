---# ScreenRAD615
---A dynamic and reusable screen builder for RAD615 displays using preallocated label and button controls.
---
---This module handles creation, configuration, and management of multiple screens and their UI components
---(labels and buttons), ensuring reuse of a limited pool of AWTX controls (69 labels and 14 buttons).
---
---## Features:
--- - Create screens dynamically by name
--- - Add labeled UI components with full configuration
--- - Share a limited pool of controls between screens
--- - Helper methods for resizing, positioning, text, visibility, font, and alignment
---
---## Usage Example:
---```lua
---local myScreen = _ScreenRAD615.screen:new("MainScreen")
---myScreen:newLabel("greeting", "Hello!", {x = 10, y = 5}, {width = 50, height = 10})
---myScreen:show()
---```
---
---## Limitations:
--- - Maximum 69 label controls and 12 button controls
--- - Components must be uniquely named within each screen
--- - Components must be reinitialized before displaying
---
---## Component Classes:
--- - `_ScreenRAD615.screen`: represents a screen with its UI elements
--- - `_ScreenRAD615.screen.component`: defines a visual UI element (label or button)
---
---## Dependencies:
--- - `awtx.graphics.label`, `awtx.graphics.button`, `awtx.graphics.screens`
--- - `awtx.display`, `awtxConstants`, `brmUtilities`

if _ScreenRAD615 then return _ScreenRAD615 end
local brmUtilities = require("Reqs.brmUtilities")
local awtxConstants = require("Reqs.awtxReqConstants")
local maxLabels = 69
local maxButtons = 14
local maxBitmaps = 11

---@class _ScreenRAD615
---@field screens table<string, _ScreenRAD615.screen>
---@field activeScreen string |nil
---@field private _labels awtx.labelCtrl[]
---@field private _buttons awtx.buttonCtrl[]
---@field private _pictureboxes awtx.pictureboxCtrl[]
_ScreenRAD615 = {
    screens = {
    },
    activeScreen = nil,
    _labels ={},
    _buttons = {},
    _pictureboxes = {}
}

 ---@private
 ---Retrieves or creates a label from the internal _labels list by index.
---If the label already exists, it is returned. If not and the index is within allowed limits, a new label is created.
---This function ensures safe and lazy initialization of labels, avoiding out-of-bounds errors.
---
---@param index integer                 -- Index of the label to retrieve or create
---@return awtx.labelCtrl|nil                   -- The label at the given index, or nil if the index exceeds maxLabels
_ScreenRAD615._getAwtxLabel = function (index)
    local totalLabels = #_ScreenRAD615._labels
    if index <= totalLabels then return _ScreenRAD615._labels[index] end
    if index > totalLabels+1  then print("index error") return end
    if index > maxLabels then print("max labels") return end
    _ScreenRAD615._labels[totalLabels+1]  = awtx.graphics.label.new("label"..totalLabels)
    return _ScreenRAD615._labels[totalLabels+1]
end

_ScreenRAD615._getAwtxButtons = function (index)
    local totalButtons = #_ScreenRAD615._buttons
    if index <= totalButtons then return _ScreenRAD615._buttons[index] end
    if index > totalButtons+1  then print("index error") return end
    if index > maxButtons then print("max button") return end
    _ScreenRAD615._buttons[totalButtons+1]  = awtx.graphics.button.new("button"..totalButtons)
    return _ScreenRAD615._buttons[totalButtons+1]
end

_ScreenRAD615._getAwtxPicturebox = function ()

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
local screen = {
    labels = {},
    buttons = {}
}
screen.__index = screen

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

---Creates a new screen instance with a unique name.
---Registers the screen in the internal `_names` table and initializes its graphics control.
---
---@param name string                          -- Unique name for the screen
---@param labels? table<_ScreenRAD615.screen.component> -- Optional label components to preload
---@param buttons? _ScreenRAD615.screen.component[]     -- Optional button components to preload
---@param scaleControlNumber? number          -- Optional scale control parameter (reserved)
---@return _ScreenRAD615.screen?              -- Returns the screen instance or nil if name already exists
function _ScreenRAD615.newScreen(name, labels, buttons, scaleControlNumber)
    local instance = {}
    setmetatable(instance, screen)
    if _ScreenRAD615.screens[name] ~= nil then
        print("screen already exist")
        return
    end
    instance.name = name
    instance._screen = awtx.graphics.screens.new(name)
    _ScreenRAD615.screens[name] = instance
    return instance
end

---Prepares and returns a complete set of component parameters with default values.
---This helper function ensures all component fields are safely initialized, even if not provided.
---
---Useful for avoiding repeated default handling logic in component constructors.
---
---@param name string                 -- Name of the component (must be unique per screen)
---@param text? string               -- Optional display text (default: "")
---@param location? Vector2D        -- Optional screen position (default: { x = 0, y = 0 })
---@param size? Size                -- Optional size of the component (default: { width = 0, height = 0 })
---@param alignment? AlignmentID    -- Optional text alignment (default: 0)
---@param fontNumber? FontID        -- Optional font number (default: 0)
---@param visible? boolean          -- Optional visibility state (default: false)
---@return table                    -- Table containing all initialized component parameters
local function prepareComponentParams(name, text, location, size, alignment, fontNumber, visible)
    return {
        name = name,
        text = text or "",
        location = location or { x = 0, y = 0 },
        size = size or { width = 0, height = 0 },
        alignment = alignment or 0,
        fontNumber = fontNumber or 0,
        visible = visible or false
    }
end

---Creates and adds a new label to the screen.
---Uses a pooled label control from a fixed pool (max 69). Fails silently if name is duplicate or pool exhausted.
---
---Access the label later via: `screenInstance.labels["labelName"]` or `screenInstance.labels.labelName`
---
---@param name string             -- Unique identifier for the label
---@param text? string            -- Optional label text
---@param location? Vector2D      -- Optional location (default: {x = 0, y = 0})
---@param size? Size              -- Optional size (default: {width = 0, height = 0})
---@param alignment? AlignmentID  -- Optional alignment (default: 0)
---@param fontNumber? FontID      -- Optional font number (default: 0)
---@param visible? boolean        -- Optional visibility (default: false)
function screen:newLabel(name, text, location, size, alignment, fontNumber, visible)
    local numberOfLabels = table.count(self.labels)
    if numberOfLabels >= maxLabels then print("MAX LABELS") return end
    if type(name) ~= 'string' then print("name should be a string")return end
    if self.labels[name] ~= nil then print("label already exist") return end
    local params = prepareComponentParams(name, text, location, size, alignment, fontNumber, visible)
    local label = _component:_new(
        params.name,
        params.text,
        params.location,
        params.size,
        params.alignment,
        params.fontNumber,
        params.visible
    )
    local awtxLabel = _ScreenRAD615._getAwtxLabel(numberOfLabels+1)
    if awtxLabel == nil then return end
    label._labelOrButton = awtxLabel
    self._screen:addControl(label._labelOrButton)
    self.labels[name] = label
end

---Creates and adds a new button to the screen.
---Uses a pooled button control from a fixed pool (max 14). Fails silently if name is duplicate or pool exhausted.
---
---Access the button later via: `screenInstance.buttons["buttonName"]` or screenInstance.buttons.buttonName
---
---@param name string             -- Unique identifier for the button
---@param text? string            -- Optional button text
---@param location? Vector2D      -- Optional location (default: {x = 0, y = 0})
---@param size? Size              -- Optional size (default: {width = 0, height = 0})
---@param alignment? AlignmentID  -- Optional alignment (default: 0)
---@param fontNumber? FontID      -- Optional font number (default: 0)
---@param visible? boolean        -- Optional visibility (default: false)
function screen:newButton(name, text, location, size, alignment, fontNumber, visible)
    local numberOfButtons = table.count(self.buttons)
    if numberOfButtons >= maxButtons then print("MAX BUTTONS") return end
    if type(name) ~= 'string' then return end
    if self.buttons[name] ~= nil then print("button already exist") return end
    local params = prepareComponentParams(name, text, location, size, alignment, fontNumber, visible)
    local button = _component:_new(
        params.name,
        params.text,
        params.location,
        params.size,
        params.alignment,
        params.fontNumber,
        params.visible
    )
 
    local awtxButton = _ScreenRAD615._getAwtxButtons(numberOfButtons+1)
    if awtxButton == nil then return end
    button._labelOrButton = awtxButton
    self.buttons[name] = button
end
---Initializes and applies properties to all label and button components of the screen.
function screen:_initScreen()
    for _, label in pairs(self.labels) do
        self:_initComponent(label)
    end
    for _, button in pairs(self.buttons) do
        self:_initComponent(button)
    end
end

---Applies properties to a label or button (text, location, size, font, visibility, etc.).
---Used internally during screen initialization.
---@param component _ScreenRAD615.screen.component  -- Component to apply properties to
function screen:_initComponent(component)
    component._labelOrButton:setText(component.text)
    component._labelOrButton:setLocation(component.location.x, component.location.y)
    component._labelOrButton:reSize(component.size.width, component.size.height)
    component._labelOrButton:setAlignment(component.alignment)
    component._labelOrButton:setFont(component.fontNumber)
    component._labelOrButton:setVisible(component.visible)
end
---Displays the screen and initializes all components.
---Should be called after adding labels/buttons.
function screen:show()
    self:_initScreen()
    self._screen:show()
end

---Creates a new component instance (label or button) with given properties.
---
---@param name string             -- Component name
---@param text string             -- Displayed text
---@param location Vector2D       -- Location on screen
---@param size Size               -- Size of the component
---@param alignment AlignmentID   -- Text alignment
---@param fontNumber FontID       -- Font number
---@param visible boolean         -- Whether the component is visible
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
function _component:reSize(newSize)
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

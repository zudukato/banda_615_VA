---@diagnostic disable: invisible
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
local BrmPicturebox = require("Reqs.RAD615Screen.brmPictureBox")
local BrmComponent = require("Reqs.RAD615Screen.brmComponent")
local BrmScreenScale = require "Reqs.RAD615Screen.brmScreenScale"
local maxLabels = 69
local maxButtons = 14
local maxPictureboxes = 11
local maxTextboxes = 10
local maxScales = 10
local numericFirmwareVersion = brmUtilities.getNumericFirmwareVersion()

---@class _ScreenRAD615
---@field screens table<string, _ScreenRAD615.screen>
---@field activeScreen string |nil
---@field private _labels awtx.labelCtrl[]
---@field private _buttons awtx.buttonCtrl[]
---@field private _pictureboxes awtx.pictureboxCtrl[]
---@field private _scales awtx.scaleCtrl[]
_ScreenRAD615 = {
    screens = {
    },
    activeScreen = nil,
    _labels = {},
    _buttons = {},
    _pictureboxes = {},
    _textboxes = {},
    _scales = {}
}

---@class Vector2D
---@field x number
---@field y number

---@class Size
---@field width number
---@field height number

------------------Screen------------------------------------
---@class _ScreenRAD615.screen
---@field labels table<string,_ScreenRAD615.screen.component>
---@field buttons table<string,_ScreenRAD615.screen.component>
---@field pictureboxes table<string, _ScreenRAD615.screen.picturebox>
---@field textboxes table<string,_ScreenRAD615.screen.component>
---@field scales table<string,_ScreenRAD615.screen.scale>
---@field private _screen awtx.screenCtrl
local Screen = {
}
Screen.__index = Screen

---Generic get awtxComponent
---@param type string -- Type of control
---@param pool table -- The internal storage table (e.g., _ScreenRAD615._labels)
---@param maxCount integer -- Maximum allowed items
---@param creatorFn fun(id: string, ...): any Control constructor (should return the created control)
---@param index integer Index to retrieve or create
---@param ...  any Additional arguments passed to the creator function
---@return any|nil
local _getAwtxControl = function(type, pool, maxCount, creatorFn, index, ...)
    local totalControls = #pool
    if index <= totalControls then return pool[index] end
    if index > totalControls + 1 then
        print("index error")
        return
    end
    if index > maxCount then
        print("max limit reached")
        return
    end
    local currentCount = totalControls + 1
    local control = creatorFn(type .. currentCount, ...)
    pool[currentCount] = control
    return control
end


---Retrieves or creates a label from the internal _labels list by index.
---If the label already exists, it is returned. If not and the index is within allowed limits, a new label is created.
---This function ensures safe and lazy initialization of labels, avoiding out-of-bounds errors.
---
---@param index integer                 -- Index of the label to retrieve or create
---@return awtx.labelCtrl|nil                   -- The label at the given index, or nil if the index exceeds maxLabels
local _getAwtxLabel = function(index)
    return _getAwtxControl("label", _ScreenRAD615._labels, maxLabels, awtx.graphics.label.new, index)
end

---Retrieves or creates a pooled button control based on index.
---Ensures buttons are reused from a preallocated pool of max 14 items.
---
---@param index integer                     -- Index of the button (1-based)
---@return awtx.buttonCtrl|nil             -- A button control instance or nil if out of bounds
local _getAwtxButtons = function(index)
    return _getAwtxControl("button", _ScreenRAD615._buttons, maxButtons, awtx.graphics.button.new, index)
end

---Retrieves or creates a pooled button control based on index.
---Ensures buttons are reused from a preallocated pool of max 14 items.
---
---@param index integer                     -- Index of the button (1-based)
---@return awtx.buttonCtrl|nil             -- A button control instance or nil if out of bounds
local _getAwtxTextbox = function(index)
    return _getAwtxControl("textbox", _ScreenRAD615._textboxes, maxTextboxes, awtx.graphics.textbox.new, index)
end


local _getAwtxScales = function(index, scaleNumber, style)
    return _getAwtxControl("scale", _ScreenRAD615._scales, maxScales, awtx.graphics.scale.new, index, scaleNumber, style)
end

---Retrieves or creates a pooled picturebox control based on index.
---
---## Important:
--- - Conditionally enables `setBitmap()` support based on firmware version (`>= 2.5.0.0`).
--- - On firmware versions **below** 2.5.0.0:
---   - `setBitmap()` is **not available**
---   - Only **10 pictureboxes** can be used in total.
---
---@param index integer                     -- Index of the picturebox (1-based)
---@param path string                       -- File path for the bitmap image
---@return awtx.pictureboxCtrl|nil         -- A picturebox control or nil if out of bounds or unsupported
local _getAwtxPicturebox = function(index, path)
    return _getAwtxControl("picturebox", _ScreenRAD615._pictureboxes, maxPictureboxes, awtx.graphics.picturebox.new,
        index, path)
end


---Creates a new screen instance with a unique name.
---
---@param name string                          -- Unique name for the screen
---@return _ScreenRAD615.screen?              -- Returns the screen instance or nil if name already exists
_ScreenRAD615.newScreen = function(name)
    if _ScreenRAD615.screens[name] then return end
    local screenInstance = Screen:new(name)
    _ScreenRAD615.screens[name] = screenInstance
    return _ScreenRAD615.screens[name]
end

---Internal screen constructor. Called by `newScreen`.
---@param name string                          -- Unique name for the screen
---@return _ScreenRAD615.screen?              -- Returns the screen instance or nil if name already exists
---@private
function Screen:new(name)
    local instance = {}
    setmetatable(instance, self)
    instance.labels = {}
    instance.buttons = {}
    instance.textboxes = {}
    instance.pictureboxes = {}
    instance.scales = {}
    if _ScreenRAD615.screens[name] ~= nil then
        print("screen already exist")
        return
    end
    instance.name = name
    instance._screen = awtx.graphics.screens.new(name)
    return instance
end

---@alias ComponentMap
---| "label"
---| "button"
---| "textbox"
local componentMap = {
    label = { pool = "labels", creator = _getAwtxLabel },
    button = { pool = "buttons", creator = _getAwtxButtons },
    textbox = { pool = "textboxes", creator = _getAwtxTextbox },
    -- future: scale, slider, etc.
}
---Generic function to create and add a reusable UI component to the screen.
---Used for labels, buttons, and textboxes (components backed by BrmComponent and pooled AWTX controls).
---@param componentType ComponentMap       -- type of component label, button or textbox
---@param name string             -- Unique identifier for the label
---@param text? string            -- Optional label text
---@param location? Vector2D      -- Optional location (default: {x = 0, y = 0})
---@param size? Size              -- Optional size (default: {width = 0, height = 0})
---@param alignment? AlignmentID  -- Optional alignment (default: 0)
---@param fontNumber? FontID      -- Optional font number (default: 0)
---@param visible? boolean        -- Optional visibility (default: false)
---@param inverted? boolean        -- Optional visibility (default: false)
---@private
function Screen:_newComponent(componentType, name, text, location, size, alignment, fontNumber, visible, inverted)
    local def = componentMap[componentType]
    if not def then
        print("Unknown component type: " .. tostring(componentType))
        return
    end
    local pool = self[def.pool]
    if type(name) ~= 'string' then
        print("name should be a string")
        return
    end
    if pool[name] ~= nil then
        print("component already exist")
        return
    end
    local component = BrmComponent:_new(name, text, location, size, alignment, fontNumber, visible, inverted)
    local awtxComponent = def.creator(table.count(pool) + 1)
    if not awtxComponent then return end
    component:setAwtxComponent(awtxComponent)
    self._screen:addControl(component._awtxComponent)
    pool[name] = component
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
---@param inverted? boolean        -- Optional (default: false)
function Screen:newLabel(name, text, location, size, alignment, fontNumber, visible, inverted)
    self:_newComponent("label", name, text, location, size, alignment, fontNumber, visible, inverted)
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
---@param inverted? boolean        -- Optional visibility (default: false)
function Screen:newButton(name, text, location, size, alignment, fontNumber, visible, inverted)
    self:_newComponent("button", name, text, location, size, alignment, fontNumber, visible, inverted)
end

function Screen:newTextbox(name, text, location, size, alignment, fontNumber, visible)
    self:_newComponent("textbox", name, text, location, size, alignment, fontNumber, visible)
end

---Creates and adds a new picturebox (image) to the screen.
---Uses a pooled picturebox control from a fixed pool (max 11). Fails silently if the name is duplicated or pool is exhausted.
---
---Access the picturebox later via: `screenInstance.pictureboxes["picName"]` or `screenInstance.pictureboxes.picName`.
---
---## Important:
--- - Conditionally enables `setBitmap()` support based on firmware version (`>= 2.5.0.0`).
--- - On firmware versions **below** 2.5.0.0:
---   - `setBitmap()` is **not available**
---   - Only **10 pictureboxes** can be used in total for all screens
---
---## Notes:
--- - Pictureboxes are loaded by path and are positioned using a `Vector2D`.
--- - If the picturebox with the given name already exists, no new one is created.
--- - The `visible` parameter defaults to `true` if not explicitly provided.
---
---@param name string              -- Unique identifier for the picturebox
---@param path string              -- File path or resource ID for the image
---@param location? Vector2D       -- Optional location (default: `{x = 0, y = 0}`)
---@param visible? boolean         -- Optional visibility flag (default: `true`)
function Screen:newPicturebox(name, path, location, visible)
    if type(name) ~= "string" then
        print("Name should be a string")
        return
    end
    if type(path) ~= "string" then
        print("Path should be a string")
        return
    end
    if self.pictureboxes[name] then
        print("Picturebox already exist")
        return
    end
    local numberOfPictureboxes = table.count(self.pictureboxes)
    local brmPicturebox = BrmPicturebox:new(name, path, location, visible)
    local awtxPicturebox = _getAwtxPicturebox(numberOfPictureboxes + 1, path)
    if not awtxPicturebox then return end
    brmPicturebox:setAwtxPicturebox(awtxPicturebox)
    self._screen:addControl(awtxPicturebox)
    self.pictureboxes[name] = brmPicturebox
end

---Creates and adds a new scale control to the screen.
---
---This function initializes a reusable scale component (`BrmScreenScale`) and binds it to a pooled
---AWTX scale control. It then adds the AWTX control to the internal screen instance for display.
---Each scale is uniquely identified by its `name` and stored in `screen.scales[name]`.
---
---### Notes:
---- Only a limited number of pooled scales are available (typically max 10).
---- If the name already exists or the pool is exhausted, the function fails silently.
---
---### Example:
---```lua
---screen:newScale("mainScale", 0, 1, {x = 0, y = 20}, true, -1)
---```
---
---@param name string                     Unique identifier for the scale
---@param scaleNumber? integer            Scale number (0 = active; 1-4 = specific scale index)
---@param scaleStyle? ScaleStyle          Visual style of the scale (1 = large, 2 = medium, etc.)
---@param location? Vector2D              Optional screen location `{x, y}`; default is `{0,0}`
---@param visible? boolean                Whether the scale should be initially visible
---@param activeValue? ActiveValueScale   Optional active value (e.g. Net/Gross); default is `-1`
function Screen:newScale(name, scaleNumber, scaleStyle, location, visible,activeValue)
    if type(name) ~= "string" then
        print("Name should be a string")
        return
    end
    if self.scales[name] then
        print("Scale already exist")
        return
    end
    local numberOfScales = table.count(self.scales)
    local brmScreenScale = BrmScreenScale:new(name,scaleNumber,scaleStyle,location,visible,activeValue)
    local awtxScreenScale = _getAwtxScales(numberOfScales+1,brmScreenScale.scaleNumber, brmScreenScale.scaleStyle)
    if not awtxScreenScale then return end
    brmScreenScale:setAwtxScale(awtxScreenScale)
    self._screen:addControl(awtxScreenScale)
    self.scales[name] = brmScreenScale
end

---Initializes and applies properties to all label and button components of the screen.
---@private
function Screen:_initScreen(visible)
    local componentsList = {self.labels, self.buttons,self.pictureboxes, self.textboxes, self.scales}
    for _,components in pairs(componentsList) do
        for _,component in pairs(components) do
            if visible then
                pcall(component.setVisible, component)
            else
                component:_init()
            end
        end
    end
end

---Displays the screen and initializes all components.
---Should be called after adding labels/buttons.
function Screen:show()
    self:_initScreen()
    self._screen:show()
    self:_initScreen(true)
end

return _ScreenRAD615

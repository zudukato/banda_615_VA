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
    _textboxes = {}
}

---Retrieves or creates a label from the internal _labels list by index.
---If the label already exists, it is returned. If not and the index is within allowed limits, a new label is created.
---This function ensures safe and lazy initialization of labels, avoiding out-of-bounds errors.
---
---@param index integer                 -- Index of the label to retrieve or create
---@return awtx.labelCtrl|nil                   -- The label at the given index, or nil if the index exceeds maxLabels
---@private
local _getAwtxLabel = function(index)
    local totalLabels = #_ScreenRAD615._labels
    if index <= totalLabels then return _ScreenRAD615._labels[index] end
    if index > totalLabels + 1 then
        print("index error")
        return
    end
    if index > maxLabels then
        print("max labels")
        return
    end
    _ScreenRAD615._labels[totalLabels + 1] = awtx.graphics.label.new("label" .. totalLabels)
    return _ScreenRAD615._labels[totalLabels + 1]
end

---Retrieves or creates a pooled button control based on index.
---Ensures buttons are reused from a preallocated pool of max 14 items.
---
---@param index integer                     -- Index of the button (1-based)
---@return awtx.buttonCtrl|nil             -- A button control instance or nil if out of bounds
---@private
local _getAwtxButtons = function(index)
    local totalButtons = #_ScreenRAD615._buttons
    if index <= totalButtons then return _ScreenRAD615._buttons[index] end
    if index > totalButtons + 1 then
        print("index error")
        return
    end
    if index > maxButtons then
        print("max button")
        return
    end
    _ScreenRAD615._buttons[totalButtons + 1] = awtx.graphics.button.new("button" .. totalButtons)
    return _ScreenRAD615._buttons[totalButtons + 1]
end

---Retrieves or creates a pooled button control based on index.
---Ensures buttons are reused from a preallocated pool of max 14 items.
---
---@param index integer                     -- Index of the button (1-based)
---@return awtx.buttonCtrl|nil             -- A button control instance or nil if out of bounds
---@private
local _getAwtxTextbox = function(index)
    local totalTextboxes = #_ScreenRAD615._textboxes
    if index <= totalTextboxes then return _ScreenRAD615._textboxes[index] end
    if index > totalTextboxes + 1 then
        print("index error")
        return
    end
    if index > maxTextboxes then
        print("max textboxes")
        return
    end
    _ScreenRAD615._textboxes[totalTextboxes + 1] = awtx.graphics.textbox.new("textbox" .. totalTextboxes)
    return _ScreenRAD615._textboxes[totalTextboxes + 1]
end

local _getAwtxScales = function (index, scaleNumber, style)
    local totalScales = #_ScreenRAD615._scales
    if index <= totalScales then return _ScreenRAD615._scales[index] end
    if index > totalScales + 1 then
        print("index error")
        return
    end
    if index > maxScales then
        print("max scales")
        return
    end
    _ScreenRAD615._scales[totalScales + 1] = awtx.graphics.scale.new("scale" .. totalScales, scaleNumber, style)
    return _ScreenRAD615._scales[totalScales + 1]
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
---@private
local _getAwtxPicturebox = function(index, path)
    local totalPictureboxes = #_ScreenRAD615._pictureboxes
    if numericFirmwareVersion >= 2500 then
        if index <= totalPictureboxes then return _ScreenRAD615._pictureboxes[index] end
        if index > totalPictureboxes + 1 then
            print("index error")
            return
        end
    end
    if totalPictureboxes >= maxPictureboxes then
        print("max pictureboxes")
        return
    end
    _ScreenRAD615._pictureboxes[totalPictureboxes + 1] = awtx.graphics.picturebox.new("picturebox" .. totalPictureboxes,
        path)
    return _ScreenRAD615._pictureboxes[totalPictureboxes + 1]
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
---@field private _screen awtx.screenCtrl
local Screen = {
}
Screen.__index = Screen

---Creates a new screen instance with a unique name.
---
---@param name string                          -- Unique name for the screen
---@param labels? table<_ScreenRAD615.screen.component> -- Optional label components to preload
---@param buttons? _ScreenRAD615.screen.component[]     -- Optional button components to preload
---@param scaleControlNumber? number          -- Optional scale control parameter (reserved)
---@return _ScreenRAD615.screen?              -- Returns the screen instance or nil if name already exists
_ScreenRAD615.newScreen = function(name, labels, buttons, scaleControlNumber)
    if _ScreenRAD615.screens[name] then return end
    local screenInstance = Screen:new(name, labels, buttons, scaleControlNumber)
    _ScreenRAD615.screens[name] = screenInstance
    return _ScreenRAD615.screens[name]
end

---Internal screen constructor. Called by `newScreen`.
---
---@param name string                          -- Unique name for the screen
---@param labels? table<_ScreenRAD615.screen.component> -- Optional label components to preload
---@param buttons? _ScreenRAD615.screen.component[]     -- Optional button components to preload
---@param scaleControlNumber? number          -- Optional scale control parameter (reserved)
---@return _ScreenRAD615.screen?              -- Returns the screen instance or nil if name already exists
function Screen:new(name, labels, buttons, scaleControlNumber)
    local instance = {}
    setmetatable(instance, self)
    instance.labels = {}
    instance.buttons = {}
    instance.textboxes = {}
    instance.pictureboxes = {}
    if _ScreenRAD615.screens[name] ~= nil then
        print("screen already exist")
        return
    end
    instance.name = name
    instance._screen = awtx.graphics.screens.new(name)
    return instance
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
function Screen:newLabel(name, text, location, size, alignment, fontNumber, visible)
    local numberOfLabels = table.count(self.labels)
    if numberOfLabels >= maxLabels then
        print("MAX LABELS")
        return
    end
    if type(name) ~= 'string' then
        print("name should be a string")
        return
    end
    if self.labels[name] ~= nil then
        print("label already exist")
        return
    end
    local params = prepareComponentParams(name, text, location, size, alignment, fontNumber, visible)
    local label = Component:_new(
        params.name,
        params.text,
        params.location,
        params.size,
        params.alignment,
        params.fontNumber,
        params.visible
    )
    local awtxLabel = _getAwtxLabel(numberOfLabels + 1)
    if not awtxLabel then return end
    label._awtxComponent = awtxLabel
    self._screen:addControl(label._awtxComponent)
    self.labels[name] = label
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
    if numberOfPictureboxes >= maxPictureboxes then
        print("Max pictureboxes")
        return
    end
    -- if self.pictureboxes
    location = location or { x = 0, y = 0 }
    visible = visible or true
    local BrmPicturebox = BrmPicturebox:new(name, path, location, visible)
    local awtxPicturebox = _getAwtxPicturebox(numberOfPictureboxes + 1, path)
    if not awtxPicturebox then return end
    BrmPicturebox._awtxPicturebox = awtxPicturebox
    self._screen:addControl(awtxPicturebox)
    self.pictureboxes[name] = BrmPicturebox
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
function Screen:newButton(name, text, location, size, alignment, fontNumber, visible)
    local numberOfButtons = table.count(self.buttons)
    if numberOfButtons >= maxButtons then
        print("MAX BUTTONS")
        return
    end
    if type(name) ~= 'string' then return end
    if self.buttons[name] ~= nil then
        print("button already exist")
        return
    end
    local params = prepareComponentParams(name, text, location, size, alignment, fontNumber, visible)
    local button = Component:_new(
        params.name,
        params.text,
        params.location,
        params.size,
        params.alignment,
        params.fontNumber,
        params.visible
    )

    local awtxButton = _getAwtxButtons(numberOfButtons + 1)
    if not awtxButton then return end
    button._awtxComponent = awtxButton
    self.buttons[name] = button
end

function Screen:newTextbox(name, text, location, size, alignment, fontNumber, visible)
    local numberOfTextbox = table.count(self.textboxes)
    if numberOfTextbox >= maxTextboxes then print("Max Textboxes") return end
    if type(name) ~= 'string' then
        print("Name should be a string")
        return
    end
    if self.textboxes[name] then
        print("Textbox already exist")
        return
    end
    local params = prepareComponentParams(name, text, location, size, alignment, fontNumber, visible)
    local textbox = Component:_new(
        params.name,
        params.text,
        params.location,
        params.size,
        params.alignment,
        params.fontNumber,
        params.visible
    )
    local awtxTextbox = _getAwtxTextbox(numberOfTextbox+1)
    if not awtxTextbox then return end
    textbox._awtxComponent = awtxTextbox
end

function Screen:newScale()
end

---Initializes and applies properties to all label and button components of the screen.
---@private
function Screen:_initScreen()
    for _, label in pairs(self.labels) do
        label:_init()
    end
    for _, button in pairs(self.buttons) do
        button:_init()
    end
    for _, brmPicturebox in pairs(self.pictureboxes) do
        brmPicturebox:_init()
    end
    for _,textbox in pairs(self.textboxes) do
        textbox:_init()
    end
end


---Displays the screen and initializes all components.
---Should be called after adding labels/buttons.
function Screen:show()
    self:_initScreen()
    self._screen:show()
end
----------------------------------Components---------------------------------

---@class _ScreenRAD615.screen.component
---@field name string
---@field text string
---@field location Vector2D
---@field size Size
---@field alignment AlignmentID
---@field fontNumber FontID
---@field visible boolean
---@field private _awtxComponent awtx.labelCtrl|awtx.buttonCtrl
local Component = {}
Component.__index = Component
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
---@private
function Component:_new(name, text, location, size, alignment, fontNumber, visible)
    local instance = {}
    setmetatable(instance, self)
    instance.name = name
    instance.text = text
    instance.location = location
    instance.size = size
    instance.alignment = alignment
    instance.fontNumber = fontNumber
    instance.visible = visible
    return instance
end

function Component:_init()
    self._awtxComponent:setText(self.text)
    self._awtxComponent:setLocation(self.location.x, self.location.y)
    self._awtxComponent:reSize(self.size.width, self.size.height)
    self._awtxComponent:setAlignment(self.alignment)
    self._awtxComponent:setFont(self.fontNumber)
    self._awtxComponent:setVisible(self.visible)
end

---This function sets the size of the component, you need to redraw the screen
---@param newSize Size
function Component:reSize(newSize)
    self.size = newSize
    if self._awtxComponent then self._awtxComponent:reSize(newSize.width, newSize.height) end
end

---This function sets the alignment of the component, you need to redraw the screen
---@param alignment AlignmentID
function Component:setAlignment(alignment)
    self.alignment = alignment
    if self._awtxComponent then self._awtxComponent:setAlignment(alignment) end
end

---This function sets the font of the component, you need to redraw the screen
---@param fontNumber FontID
function Component:setFont(fontNumber)
    self.fontNumber = fontNumber
    if self._awtxComponent then self._awtxComponent:setFont(fontNumber) end
end

---This function sets the location of the component, you need to redraw the screen
---@param location Vector2D
function Component:setLocation(location)
    self.location = location
    if self._awtxComponent then self._awtxComponent:setLocation(location.x, location.y) end
end

---This function sets the text of component, you need to redraw the screen
---@param text string
function Component:setText(text)
    self.text = text
    if self._awtxComponent then self._awtxComponent:setText(text) end
end

---This function sets the visibility of the component, you need to redraw the screen
---@param visible boolean
function Component:setVisible(visible)
    self.visible = visible
    if self._awtxComponent then self._awtxComponent:setVisible(visible) end
end
-----------------------------Pictureboxes-----------------------------
---@class _ScreenRAD615.screen.picturebox
---@field name string
---@field path string
---@field location Vector2D
---@field visible boolean
---@field private _awtxPicturebox awtx.pictureboxCtrl
local BrmPicturebox = {}
BrmPicturebox.__index = BrmPicturebox

function BrmPicturebox:new(name, path, location, visible)
    local instance = {}
    setmetatable(instance, self)
    instance.name = name
    instance.path = path
    instance.location = location or { x = 0, y = 0 }
    instance.visible = visible
    return instance
end

function BrmPicturebox:_init()
    if numericFirmwareVersion == 2500 then
        self._awtxPicturebox:setBitmap(self.path)
    end
    self._awtxPicturebox:setLocation(self.location.x, self.location.y)
end

return _ScreenRAD615

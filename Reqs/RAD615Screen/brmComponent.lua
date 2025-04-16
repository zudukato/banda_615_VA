---@class _ScreenRAD615.screen.component
---@field name string
---@field text string
---@field location Vector2D
---@field size Size
---@field alignment AlignmentID
---@field fontNumber FontID
---@field visible boolean
---@field inverted boolean
---@field private _awtxComponent awtx.labelCtrl|awtx.buttonCtrl|awtx.textboxCtrl
local BrmComponent = {}
BrmComponent.__index = BrmComponent

---Prepares and returns a complete set of component parameters with default values.
---This helper function ensures all component fields are safely initialized, even if not provided.
---
---Useful for avoiding repeated default handling logic in component constructors.
---
---@param name string               -- Name of the component (must be unique per screen)
---@param text? string              -- Optional display text (default: "")
---@param location? Vector2D        -- Optional screen position (default: { x = 0, y = 0 })
---@param size? Size                -- Optional size of the component (default: { width = 0, height = 0 })
---@param alignment? AlignmentID    -- Optional text alignment (default: 0)
---@param fontNumber? FontID        -- Optional font number (default: 0)
---@param visible? boolean          -- Optional visibility state (default: false)
---@param inverted? boolean          -- Optional visibility state (default: false)
---@return table                    -- Table containing all initialized component parameters
local function prepareComponentParams(name, text, location, size, alignment, fontNumber, visible, inverted)
    return {
        name = name,
        text = text or "",
        location = location or { x = 0, y = 0 },
        size = size or { width = 0, height = 0 },
        alignment = alignment or 0,
        fontNumber = fontNumber or 0,
        visible = visible or false,
        inverted = inverted or false,
    }
end

---Creates a new component instance (label or button) with given properties.
---
---@param name string             -- Component name
---@param text? string             -- Displayed text
---@param location? Vector2D       -- Location on screen
---@param size? Size               -- Size of the component
---@param alignment? AlignmentID   -- Text alignment
---@param fontNumber? FontID       -- Font number
---@param visible? boolean         -- Whether the component is visible
---@param inverted? boolean         -- Whether the component is inverted
---@return _ScreenRAD615.screen.component 
---@private
function BrmComponent:_new(name, text, location, size, alignment, fontNumber, visible, inverted)
    local instance = {}
    setmetatable(instance, self)
    local params = prepareComponentParams(name, text, location, size, alignment, fontNumber, visible, inverted)
    instance.name = params.name
    instance.text = params.text
    instance.location = params.location
    instance.size = params.size
    instance.alignment = params.alignment
    instance.fontNumber = params.fontNumber
    instance.visible = params.visible
    instance.inverted = params.inverted
    return instance
end

function BrmComponent:_init()
    self:setText()
    self:setLocation()
    self:reSize()
    self:setAlignment()
    self:setFont()
    self:setVisible()
    self:setInverted()
end

---This function sets the size of the component, you need to redraw the screen
---@param size? Size
function BrmComponent:reSize(size)
    self.size = size or self.size
    if self._awtxComponent then self._awtxComponent:reSize(self.size.width, self.size.height) end
end

---This function sets the alignment of the component, you need to redraw the screen
---@param alignment? AlignmentID
function BrmComponent:setAlignment(alignment)
    self.alignment = alignment or self.alignment
    if self._awtxComponent then self._awtxComponent:setAlignment(self.alignment) end
end

---This function sets the font of the component, you need to redraw the screen
---@param fontNumber? FontID
function BrmComponent:setFont(fontNumber)
    self.fontNumber = fontNumber or self.fontNumber
    if self._awtxComponent then self._awtxComponent:setFont(self.fontNumber) end
end

---This function sets the location of the component, you need to redraw the screen
---@param location? Vector2D
function BrmComponent:setLocation(location)
    self.location = location or self.location
    if self._awtxComponent then self._awtxComponent:setLocation(self.location.x, self.location.y) end
end

---This function sets the text of component, you need to redraw the screen
---@param text? string
function BrmComponent:setText(text)
    self.text = text or self.text
    if self._awtxComponent then self._awtxComponent:setText(self.text) end
end

---This function sets the visibility of the component, you need to redraw the screen
---@param visible? boolean
function BrmComponent:setVisible(visible)
    if type(visible) =="boolean" then self.visible = visible end
    if self._awtxComponent then self._awtxComponent:setVisible(self.visible) end
end

---This function sets inverted the component, you need to redraw the screen
---@param inverted? boolean
function BrmComponent:setInverted(inverted)
    if type(inverted) =="boolean" then self.inverted = inverted end
    if self._awtxComponent then self._awtxComponent:setInverted(self.inverted) end
end

---function to set AwtxComponent like labelCtrl
---@param awtxComponent awtx.labelCtrl|awtx.buttonCtrl|awtx.textboxCtrl
---@private
function BrmComponent:setAwtxComponent(awtxComponent)
    self._awtxComponent = awtxComponent
end


return BrmComponent
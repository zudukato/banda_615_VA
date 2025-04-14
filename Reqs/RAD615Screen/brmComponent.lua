---@class _ScreenRAD615.screen.component
---@field name string
---@field text string
---@field location Vector2D
---@field size Size
---@field alignment AlignmentID
---@field fontNumber FontID
---@field visible boolean
---@field private _awtxComponent awtx.labelCtrl|awtx.buttonCtrl
local BrmComponent = {}
BrmComponent.__index = BrmComponent

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
function BrmComponent:_new(name, text, location, size, alignment, fontNumber, visible)
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

function BrmComponent:_init()
    self._awtxComponent:setText(self.text)
    self._awtxComponent:setLocation(self.location.x, self.location.y)
    self._awtxComponent:reSize(self.size.width, self.size.height)
    self._awtxComponent:setAlignment(self.alignment)
    self._awtxComponent:setFont(self.fontNumber)
    self._awtxComponent:setVisible(self.visible)
end

---This function sets the size of the component, you need to redraw the screen
---@param newSize Size
function BrmComponent:reSize(newSize)
    self.size = newSize
    if self._awtxComponent then self._awtxComponent:reSize(newSize.width, newSize.height) end
end

---This function sets the alignment of the component, you need to redraw the screen
---@param alignment AlignmentID
function BrmComponent:setAlignment(alignment)
    self.alignment = alignment
    if self._awtxComponent then self._awtxComponent:setAlignment(alignment) end
end

---This function sets the font of the component, you need to redraw the screen
---@param fontNumber FontID
function BrmComponent:setFont(fontNumber)
    self.fontNumber = fontNumber
    if self._awtxComponent then self._awtxComponent:setFont(fontNumber) end
end

---This function sets the location of the component, you need to redraw the screen
---@param location Vector2D
function BrmComponent:setLocation(location)
    self.location = location
    if self._awtxComponent then self._awtxComponent:setLocation(location.x, location.y) end
end

---This function sets the text of component, you need to redraw the screen
---@param text string
function BrmComponent:setText(text)
    self.text = text
    if self._awtxComponent then self._awtxComponent:setText(text) end
end

---This function sets the visibility of the component, you need to redraw the screen
---@param visible boolean
function BrmComponent:setVisible(visible)
    self.visible = visible
    if self._awtxComponent then self._awtxComponent:setVisible(visible) end
end

return BrmComponent
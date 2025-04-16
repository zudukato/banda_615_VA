---@class _ScreenRAD615.screen.scale
---@field name string
---@field location Vector2D
---@field visible boolean
---@field scaleNumber integer
---@field scaleStyle ScaleStyle
---@field activeValue  ActiveValueScale
---@field private _awtxScale awtx.scaleCtrl
local BrmScreenScale = {}
BrmScreenScale.__index = BrmScreenScale

local function prepareComponentParams(name, location, visible, scaleNumber, scaleStyle, activeValue)
    return {
        name = name,
        location = location or { x = 0, y = 0 },
        scaleNumber = scaleNumber or 0,
        scaleStyle = scaleStyle or 1,
        activeValue = activeValue or -1,
        visible = visible or false,
    }
end

---Creates a new screen scale instance for the RAD615Screen
---
---This constructor sets up the logical definition of a scale control, including its position, visibility,
---style, and related configuration. The actual AWTX control must be attached later using `setAwtxScale()`.
---
---### Example:
---```lua
---local scale = BrmScreenScale:new("mainScale", {x = 0, y = 10}, true, 0, 1, -1)
---```
---
---@param name string                          --Unique component identifier (must be unique per screen)
---@param scaleNumber? integer                 --Scale number (0 = active scale; 1–4 for specific scales); default is `0`
---@param scaleStyle? ScaleStyle               --Visual style of the scale control (e.g., 1 = large, 2 = medium); default is `1`
---@param location? Vector2D                   --Optional control position; default is `{x = 0, y = 0}`
---@param visible? boolean                     --Whether the control is initially visible; default is `false`
---@param activeValue? ActiveValueScale        --Optional active value basis (e.g., Gross, Net); default is `-1`
---@return _ScreenRAD615.screen.scale          Returns a new scale component instance
function BrmScreenScale:new(name, scaleNumber, scaleStyle, location, visible, activeValue)
    local instance = {}
    setmetatable(instance, self)
    local params = prepareComponentParams(name, location, visible, scaleNumber, scaleStyle, activeValue)
    instance.name = params.name
    instance.location = params.location
    instance.visible = params.visible
    instance.scaleNumber = params.scaleNumber
    instance.scaleStyle = params.scaleStyle
    instance.activeValue = params.activeValue
    return instance
end
---Binds the AWTX scale control to this screen scale instance.
---
---This function stores the actual graphical control (`awtx.scaleCtrl`) used to visually represent the scale.
---It should be called after creating the AWTX control and before showing the screen.
---
---@param awtxScale awtx.scaleCtrl  --The actual AWTX scale control to associate
---@private
function BrmScreenScale:setAwtxScale(awtxScale)
    if not awtxScale then return end
    self._awtxScale = awtxScale
end

---Updates the position of the scale control and applies it to the bound AWTX control (if available).
---
---This method updates both the logical location (stored in the instance) and the visual position of
---the control on screen via `awtxScale:setLocation(x, y)`.
---
---@param location? Vector2D   --New position `{x, y}`; if nil, the current value is reused
function BrmScreenScale:setLocation(location)
    self.location = location or self.location
    if not self._awtxScale then return end
    self._awtxScale:setLocation(self.location.x, self.location.y)
end
---Initializes the scale component by applying all preconfigured visual properties.
---
---This should be called before the screen is shown to ensure the AWTX component reflects the correct state.
---Currently, only applies the position via `setLocation()`.
---@private
function BrmScreenScale:_init()
    self:setLocation()
end

return BrmScreenScale

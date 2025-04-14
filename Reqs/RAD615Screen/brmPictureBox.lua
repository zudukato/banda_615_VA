
local brmUtilities = require("Reqs.brmUtilities")
local numericFirmwareVersion = brmUtilities.getNumericFirmwareVersion()

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

return BrmPicturebox
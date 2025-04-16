
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

---comment
---@param name string
---@param path string
---@param location? Vector2D
---@param visible? boolean
---@return _ScreenRAD615.screen.picturebox
function BrmPicturebox:new(name, path, location, visible)
    local instance = {}
    setmetatable(instance, self)
    instance.name = name
    instance.path = path
    instance.location = location or { x = 0, y = 0 }
    instance.visible = visible or false
    return instance
end

---function to change position of picturebox
---@param location? Vector2D
function BrmPicturebox:setLocation(location)
    self.location =  location or self.location
    if not self._awtxPicturebox then return end
    self._awtxPicturebox:setLocation(self.location.x,self.location.y)
end

---This function set the image to show in this picturebox
---@param path? string ---Path of the img "C:\\something\\...\\"
function BrmPicturebox:setBitmap(path)
    if numericFirmwareVersion < 2500 then return end
    self.path = path or self.path
    if not self._awtxPicturebox then return end
    self._awtxPicturebox:setBitmap(self.path)
end

---@param awtxPicturebox awtx.pictureboxCtrl
---@private
function BrmPicturebox:setAwtxPicturebox(awtxPicturebox)
    self._awtxPicturebox = awtxPicturebox
end

function BrmPicturebox:_init()
    self:setBitmap()
    self:setLocation()
end

return BrmPicturebox
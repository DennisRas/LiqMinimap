---@class LMM_Addon
local addon = select(2, ...)

---@class LMM_Helpers
local Helpers = {}
addon.Helpers = Helpers

---@type table<Region, boolean>
local hooked = {}

---@param self Region
local function hideOnShow(self)
  self:Hide()
end

---@param region Region?
function Helpers:KeepHidden(region)
  if not region then
    return
  end
  region:Hide()
  if hooked[region] then
    return
  end
  hooked[region] = true
  hooksecurefunc(region, "Show", hideOnShow)
end

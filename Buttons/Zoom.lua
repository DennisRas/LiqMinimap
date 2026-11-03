---@class LMM_Addon
local addon = select(2, ...)

local Buttons = addon.Buttons
local Constants = addon.Constants
local Helpers = addon.Helpers
local LiqUI = addon.libs.LiqUI
local Events = LiqUI.Events

local function hideDefault()
  Helpers:KeepHidden(Minimap.ZoomIn)
  Helpers:KeepHidden(Minimap.ZoomOut)
  Minimap.ZoomHitArea:EnableMouse(false)
  return false
end

---@type LMM_CollectionButton
local row = {
  id = "zoom",
  container = Constants.container.Default,
  enabled = false,
  mode = Constants.show.Hidden,
  order = 8,
}
Buttons:Register(row)
Buttons:OnHideDefault(hideDefault)

Buttons:OnEnable(function()
  hideDefault()
  Events:RegisterEvent("ADDON_LOADED", hideDefault)
  C_Timer.After(2, hideDefault)
end)

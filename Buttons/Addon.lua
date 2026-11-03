---@class LMM_Addon
local addon = select(2, ...)

local Buttons = addon.Buttons
local Helpers = addon.Helpers
local LiqUI = addon.libs.LiqUI
local Events = LiqUI.Events
local LibDBIcon = addon.libs.LibDBIcon

local LIBDBICON_PREFIX = "LibDBIcon10_"
local MINIMAP_BUTTON_SUFFIX = "MinimapButton"
local MINIMAP_ICON_SUFFIX = "MinimapIcon"

---@param frameName string
---@return boolean
local function isLauncherName(frameName)
  if frameName:sub(1, #LIBDBICON_PREFIX) == LIBDBICON_PREFIX then
    return true
  end
  if frameName:sub(-#MINIMAP_BUTTON_SUFFIX) == MINIMAP_BUTTON_SUFFIX then
    return true
  end
  if frameName:sub(-#MINIMAP_ICON_SUFFIX) == MINIMAP_ICON_SUFFIX then
    return true
  end
  return false
end

---@param frame Frame
local function hideLauncher(frame)
  if frame:IsForbidden() then
    return
  end
  local frameName = frame:GetName()
  if not frameName or not isLauncherName(frameName) then
    return
  end
  Helpers:KeepHidden(frame)
end

local function hideLaunchers()
  Helpers:KeepHidden(AddonCompartmentFrame)
  if LibDBIcon then
    local names = LibDBIcon:GetButtonList()
    for index = 1, #names do
      Helpers:KeepHidden(LibDBIcon:GetMinimapButton(names[index]))
    end
  end

  ---@type Frame[]
  local parents = {
    Minimap,
    MinimapCluster,
    MinimapBackdrop,
    MinimapCluster.IndicatorFrame,
    MinimapCluster.Tracking,
    MinimapCluster.MinimapContainer,
  }
  for index = 1, #parents do
    local parent = parents[index]
    if parent then
      local children = { parent:GetChildren() }
      for childIndex = 1, #children do
        hideLauncher(children[childIndex])
      end
    end
  end
end

---@param _event string
---@param button Frame
local function onLauncherCreated(_event, button)
  Helpers:KeepHidden(button)
end

Buttons:OnEnable(function()
  if LibDBIcon then
    LibDBIcon.RegisterCallback(Buttons, "LibDBIcon_IconCreated", onLauncherCreated)
  end
  Events:RegisterEvent("ADDON_LOADED", hideLaunchers)
  hideLaunchers()
  C_Timer.After(2, hideLaunchers)
end)

---@class LMM_Addon
local addon = select(2, ...)

---@class LMM_Icons
local Icons = {}
addon.Icons = Icons

local Helpers = addon.Helpers
local LiqUI = addon.libs.LiqUI
local Events = LiqUI.Events
local LibDBIcon = addon.libs.LibDBIcon

local LAUNCHER_PREFIX = "LibDBIcon10_"
local BUTTON_SUFFIX = "MinimapButton"
local ICON_SUFFIX = "MinimapIcon"

---@param frameName string
---@return boolean
local function isLauncherName(frameName)
  if frameName:sub(1, #LAUNCHER_PREFIX) == LAUNCHER_PREFIX then
    return true
  end
  if frameName:sub(-#BUTTON_SUFFIX) == BUTTON_SUFFIX then
    return true
  end
  if frameName:sub(-#ICON_SUFFIX) == ICON_SUFFIX then
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

---@param _event string
---@param button Frame
local function onIconCreated(_event, button)
  Helpers:KeepHidden(button)
end

local function onLauncherLoaded()
  Icons:HideChrome()
  Icons:HideLaunchers()
end

function Icons:HideChrome()
  local cluster = MinimapCluster
  Helpers:KeepHidden(cluster.Tracking)
  Helpers:KeepHidden(cluster.Tracking.Button)
  Helpers:KeepHidden(cluster.IndicatorFrame.MailFrame)
  Helpers:KeepHidden(cluster.IndicatorFrame.CraftingOrderFrame)
  Helpers:KeepHidden(cluster.InstanceDifficulty)
  Helpers:KeepHidden(GameTimeFrame)
  Helpers:KeepHidden(AddonCompartmentFrame)
  Helpers:KeepHidden(ExpansionLandingPageMinimapButton)
  Helpers:KeepHidden(Minimap.ZoomIn)
  Helpers:KeepHidden(Minimap.ZoomOut)
  Minimap.ZoomHitArea:EnableMouse(false)
end

function Icons:HideLaunchers()
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

function Icons:Enable()
  if LibDBIcon then
    LibDBIcon.RegisterCallback(self, "LibDBIcon_IconCreated", onIconCreated)
  end
  Events:RegisterEvent("ADDON_LOADED", onLauncherLoaded)
  self:HideChrome()
  self:HideLaunchers()
  C_Timer.After(2, function()
    Icons:HideChrome()
    Icons:HideLaunchers()
  end)
end

---@class LMM_Addon
local addon = select(2, ...)

---@class LMM_Shape
local Shape = {}
addon.Shape = Shape

local Constants = addon.Constants
local Helpers = addon.Helpers
local LiqUI = addon.libs.LiqUI
local Events = LiqUI.Events

local deferred = false

local function onLeaveCombat()
  if not deferred then
    return
  end
  deferred = false
  Shape:SetSquare()
end

---@param _frame Frame
---@param _event string
---@param addonName string
local function onHybridLoaded(_frame, _event, addonName)
  if addonName ~= "Blizzard_HybridMinimap" then
    return
  end
  Shape:SetSquare()
end

function Shape:SetSquare()
  if InCombatLockdown() then
    deferred = true
    return
  end

  local size = Constants.layout.size
  Minimap:SetSize(size, size)
  Minimap:SetMaskTexture(Constants.media.squareMask)
  Minimap:SetArchBlobRingAlpha(0)
  Minimap:SetArchBlobRingScalar(0)
  Minimap:SetQuestBlobRingAlpha(0)
  Minimap:SetQuestBlobRingScalar(0)

  if not HybridMinimap then
    return
  end

  local mask = HybridMinimap.CircleMask
  mask:SetTexture(Constants.media.squareMask)
  mask:ClearAllPoints()
  mask:SetAllPoints(HybridMinimap)
  HybridMinimap.MapCanvas:SetUseMaskTexture(false)
  HybridMinimap.MapCanvas:SetUseMaskTexture(true)
end

local function pingCorner()
  local cursorX, cursorY = GetCursorPosition()
  local scale = Minimap:GetEffectiveScale()
  if scale == 0 then
    return
  end
  cursorX = cursorX / scale
  cursorY = cursorY / scale
  local centerX, centerY = Minimap:GetCenter()
  if not centerX or not centerY then
    return
  end
  cursorX = cursorX - centerX
  cursorY = cursorY - centerY
  local half = Minimap:GetWidth() / 2
  if cursorX < -half or cursorX > half or cursorY < -half or cursorY > half then
    return
  end
  if math.sqrt((cursorX * cursorX) + (cursorY * cursorY)) < half then
    return
  end
  Minimap:PingLocation(cursorX, cursorY)
end

function Shape:Enable()
  Events:RegisterEvent("PLAYER_REGEN_ENABLED", onLeaveCombat)
  Events:RegisterEvent("ADDON_LOADED", onHybridLoaded)
  Minimap:HookScript("OnMouseUp", pingCorner)
  Helpers:KeepHidden(MinimapCompassTexture)
  if MinimapCluster.BorderTop then
    Helpers:KeepHidden(MinimapCluster.BorderTop)
  end
  self:SetSquare()
end

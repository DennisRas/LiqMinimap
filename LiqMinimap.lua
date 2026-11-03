---@class LMM_Addon
local addon = select(2, ...)

local Constants = addon.Constants
local Data = addon.Data
local Helpers = addon.Helpers
local LibAceAddon = addon.libs.AceAddon
local LiqUI = addon.libs.LiqUI
local Events = LiqUI.Events

---@class LMM_Core
local Core = LibAceAddon:NewAddon(addon.name, "AceConsole-3.0")
addon.Core = Core

local deferred = false

local function setSquareMask()
  if InCombatLockdown() then
    deferred = true
    return
  end

  local size = Constants.map.size
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

local function onLeaveCombat()
  if not deferred then
    return
  end
  deferred = false
  setSquareMask()
end

---@param _frame Frame
---@param _event string
---@param addonName string
local function onHybridLoaded(_frame, _event, addonName)
  if addonName ~= "Blizzard_HybridMinimap" then
    return
  end
  setSquareMask()
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

function Core:OnInitialize()
  if not LiqUI or not LiqUI.Utils then
    self:Print("This version needs a newer LiqUI embed. Reload after updating LiqUI.")
    return
  end

  Data:Initialize()
  addon.logger = LiqUI:NewLogger({
    name = addon.name,
    title = addon.title,
    storage = Data.db.global.logs,
    maxLines = 10000,
  })
end

function Core:OnEnable()
  if not addon.logger then
    return
  end
  Events:RegisterEvent("PLAYER_REGEN_ENABLED", onLeaveCombat)
  Events:RegisterEvent("ADDON_LOADED", onHybridLoaded)
  Minimap:HookScript("OnMouseUp", pingCorner)
  Helpers:KeepHidden(MinimapCompassTexture)
  if MinimapCluster.BorderTop then
    Helpers:KeepHidden(MinimapCluster.BorderTop)
  end
  setSquareMask()
  addon.Buttons:Enable()
  addon.Map:Enable()
end

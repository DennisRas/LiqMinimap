---@class LMM_Addon
local addon = select(2, ...)

---@class LMM_Map
local Map = {}
addon.Map = Map

local Constants = addon.Constants
local Helpers = addon.Helpers
local LiqUI = addon.libs.LiqUI
local Events = LiqUI.Events

local HIDE_WAIT = 1

local deferred = false
local fitting = false
local hovered = false
local hideToken = 0
local clockHooked = false
local coordsFrame

---@type Frame?
local border

local TEXT_FLAGS = "OUTLINE"

---@param container Frame
---@return Frame?
local function findCoords(container)
  if coordsFrame then
    return coordsFrame
  end
  local children = { container:GetChildren() }
  for index = 1, #children do
    local child = children[index]
    if child ~= Minimap then
      coordsFrame = child
      return coordsFrame
    end
  end
  return nil
end

---@return boolean
function Map:IsHolderHovered()
  if Minimap:IsMouseOver() then
    return true
  end
  if MinimapCluster.ZoneTextButton:IsMouseOver() then
    return true
  end
  if TimeManagerClockButton and TimeManagerClockButton:IsMouseOver() then
    return true
  end
  return addon.Buttons:IsMouseOver()
end

local function setHover()
  local zone = MinimapCluster.ZoneTextButton
  if hovered then
    zone:Show()
  else
    zone:Hide()
  end

  local coords = findCoords(MinimapCluster.MinimapContainer)
  if coords then
    local showCoords = hovered and GetCVarBool("minimapShowPlayerCoords")
    coords:SetAlpha(showCoords and 1 or 0)
  end

  addon.Buttons:SetHover(hovered)
end

---@param isHovered boolean
function Map:SetHovered(isHovered)
  if isHovered then
    hideToken = hideToken + 1
    if hovered then
      return
    end
    hovered = true
    setHover()
    return
  end
  hideToken = hideToken + 1
  local token = hideToken
  C_Timer.After(HIDE_WAIT, function()
    if token ~= hideToken then
      return
    end
    if Map:IsHolderHovered() or addon.Buttons:IsAttentionOpen() then
      return
    end
    if not hovered then
      return
    end
    hovered = false
    setHover()
  end)
end

local function onEnter()
  Map:SetHovered(true)
end

local function onLeave()
  Map:SetHovered(false)
end

---@param label FontString
local function setLabelFont(label)
  label:SetFont(Constants.media.textFont, Constants.map.labelSize, TEXT_FLAGS)
  label:SetShadowOffset(0, 0)
  label:SetWordWrap(false)
  label:SetHeight(Constants.map.labelSize)
end

---@param frame Frame
---@return FontString?
local function findLabel(frame)
  local regions = { frame:GetRegions() }
  for index = 1, #regions do
    local region = regions[index]
    if region.GetObjectType and region:GetObjectType() == "FontString" then
      return region
    end
  end
  return nil
end

local function setLabels()
  local map = Constants.map
  local inset = map.labelInset
  local zone = MinimapZoneText
  setLabelFont(zone)
  zone:ClearAllPoints()
  zone:SetPoint("TOPLEFT", Minimap, "TOPLEFT", inset, -inset)
  zone:SetJustifyH("LEFT")
  zone:SetJustifyV("TOP")
  zone:SetWidth(Minimap:GetWidth() - (inset * 2) - (map.labelSize * 5))

  local clock = TimeManagerClockTicker
  if clock then
    setLabelFont(clock)
    clock:SetTextColor(1, 1, 1)
    clock:ClearAllPoints()
    clock:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -inset, -inset)
    clock:SetJustifyH("RIGHT")
    clock:SetJustifyV("TOP")
  end

  local coords = findCoords(MinimapCluster.MinimapContainer)
  if not coords then
    return
  end
  local coordsLabel = findLabel(coords)
  if not coordsLabel then
    return
  end
  setLabelFont(coordsLabel)
  coordsLabel:SetTextColor(1, 1, 1)
  coordsLabel:ClearAllPoints()
  coordsLabel:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", -inset, inset)
  coordsLabel:SetJustifyH("RIGHT")
  coordsLabel:SetJustifyV("BOTTOM")
end

local function setBorder()
  if border then
    return
  end
  local mapBorder = Constants.map.border
  local edge = CreateFrame("Frame", nil, Minimap, "BackdropTemplate")
  border = edge
  local outset = mapBorder.outset
  edge:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -outset, outset)
  edge:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", outset, -outset)
  edge:EnableMouse(false)
  ---@type backdropInfo
  local borderBackdrop = {
    edgeFile = Constants.media.border,
    edgeSize = mapBorder.edgeSize,
    insets = {
      left = mapBorder.inset,
      right = mapBorder.inset,
      top = mapBorder.inset,
      bottom = mapBorder.inset,
    },
  }
  edge:SetBackdrop(borderBackdrop)
  local color = mapBorder.color
  edge:SetBackdropBorderColor(color.r, color.g, color.b, color.a)
end

local function setZone()
  local zone = MinimapCluster.ZoneTextButton
  local inset = Constants.map.labelInset
  zone:SetParent(Minimap)
  zone:SetHeight(Constants.map.labelSize)
  zone:ClearAllPoints()
  zone:SetPoint("TOPLEFT", Minimap, "TOPLEFT", inset, -inset)
end

local function setClock()
  local clock = TimeManagerClockButton
  if not clock then
    return
  end
  local inset = Constants.map.labelInset
  clock:SetParent(Minimap)
  clock:SetHitRectInsets(0, 0, 0, 0)
  clock:SetHeight(Constants.map.labelSize)
  clock:ClearAllPoints()
  clock:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -inset, -inset)
  clock:Show()
  if clockHooked then
    return
  end
  clockHooked = true
  hooksecurefunc(clock, "SetPoint", function()
    Map:SetLayout()
  end)
  clock:HookScript("OnEnter", onEnter)
  clock:HookScript("OnLeave", onLeave)
end

local function setCoords()
  local coords = findCoords(MinimapCluster.MinimapContainer)
  if not coords then
    return
  end
  local inset = Constants.map.labelInset
  coords:SetParent(Minimap)
  coords:SetHeight(Constants.map.labelSize)
  coords:ClearAllPoints()
  coords:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", -inset, inset)
end

local function raiseLabels()
  local level = Minimap:GetFrameLevel()
  if border then
    border:SetFrameLevel(level + 3)
  end
  MinimapCluster.ZoneTextButton:SetFrameLevel(level + 4)
  local clock = TimeManagerClockButton
  if clock then
    clock:SetFrameLevel(level + 4)
  end
  local coords = findCoords(MinimapCluster.MinimapContainer)
  if coords then
    coords:SetFrameLevel(level + 4)
  end
end

function Map:SetLayout()
  if fitting then
    return
  end
  if InCombatLockdown() then
    deferred = true
    return
  end

  fitting = true

  local cluster = MinimapCluster
  local container = cluster.MinimapContainer
  local size = Constants.map.size

  Helpers:KeepHidden(cluster.IndicatorFrame)
  setBorder()
  setZone()
  setClock()
  setCoords()
  setLabels()

  cluster:SetWidthPadding(0)
  cluster:SetHitRectInsets(0, 0, 0, 0)

  container:ClearAllPoints()
  container:SetPoint("TOPRIGHT", cluster, "TOPRIGHT", 0, 0)
  container:SetSize(size, size)

  Minimap:ClearAllPoints()
  Minimap:SetPoint("CENTER", container, "CENTER", 0, 0)
  Minimap:SetSize(size, size)

  MinimapBackdrop:ClearAllPoints()
  MinimapBackdrop:SetPoint("CENTER", Minimap, "CENTER", 0, 0)
  MinimapBackdrop:SetSize(size, size)

  raiseLabels()
  cluster:Layout()
  setHover()

  fitting = false
end

local function onLeaveCombat()
  if not deferred then
    return
  end
  deferred = false
  Map:SetLayout()
end

---@param _frame Frame
---@param _event string
---@param addonName string
local function onAddonLoaded(_frame, _event, addonName)
  if addonName ~= "Blizzard_TimeManager" then
    return
  end
  Map:SetLayout()
end

local function onContainerPoint()
  Map:SetLayout()
end

function Map:Enable()
  local zone = MinimapCluster.ZoneTextButton
  local coords = findCoords(MinimapCluster.MinimapContainer)
  Events:RegisterEvent("PLAYER_REGEN_ENABLED", onLeaveCombat)
  Events:RegisterEvent("ADDON_LOADED", onAddonLoaded)
  hooksecurefunc(MinimapCluster.MinimapContainer, "SetPoint", onContainerPoint)
  hooksecurefunc(zone, "SetPoint", onContainerPoint)
  if coords then
    hooksecurefunc(coords, "SetPoint", onContainerPoint)
  end
  Minimap:HookScript("OnEnter", onEnter)
  Minimap:HookScript("OnLeave", onLeave)
  zone:HookScript("OnEnter", onEnter)
  zone:HookScript("OnLeave", onLeave)
  self:SetLayout()
end

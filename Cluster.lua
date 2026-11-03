---@class LMM_Addon
local addon = select(2, ...)

---@class LMM_Cluster
local Cluster = {}
addon.Cluster = Cluster

local Constants = addon.Constants
local Helpers = addon.Helpers
local LiqUI = addon.libs.LiqUI
local Events = LiqUI.Events

local BORDER_EDGE_SIZE = 16

local deferred = false
local fitting = false
local hovered = false
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

local function mouseOverMap()
  if Minimap:IsMouseOver() then
    return true
  end
  if MinimapCluster.ZoneTextButton:IsMouseOver() then
    return true
  end
  if TimeManagerClockButton and TimeManagerClockButton:IsMouseOver() then
    return true
  end
  return false
end

local function setHover()
  local zone = MinimapCluster.ZoneTextButton
  if hovered then
    zone:Show()
  else
    zone:Hide()
  end

  local coords = findCoords(MinimapCluster.MinimapContainer)
  if not coords then
    return
  end
  local showCoords = hovered and GetCVarBool("minimapShowPlayerCoords")
  coords:SetAlpha(showCoords and 1 or 0)
end

local function onEnter()
  hovered = true
  setHover()
end

local function onLeave()
  hovered = mouseOverMap()
  setHover()
end

---@param label FontString
local function setLabelFont(label)
  label:SetFont(Constants.media.textFont, Constants.layout.textSize, TEXT_FLAGS)
  label:SetShadowOffset(0, 0)
  label:SetWordWrap(false)
  label:SetHeight(Constants.layout.textSize)
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
  local layout = Constants.layout
  local inset = layout.textInset
  local zone = MinimapZoneText
  setLabelFont(zone)
  zone:ClearAllPoints()
  zone:SetPoint("TOPLEFT", Minimap, "TOPLEFT", inset, -inset)
  zone:SetJustifyH("LEFT")
  zone:SetJustifyV("TOP")
  zone:SetWidth(Minimap:GetWidth() - (inset * 2) - (layout.textSize * 5))

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
  local layout = Constants.layout
  local edge = CreateFrame("Frame", nil, Minimap, "BackdropTemplate")
  border = edge
  local outset = layout.borderOutset
  edge:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -outset, outset)
  edge:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", outset, -outset)
  edge:EnableMouse(false)
  ---@type backdropInfo
  local borderBackdrop = {
    edgeFile = Constants.media.border,
    edgeSize = BORDER_EDGE_SIZE,
    insets = {
      left = layout.borderSize,
      right = layout.borderSize,
      top = layout.borderSize,
      bottom = layout.borderSize,
    },
  }
  edge:SetBackdrop(borderBackdrop)
  local color = Constants.colors.border
  edge:SetBackdropBorderColor(color.r, color.g, color.b, color.a)
end

local function setZone()
  local zone = MinimapCluster.ZoneTextButton
  local inset = Constants.layout.textInset
  zone:SetParent(Minimap)
  zone:SetHeight(Constants.layout.textSize)
  zone:ClearAllPoints()
  zone:SetPoint("TOPLEFT", Minimap, "TOPLEFT", inset, -inset)
end

local function setClock()
  local clock = TimeManagerClockButton
  if not clock then
    return
  end
  local inset = Constants.layout.textInset
  clock:SetParent(Minimap)
  clock:SetHitRectInsets(0, 0, 0, 0)
  clock:SetHeight(Constants.layout.textSize)
  clock:ClearAllPoints()
  clock:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -inset, -inset)
  clock:Show()
  if clockHooked then
    return
  end
  clockHooked = true
  hooksecurefunc(clock, "SetPoint", function()
    Cluster:SetLayout()
  end)
  clock:HookScript("OnEnter", onEnter)
  clock:HookScript("OnLeave", onLeave)
end

local function setCoords()
  local coords = findCoords(MinimapCluster.MinimapContainer)
  if not coords then
    return
  end
  local inset = Constants.layout.textInset
  coords:SetParent(Minimap)
  coords:SetHeight(Constants.layout.textSize)
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

function Cluster:SetLayout()
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
  local size = Constants.layout.size

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
  Cluster:SetLayout()
end

---@param _frame Frame
---@param _event string
---@param addonName string
local function onAddonLoaded(_frame, _event, addonName)
  if addonName ~= "Blizzard_TimeManager" then
    return
  end
  Cluster:SetLayout()
end

local function onContainerPoint()
  Cluster:SetLayout()
end

function Cluster:Enable()
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

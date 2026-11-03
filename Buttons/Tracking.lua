---@class LMM_Addon
local addon = select(2, ...)

local Buttons = addon.Buttons
local Constants = addon.Constants

---@type LMM_CollectionButton
local row

---@param mouseButton string
local function onTrackingClick(mouseButton)
  if mouseButton ~= "LeftButton" then
    return
  end
  local button = row.button
  if not button then
    return
  end
  local tracking = MinimapCluster.Tracking.Button
  if not InCombatLockdown() then
    tracking:ClearAllPoints()
    tracking:SetPoint("CENTER", button, "CENTER")
  end
  tracking:OpenMenu()
  Buttons:WatchOpenMenu()
  local menu = Menu.GetManager():GetOpenMenu()
  if menu then
    menu:ClearAllPoints()
    menu:SetPoint("TOPRIGHT", button, "TOPLEFT", 0, 0)
  end
end

---@param button LMM_Button
local function onTrackingEnter(button)
  GameTooltip:SetOwner(button, "ANCHOR_LEFT")
  GameTooltip:SetText(TRACKING, 1, 1, 1)
  GameTooltip:AddLine(MINIMAP_TRACKING_TOOLTIP_NONE, nil, nil, nil, true)
  GameTooltip:Show()
end

---@return boolean
local function trackingEnabled()
  return not C_GameRules.IsGameRuleActive(Enum.GameRule.IngameTrackingDisabled)
end

---@return boolean
local function hideDefault()
  MinimapCluster:MarkIgnoreInLayout(MinimapCluster.Tracking)
  if InCombatLockdown() then
    return true
  end
  local frames = { MinimapCluster.Tracking, MinimapCluster.Tracking.Button }
  for index = 1, #frames do
    frames[index]:SetAlpha(0)
    frames[index]:EnableMouse(false)
  end
  return false
end

row = {
  id = "tracking",
  container = Constants.container.Default,
  enabled = trackingEnabled,
  mode = Constants.show.Hover,
  order = 1,
  atlas = "ui-hud-minimap-tracking-up",
  onEnter = onTrackingEnter,
  onClick = onTrackingClick,
}
Buttons:Register(row)
Buttons:OnHideDefault(hideDefault)

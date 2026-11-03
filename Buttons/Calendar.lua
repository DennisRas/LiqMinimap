---@class LMM_Addon
local addon = select(2, ...)

local Buttons = addon.Buttons
local Constants = addon.Constants

local function onCalendarClick()
  GameTimeFrame_OnClick(GameTimeFrame)
end

---@return boolean
local function calendarEnabled()
  return not C_GameRules.IsGameRuleActive(Enum.GameRule.IngameCalendarDisabled)
end

---@return boolean
local function calendarActive()
  local count = C_Calendar.GetNumPendingInvites()
  if count == nil or (issecretvalue and issecretvalue(count)) then
    return false
  end
  return count > 0
end

---@return string?
local function calendarAtlas()
  local current = C_DateAndTime.GetCurrentCalendarTime()
  if not current or not current.monthDay then
    return nil
  end
  return format("ui-hud-calendar-%d-up", current.monthDay)
end

---@return boolean
local function hideDefault()
  MinimapCluster:MarkIgnoreInLayout(GameTimeFrame)
  if InCombatLockdown() then
    return true
  end
  GameTimeFrame:SetAlpha(0)
  GameTimeFrame:EnableMouse(false)
  return false
end

---@type LMM_CollectionButton
local row = {
  id = "calendar",
  title = GAMETIME_TOOLTIP_TOGGLE_CALENDAR,
  container = Constants.container.Default,
  enabled = calendarEnabled,
  mode = Constants.show.Hover,
  order = 2,
  zoom = 1.25,
  offsetX = 0.08,
  offsetY = 0.08,
  atlas = calendarAtlas,
  active = calendarActive,
  events = {
    "CALENDAR_UPDATE_PENDING_INVITES",
    "PLAYER_ENTERING_WORLD",
  },
  onClick = onCalendarClick,
}
Buttons:Register(row)
Buttons:OnHideDefault(hideDefault)

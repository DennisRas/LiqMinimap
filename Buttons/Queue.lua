---@class LMM_Addon
local addon = select(2, ...)

local Buttons = addon.Buttons
local Constants = addon.Constants

---@param button LMM_Button
local function onQueueEnter(button)
  if not InCombatLockdown() then
    QueueStatusFrame:ClearAllPoints()
    QueueStatusFrame:SetPoint("TOPRIGHT", button, "TOPLEFT", -2, 0)
  end
  QueueStatusFrame:Show()
end

local function onQueueLeave()
  if QueueStatusFrame:IsMouseOver() then
    return
  end
  QueueStatusFrame:Hide()
end

---@param mouseButton string
local function onQueueClick(mouseButton)
  QueueStatusButton:OnClick(mouseButton)
  Buttons:HookOpenMenu()
end

---@return boolean
local function queueActive()
  return QueueStatusButton:IsShown()
end

---@return boolean
local function hideDefault()
  if InCombatLockdown() then
    return true
  end
  QueueStatusButton:SetAlpha(0)
  QueueStatusButton:EnableMouse(false)
  return false
end

local function onQueuePanelHide()
  addon.Map:SetHovered(false)
end

---@type LMM_CollectionButton
local row = {
  id = "queue",
  container = Constants.container.Default,
  enabled = true,
  mode = Constants.show.Hidden,
  order = 5,
  atlas = "groupfinder-eye-single",
  active = queueActive,
  events = {
    "LOBBY_MATCHMAKER_QUEUE_STATUS_UPDATE",
    "LOBBY_MATCHMAKER_QUEUE_ABANDONED",
    "LOBBY_MATCHMAKER_QUEUE_POPPED",
    "LOBBY_MATCHMAKER_QUEUE_EXPIRED",
    "LOBBY_MATCHMAKER_QUEUE_ERROR",
    "LFG_UPDATE",
    "LFG_ROLE_CHECK_UPDATE",
    "LFG_READY_CHECK_UPDATE",
    "LFG_PROPOSAL_UPDATE",
    "LFG_PROPOSAL_FAILED",
    "LFG_PROPOSAL_SUCCEEDED",
    "LFG_PROPOSAL_SHOW",
    "LFG_QUEUE_STATUS_UPDATE",
    "LFG_LIST_ACTIVE_ENTRY_UPDATE",
    "LFG_LIST_SEARCH_RESULTS_RECEIVED",
    "LFG_LIST_SEARCH_RESULT_UPDATED",
    "LFG_LIST_APPLICANT_UPDATED",
    "LFG_LIST_REVEALED_CENSORED_ACTIVE_ENTRY",
    "UPDATE_BATTLEFIELD_STATUS",
    "PVP_BRAWL_INFO_UPDATED",
    "PET_BATTLE_QUEUE_STATUS",
    "PLAYER_ENTERING_WORLD",
  },
  onEnter = onQueueEnter,
  onLeave = onQueueLeave,
  onClick = onQueueClick,
}
Buttons:Register(row)
Buttons:OnHideDefault(hideDefault)

Buttons:OnEnable(function()
  QueueStatusFrame:HookScript("OnHide", onQueuePanelHide)
end)

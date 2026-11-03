---@class LMM_Addon
local addon = select(2, ...)

local Buttons = addon.Buttons
local Constants = addon.Constants

---@param button LMM_Button
local function onMailEnter(button)
  GameTooltip:SetOwner(button, "ANCHOR_LEFT")
  ---@type string[]
  local senders = {}
  local latest = { GetLatestThreeSenders() }
  for index = 1, #latest do
    local sender = latest[index]
    if type(sender) == "string" then
      senders[#senders + 1] = sender
    end
  end
  local header = #senders >= 1 and HAVE_MAIL_FROM or HAVE_MAIL
  FormatUnreadMailTooltip(GameTooltip, header, senders)
  GameTooltip:Show()
end

---@return boolean
local function mailActive()
  ---@type boolean?
  local hasMail = HasNewMail()
  if hasMail == nil or (issecretvalue and issecretvalue(hasMail)) then
    return false
  end
  return hasMail
end

---@return boolean
local function hideDefault()
  if InCombatLockdown() then
    return true
  end
  local frame = MinimapCluster.IndicatorFrame.MailFrame
  frame:SetAlpha(0)
  frame:EnableMouse(false)
  return false
end

---@type LMM_CollectionButton
local row = {
  id = "mail",
  container = Constants.container.Default,
  enabled = true,
  mode = Constants.show.Hidden,
  order = 3,
  atlas = "ui-hud-minimap-mail-up",
  active = mailActive,
  events = {
    "UPDATE_PENDING_MAIL",
  },
  onEnter = onMailEnter,
}
Buttons:Register(row)
Buttons:OnHideDefault(hideDefault)

---@class LMM_Addon
local addon = select(2, ...)

local Buttons = addon.Buttons
local Constants = addon.Constants

---@param button LMM_Button
local function onCraftingEnter(button)
  GameTooltip:SetOwner(button, "ANCHOR_LEFT")
  GameTooltip:AddLine(MAILFRAME_CRAFTING_ORDERS_TOOLTIP_TITLE)
  local orders = C_CraftingOrders.GetPersonalOrdersInfo()
  if orders then
    for index = 1, #orders do
      local info = orders[index]
      GameTooltip:AddLine(PERSONAL_CRAFTING_ORDERS_AVAIL_FMT:format(info.numPersonalOrders, info.professionName))
    end
  end
  GameTooltip:Show()
end

---@return boolean
local function craftingActive()
  local orders = C_CraftingOrders.GetPersonalOrdersInfo()
  if not orders then
    return false
  end
  return #orders > 0
end

---@return boolean
local function hideDefault()
  if InCombatLockdown() then
    return true
  end
  local frame = MinimapCluster.IndicatorFrame.CraftingOrderFrame
  frame:SetAlpha(0)
  frame:EnableMouse(false)
  return false
end

---@type LMM_CollectionButton
local row = {
  id = "crafting",
  container = Constants.container.Default,
  enabled = true,
  mode = Constants.show.Hidden,
  order = 4,
  atlas = "UI-HUD-Minimap-CraftingOrder-Up",
  active = craftingActive,
  events = {
    "CRAFTINGORDERS_UPDATE_PERSONAL_ORDER_COUNTS",
    "PLAYER_ENTERING_WORLD",
  },
  onEnter = onCraftingEnter,
}
Buttons:Register(row)
Buttons:OnHideDefault(hideDefault)

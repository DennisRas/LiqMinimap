---@class LMM_Addon
local addon = select(2, ...)

local Buttons = addon.Buttons
local Constants = addon.Constants

local RUNES_SYSTEM = 48
local RUNES_TREE = 1186

local function onLandingClick()
  ExpansionLandingPageMinimapButton:ToggleLandingPage()
end

---@param button LMM_Button
local function onLandingEnter(button)
  local source = ExpansionLandingPageMinimapButton
  if not source.title then
    return
  end
  GameTooltip:SetOwner(button, "ANCHOR_LEFT")
  GameTooltip:SetText(source.title, 1, 1, 1)
  if source.description then
    GameTooltip:AddLine(source.description, nil, nil, nil, true)
  end
  GameTooltip:Show()
end

---@return boolean
local function landingEnabled()
  if not GameRulesUtil.ShouldShowExpansionLandingPageButton() then
    return false
  end
  if ExpansionLandingPage:IsOverlayApplied() then
    return true
  end
  ---@type number?
  local garrisonType = C_Garrison.GetLandingPageGarrisonType()
  if not garrisonType then
    return false
  end
  return C_Garrison.IsLandingPageMinimapButtonVisible(garrisonType) == true
end

---@return boolean
local function folioActive()
  local configID = C_Traits.GetConfigIDBySystemID(RUNES_SYSTEM)
  if not configID then
    return false
  end
  local currencies = C_Traits.GetTreeCurrencyInfo(configID, RUNES_TREE, false)
  if not currencies or #currencies == 0 then
    return false
  end
  local unspent = currencies[1].quantity
  if not unspent or unspent <= 0 then
    return false
  end
  local nodeIDs = C_Traits.GetTreeNodes(RUNES_TREE)
  if not nodeIDs then
    return false
  end
  for index = 1, #nodeIDs do
    local nodeID = nodeIDs[index]
    local costs = C_Traits.GetNodeCost(configID, nodeID)
    local canAfford = not costs or #costs == 0 or (costs[1] ~= nil and unspent >= costs[1].amount)
    if canAfford then
      local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID)
      if nodeInfo and nodeInfo.entryIDs then
        for entryIndex = 1, #nodeInfo.entryIDs do
          if C_Traits.CanPurchaseRank(configID, nodeID, nodeInfo.entryIDs[entryIndex]) then
            return true
          end
        end
      end
    end
  end
  return false
end

---@return string?
local function landingAtlas()
  local normal = ExpansionLandingPageMinimapButton:GetNormalTexture()
  if not normal then
    return nil
  end
  local atlas = normal:GetAtlas()
  if atlas and atlas ~= "" then
    return atlas
  end
  return nil
end

local function onOverlayChanged()
  Buttons:Layout()
end

---@return boolean
local function hideDefault()
  if InCombatLockdown() then
    return true
  end
  ExpansionLandingPageMinimapButton:SetAlpha(0)
  ExpansionLandingPageMinimapButton:EnableMouse(false)
  return false
end

---@type LMM_CollectionButton
local row = {
  id = "landing",
  container = Constants.container.Default,
  enabled = landingEnabled,
  mode = Constants.show.Hover,
  order = 6,
  atlas = landingAtlas,
  zoom = 2.55,
  active = folioActive,
  events = {
    "TRAIT_TREE_CURRENCY_INFO_UPDATED",
    "GARRISON_SHOW_LANDING_PAGE",
    "GARRISON_HIDE_LANDING_PAGE",
    "PLAYER_ENTERING_WORLD",
  },
  onEnter = onLandingEnter,
  onClick = onLandingClick,
}
Buttons:Register(row)
Buttons:OnHideDefault(hideDefault)

Buttons:OnEnable(function()
  EventRegistry:RegisterCallback("ExpansionLandingPage.OverlayChanged", onOverlayChanged)
end)

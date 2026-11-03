---@class LMM_Addon
local addon = select(2, ...)

local Buttons = addon.Buttons
local Constants = addon.Constants
local LiqUI = addon.libs.LiqUI
local Events = LiqUI.Events

local DIFFICULTY_WAIT = 0.25
local HOURGLASS = [[Interface\Common\mini-hourglass]]

local difficultyWaiting = false

---@param frame Frame
---@return string?
local function artInFrame(frame)
  if not frame:IsShown() then
    return nil
  end
  local regions = { frame:GetRegions() }
  for index = 1, #regions do
    local region = regions[index]
    if region:GetObjectType() == "Texture" and region:IsShown() then
      local atlas = region:GetAtlas()
      if atlas and atlas ~= "" then
        local lower = atlas:lower()
        if not lower:find("background", 1, true) and not lower:find("border", 1, true) then
          return atlas
        end
      else
        local _, _, difficulty = GetInstanceInfo()
        if difficulty then
          local _, _, _, isChallengeMode = GetDifficultyInfo(difficulty)
          if isChallengeMode then
            return HOURGLASS
          end
        end
      end
    end
  end
  local children = { frame:GetChildren() }
  for index = 1, #children do
    local art = artInFrame(children[index])
    if art then
      return art
    end
  end
  return nil
end

---@return string?
local function difficultyAtlas()
  local children = { MinimapCluster.InstanceDifficulty:GetChildren() }
  for index = 1, #children do
    local art = artInFrame(children[index])
    if art then
      return art
    end
  end
  return nil
end

---@param button LMM_Button
local function onDifficultyEnter(button)
  local _, instanceType, difficulty, _, maxPlayers, _, _, _, instanceGroupSize = GetInstanceInfo()
  ---@type string?
  local difficultyName
  if difficulty then
    ---@type string?
    local name = DifficultyUtil.GetDifficultyName(difficulty)
    if name and name ~= "" then
      difficultyName = name
    end
  end
  if not difficultyName and (instanceType == nil or instanceType == "none") then
    ---@type string?
    local name = DifficultyUtil.GetWorldTierDifficultyName()
    if name and name ~= "" then
      difficultyName = name
    end
  end
  if not difficultyName then
    return
  end
  GameTooltip:SetOwner(button, "ANCHOR_LEFT")
  GameTooltip:SetText(DUNGEON_DIFFICULTY_BANNER_TOOLTIP:format(difficultyName), 1, 1, 1)
  if maxPlayers > 0 then
    GameTooltip:AddLine(DUNGEON_DIFFICULTY_BANNER_TOOLTIP_PLAYER_COUNT:format(instanceGroupSize, maxPlayers))
  end
  if instanceType and MinimapCluster.InstanceDifficulty:IsGuildGroup() then
    GameTooltip:AddLine(GUILD_GROUP, 0, 1, 0)
  end
  GameTooltip:Show()
end

---@return boolean
local function difficultyEnabled()
  if C_GameRules.IsGameRuleActive(Enum.GameRule.InstanceDifficultyBannerDisabled) then
    return false
  end
  local _, instanceType, difficulty = GetInstanceInfo()
  if instanceType == "interior" or instanceType == "neighborhood" then
    return false
  end
  if MinimapCluster.InstanceDifficulty:IsGuildGroup() then
    return true
  end
  if difficulty ~= nil then
    local _, _, _, isChallengeMode = GetDifficultyInfo(difficulty)
    if isChallengeMode then
      return true
    end
  end
  if instanceType ~= nil and instanceType ~= "none" then
    return true
  end
  local tier = C_DelvesUI.GetWorldTierDifficultyForActivePlayer()
  return tier ~= nil and tier ~= Enum.WorldTierDifficulty.Normal
end

local function onDifficultyDefer()
  if difficultyWaiting then
    return
  end
  difficultyWaiting = true
  C_Timer.After(DIFFICULTY_WAIT, function()
    difficultyWaiting = false
    Buttons:Layout()
  end)
end

---@return boolean
local function hideDefault()
  MinimapCluster:MarkIgnoreInLayout(MinimapCluster.InstanceDifficulty)
  if InCombatLockdown() then
    return true
  end
  MinimapCluster.InstanceDifficulty:SetAlpha(0)
  MinimapCluster.InstanceDifficulty:EnableMouse(false)
  return false
end

---@type LMM_CollectionButton
local row = {
  id = "difficulty",
  container = Constants.container.Default,
  enabled = difficultyEnabled,
  mode = Constants.show.Hover,
  order = 7,
  atlas = difficultyAtlas,
  events = {
    "PLAYER_GUILD_UPDATE",
    "PARTY_MEMBER_ENABLE",
    "PARTY_MEMBER_DISABLE",
    "GUILD_PARTY_STATE_UPDATED",
    "GROUP_ROSTER_UPDATE",
    "ZONE_CHANGED_NEW_AREA",
    "ZONE_CHANGED",
  },
  onEnter = onDifficultyEnter,
}
Buttons:Register(row)
Buttons:OnHideDefault(hideDefault)

Buttons:OnEnable(function()
  Events:RegisterEvent({
    "PLAYER_DIFFICULTY_CHANGED",
    "INSTANCE_GROUP_SIZE_CHANGED",
    "UPDATE_INSTANCE_INFO",
    "GROUP_ROSTER_UPDATE",
  }, onDifficultyDefer, true)
end)

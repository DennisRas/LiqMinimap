---@class LMM_Addon
local addon = select(2, ...)

local Buttons = addon.Buttons
local Constants = addon.Constants
local Helpers = addon.Helpers
local LiqUI = addon.libs.LiqUI
local Events = LiqUI.Events
local TableForEach = LiqUI.Utils.TableForEach
local LibDBIcon = addon.libs.LibDBIcon

local LIBDBICON_PREFIX = "LibDBIcon10_"
local MINIMAP_BUTTON_SUFFIX = "MinimapButton"
local MINIMAP_ICON_SUFFIX = "MinimapIcon"

---@type table<string, boolean>
local defaultNames = {
  AddonCompartmentFrame = true,
  ExpansionLandingPageMinimapButton = true,
  GameTimeFrame = true,
  HybridMinimap = true,
  MinimapCompassTexture = true,
  MinimapZoneText = true,
  QueueStatusButton = true,
  TimeManagerClockButton = true,
}

---@type LMM_AddonCompartment
local compartment = AddonCompartmentFrame

---@type table<string, LMM_CollectionButton>
local known = {}

---@param frameName string
---@return boolean
local function isLauncherName(frameName)
  if frameName:sub(1, #LIBDBICON_PREFIX) == LIBDBICON_PREFIX then
    return true
  end
  if frameName:sub(-#MINIMAP_BUTTON_SUFFIX) == MINIMAP_BUTTON_SUFFIX then
    return true
  end
  if frameName:sub(-#MINIMAP_ICON_SUFFIX) == MINIMAP_ICON_SUFFIX then
    return true
  end
  return false
end

---@param frameName string
---@return string
local function shortName(frameName)
  if frameName:sub(1, #LIBDBICON_PREFIX) == LIBDBICON_PREFIX then
    return frameName:sub(#LIBDBICON_PREFIX + 1)
  end
  return frameName
end

---@param value string?
---@return string
local function plainText(value)
  if type(value) ~= "string" then
    return ""
  end
  local text = C_StringUtil.StripHyperlinks(value)
  text = text:gsub("|c%x%x%x%x%x%x%x%x", "")
  text = text:gsub("|r", "")
  return text
end

---@param value string?
---@return string
local function compactName(value)
  return plainText(value):lower():gsub("[^%w]", "")
end

---@param left string?
---@param right string?
---@return boolean
local function sameAddonName(left, right)
  local leftKey = compactName(left)
  local rightKey = compactName(right)
  if leftKey == "" or rightKey == "" then
    return false
  end
  if leftKey == rightKey then
    return true
  end
  if #leftKey >= 8 and rightKey:sub(-#leftKey) == leftKey then
    return true
  end
  if #rightKey >= 8 and leftKey:sub(-#rightKey) == rightKey then
    return true
  end
  return false
end

---@param keys string[]
---@param value string?
local function pushKey(keys, value)
  local key = compactName(value)
  key = key:gsub("minimapbutton$", ""):gsub("minimapicon$", "")
  if #key < 3 then
    return
  end
  for index = 1, #keys do
    if keys[index] == key then
      return
    end
  end
  keys[#keys + 1] = key
end

---@param left string[]
---@param right string[]
---@return boolean
local function sharesKeys(left, right)
  for leftIndex = 1, #left do
    local key = left[leftIndex]
    for rightIndex = 1, #right do
      if sameAddonName(key, right[rightIndex]) then
        return true
      end
    end
  end
  return false
end

---@param launcher LMM_LauncherButton
---@return number
local function launcherScore(launcher)
  local object = launcher.dataObject
  if object and object.OnTooltipShow then
    return 4
  end
  if object and object.OnEnter then
    return 3
  end
  if launcher:GetScript("OnEnter") then
    return 2
  end
  return 1
end

---@param launcher LMM_LauncherButton
---@return boolean
local function wantsLauncher(launcher)
  local saved = launcher.db
  if not saved or not saved.hide then
    return true
  end
  return saved.showInCompartment == true
end

---@param icon Texture
---@param art string|number|nil
---@return boolean
local function applyArt(icon, art)
  if type(art) == "number" then
    icon:SetTexture(art)
  elseif type(art) == "string" and art ~= "" and C_Texture.GetAtlasInfo(art) then
    icon:SetAtlas(art, false)
  elseif type(art) == "string" and art ~= "" then
    icon:SetTexture(art)
  else
    return false
  end
  local atlas = icon:GetAtlas()
  if not icon:GetTexture() and (not atlas or atlas == "") then
    return false
  end
  icon:SetTexCoord(0, 1, 0, 1)
  icon:SetVertexColor(1, 1, 1, 1)
  return true
end

---@param icon Texture
---@param launcher LMM_LauncherButton
---@return boolean
local function paintLauncher(icon, launcher)
  local object = launcher.dataObject
  if object and applyArt(icon, object.icon) then
    return true
  end
  local source = launcher.icon
  if source and (applyArt(icon, source:GetAtlas()) or applyArt(icon, source:GetTexture())) then
    return true
  end
  local normal = launcher:GetNormalTexture()
  if normal and (applyArt(icon, normal:GetAtlas()) or applyArt(icon, normal:GetTexture())) then
    return true
  end
  local frameName = launcher:GetName()
  if frameName then
    ---@type Texture?
    local namedIcon = _G[frameName .. "Icon"]
    if namedIcon and namedIcon:IsObjectType("Texture") then
      if applyArt(icon, namedIcon:GetAtlas()) or applyArt(icon, namedIcon:GetTexture()) then
        return true
      end
    end
  end
  return false
end

---@param candidate LMM_AddonCandidate
---@return number
local function behaviorRank(candidate)
  local rank = candidate.score
  if candidate.kind == "ldbicon" then
    rank = rank + 300
  elseif candidate.kind == "button" then
    rank = rank + 200
  else
    rank = rank + 100
  end
  if candidate.launcher and candidate.launcher:IsEnabled() then
    rank = rank + 10
  end
  return rank
end

---@param icon Texture
---@param group LMM_AddonCandidate[]
---@return boolean
local function paintGroup(icon, group)
  local order = {}
  for index = 1, #group do
    order[index] = group[index]
  end
  table.sort(order, function(left, right)
    return behaviorRank(left) > behaviorRank(right)
  end)
  for index = 1, #order do
    local candidate = order[index]
    if candidate.launcher and paintLauncher(icon, candidate.launcher) then
      return true
    end
    if candidate.entry and applyArt(icon, candidate.entry.icon) then
      return true
    end
  end
  icon:SetTexture(nil)
  return true
end

---@param launcher LMM_LauncherButton
---@param brokerName string
---@return LMM_CollectionButton
local function describeLauncher(launcher, brokerName)
  ---@type LMM_CollectionButton
  local row

  local function enabled()
    return wantsLauncher(launcher)
  end

  ---@param icon Texture
  ---@return boolean
  local function onIcon(icon)
    return paintLauncher(icon, launcher)
  end

  ---@param button LMM_Button
  local function alignLauncher(button)
    if InCombatLockdown() then
      return
    end
    launcher:ClearAllPoints()
    launcher:SetPoint("CENTER", button, "CENTER")
  end

  ---@param button LMM_Button
  local function onEnter(button)
    alignLauncher(button)
    local object = launcher.dataObject
    if object and object.OnTooltipShow then
      GameTooltip:SetOwner(button, "ANCHOR_LEFT")
      object.OnTooltipShow(GameTooltip)
      GameTooltip:Show()
      return
    end
    local script = launcher:GetScript("OnEnter")
    if script then
      script(launcher)
    end
  end

  local function onLeave()
    local object = launcher.dataObject
    if object and object.OnLeave then
      object.OnLeave(launcher)
    end
    if LibDBIcon then
      LibDBIcon.tooltip:Hide()
    end
  end

  ---@param mouseButton string
  local function onClick(mouseButton)
    if row.button then
      alignLauncher(row.button)
    end
    local script = launcher:GetScript("OnClick")
    if not script then
      script = launcher:GetScript("OnMouseUp")
    end
    if script then
      script(launcher, mouseButton)
    end
    Buttons:WatchOpenMenu()
  end

  row = {
    id = launcher:GetName() or brokerName,
    title = brokerName,
    container = Constants.container.Addons,
    enabled = enabled,
    order = 0,
    onIcon = onIcon,
    onEnter = onEnter,
    onLeave = onLeave,
    onClick = onClick,
  }
  return row
end

---@param entry LMM_CompartmentRow
---@param title string
---@return LMM_CollectionButton
local function describeCompartment(entry, title)
  ---@param icon Texture
  ---@return boolean
  local function onIcon(icon)
    applyArt(icon, entry.icon)
    return true
  end

  ---@param button LMM_Button
  local function onEnter(button)
    if entry.funcOnEnter then
      entry.funcOnEnter(button)
      return
    end
    if title == "" then
      return
    end
    GameTooltip:SetOwner(button, "ANCHOR_LEFT")
    GameTooltip:SetText(title, 1, 1, 1)
    GameTooltip:Show()
  end

  ---@param button LMM_Button
  local function onLeave(button)
    if entry.funcOnLeave then
      entry.funcOnLeave(button)
    end
  end

  ---@param mouseButton string
  local function onClick(mouseButton)
    if not entry.func then
      return
    end
    ---@type LMM_CompartmentClick
    local input = { buttonName = mouseButton }
    entry.func(entry, input)
    Buttons:WatchOpenMenu()
  end

  ---@type LMM_CollectionButton
  local row = {
    id = "compartment:" .. title,
    title = title,
    container = Constants.container.Addons,
    enabled = true,
    order = 0,
    onIcon = onIcon,
    onEnter = onEnter,
    onLeave = onLeave,
    onClick = onClick,
  }
  return row
end

---@param row LMM_CollectionButton
local function adopt(row)
  local existing = known[row.id]
  if existing then
    existing.order = row.order
    existing.title = row.title
    existing.enabled = row.enabled
    existing.onIcon = row.onIcon
    existing.onEnter = row.onEnter
    existing.onLeave = row.onLeave
    existing.onClick = row.onClick
    return
  end
  known[row.id] = row
  Buttons:Register(row)
end

local collecting = false
local queued = false

local function collectAddons()
  if collecting then
    queued = true
    return
  end
  collecting = true

  ---@type table<string, boolean>
  local present = {}
  ---@type LMM_AddonCandidate[]
  local candidates = {}
  ---@type table<string, boolean>
  local listed = {}

  ---@param launcher LMM_LauncherButton
  ---@param brokerName string
  ---@param kind "ldbicon" | "button"
  local function addLauncher(launcher, brokerName, kind)
    if launcher:IsForbidden() then
      return
    end
    local frameName = launcher:GetName()
    if frameName and listed[frameName] then
      return
    end
    if frameName then
      listed[frameName] = true
    end
    Helpers:KeepHidden(launcher)
    local row = describeLauncher(launcher, brokerName)
    ---@type string[]
    local keys = {}
    pushKey(keys, brokerName)
    if frameName then
      pushKey(keys, frameName)
    end
    local object = launcher.dataObject
    if object then
      pushKey(keys, object.label)
    end
    ---@type LMM_AddonCandidate
    local candidate = {
      kind = kind,
      score = launcherScore(launcher),
      keys = keys,
      row = row,
      launcher = launcher,
    }
    candidates[#candidates + 1] = candidate
  end

  if LibDBIcon then
    local names = LibDBIcon:GetButtonList()
    for index = 1, #names do
      local brokerName = names[index]
      local launcher = LibDBIcon:GetMinimapButton(brokerName)
      if launcher then
        addLauncher(launcher, brokerName, "ldbicon")
      end
    end
  end

  ---@type Frame[]
  local parents = {
    Minimap,
    MinimapCluster,
    MinimapBackdrop,
    MinimapCluster.IndicatorFrame,
    MinimapCluster.Tracking,
    MinimapCluster.MinimapContainer,
  }
  for index = 1, #parents do
    local parent = parents[index]
    if parent then
      local children = { parent:GetChildren() }
      for childIndex = 1, #children do
        local child = children[childIndex]
        if not child:IsForbidden() then
          local frameName = child:GetName()
          if frameName and isLauncherName(frameName) and not listed[frameName] and not defaultNames[frameName] and child:IsObjectType("Button") then
            ---@type LMM_LauncherButton?
            local launcher = _G[frameName]
            if launcher then
              addLauncher(launcher, shortName(frameName), "button")
            end
          end
        end
      end
    end
  end

  ---@type table<string, string>
  local addonNames = {}
  for addonIndex = 1, C_AddOns.GetNumAddOns() do
    local addonName, addonTitle = C_AddOns.GetAddOnInfo(addonIndex)
    local titleKey = compactName(addonTitle)
    if titleKey ~= "" then
      addonNames[titleKey] = addonName
    end
    local nameKey = compactName(addonName)
    if nameKey ~= "" then
      addonNames[nameKey] = addonName
    end
  end

  local entries = compartment.registeredAddons
  if entries then
    for index = 1, #entries do
      local entry = entries[index]
      local title = plainText(entry.text)
      if title ~= "" then
        local row = describeCompartment(entry, title)
        ---@type string[]
        local keys = {}
        pushKey(keys, title)
        pushKey(keys, addonNames[compactName(title)])
        local score = 0
        if entry.funcOnEnter then
          score = 2
        end
        ---@type LMM_AddonCandidate
        local candidate = {
          kind = "compartment",
          score = score,
          keys = keys,
          row = row,
          entry = entry,
        }
        candidates[#candidates + 1] = candidate
      end
    end
  end

  ---@type number[]
  local parentIndex = {}
  for index = 1, #candidates do
    parentIndex[index] = index
  end

  ---@param index number
  ---@return number
  local function findIndex(index)
    local root = index
    while parentIndex[root] ~= root do
      root = parentIndex[root]
    end
    parentIndex[index] = root
    return root
  end

  for index = 1, #candidates do
    for otherIndex = index + 1, #candidates do
      if sharesKeys(candidates[index].keys, candidates[otherIndex].keys) then
        local leftRoot = findIndex(index)
        local rightRoot = findIndex(otherIndex)
        if leftRoot ~= rightRoot then
          parentIndex[rightRoot] = leftRoot
        end
      end
    end
  end

  ---@type table<number, LMM_AddonCandidate[]>
  local groups = {}
  for index = 1, #candidates do
    local root = findIndex(index)
    local group = groups[root]
    if not group then
      group = {}
      groups[root] = group
    end
    group[#group + 1] = candidates[index]
  end

  ---@type LMM_CollectionButton[]
  local found = {}
  for index = 1, #candidates do
    if findIndex(index) == index then
      local group = groups[index]
      local winner = group[1]
      for groupIndex = 2, #group do
        if behaviorRank(group[groupIndex]) > behaviorRank(winner) then
          winner = group[groupIndex]
        end
      end
      local row = winner.row
      ---@param icon Texture
      ---@return boolean
      local function onIcon(icon)
        return paintGroup(icon, group)
      end
      row.onIcon = onIcon
      found[#found + 1] = row
    end
  end

  table.sort(found, function(left, right)
    return strcmputf8i(left.title or left.id, right.title or right.id) < 0
  end)

  for index = 1, #found do
    local row = found[index]
    row.order = index
    present[row.id] = true
    adopt(row)
  end

  TableForEach(known, function(row, id)
    if not present[id] then
      row.enabled = false
    end
  end)

  Helpers:KeepHidden(compartment)
  Buttons:Layout()
  collecting = false
  if queued then
    queued = false
    collectAddons()
  end
end

Buttons:OnEnable(function()
  if LibDBIcon then
    LibDBIcon.RegisterCallback(Buttons, "LibDBIcon_IconCreated", collectAddons)
    hooksecurefunc(LibDBIcon, "Refresh", collectAddons)
  end
  hooksecurefunc(compartment, "RegisterAddon", collectAddons)
  hooksecurefunc(compartment, "RegisterAddons", collectAddons)
  Events:RegisterEvent({ "ADDON_LOADED", "PLAYER_ENTERING_WORLD", "LOADING_SCREEN_DISABLED" }, collectAddons, true)
  collectAddons()
  C_Timer.After(2, collectAddons)
end)

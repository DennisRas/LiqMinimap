---@class LMM_Addon
local addon = select(2, ...)

---@class LMM_Buttons
local Buttons = {}
addon.Buttons = Buttons

local Button = addon.Button
local Constants = addon.Constants
local Container = addon.Container
local LiqUI = addon.libs.LiqUI
local Events = LiqUI.Events

local holding = false
local deferred = false
local hovered = false
local ready = false

local watchingMenu = false

---@type LMM_CollectionButton[]
local rows = {}

---@type LMM_Container[]
local containerList = {}

---@type table<LMM_ContainerId, LMM_Container>
local containers = {}

---@type (fun())[]
local starters = {}

---@type (fun(): boolean)[]
local hiders = {}

---@param callback fun()
function Buttons:OnEnable(callback)
  starters[#starters + 1] = callback
end

---@param callback fun(): boolean
function Buttons:OnHideDefault(callback)
  hiders[#hiders + 1] = callback
end

---@param row LMM_CollectionButton
---@return boolean
local function isEnabled(row)
  local gate = row.enabled
  if gate == nil or gate == true then
    return true
  end
  if gate == false then
    return false
  end
  return gate() == true
end

---@param row LMM_CollectionButton
---@return boolean
local function isActive(row)
  if not row.active then
    return false
  end
  return row.active() == true
end

---@param row LMM_CollectionButton
---@return LMM_ShowId
local function modeOf(row)
  return row.mode or Constants.show.Hover
end

---@return boolean
local function attentionOpen()
  if Menu.GetManager():IsAnyMenuOpen() then
    return true
  end
  return QueueStatusFrame:IsShown()
end

local function watchMenu()
  if Menu.GetManager():IsAnyMenuOpen() then
    C_Timer.After(0.1, watchMenu)
    return
  end
  watchingMenu = false
  addon.Map:SetHovered(false)
end

function Buttons:WatchOpenMenu()
  if watchingMenu or not Menu.GetManager():IsAnyMenuOpen() then
    return
  end
  watchingMenu = true
  C_Timer.After(0.1, watchMenu)
end

---@param row LMM_CollectionButton
---@return boolean
local function isSteady(row)
  if not isEnabled(row) then
    return false
  end
  if isActive(row) then
    return true
  end
  return modeOf(row) == Constants.show.Show
end

---@param row LMM_CollectionButton
---@return boolean
local function wantsRow(row)
  if not isEnabled(row) then
    return false
  end
  if isActive(row) then
    return true
  end
  local mode = modeOf(row)
  if mode == Constants.show.Show then
    return true
  end
  if mode == Constants.show.Hover then
    return hovered or attentionOpen()
  end
  return false
end

---@param row LMM_CollectionButton
---@return string?
local function rowArt(row)
  local atlas = row.atlas
  if type(atlas) == "function" then
    return atlas()
  end
  return atlas
end

---@param button LMM_Button
local function fitIcon(button)
  local icon = button.icon
  local inset = Constants.button.iconInset
  icon:ClearAllPoints()
  icon:SetPoint("TOPLEFT", button, "TOPLEFT", inset, -inset)
  icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -inset, inset)
end

---@param row LMM_CollectionButton
---@return boolean
local function setIcon(row)
  local button = row.button
  if not button then
    return false
  end
  local icon = button.icon
  if row.onIcon then
    if row.onIcon(icon) ~= true then
      return false
    end
    fitIcon(button)
    return true
  end
  local art = rowArt(row)
  if not art then
    icon:SetTexture(nil)
    return false
  end
  if art:find("\\", 1, true) then
    icon:SetTexture(art)
  else
    icon:SetAtlas(art, false)
  end
  fitIcon(button)
  local scale = row.zoom
  local crop = 0
  if scale and scale > 1 then
    crop = (scale - 1) / (2 * scale)
  end
  local biasX = row.offsetX or 0
  local biasY = row.offsetY or 0
  local left = crop - biasX
  local right = 1 - crop - biasX
  local top = crop - biasY
  local bottom = 1 - crop - biasY
  if left < 0 then
    left = 0
  end
  if top < 0 then
    top = 0
  end
  if right > 1 then
    right = 1
  end
  if bottom > 1 then
    bottom = 1
  end
  icon:SetTexCoord(left, right, top, bottom)
  return true
end

local function hideDefaults()
  for index = 1, #hiders do
    if hiders[index]() then
      deferred = true
    end
  end
end

local function onRowEvent()
  Buttons:Layout()
end

local function onMouseDown()
  addon.Map:SetHovered(false)
end

local function onLeaveCombat()
  if not deferred then
    return
  end
  deferred = false
  Buttons:Layout()
end

---@param button LMM_Button
---@return boolean
local function canMove(button)
  if InCombatLockdown() and button:IsProtected() then
    deferred = true
    return false
  end
  return true
end

---@param row LMM_CollectionButton
local function attachButton(row)
  local container = containers[row.container]
  local button = Button:New(container.frame, row.secureClick)
  button.row = row
  row.button = button
end

---@param row LMM_CollectionButton
function Buttons:Register(row)
  rows[#rows + 1] = row
  if not ready then
    return
  end
  attachButton(row)
  if row.events then
    Events:RegisterEvent(row.events, onRowEvent, true)
  end
  self:Layout()
end

function Buttons:Layout()
  if not ready or holding then
    return
  end
  holding = true
  hideDefaults()

  table.sort(rows, function(left, right)
    local leftSteady = isSteady(left)
    if leftSteady ~= isSteady(right) then
      return leftSteady
    end
    return left.order < right.order
  end)

  ---@type table<LMM_ContainerId, LMM_Button[]>
  local shown = {}
  for index = 1, #containerList do
    shown[containerList[index].id] = {}
  end

  for index = 1, #rows do
    local row = rows[index]
    local button = row.button
    local list = shown[row.container]
    if button and list and wantsRow(row) and setIcon(row) then
      if canMove(button) then
        button:Show()
      end
      if button:IsShown() then
        list[#list + 1] = button
      end
    elseif button then
      if canMove(button) then
        button:Hide()
      elseif button:IsShown() then
        list[#list + 1] = button
      end
    end
  end

  for index = 1, #containerList do
    local container = containerList[index]
    container:Layout(shown[container.id])
  end

  holding = false
end

---@param isHovered boolean
function Buttons:SetHover(isHovered)
  if hovered == isHovered then
    return
  end
  hovered = isHovered
  self:Layout()
end

---@return boolean
function Buttons:IsAttentionOpen()
  return attentionOpen()
end

---@return boolean
function Buttons:IsMouseOver()
  for index = 1, #containerList do
    if containerList[index].frame:IsMouseOver() then
      return true
    end
  end
  return false
end

function Buttons:Enable()
  local gap = Constants.containerGap
  local containerId = Constants.container

  ---@type LMM_ContainerOptions
  local defaultOptions = {
    id = containerId.Default,
    point = "TOPRIGHT",
    relativePoint = "TOPLEFT",
    offsetX = -gap,
    offsetY = 0,
    stack = "column",
  }
  ---@type LMM_ContainerOptions
  local addonsOptions = {
    id = containerId.Addons,
    point = "TOPLEFT",
    relativePoint = "BOTTOMLEFT",
    offsetX = 0,
    offsetY = -gap,
    stack = "wrap",
  }
  local defaultContainer = Container:New(defaultOptions)
  local addonsContainer = Container:New(addonsOptions)
  containerList = { defaultContainer, addonsContainer }
  containers[defaultContainer.id] = defaultContainer
  containers[addonsContainer.id] = addonsContainer

  ready = true
  for index = 1, #rows do
    attachButton(rows[index])
  end
  for index = 1, #rows do
    local events = rows[index].events
    if events then
      Events:RegisterEvent(events, onRowEvent, true)
    end
  end
  for index = 1, #starters do
    starters[index]()
  end

  Events:RegisterEvent("PLAYER_REGEN_ENABLED", onLeaveCombat, true)
  EventRegistry:RegisterFrameEventAndCallback("GLOBAL_MOUSE_DOWN", onMouseDown)
  self:Layout()
end

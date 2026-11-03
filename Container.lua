---@class LMM_Addon
local addon = select(2, ...)

---@class LMM_Container
local Container = {}
addon.Container = Container

---@class LMM_Container
local ContainerMixin = {}

local Constants = addon.Constants

---@param button LMM_Button
---@param offsetX number
---@param offsetY number
local function pointButton(button, offsetX, offsetY)
  if InCombatLockdown() and button:IsProtected() then
    return
  end
  local parent = button:GetParent()
  if not parent then
    return
  end
  button:ClearAllPoints()
  button:SetPoint("TOPLEFT", parent, "TOPLEFT", offsetX, offsetY)
end

---@param buttons LMM_Button[]
function ContainerMixin:Layout(buttons)
  local buttonStyle = Constants.button
  local size = buttonStyle.size
  local gap = buttonStyle.gap
  local count = #buttons
  local frame = self.frame

  if self.stack == "column" then
    local offset = 0
    for index = 1, count do
      local button = buttons[index]
      pointButton(button, 0, -offset)
      offset = offset + size + gap
    end
    if count == 0 then
      frame:SetSize(size, 1)
    else
      frame:SetSize(size, offset - gap)
    end
    frame:Show()
    return
  end

  if count == 0 then
    frame:SetSize(size, 1)
    frame:Hide()
    return
  end

  local stride = size + gap
  local columns = math.floor((Constants.map.size + gap) / stride)
  if columns < 1 then
    columns = 1
  end
  local column = 0
  local row = 0
  for index = 1, count do
    local button = buttons[index]
    pointButton(button, column * stride, -(row * stride))
    column = column + 1
    if column >= columns then
      column = 0
      row = row + 1
    end
  end
  local widthColumns = count
  if widthColumns > columns then
    widthColumns = columns
  end
  local heightRows = math.ceil(count / columns)
  frame:SetSize((widthColumns * stride) - gap, (heightRows * stride) - gap)
  frame:Show()
end

---@param options LMM_ContainerOptions
---@return LMM_Container
function Container:New(options)
  if not options or not options.id or not options.stack then
    error("Container needs an id and a stack")
  end

  local frame = CreateFrame("Frame", nil, MinimapCluster)
  frame:SetPoint(options.point, Minimap, options.relativePoint, options.offsetX, options.offsetY)
  frame:SetSize(Constants.button.size, 1)
  frame:EnableMouse(true)
  frame:SetScript("OnEnter", function()
    addon.Map:SetHovered(true)
  end)
  frame:SetScript("OnLeave", function()
    addon.Map:SetHovered(false)
  end)
  MinimapCluster:MarkIgnoreInLayout(frame)

  local container = Mixin({}, ContainerMixin)
  ---@type LMM_Container
  local instance = container
  instance.frame = frame
  instance.id = options.id
  instance.stack = options.stack
  return instance
end

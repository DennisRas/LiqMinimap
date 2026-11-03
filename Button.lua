---@class LMM_Addon
local addon = select(2, ...)

---@class LMM_Button
local Button = {}
addon.Button = Button

---@class LMM_Button
local ButtonMixin = {}

local Constants = addon.Constants

---@param texture Texture
---@param parent Frame
---@param inset number
local function setTextureInset(texture, parent, inset)
  texture:SetPoint("TOPLEFT", parent, "TOPLEFT", inset, -inset)
  texture:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -inset, inset)
end

---@param parent Frame
---@param sublevel number
---@return Texture
local function createWhiteTexture(parent, sublevel)
  local texture = parent:CreateTexture(nil, "BACKGROUND", nil, sublevel)
  texture:SetTexture(Constants.media.squareMask)
  return texture
end

---@param button LMM_Button
---@param borderColor ColorRGBAData
---@param backgroundColor ColorRGBAData
local function setButtonColors(button, borderColor, backgroundColor)
  button.border:SetVertexColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
  button.background:SetVertexColor(backgroundColor.r, backgroundColor.g, backgroundColor.b, backgroundColor.a)
end

function ButtonMixin:OnEnter()
  local buttonStyle = Constants.button
  setButtonColors(self, buttonStyle.borderHoverColor, buttonStyle.backgroundHoverColor)
  local row = self.row
  if not row then
    return
  end
  if row.onEnter then
    row.onEnter(self)
    return
  end
  if not row.title then
    return
  end
  GameTooltip:SetOwner(self, "ANCHOR_LEFT")
  GameTooltip:SetText(row.title, 1, 1, 1)
  GameTooltip:Show()
end

function ButtonMixin:OnLeave()
  local buttonStyle = Constants.button
  setButtonColors(self, buttonStyle.borderColor, buttonStyle.backgroundColor)
  GameTooltip_Hide()
  local row = self.row
  if row and row.onLeave then
    row.onLeave(self)
  end
end

---@param mouseButton string
function ButtonMixin:OnClick(mouseButton)
  GameTooltip_Hide()
  local row = self.row
  if row and row.onClick then
    row.onClick(mouseButton)
  end
end

---@param parent Frame
---@param secureClick Button?
---@return LMM_Button
function Button:New(parent, secureClick)
  if not parent then
    error("Button needs a parent")
  end

  local buttonStyle = Constants.button
  local template = nil
  if secureClick then
    template = "SecureActionButtonTemplate"
  end
  local shell = CreateFrame("Button", nil, parent, template)
  shell:SetSize(buttonStyle.size, buttonStyle.size)
  shell:RegisterForClicks("AnyUp")
  if secureClick then
    shell:SetAttribute("type", "click")
    shell:SetAttribute("clickbutton", secureClick)
    shell:SetAttribute("useOnKeyDown", false)
  end

  local border = createWhiteTexture(shell, 0)
  border:SetAllPoints()

  local background = createWhiteTexture(shell, 1)
  setTextureInset(background, shell, buttonStyle.borderSize)

  local icon = shell:CreateTexture(nil, "ARTWORK")
  setTextureInset(icon, shell, buttonStyle.iconInset)

  Mixin(shell, ButtonMixin)
  ---@type LMM_Button
  local button = shell
  button.border = border
  button.background = background
  button.icon = icon
  setButtonColors(button, buttonStyle.borderColor, buttonStyle.backgroundColor)
  button:SetScript("OnEnter", ButtonMixin.OnEnter)
  button:SetScript("OnLeave", ButtonMixin.OnLeave)
  if secureClick then
    button:SetScript("PostClick", ButtonMixin.OnClick)
  else
    button:SetScript("OnClick", ButtonMixin.OnClick)
  end
  return button
end

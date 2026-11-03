---@class LMM_Addon
local addon = select(2, ...)

---@class LMM_Constants
local Constants = {}
addon.Constants = Constants

Constants.prefix = format("<%s> ", addon.name)

Constants.media = {
  squareMask = [[Interface\BUTTONS\WHITE8X8]],
  border = [[Interface\Tooltips\UI-Tooltip-Border]],
  textFont = [[Fonts\FRIZQT__.TTF]],
}

---@enum LMM_ShowId
Constants.show = {
  Hidden = "hidden",
  Hover = "hover",
  Show = "show",
}

---@enum LMM_ContainerId
Constants.container = {
  Default = "default",
  Addons = "addons",
}

Constants.map = {
  size = 200,
  labelSize = 12,
  labelInset = 4,
  border = {
    edgeSize = 16,
    inset = 4,
    outset = 3,
    color = { r = 0, g = 0, b = 0, a = 0.5 },
  },
}

Constants.button = {
  size = 24,
  gap = 2,
  iconInset = 4,
  backgroundColor = { r = 0, g = 0, b = 0, a = 0.85 },
  backgroundHoverColor = { r = 0.15, g = 0.15, b = 0.15, a = 0.85 },
  borderSize = 2,
  borderColor = { r = 0, g = 0, b = 0, a = 0.5 },
  borderHoverColor = { r = 0.7, g = 0.5, b = 0.2, a = 0.5 },
}

Constants.containerGap = 4

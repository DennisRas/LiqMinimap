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
  Always = "always",
  Hover = "hover",
  Active = "active",
  Hidden = "hidden",
}

---@enum LMM_CollectionId
Constants.collection = {
  Game = "game",
  Addons = "addons",
}

Constants.layout = {
  size = 200,
  borderSize = 4,
  borderOutset = 3,
  iconSize = 24,
  iconGap = 2,
  columnGap = 4,
  textSize = 12,
  textInset = 4,
}

Constants.colors = {
  border = { r = 0, g = 0, b = 0, a = 0.5 },
}

local show = Constants.show
local game = Constants.collection.Game

Constants.chrome = {
  zone = { show = show.Hover },
  clock = { show = show.Always },
  coords = { show = show.Hover },
  zoom = { show = show.Hidden },
  compartment = { show = show.Hidden },
  tracking = { show = show.Hover, collection = game, order = 1 },
  calendar = { show = show.Active, collection = game, order = 2 },
  mail = { show = show.Active, collection = game, order = 3 },
  craftingOrders = { show = show.Active, collection = game, order = 4 },
  queue = { show = show.Active, collection = game, order = 5 },
  landing = { show = show.Active, collection = game, order = 6 },
  difficulty = { show = show.Active, collection = game, order = 7 },
}

---@class LMM_Addon
local addon = select(2, ...)

local Data = addon.Data
local LibAceAddon = addon.libs.AceAddon
local LiqUI = addon.libs.LiqUI

---@class LMM_Core
local Core = LibAceAddon:NewAddon(addon.name, "AceConsole-3.0")
addon.Core = Core

function Core:OnInitialize()
  if not LiqUI or not LiqUI.Utils then
    self:Print("This version needs a newer LiqUI embed. Reload after updating LiqUI.")
    return
  end

  Data:Initialize()
  addon.logger = LiqUI:NewLogger({
    name = addon.name,
    title = addon.title,
    storage = Data.db.global.logs,
    maxLines = 10000,
  })
end

function Core:OnEnable()
  if not addon.logger then
    return
  end
  addon.Shape:Enable()
  addon.Icons:Enable()
  addon.Cluster:Enable()
end

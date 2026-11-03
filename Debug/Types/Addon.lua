---@class LMM_Addon
---@field name string
---@field title string
---@field version string
---@field notes string
---@field libs LMM_Libs
---@field Core LMM_Core
---@field Data LMM_Data
---@field Constants LMM_Constants
---@field Helpers LMM_Helpers
---@field Shape LMM_Shape
---@field Cluster LMM_Cluster
---@field Icons LMM_Icons
---@field logger LiqUI_LoggerHandle|nil

---@class LMM_Cluster

---@class LMM_Core : AceAddon, AceConsole-3.0

---@class LMM_Helpers

---@class LMM_Icons

---@class LMM_LibDBIcon
---@field GetButtonList fun(self: LMM_LibDBIcon): string[]
---@field GetMinimapButton fun(self: LMM_LibDBIcon, name: string): Frame?
---@field RegisterCallback fun(target: table, event: string, callback: fun(event: string, button: Frame, name: string))

---@class LMM_Libs
---@field AceDB AceDB-3.0
---@field AceAddon AceAddon-3.0
---@field LibDBIcon LMM_LibDBIcon
---@field LiqUI LiqUI

---@class LMM_Shape

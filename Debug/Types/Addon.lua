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
---@field Button LMM_Button
---@field Buttons LMM_Buttons
---@field Container LMM_Container
---@field Map LMM_Map
---@field logger LiqUI_LoggerHandle|nil

---@class LMM_AddonCandidate
---@field kind "ldbicon" | "button" | "compartment"
---@field score number
---@field keys string[]
---@field row LMM_CollectionButton
---@field launcher LMM_LauncherButton?
---@field entry LMM_CompartmentRow?

---@class LMM_AddonCompartment : Frame
---@field registeredAddons LMM_CompartmentRow[]?
---@field RegisterAddon fun(self: LMM_AddonCompartment, data: LMM_CompartmentRow)
---@field RegisterAddons fun(self: LMM_AddonCompartment)

---@class LMM_Button : Frame
---@field border Texture
---@field background Texture
---@field icon Texture
---@field row LMM_CollectionButton

---@class LMM_Buttons

---@class LMM_CollectionButton
---@field id string
---@field title string?
---@field container LMM_ContainerId
---@field enabled boolean|fun(): boolean
---@field mode LMM_ShowId?
---@field order number
---@field atlas string|fun(): string?
---@field zoom number?
---@field offsetX number?
---@field offsetY number?
---@field active? fun(): boolean
---@field events string[]?
---@field onIcon (fun(icon: Texture): boolean)?
---@field onEnter fun(button: LMM_Button)?
---@field onLeave fun(button: LMM_Button)?
---@field onClick fun(mouseButton: string)?
---@field secureClick Button?
---@field button LMM_Button?

---@class LMM_CompartmentClick
---@field buttonName string

---@class LMM_CompartmentRow
---@field text string
---@field icon string|number|nil
---@field func fun(data: LMM_CompartmentRow, input: LMM_CompartmentClick, menu: Frame?)?
---@field funcOnEnter fun(button: Frame)?
---@field funcOnLeave fun(button: Frame)?

---@alias LMM_ContainerStack "column" | "wrap"

---@class LMM_Container
---@field frame Frame
---@field id LMM_ContainerId
---@field stack LMM_ContainerStack

---@class LMM_ContainerOptions
---@field id LMM_ContainerId
---@field point FramePoint
---@field relativePoint FramePoint
---@field offsetX number
---@field offsetY number
---@field stack LMM_ContainerStack

---@class LMM_Core : AceAddon, AceConsole-3.0

---@class LMM_Helpers

---@class LMM_LauncherButton : Button
---@field icon Texture?
---@field db LMM_LauncherDB?
---@field dataObject LMM_LauncherObject?
---@field compartmentData LMM_CompartmentRow?

---@class LMM_LauncherDB
---@field hide boolean?
---@field showInCompartment boolean?

---@class LMM_LauncherObject
---@field label string?
---@field text string?
---@field icon string|number|nil
---@field OnClick fun(self: Frame, mouseButton: string)?
---@field OnEnter fun(self: Frame)?
---@field OnLeave fun(self: Frame)?
---@field OnTooltipShow fun(tooltip: GameTooltip)?

---@class LMM_LibDBIcon
---@field tooltip GameTooltip
---@field GetButtonList fun(self: LMM_LibDBIcon): string[]
---@field GetMinimapButton fun(self: LMM_LibDBIcon, name: string): LMM_LauncherButton?
---@field Refresh fun(self: LMM_LibDBIcon, name: string, saved: LMM_LauncherDB?)
---@field RegisterCallback fun(target: table, event: string, callback: fun(event: string, button: LMM_LauncherButton, name: string))

---@class LMM_Libs
---@field AceDB AceDB-3.0
---@field AceAddon AceAddon-3.0
---@field LibDBIcon LMM_LibDBIcon
---@field LiqUI LiqUI

---@class LMM_Map

---@class LMM_ButtonStyle
---@field size number
---@field gap number
---@field iconInset number
---@field backgroundColor ColorRGBAData
---@field backgroundHoverColor ColorRGBAData
---@field borderSize number
---@field borderColor ColorRGBAData
---@field borderHoverColor ColorRGBAData

---@class LMM_Constants
---@field prefix string
---@field media { squareMask: string, border: string, textFont: string }
---@field show table<string, LMM_ShowId>
---@field container table<string, LMM_ContainerId>
---@field map LMM_MapLayout
---@field button LMM_ButtonStyle
---@field containerGap number

---@class LMM_MapBorder
---@field edgeSize number
---@field inset number
---@field outset number
---@field color ColorRGBAData

---@class LMM_MapLayout
---@field size number
---@field labelSize number
---@field labelInset number
---@field border LMM_MapBorder

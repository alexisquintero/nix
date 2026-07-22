-- Banish GlobalProtect's window to Desktop 13 (the "shadow realm") whenever it
-- appears, so its startup popup doesn't interrupt the current desktop.

local spaces = require("hs.spaces")
local window = require("hs.window")

local M = {}

local GLOBALPROTECT_BUNDLE = "com.paloaltonetworks.GlobalProtect.client"
local TARGET_DESKTOP = 13

-- Resolve the space ID for the target desktop number (its position in the
-- current screen's Mission Control ordering).
local function targetSpaceId()
  local ordered = spaces.spacesForScreen()
  if not ordered then return nil end
  return ordered[TARGET_DESKTOP]
end

local function banish(win)
  if not win then return end
  local spaceId = targetSpaceId()
  if not spaceId then return end
  -- Small delay so the window is fully realized before moving it.
  hs.timer.doAfter(0.3, function()
    spaces.moveWindowToSpace(win, spaceId)
  end)
end

function M.start()
  M.filter = window.filter.new(false)
  M.filter:setAppFilter("GlobalProtect", { allowRoles = "*" })

  M.filter:subscribe(window.filter.windowCreated, function(win)
    banish(win)
  end)

  -- Also handle a window that already exists at load time.
  local gp = hs.application.get(GLOBALPROTECT_BUNDLE)
  if gp then
    for _, win in ipairs(gp:allWindows()) do
      banish(win)
    end
  end
end

return M

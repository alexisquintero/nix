-- Suppress GlobalProtect's startup/status popup so it doesn't interrupt the
-- current desktop.
--
-- The popup is an AXSystemDialog: it can't be moved between Spaces
-- (moveWindowToSpace silently fails) and can't be closed/minimized via the
-- accessibility API. But hiding the whole app (app:hide()) removes the popup
-- while keeping GlobalProtect running (VPN stays connected). So we watch for
-- the popup appearing and hide the app.

local windowfilter = require("hs.window.filter")
local application = require("hs.application")

local M = {}

local GLOBALPROTECT_BUNDLE = "com.paloaltonetworks.GlobalProtect.client"

local function hideGlobalProtect()
  local gp = application.get(GLOBALPROTECT_BUNDLE)
  if gp then gp:hide() end
end

function M.start()
  -- Detect the popup window appearing (AXSystemDialog is only visible via a
  -- window.filter with allowRoles = "*").
  M.filter = windowfilter.new(false):setAppFilter("GlobalProtect", { allowRoles = "*" })
  M.filter:subscribe(windowfilter.windowCreated, function()
    -- Let the dialog fully appear, then hide the app.
    hs.timer.doAfter(0.3, hideGlobalProtect)
  end)

  -- Cover the login-time race (GlobalProtect may show its popup before
  -- Hammerspoon finishes loading): poll for the first few seconds and hide it.
  M.startupPoll = hs.timer.doEvery(1, function()
    local gp = application.get(GLOBALPROTECT_BUNDLE)
    if gp and #M.filter:getWindows() > 0 then
      hideGlobalProtect()
    end
  end)
  -- Stop the startup poll after 15s.
  hs.timer.doAfter(15, function()
    if M.startupPoll then M.startupPoll:stop(); M.startupPoll = nil end
  end)
end

return M

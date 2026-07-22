-- Option+Q: toggle between the current and last-used desktop (Space).
--
-- hs.spaces.gotoSpace is unreliable and doesn't move keyboard focus. Instead we
-- track which *desktop number* is active and replay the native macOS
-- "switch to desktop N" shortcut (Option+N), which switches AND focuses
-- correctly. (macOS has no native "previous desktop" command, so this stays.)

local spaces = require("hs.spaces")
local eventtap = require("hs.eventtap")

local M = {}

-- Keys that macOS "Switch to Desktop N" is bound to (Option+key), indexed by
-- desktop number. Desktops 1-9 -> digits, 10 -> "0", 11 -> "-", 12 -> "=".
local desktopKey = {
  [1] = "1", [2] = "2", [3] = "3", [4] = "4", [5] = "5",
  [6] = "6", [7] = "7", [8] = "8", [9] = "9", [10] = "0",
  [11] = "-", [12] = "=",
}

-- Map the currently focused space ID to its desktop number (its position in the
-- Mission Control ordering for the current screen).
local function currentDesktopNumber()
  local focused = spaces.focusedSpace()
  local ordered = spaces.spacesForScreen()
  if not ordered then return nil end
  for index, spaceId in ipairs(ordered) do
    if spaceId == focused then return index end
  end
  return nil
end

local previousDesktop = nil
local currentDesktop = currentDesktopNumber()

function M.start()
  M.watcher = spaces.watcher.new(function()
    local now = currentDesktopNumber()
    if now and now ~= currentDesktop then
      previousDesktop = currentDesktop
      currentDesktop = now
    end
  end)
  M.watcher:start()

  hs.hotkey.bind({ "alt" }, "q", function()
    local target = previousDesktop
    if not target then
      hs.alert.show("No previous desktop yet")
      return
    end
    local key = desktopKey[target]
    if key then
      -- Native "Switch to Desktop N" = Option + key. Switches and focuses.
      eventtap.keyStroke({ "alt" }, key, 0)
    else
      hs.alert.show("No shortcut for desktop " .. tostring(target))
    end
  end)
end

return M

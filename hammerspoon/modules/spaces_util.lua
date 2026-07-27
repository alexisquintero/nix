-- Shared helpers for desktop/Space navigation used by desktop_toggle and
-- desktop_nav. Switching is done by replaying the native "Switch to Desktop N"
-- shortcut (Option+key) because hs.spaces.gotoSpace is unreliable and doesn't
-- move keyboard focus.

local spaces = require("hs.spaces")
local eventtap = require("hs.eventtap")

local M = {}

-- Keys macOS "Switch to Desktop N" is bound to (Option+key), by desktop number.
-- Desktops 1-9 -> digits, 10 -> "0", 11 -> "-", 12 -> "=".
M.desktopKey = {
  [1] = "1", [2] = "2", [3] = "3", [4] = "4", [5] = "5",
  [6] = "6", [7] = "7", [8] = "8", [9] = "9", [10] = "0",
  [11] = "-", [12] = "=",
}

-- Current desktop's 1-based index in the Mission Control ordering, or nil.
function M.currentIndex()
  local focused = spaces.focusedSpace()
  for i, sid in ipairs(spaces.spacesForScreen() or {}) do
    if sid == focused then return i end
  end
end

-- Switch to (and focus) desktop N by replaying its native Option+key shortcut.
function M.switchTo(index)
  local key = M.desktopKey[index]
  if key then eventtap.keyStroke({ "alt" }, key, 0) end
end

return M

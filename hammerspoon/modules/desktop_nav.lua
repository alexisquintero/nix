-- Option+N / Option+P: go to next / previous desktop (Space).
--
-- Replays the native macOS "switch to desktop N" shortcut (Control+N) for the
-- adjacent desktop, which switches AND focuses correctly -- the same proven
-- mechanism used by desktop_toggle. (Control+Arrow via synthetic events is
-- unreliable for triggering the space-switch, so we avoid it.)

local spaces = require("hs.spaces")
local eventtap = require("hs.eventtap")

local M = {}

-- Keys that macOS "Switch to Desktop N" is bound to, indexed by desktop number.
local desktopKey = {
  [1] = "1", [2] = "2", [3] = "3", [4] = "4", [5] = "5",
  [6] = "6", [7] = "7", [8] = "8", [9] = "9", [10] = "0",
  [11] = "-", [12] = "=",
}

-- Current desktop number = position of the focused space in Mission Control order.
local function currentDesktopNumber()
  local focused = spaces.focusedSpace()
  local ordered = spaces.spacesForScreen()
  if not ordered then return nil end
  for index, spaceId in ipairs(ordered) do
    if spaceId == focused then return index end
  end
  return nil
end

local function switchTo(desktop)
  local key = desktopKey[desktop]
  if key then
    eventtap.keyStroke({ "ctrl" }, key, 0)
  end
end

function M.start()
  hs.hotkey.bind({ "alt" }, "n", function()
    local cur = currentDesktopNumber()
    if cur then switchTo(cur + 1) end
  end)

  hs.hotkey.bind({ "alt" }, "p", function()
    local cur = currentDesktopNumber()
    if cur and cur > 1 then switchTo(cur - 1) end
  end)
end

return M

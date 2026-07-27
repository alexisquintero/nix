-- Option+n / Option+p: go to the next / previous non-empty desktop (wrapping).
--
-- "Non-empty" = the space has at least one standard application window.
-- hs.spaces.windowsForSpace lists many false positives (overlays etc.), so we
-- cross-reference against hs.window.filter's standard windows.

local spaces = require("hs.spaces")
local windowfilter = require("hs.window.filter")
local util = require("modules.spaces_util")

local M = {}

-- Set of desktop indices (1-based, in Mission Control order) that are non-empty.
local function nonEmpty()
  local real = {}
  for _, w in ipairs(windowfilter.new():getWindows()) do real[w:id()] = true end
  local ordered = spaces.spacesForScreen() or {}
  local result = {}
  for i, sid in ipairs(ordered) do
    for _, wid in ipairs(spaces.windowsForSpace(sid) or {}) do
      if real[wid] then result[i] = true; break end
    end
  end
  return result, #ordered
end

local function go(step)
  local occupied, total = nonEmpty()
  local cur = util.currentIndex()
  if not cur or total == 0 then return end
  for k = 1, total do
    local i = ((cur - 1 + step * k) % total) + 1
    if occupied[i] then
      util.switchTo(i)
      return
    end
  end
end

function M.start()
  hs.hotkey.bind({ "alt" }, "n", function() go(1) end)
  hs.hotkey.bind({ "alt" }, "p", function() go(-1) end)
end

return M

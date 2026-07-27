-- Option+Q: toggle between the current and last-used desktop (Space).
--
-- We track which *desktop number* is active and replay the native macOS "switch
-- to desktop N" shortcut (via spaces_util), which switches AND focuses correctly.
-- (macOS has no native "previous desktop" command, so we track it ourselves.)

local spaces = require("hs.spaces")
local util = require("modules.spaces_util")

local M = {}

local previousDesktop = nil
local currentDesktop = util.currentIndex()

function M.start()
  M.watcher = spaces.watcher.new(function()
    local now = util.currentIndex()
    if now and now ~= currentDesktop then
      previousDesktop = currentDesktop
      currentDesktop = now
    end
  end)
  M.watcher:start()

  hs.hotkey.bind({ "alt" }, "q", function()
    if not previousDesktop then
      hs.alert.show("No previous desktop yet")
      return
    end
    util.switchTo(previousDesktop)
  end)
end

return M

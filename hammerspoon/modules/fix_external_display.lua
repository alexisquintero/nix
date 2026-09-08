-- Automatically re-applies the correct connection mode (RGB, Full range, SDR)
-- to the MAG274QRF-QD external monitor whenever it (re)connects.
--
-- Without this, macOS/the KVM negotiates a bad default (HDR10, YCbCr 4:2:2,
-- Limited range) on every clamshell transition or display reconnect, causing
-- washed out/oversaturated colors. BetterDisplay's free tier has no
-- persistent "protect connection mode" option, so we replicate it here.

local M = {}

local BETTERDISPLAY_BIN = "/Users/alequintero/Applications/BetterDisplay.app/Contents/MacOS/BetterDisplay"
local DISPLAY_NAME_LIKE = "MAG274"
local GOOD_CONNECTION_MODE = "5804858359901850112" -- 2560x1440 120Hz 8bit SDR RGB Full

local function applyFix()
  local cmd = string.format(
    "%s set -namelike=%s -connectionMode=%s",
    BETTERDISPLAY_BIN, DISPLAY_NAME_LIKE, GOOD_CONNECTION_MODE
  )
  hs.execute(cmd, true)
end

function M.start()
  M.watcher = hs.screen.watcher.new(function()
    -- Debounce: display reconfiguration fires multiple events in quick
    -- succession (connect, mode change, clamshell transitions, etc).
    if M.debounce then
      M.debounce:stop()
    end
    M.debounce = hs.timer.doAfter(2, function()
      for _, screen in ipairs(hs.screen.allScreens()) do
        if screen:name():find(DISPLAY_NAME_LIKE) then
          applyFix()
          break
        end
      end
    end)
  end)
  M.watcher:start()
end

return M

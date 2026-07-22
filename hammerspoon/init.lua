-- Hammerspoon configuration
--
-- Each piece of functionality lives in its own module under modules/.
-- Add a new feature by creating modules/<name>.lua that returns a table with a
-- `start()` function, then require + start it here.

-- Enable the `hs` command-line tool.
require("hs.ipc")

require("modules.desktop_toggle").start()
require("modules.globalprotect_banish").start()

hs.alert.show("Hammerspoon config loaded")

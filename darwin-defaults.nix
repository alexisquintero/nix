{ ... }:

{
  system.defaults = {
    # ---------------- NSGlobalDomain (System-wide / "Appearance", "Keyboard") --
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";              # Appearance: Dark mode

      # Keyboard: fast key repeat + short delay before repeat.
      KeyRepeat = 2;                             # repeat rate (lower = faster)
      InitialKeyRepeat = 15;                     # delay until repeat (lower = shorter)

      # Keyboard: disable all the "smart" text munging.
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticInlinePredictionEnabled = false;

      # Trackpad / mouse: "natural" scrolling turned OFF (traditional direction).
      "com.apple.swipescrolldirection" = false;

      # Trackpad: force-click enabled.
      "com.apple.trackpad.forceClick" = true;

      # Sound: don't flash the screen on the alert beep.
      "com.apple.sound.beep.flash" = 0;

      # Disable spring-loading of folders (drag-hover to open).
      "com.apple.springing.enabled" = false;
      "com.apple.springing.delay" = 0.5;

      # UI responsiveness: kill window/animation delays.
      NSAutomaticWindowAnimationsEnabled = false;
      NSWindowResizeTime = 0.001;

      # First day of the week = Monday (2).
      AppleKeyboardUIMode = 2;                   # full keyboard access (Tab to all controls)

      # Auto-hide the menu bar.
      _HIHideMenuBar = true;

      # Double-click on a window title bar does nothing (no minimize/zoom).
      AppleActionOnDoubleClick = "None";
    };

    # ---------------- Dock -----------------------------------------------------
    dock = {
      autohide = true;
      autohide-delay = 0.0;                      # no delay before the Dock slides in
      autohide-time-modifier = 0.0;              # instant slide animation
      launchanim = false;                        # no bounce on launch
      expose-animation-duration = 0.0;
      mru-spaces = false;                        # don't auto-reorder Spaces by use
      show-recents = false;
      show-process-indicators = false;
      tilesize = 16;                             # very small Dock icons
      # Hot corner: bottom-right = 14 (Quick Note is 14; 1=disabled).
      wvous-br-corner = 14;
      # springboard (Launchpad) animation durations zeroed.
      springboard-show-duration = 0.0;
      springboard-hide-duration = 0.0;
      springboard-page-duration = 0.0;
    };

    # ---------------- Finder ---------------------------------------------------
    finder = {
      # Desktop: show external drives + removable media, hide internal HDDs.
      ShowExternalHardDrivesOnDesktop = true;
      ShowHardDrivesOnDesktop = false;
      ShowRemovableMediaOnDesktop = true;
      # iCloud Drive for Desktop & Documents turned off.
      FXICloudDriveEnabled = false;
      # (com.apple.finder DisableAllAnimations = 1 has no typed nix-darwin
      #  option; see CustomUserPreferences below.)
    };

    # ---------------- Trackpad -------------------------------------------------
    trackpad = {
      Clicking = false;                          # tap-to-click OFF
      Dragging = false;
      TrackpadThreeFingerDrag = false;
      TrackpadThreeFingerTapGesture = 0;         # three-finger tap (lookup) OFF
      TrackpadRightClick = true;
    };

    # ---------------- Screenshots ---------------------------------------------
    screencapture = {
      target = "clipboard";                      # screenshots go to clipboard, not files
    };

    # ---------------- Menu bar clock ------------------------------------------
    menuExtraClock = {
      ShowDayOfWeek = true;
      ShowDate = 0;                              # 0 = never show the date
      ShowAMPM = true;
    };

    # ---------------- Stage Manager / Desktop (com.apple.WindowManager) --------
    WindowManager = {
      AutoHide = true;                           # Stage Manager auto-hide strip
      HideDesktop = true;                        # hide desktop icons when clicking wallpaper
    };

    # ---------------- System-level domains (/Library/Preferences) --------------
    CustomSystemPreferences = {
      # Displays: "Automatically adjust brightness" = OFF (ambient light sensor).
      "com.apple.iokit.AmbientLightSensor" = {
        "Automatic Display Enabled" = 0;
      };
    };

    # ---------------- Options without dedicated typed attributes ---------------
    # These live under CustomUserPreferences so they can be written verbatim.
    CustomUserPreferences = {
      "com.apple.finder" = {
        DisableAllAnimations = true;             # Finder: turn off window animations
      };
      NSGlobalDomain = {
        AppleMiniaturizeOnDoubleClick = false;
        AppleAntiAliasingThreshold = 4;
        AppleFirstWeekday = { gregorian = 2; };  # week starts Monday
        # Instant Quick Look / column-browser animations.
        NSBrowserColumnAnimationSpeedMultiplier = 0;
        QLPanelAnimationDuration = 0;
        NSToolbarFullScreenAnimationDuration = 0;
        # Scroll wheel scaling reduced slightly.
        "com.apple.scrollwheel.scaling" = 0.75;
      };

      # Mission Control keyboard shortcuts (System Settings > Keyboard >
      # Keyboard Shortcuts > Mission Control). parameters = [ char keyCode
      # modifierFlags ]; option flag = 524288. Desktop switching is native
      # Option+<key>, which frees all Ctrl+<number> combos for apps like neovim.
      "com.apple.symbolichotkeys".AppleSymbolicHotKeys = {
        # Switch to Desktop N -> Option+<key>
        "118" = { enabled = 1; value = { type = "standard"; parameters = [ 49 18 524288 ]; }; };  # Opt+1  -> Desktop 1
        "119" = { enabled = 1; value = { type = "standard"; parameters = [ 50 19 524288 ]; }; };  # Opt+2  -> Desktop 2
        "120" = { enabled = 1; value = { type = "standard"; parameters = [ 51 20 524288 ]; }; };  # Opt+3  -> Desktop 3
        "121" = { enabled = 1; value = { type = "standard"; parameters = [ 52 21 524288 ]; }; };  # Opt+4  -> Desktop 4
        "122" = { enabled = 1; value = { type = "standard"; parameters = [ 53 23 524288 ]; }; };  # Opt+5  -> Desktop 5
        "123" = { enabled = 1; value = { type = "standard"; parameters = [ 54 22 524288 ]; }; };  # Opt+6  -> Desktop 6
        "124" = { enabled = 1; value = { type = "standard"; parameters = [ 55 26 524288 ]; }; };  # Opt+7  -> Desktop 7
        "125" = { enabled = 1; value = { type = "standard"; parameters = [ 56 28 524288 ]; }; };  # Opt+8  -> Desktop 8
        "126" = { enabled = 1; value = { type = "standard"; parameters = [ 57 25 524288 ]; }; };  # Opt+9  -> Desktop 9
        "127" = { enabled = 1; value = { type = "standard"; parameters = [ 48 29 524288 ]; }; };  # Opt+0  -> Desktop 10
        "128" = { enabled = 1; value = { type = "standard"; parameters = [ 45 27 524288 ]; }; };  # Opt+-  -> Desktop 11
        "129" = { enabled = 1; value = { type = "standard"; parameters = [ 61 24 524288 ]; }; };  # Opt+=  -> Desktop 12
        # Move one space left / right
        "79" = { enabled = 1; value = { type = "standard"; parameters = [ 112 35 524288 ]; }; };  # Opt+p  -> move space left
        "81" = { enabled = 1; value = { type = "standard"; parameters = [ 110 45 524288 ]; }; };  # Opt+n  -> move space right
      };
    };
  };

  # ---------------- Battery: display dimming ---------------------------------
  # System Settings > Battery > Options > "Slightly dim the display on battery"
  # = OFF. This is a power-management setting with no system.defaults option;
  # under nix-darwin it would be an activation script:
  #   system.activationScripts.postActivation.text = ''
  #     /usr/bin/pmset -b lessbright 0
  #   '';

  # ---------------- Keyboard modifier remap (Caps Lock / Control) -------------
  # The live system has a HID modifier remapping under
  # com.apple.HIToolbox `com.apple.keyboard.modifiermapping.0-0-0`.
  # Decoded, it disables Caps Lock (0x39) and Right Control (0xe4) and shuffles
  # Left Control (0xe0). nix-darwin's `system.keyboard.userKeyMapping` only maps
  # a subset of keys and does NOT round-trip these Apple-vendor HID codes
  # cleanly, so it is left as a documented note rather than a possibly-wrong
  # declaration. Re-create it via System Settings > Keyboard > Modifier Keys,
  # or read the raw mapping with:
  #   defaults -currentHost read -g com.apple.keyboard.modifiermapping.0-0-0
  #
  # system.keyboard.enableKeyMapping = true;
  # system.keyboard.userKeyMapping = [ ... ];
}

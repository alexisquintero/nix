{ config, pkgs, lib, ... }:

# To enable niri:
# 1. Import this file in home-alexis.nix (instead of xmonad.nix)
# 2. Disable xsession / X11 window manager in linux.nix
# 3. Disable sxhkd service — niri binds handle keys directly (swhkd isn't in nixpkgs yet)
# 4. Replace dunst with mako (Wayland notification daemon) if desired
# 5. Remove useX11LegacyScreenshot from flameshot settings (no longer needed; niri has
#    its own screenshot binds below)
# 6. Wallpaper: add swaybg or swww to spawn-at-startup if desired

let
  bg     = "#0f2a3f";
  fg     = "#f6d6bd";
  accent = "#c3a38a";

  # Start waybar hidden — SIGUSR1 toggles visibility
  waybar-hidden = pkgs.writeShellScriptBin "waybar-hidden" ''
    waybar &
    sleep 0.5
    pkill -SIGUSR1 waybar
  '';

  # niri KDL settings use attrsOf (KDL-value): bare scalars/lists for single-arg
  # nodes, `{}` for flag/leaf nodes, `_props` for named properties, `_children`
  # for ordered/repeated child nodes. See:
  # https://nix-community.github.io/home-manager/options.xhtml#opt-wayland.windowManager.niri.settings
  workspaceBinds = lib.listToAttrs (
    lib.concatMap (n: [
      (lib.nameValuePair "Mod+${toString n}"       { focus-workspace = n; })
      (lib.nameValuePair "Mod+Shift+${toString n}" { move-column-to-workspace = n; })
    ]) (lib.range 1 9)
  );
in
{
  wayland.windowManager.niri = {
    enable = true;
    package = pkgs.niri;

    settings = {
      prefer-no-csd = { };

      screenshot-path = "~/Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png";

      input = {
        # Derived from home.keyboard — single source of truth
        keyboard.xkb = {
          layout  = config.home.keyboard.layout;
          variant = config.home.keyboard.variant;
          options = builtins.concatStringsSep "," config.home.keyboard.options;
        };
        touchpad = {
          tap            = { };
          natural-scroll = { };
        };
      };

      layout = {
        gaps = 8;
        center-focused-column = "never";
        default-column-width.proportion = 0.5;
        focus-ring = {
          width          = 2;
          active-color   = accent;
          inactive-color = bg;
        };
      };

      # Two spawn-at-startup nodes can't share one attrset key, so they're
      # expressed via _children (home-manager's repeated-node mechanism —
      # same pattern used for repeated `workspace` nodes upstream).
      _children = [
        { spawn-at-startup = [ "${waybar-hidden}/bin/waybar-hidden" ]; }
        { spawn-at-startup = [ (lib.getExe pkgs.fcitx5) "--replace" "-d" ]; }
      ];

      binds = workspaceBinds // {
        # Terminal & apps
        "Mod+Return".spawn = [ (lib.getExe pkgs.kitty) ];
        "Mod+F".spawn      = [ (lib.getExe pkgs.firefox) ];
        "Mod+C".spawn      = [ "google-chrome-stable" ];

        # Waybar toggle
        "Mod+B".spawn = [ "pkill" "-SIGUSR1" "waybar" ];

        # Window management
        "Mod+Q".close-window       = { };
        "Mod+Shift+E".quit         = { };

        # Focus (vim-style)
        "Mod+H".focus-column-left  = { };
        "Mod+L".focus-column-right = { };
        "Mod+J".focus-window-down  = { };
        "Mod+K".focus-window-up    = { };

        # Move (vim-style)
        "Mod+Shift+H".move-column-left  = { };
        "Mod+Shift+L".move-column-right = { };
        "Mod+Shift+J".move-window-down  = { };
        "Mod+Shift+K".move-window-up    = { };

        # Column width
        "Mod+Minus".set-column-width   = "-10%";
        "Mod+Equal".set-column-width   = "+10%";
        "Mod+Shift+F".maximize-column  = { };
        "Mod+Ctrl+F".fullscreen-window = { };

        # Screenshots (niri built-in, Wayland native)
        "Print".screenshot             = { };
        "Ctrl+Print".screenshot-screen = { };
        "Alt+Print".screenshot-window  = { };

        # Screen lock — swaylock replaces i3lock
        "Mod+Y".spawn = [ (lib.getExe pkgs.swaylock) "-c" "000000" ];

        # Media keys handled directly by niri (no swhkd yet)
        "XF86AudioRaiseVolume".spawn = [ (lib.getExe pkgs.pulsemixer) "--change-volume" "+5" ];
        "XF86AudioLowerVolume".spawn = [ (lib.getExe pkgs.pulsemixer) "--change-volume" "-5" ];
        "XF86AudioMute".spawn        = [ (lib.getExe pkgs.pulsemixer) "--toggle-mute" ];
      };
    };
  };

  services.kanshi = {
    enable = true;
    # Fill in output names after first boot: `niri msg outputs`
    profiles = {
      desk = {
        outputs = [
          { criteria = "TODO-4K-name"; scale = 1.5; }
          { criteria = "TODO-2K-name"; scale = 1.0; }
        ];
      };
      laptop = {
        outputs = [
          { criteria = "eDP-1"; scale = 1.5; }
        ];
      };
    };
  };

  home.packages = [ pkgs.wdisplays ]; # GUI display manager (wlr-based, may or may not work with niri)

  programs.waybar = {
    enable = true;
    settings.mainBar = {
      layer    = "top";
      position = "top";
      modules-left   = [ "niri/workspaces" ];
      modules-center = [ "clock" ];
      modules-right  = [ "pulseaudio" "battery" "cpu" "memory" "tray" ];

      "niri/workspaces".format = "{icon}";

      clock = {
        format         = "{:%Y-%m-%d %H:%M}";
        tooltip-format = "{calendar}";
      };

      pulseaudio = {
        format       = "♪ {volume}%";
        format-muted = "♪ muted";
        on-click     = "${lib.getExe pkgs.pulsemixer}";
      };

      battery = {
        format       = "{capacity}% {icon}";
        format-icons = [ "" "" "" "" "" ];
        states       = { warning = 30; critical = 15; };
      };

      cpu.format    = "CPU {usage}%";
      memory.format = "RAM {}%";
      tray.spacing  = 10;
    };

    style = ''
      * {
        font-family: monospace;
        font-size: 13px;
        border: none;
        border-radius: 0;
        margin: 0;
        padding: 0;
      }
      window#waybar {
        background: ${bg};
        color: ${fg};
      }
      #workspaces button {
        padding: 0 8px;
        color: ${accent};
      }
      #workspaces button.active {
        color: ${fg};
        border-bottom: 2px solid ${fg};
      }
      #clock, #battery, #cpu, #memory, #pulseaudio, #tray {
        padding: 0 10px;
        color: ${accent};
      }
      #battery.warning  { color: ${fg}; }
      #battery.critical { color: #816271; }
    '';
  };
}

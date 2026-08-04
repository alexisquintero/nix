{ config, pkgs, lib, ... }:

# NOT WIRED UP — to enable niri:
# 1. Import this file in home-alexisquintero.nix (instead of i3.nix)
# 2. Disable xsession / i3 in linux.nix
# 3. Disable sxhkd service, enable swhkd (Wayland replacement, same config syntax)
# 4. Replace dunst with mako (Wayland notification daemon)
# 5. Remove useX11LegacyScreenshot from flameshot settings (no longer needed)
# 6. Wallpaper: add swaybg or swww to spawn-at-startup

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
in
{
  programs.niri = {
    enable = true;
    settings = {
      prefer-no-csd = true;

      screenshot-path = "~/Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png";

      input = {
        # Derived from home.keyboard — single source of truth
        keyboard.xkb = {
          layout  = config.home.keyboard.layout;
          variant = config.home.keyboard.variant;
          options = builtins.concatStringsSep "," config.home.keyboard.options;
        };
        touchpad = {
          tap            = true;
          natural-scroll = true;
        };
      };

      layout = {
        gaps = 8;
        center-focused-column = "never";
        default-column-width.proportion = 0.5;
        focus-ring = {
          enable         = true;
          width          = 2;
          active-color   = accent;
          inactive-color = bg;
        };
      };

      spawn-at-startup = [
        { command = [ "${waybar-hidden}/bin/waybar-hidden" ]; }
        { command = [ (lib.getExe pkgs.fcitx5) "--replace" "-d" ]; }
      ];

      binds = with config.lib.niri.actions;
        let
          workspaceBinds = lib.listToAttrs (
            lib.concatMap (n: [
              (lib.nameValuePair "Mod+${toString n}"       { action = focus-workspace n; })
              (lib.nameValuePair "Mod+Shift+${toString n}" { action = move-column-to-workspace n; })
            ]) (lib.range 1 12)
          );
        in
        workspaceBinds // {
          # Terminal & apps
          "Mod+Return".action = spawn (lib.getExe pkgs.kitty);
          "Mod+F".action      = spawn (lib.getExe pkgs.firefox);
          "Mod+C".action      = spawn "google-chrome-stable";

          # Waybar toggle
          "Mod+B".action = spawn "pkill" "-SIGUSR1" "waybar";

          # Window management
          "Mod+Q".action       = close-window;
          "Mod+Shift+E".action = quit;

          # Focus (vim-style)
          "Mod+H".action = focus-column-left;
          "Mod+L".action = focus-column-right;
          "Mod+J".action = focus-window-down;
          "Mod+K".action = focus-window-up;

          # Move (vim-style)
          "Mod+Shift+H".action = move-column-left;
          "Mod+Shift+L".action = move-column-right;
          "Mod+Shift+J".action = move-window-down;
          "Mod+Shift+K".action = move-window-up;

          # Column width
          "Mod+Minus".action   = set-column-width "-10%";
          "Mod+Equal".action   = set-column-width "+10%";
          "Mod+Shift+F".action = maximize-column;
          "Mod+Ctrl+F".action  = fullscreen-window;

          # Screenshots (niri built-in, Wayland native)
          "Print".action      = screenshot;
          "Ctrl+Print".action = screenshot-screen;
          "Alt+Print".action  = screenshot-window;

          # Screen lock — swaylock replaces i3lock
          "Mod+Y".action = spawn "${lib.getExe pkgs.swaylock}" "-c" "000000";

          # Media keys handled by swhkd — not duplicated here
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

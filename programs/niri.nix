{ config, pkgs, lib, ... }:

let
  bg = "#0f2a3f";
  fg = "#f6d6bd";
  accent = "#c3a38a";

  waybar-hidden = pkgs.writeShellScriptBin "waybar-hidden" ''
    waybar &
    sleep 0.5
    pkill -SIGUSR1 waybar
  '';
in
{
  wayland.windowManager.niri = {
    enable = true;
    package = pkgs.niri;

    settings = {
      prefer-no-csd = { };
      screenshot-path = "~/Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png";
      
      input = {
        keyboard.xkb = {
          layout = config.home.keyboard.layout;
          variant = config.home.keyboard.variant;
          options = builtins.concatStringsSep "," config.home.keyboard.options;
        };
        touchpad = {
          tap = { };
          natural-scroll = { };
        };
      };

      layout = {
        gaps = 8;
        center-focused-column = "never";
        default-column-width.proportion = 0.5;
        
        focus-ring = {
          # FIXED: Niri needs an empty set to map flat options
          enable = { }; 
          width = 2;
          active-color = accent;
          inactive-color = bg;
        };
      };

      # FIXED: The official way to pass duplicate lines via Home Manager
      spawn-at-startup._children = [
        { _args = [ "${waybar-hidden}/bin/waybar-hidden" ]; }
        { _args = [ (lib.getExe pkgs.fcitx5) "--replace" "-d" ]; }
      ];

      binds =
        let
          workspaceBinds = lib.listToAttrs (
            lib.concatMap (n: [
              (lib.nameValuePair "Mod+${toString n}"       { focus-workspace = n; })
              (lib.nameValuePair "Mod+Shift+${toString n}" { move-column-to-workspace = n; })
            ]) (lib.range 1 12)
          );
        in
        workspaceBinds // {
          "Mod+Return".spawn = [ (lib.getExe pkgs.kitty) ];
          "Mod+F".spawn      = [ (lib.getExe pkgs.firefox) ];
          "Mod+C".spawn      = [ "google-chrome-stable" ];
          "Mod+B".spawn      = [ "pkill" "-SIGUSR1" "waybar" ];

          "Mod+Q".close-window       = { };
          "Mod+Shift+E".quit         = { };

          "Mod+H".focus-column-left  = { };
          "Mod+L".focus-column-right = { };
          "Mod+J".focus-window-down  = { };
          "Mod+K".focus-window-up    = { };

          "Mod+Shift+H".move-column-left  = { };
          "Mod+Shift+L".move-column-right = { };
          "Mod+Shift+J".move-window-down  = { };
          "Mod+Shift+K".move-window-up    = { };

          "Mod+Minus".set-column-width   = "-10%";
          "Mod+Equal".set-column-width   = "+10%";
          "Mod+Shift+F".maximize-column  = { };
          "Mod+Ctrl+F".fullscreen-window = { };

          "Print".screenshot             = { };
          "Ctrl+Print".screenshot-screen = { };
          "Alt+Print".screenshot-window  = { };

          "Mod+Y".spawn = [ (lib.getExe pkgs.swaylock) "-c" "000000" ];
        };
    };
  };

  # Your waybar configuration blocks below remain exactly the same...
  programs.waybar = {
    enable = true;
    settings.mainBar = {
      layer = "top";
      position = "top";
      modules-left = [ "niri/workspaces" ];
      modules-center = [ "clock" ];
      modules-right = [ "pulseaudio" "battery" "cpu" "memory" "tray" ];
      "niri/workspaces".format = "{icon}";
      clock = {
        format = "{:%Y-%m-%d %H:%M}";
        tooltip-format = "{calendar}";
      };
      pulseaudio = {
        format = "♪ {volume}%";
        format-muted = "♪ muted";
        on-click = "${lib.getExe pkgs.pulsemixer}";
      };
      battery = {
        format = "{capacity}% {icon}";
        format-icons = [ "" "" "" "" "" ];
        states = { warning = 30; critical = 15; };
      };
      cpu.format = "CPU {usage}%";
      memory.format = "RAM {}%";
      tray.spacing = 10;
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
      #battery.warning { color: ${fg}; }
      #battery.critical { color: #816271; }
    '';
  };
}

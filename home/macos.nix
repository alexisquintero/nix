{ config, lib, pkgs, ... }:

{
  programs.kitty.settings = {
    hide_window_decorations = "titlebar-only";
    # Left Option acts as Alt inside Kitty (enables Alt+C for fzf, bash Alt-editing);
    # right Option still types special characters.
    macos_option_as_alt = "left";
    # Quit a Kitty instance when its last window closes (via Ctrl+C/Ctrl+D), so
    # drained instances don't linger as Cmd+Tab ghosts.
    macos_quit_when_last_window_closed = "yes";
    # macOS renders font sizes in points, and points map to physical pixels
    # differently per-display: 1pt = 2px on the built-in Retina screen but
    # 1pt = 1px on the non-Retina MAG274QRF-QD external monitor. Kitty has no
    # per-monitor font size, so this value is a compromise: bumped up from the
    # shared "9" so it's readable on the external display, at the cost of
    # being slightly larger than ideal on the built-in Retina screen.
    font_size = lib.mkForce "11";
  };

  # Store git HTTPS credentials in the macOS Keychain (auth once, reused silently).
  programs.git.settings.credential.helper = "osxkeychain";

  xdg.configFile."karabiner/karabiner.json".source = ../karabiner/karabiner.json;

  home.file.".hammerspoon/init.lua".source = ../hammerspoon/init.lua;
  home.file.".hammerspoon/modules" = {
    recursive = true;
    source = ../hammerspoon/modules;
  };

  home.file.".Brewfile".source = ../Brewfile;

  home.file.".hushlogin".text = "";

  programs.sketchybar = {
    enable = true;
    extraPackages = [ pkgs.jq ];
    config = {
      source = ../sketchybar;
      recursive = true;
    };
  };

  programs.bash.shellAliases = {
    brewsync = "brew bundle --global";
    brewclean = "brew bundle --global cleanup";
    ls = "${pkgs.coreutils}/bin/ls --color=auto";
    o = "open";
  };

  home.sessionVariables = {
    HOMEBREW_CASK_OPTS = "--appdir=${config.home.homeDirectory}/Applications";
  };

  imports = [
    ../private-macos.nix
  ];
}

{ config, pkgs, ... }:

{
  programs.kitty.settings = {
    shell = "${pkgs.bash}/bin/bash";
    hide_window_decorations = "titlebar-only";
    # Left Option acts as Alt inside Kitty (enables Alt+C for fzf, bash Alt-editing);
    # right Option still types special characters.
    macos_option_as_alt = "left";
    # Quit a Kitty instance when its last window closes (via Ctrl+C/Ctrl+D), so
    # drained instances don't linger as Cmd+Tab ghosts.
    macos_quit_when_last_window_closed = "yes";
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

  programs.bash.shellAliases = {
    brewsync = "brew bundle --global";
    brewclean = "brew bundle --global cleanup";
  };

  home.sessionVariables = {
    HOMEBREW_CASK_OPTS = "--appdir=${config.home.homeDirectory}/Applications";
  };

  imports = [
    ../private-macos.nix
  ];
}

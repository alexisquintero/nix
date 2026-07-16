{ config, pkgs, ... }:

{
  programs.kitty.settings = {
    shell = "${pkgs.bash}/bin/bash";
    hide_window_decorations = "titlebar-only";
    # Left Option acts as Alt inside Kitty (enables Alt+C for fzf, bash Alt-editing);
    # right Option still types special characters. Kitty-only; no effect on Linux.
    macos_option_as_alt = "left";
    # Quit a Kitty instance when its last window closes (via Ctrl+C/Ctrl+D), so
    # drained instances don't linger as Cmd+Tab ghosts.
    macos_quit_when_last_window_closed = "yes";
  };

  # Store git HTTPS credentials in the macOS Keychain (auth once, reused silently).
  programs.git.settings.credential.helper = "osxkeychain";

  home.sessionVariables = {
    # Install Homebrew casks into the user-writable ~/Applications to avoid sudo.
    HOMEBREW_CASK_OPTS = "--appdir=${config.home.homeDirectory}/Applications";
  };

  imports = [
    ../private-macos.nix
  ];
}

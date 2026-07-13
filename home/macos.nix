{ pkgs, ... }:

{
  programs.kitty.settings = {
    shell = "${pkgs.bash}/bin/bash";
    hide_window_decorations = "titlebar-only";
  };

  imports = [
    ../private-macos.nix
  ];
}

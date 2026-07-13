{ pkgs, ... }:

{
  programs.kitty.settings.shell = "${pkgs.bash}/bin/bash";

  imports = [
    ../private-macos.nix
  ];
}

{ ... }:

{
  programs.kitty.package = null;

  imports = [
    ../private-macos.nix
  ];
}

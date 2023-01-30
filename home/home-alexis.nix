{ pkgs, ... }:

{
  home = {
    username = "alexis";
    homeDirectory = "/home/alexis";

    packages = (with pkgs; [
      i3lock
    ]);
  };

  imports = [
    ./home.nix
    ../programs/xmonad.nix
  ];
}

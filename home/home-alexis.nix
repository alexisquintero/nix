{ pkgs, ... }:

{
  home = {
    username = "alexis";
    homeDirectory = "/home/alexis";

    packages = (with pkgs; [
      i3lock
    ]);
  };

  programs = {
    git.userEmail = "alexis_quintero@hotmail.com.ar";
  };

  imports = [
    ./home.nix
    ../programs/xmonad.nix
  ];
}

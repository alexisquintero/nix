{ pkgs, dotfiles, ... }:

{
  home = {
    username = "alexis";
    homeDirectory = "/home/alexis";
  };

  imports = [
    ./home.nix
    ../programs/xmonad.nix
  ];

  programs = {
    git.userEmail = "alexis_quintero@hotmail.com.ar";
  };
}

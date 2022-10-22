{ ... }:

{
  targets.genericLinux.enable = true;

  programs = {
    git.userEmail = "alexis.quintero@paidy.com";
  };

  home = {
    username = "alexis.quintero";
    homeDirectory = "/home/alexis.quintero";
  };

  imports = [
    ./home.nix
    ../programs/xmonad.nix
    ../other/4k.nix
    ../programs/kitty.nix
  ];

}


{ ... }:

{
  home = {
    username = "alexis";
    homeDirectory = "/home/alexis";
  };

  programs = {
    git.userEmail = "alexis_quintero@hotmail.com.ar";
  };

  imports = [
    ./home.nix
    ../programs/xmonad.nix
  ];

}

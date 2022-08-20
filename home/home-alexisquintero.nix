{ pkgs, ... }:

{
  targets.genericLinux.enable = true;
  home = {
    username = "alexis.quintero";
    homeDirectory = "/home/alexis.quintero";
  };

  imports = [
    ./home.nix
    ../programs/i3.nix
  ];

  xsession.windowManager.i3.enable = true;
}

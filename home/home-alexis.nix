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

  services = {
    screen-locker = {
      enable = true;
      inactiveInterval = 5;
      lockCmd = "${pkgs.i3lock}/bin/i3lock -c 000000 ;${pkgs.xorg.xset}/bin/xset dpms force off";
    };
  };

  xsession.windowManager.xmonad.enable = true;
}

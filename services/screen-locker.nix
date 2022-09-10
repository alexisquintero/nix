{ pkgs, ... }:

{
  home = {
    packages = (with pkgs; [
      i3lock
    ]);
  };

  services = {
    screen-locker = {
      enable = true;
      inactiveInterval = 10;
      lockCmd = "${pkgs.i3lock}/bin/i3lock -c 000000 ;${pkgs.xorg.xset}/bin/xset dpms force off";
    };
  };
}


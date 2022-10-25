{ pkgs, ... }:

{
  services = {
    screen-locker = {
      enable = true;
      inactiveInterval = 10;
      lockCmd = "i3lock -c 000000 ;xset dpms force off";
    };
  };
}


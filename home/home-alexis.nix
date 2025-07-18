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

  services = {
    sxhkd = {
      enable = true;
      keybindings = {
        "XF86KbdBrightness{Up,Down}" = "light -s sysfs/leds/asus::kbd_backlight -{A,U} 50";
      };
    };
  };
}

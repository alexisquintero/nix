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
        "XF86KbdBrightness{Up,Down}" = "brightnessctl -d asus::kbd_backlight set 50%{+,-}";
      };
    };
  };
}

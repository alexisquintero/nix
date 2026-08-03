{ pkgs, ... }:

{
  home = {
    username = "alexis";
    homeDirectory = "/home/alexis";

    packages = with pkgs; [
      swaylock
    ];
  };

  imports = [
    ./shared.nix
    ./linux.nix
    ../programs/niri.nix
  ];

  # sxhkd disabled — X11 only, no swhkd in nixpkgs yet
  # keyboard brightness: "XF86KbdBrightness{Up,Down}" = "brightnessctl -d asus::kbd_backlight set 50%{+,-}"
}

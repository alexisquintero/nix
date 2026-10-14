{ pkgs, lib, ... }:

{
  home = {
    username = "alexis";
    homeDirectory = "/home/alexis";

    packages = (with pkgs; [
      i3lock
      rawtherapee
      art
      swaylock
    ]);
  };

  imports = [
    ./shared.nix
    ./linux.nix
    ../programs/niri.nix
  ];

  # linux.nix enables sxhkd (X11-only) for all profiles that import it; niri
  # handles its own keybinds directly under Wayland, and sxhkd can't connect
  # to a display here, so disable it for this profile.
  # swhkd (the Wayland sxhkd equivalent) isn't in nixpkgs yet.
  services.sxhkd.enable = lib.mkForce false;
  # keyboard brightness (was an sxhkd binding): "XF86KbdBrightness{Up,Down}" =
  # "brightnessctl -d asus::kbd_backlight set 50%{+,-}"
}

{ pkgs, lib, ... }:

{
  targets.genericLinux.enable = true;

  home = {
    username = "alexis.quintero";
    homeDirectory = "/home/alexis.quintero";

    packages = (with pkgs; [
      fd
      jq
    ]);
  };

  services = {
    picom.enable = true;

    dunst.settings.global = {
      font               = lib.mkForce "Monospace 12";
      height             = lib.mkForce "(0, 150)";
      width              = lib.mkForce 500;
      padding            = lib.mkForce 12;
      horizontal_padding = lib.mkForce 12;
    };
  };

  imports = [
    ./shared.nix
    ./linux.nix
    ../programs/i3.nix
  ];

}

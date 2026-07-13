{ pkgs, ... }:

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
  };

  imports = [
    ./shared.nix
    ./linux.nix
    ../programs/i3.nix
    ../other/4k.nix
  ];

}

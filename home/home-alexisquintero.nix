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

  programs = {
    git.userEmail = "alexis.quintero@paidy.com";
  };

  imports = [
    ./home.nix
    ../programs/i3.nix
    ../other/4k.nix
  ];

}

{ ... }:

{
  targets.genericLinux.enable = true;
  home = {
    username = "alexis.quintero";
    homeDirectory = "/home/alexis.quintero";
  };

  imports = [
    ./home.nix
    ../programs/i3.nix
    ../other/4k.nix
  ];

  programs = {
    git.userEmail = mkForce "alexis.quintero@paidy.com";
  };
}

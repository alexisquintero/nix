{ ... }:

{
  targets.genericLinux.enable = true;
  home = {
    username = "alexis.quintero";
    homeDirectory = "/home/alexis.quintero";
  };

  imports = [
    ./home.nix
  ];
}

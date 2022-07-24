{ ... }:

{
  targets.genericLinux.enable = true;
  home = {
    username = "PAIDY-SECURITY-\alexis.quintero";
    homeDirectory = "/home/alexis.quintero";
  };

  imports = [
    ./home.nix
  ];
}

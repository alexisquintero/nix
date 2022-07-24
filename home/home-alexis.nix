{ ... }:

{
  home = {
    username = "alexis";
    homeDirectory = "/home/alexis";
  };

  imports = [
    ./home.nix
  ];
}

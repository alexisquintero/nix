{ pkgs, ... }:

{
  home = {
    username = "alequintero";
    homeDirectory = "/Users/alequintero";

    packages = with pkgs; [
      fd
      jq
    ];
  };

  imports = [
    ./shared.nix
    ./macos.nix
  ];
}

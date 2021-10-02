{ pkgs ? import <nixpkgs> { } }:

# nix --experimental-features 'nix-command flakes' flake init

pkgs.mkShell {
  name = "Flakes";
  buildInputs = with pkgs; [
    nixFlakes
  ];
}

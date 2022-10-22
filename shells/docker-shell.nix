{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  nativeBuildInputs = (with pkgs; [
    nodePackages.dockerfile-language-server-nodejs
  ]);
}



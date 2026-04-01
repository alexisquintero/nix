{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  nativeBuildInputs = (with pkgs; [
    dockerfile-language-server
  ]);
}



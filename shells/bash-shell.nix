{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  nativeBuildInputs = (with pkgs; [
    bash-language-server
    shellcheck
  ]);
}


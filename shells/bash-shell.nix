{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  nativeBuildInputs = (with pkgs; [
    nodePackages.bash-language-server
    shellcheck
  ]);
}


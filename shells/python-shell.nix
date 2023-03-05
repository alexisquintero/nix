{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  nativeBuildInputs = (with pkgs; [
    pyright
    python3
  ]);
}


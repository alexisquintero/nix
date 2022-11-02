{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  nativeBuildInputs = (with pkgs; [
    rustc
    rust-analyzer
    cargo
  ]);
}


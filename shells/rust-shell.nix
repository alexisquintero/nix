{ pkgs, ... }:

pkgs.mkShell {
  nativeBuildInputs = (with pkgs; [
    rustc
    rust-analyzer
    cargo
    rustfmt
  ]);
}


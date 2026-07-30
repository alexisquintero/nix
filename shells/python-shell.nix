{ pkgs, ... }:

pkgs.mkShell {
  nativeBuildInputs = (with pkgs; [
    pyright
    python3
  ]);
}


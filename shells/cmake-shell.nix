{ pkgs, ... }:

pkgs.mkShell {
  nativeBuildInputs = (with pkgs; [
    cmake-language-server
  ]);
}


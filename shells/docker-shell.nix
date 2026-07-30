{ pkgs, ... }:

pkgs.mkShell {
  nativeBuildInputs = (with pkgs; [
    dockerfile-language-server
  ]);
}



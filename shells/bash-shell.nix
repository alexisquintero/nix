{ pkgs, ... }:

pkgs.mkShell {
  nativeBuildInputs = (with pkgs; [
    bash-language-server
    shellcheck
  ]);
}


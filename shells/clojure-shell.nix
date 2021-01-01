{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  shellHook = ''
    export PS1_PRE="N\ "
  '';

  nativeBuildInputs = (with pkgs; [
    clojure
    leiningen
    clojure-lsp
    openjdk
  ]);
}

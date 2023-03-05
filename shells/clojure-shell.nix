{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  nativeBuildInputs = (with pkgs; [
    clojure
    leiningen
    clojure-lsp
    openjdk
    python3 # fireplace
  ]);
}

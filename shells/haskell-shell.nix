{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  nativeBuildInputs = (with pkgs; [
    ghc
    stack
    haskellPackages.haskell-language-server
  ]);
}

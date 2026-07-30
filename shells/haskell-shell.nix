{ pkgs, ... }:

pkgs.mkShell {
  nativeBuildInputs = (with pkgs; [
    ghc
    stack
    hlint
    haskellPackages.haskell-language-server
  ]);
}

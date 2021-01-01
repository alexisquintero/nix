{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  shellHook = ''
    export PS1_PRE="N\ "
  '';

  nativeBuildInputs = (with pkgs; [
    ghc
    stack
    haskellPackages.haskell-language-server
  ]);
}

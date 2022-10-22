{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  nativeBuildInputs = (with pkgs; [
    nodePackages.typescript-language-server
    nodePackages.typescript
  ]);
}



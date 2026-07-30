{ pkgs, ... }:

pkgs.mkShell {
  nativeBuildInputs = (with pkgs; [
    typescript-language-server
    typescript
  ]);
}



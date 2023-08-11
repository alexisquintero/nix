{ pkgs, ... }:

let
  glWrap = (pkg: (name: pkgs.writeShellScriptBin "${name}" ''
    ${pkgs.nixgl.auto.nixGLDefault}/bin/nixGL ${pkg}/bin/${name} "$@"
  ''));
in
{
  overlays = [
    (final: prev: {
      google-chrome = (glWrap pkgs.google-chrome "google-chrome");
    })
  ];

  programs = {
    kitty = {
      package = (glWrap pkgs.kitty "kitty");
    };
  };
}


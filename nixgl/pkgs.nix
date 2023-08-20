{ pkgs, nixgl, ... }:

let
  glWrap = (pkg: name: pkgs.writeShellScriptBin "${name}" ''
    ${pkgs.nixgl.auto.nixGLDefault}/bin/nixGL ${pkg}/bin/${name} "$@"
  '');
in
{
  overlays = [
    nixgl.overlay
    (final: prev: {
      google-chrome = (glWrap prev.google-chrome "google-chrome");
    })
  ];

  programs = {
    kitty = {
      package = (glWrap pkgs.kitty "kitty");
    };
  };
}


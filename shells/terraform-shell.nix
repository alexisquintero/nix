{ pkgs ? import <nixpkgs> { }, version ? "" }:

let
  versionAttrs = {
    "12" = {
      version = "0.12.31";
      sha256 = "sha256-z50WYdLz/bOhcMT7hkgaz35y2nVho50ckK/M1TpK5g4=";
    };
    "13" = {
      version = "0.13.7";
      sha256 = "sha256-z50WYdLz/bOhcMT7hkgaz35y2nVho50ckK/M1TpK5g4=";
    };
    "14" = {
      version = "0.14.11";
      sha256 = "sha256-z50WYdLz/bOhcMT7hkgaz35y2nVho50ckK/M1TpK5g4=";
    };
  };
  # sha256 seems to be borked

  terraformv =
    if "" == version then
      pkgs.terraform
    else
      pkgs.mkTerraform (builtins.getAttr version versionAttrs);
in
pkgs.mkShell {
  nativeBuildInputs = (with pkgs; [
    terraformv
    terraform-ls
  ]);
}

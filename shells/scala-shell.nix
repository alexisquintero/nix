{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  nativeBuildInputs = (with pkgs; [
    scala
    sbt
    coursier
    openjdk
    metals
  ]);
}

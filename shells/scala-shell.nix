{ pkgs ? import <nixpkgs> {} }:

let
  openjdk = pkgs.openjdk; # latest
  jdk8 = pkgs.jdk8;
  jdk11 = pkgs.jdk11;
  jdk = openjdk;
in
pkgs.mkShell {
  nativeBuildInputs = (with pkgs; [
    (scala.override { jre = jdk; })
    (sbt.override { jre = jdk; } )
    coursier
    jdk
    metals
  ]);
}

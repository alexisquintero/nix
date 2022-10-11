{ pkgs ? import <nixpkgs> {}, version ? "" }:

let
  jdk = pkgs."jdk${version}";
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

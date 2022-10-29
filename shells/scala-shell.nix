{ pkgs ? import <nixpkgs> {}, version ? "" }:

let
  jdkv = pkgs."jdk${version}";
in
pkgs.mkShell {
  nativeBuildInputs = (with pkgs; [
    (scala.override { jre = jdkv; })
    (sbt.override { jre = jdkv; } )
    coursier
    jdkv
    metals
  ]);
}

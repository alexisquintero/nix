{ pkgs ? import <nixpkgs> {}, version ? "" }:

let
  jdkpkg = pkgs."jdk${version}";
in
pkgs.mkShell {
  nativeBuildInputs = (with pkgs; [
    (scala.override { jre = jdkpkg; })
    (sbt.override { jre = jdkpkg; } )
    coursier
    jdkpkg
    metals
  ]);
}

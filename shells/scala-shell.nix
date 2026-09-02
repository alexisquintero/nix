{ pkgs, version ? "", multiverse, ... }:

let
  jdkv = pkgs."jdk${version}";
  mv = multiverse.multiverse.${pkgs.stdenv.hostPlatform.system};
  latestSbt1 = pkgs.lib.last (
    builtins.filter
      (v: builtins.head (pkgs.lib.splitVersion v) == "1")
      (mv.versionsOf "sbt")
  );
  sbtPkg =
    if version == ""
    then pkgs.sbt.override { jre = jdkv; }
    else (mv.version "sbt" latestSbt1).override { jre = jdkv; };
in
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    (scala.override { jre = jdkv; })
    sbtPkg
    coursier
    jdkv
    metals
  ];
}

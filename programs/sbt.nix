{ ... }:

{
  home.file.".sbt/1.0/global.sbt".text = ''
    testOptions += Tests.Argument(TestFrameworks.ScalaTest, "-oS")
  '';
}

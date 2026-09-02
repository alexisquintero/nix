{ pkgs, version ? "", multiverse, ... }:

let
  mv = multiverse.multiverse.${pkgs.stdenv.hostPlatform.system};
  terraformv =
    if version == ""
    then pkgs.terraform
    else mv.latest."terraform_0_${version}";
in
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    terraformv
    terraform-ls
    saml2aws
  ];
}

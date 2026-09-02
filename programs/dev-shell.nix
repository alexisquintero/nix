{ pkgs, ... }:

let
  flakeUrl = "github:alexisquintero/nix?dir=shells";

  dev-shell = pkgs.writeShellScriptBin "dev-shell" ''
    #!${pkgs.bash}/bin/bash
    nix develop ${flakeUrl}#"$1"
  '';

  dev-shell-completion = ''
    _dev_shell_completions() {
      local shells
      shells=$(nix eval ${flakeUrl}#devShells.${pkgs.stdenv.hostPlatform.system} \
        --apply builtins.attrNames --json 2>/dev/null \
        | tr -d '[]"' | tr ',' ' ')
      COMPREPLY=($(compgen -W "$shells" -- "''${COMP_WORDS[COMP_CWORD]}"))
    }
    complete -F _dev_shell_completions dev-shell
  '';
in
{
  home.packages = [ dev-shell ];
  programs.bash.initExtra = dev-shell-completion;
}

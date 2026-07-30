{ config, pkgs, ... }:

let
  git-compl-nixos-path = "/etc/profiles/per-user/${config.home.username}/share/bash-completion/completions/git";
  git-compl-profile-path = "${config.home.homeDirectory}/.nix-profile/share/bash-completion/completions/git";
  git-compl-path = if pkgs.stdenv.isDarwin || config.targets.genericLinux.enable
                   then git-compl-profile-path
                   else git-compl-nixos-path;
  source-git-compl = "[ -f ${git-compl-path} ] && source ${git-compl-path}\n";
  kitty-ssh-alias = ''
    [ "$TERM" = "xterm-kitty" ] && alias ssh="kitty +kitten ssh"
  '';

  bashrc-extra = ''
    set -o vi
    stty -ixon                          # Disable ctrl-s and ctrl-q.

    [ -f "$HOME"/.config/git/git-prompt.sh ] && source "$HOME"/.config/git/git-prompt.sh
    GIT_PS1_SHOWDIRTYSTATE=1
    GIT_PS1_SHOWUNTRACKEDFILES=1
    GIT_PS1_SHOWUPSTREAM="auto"
    GIT_PS1_DESCRIBE_STYLE=default

    __prompt_command() {
      local EXIT="$?"
      local KHAKI='\001\e[38;2;195;163;138m\002'
      local BOLD='\[\e[1m\]'
      local RESET='\[\e[0m\]'
      local EXIT_CODE=""
      local NIX_SHELL_PROMPT=""

      [ $EXIT != 0 ] && EXIT_CODE='\[\e[0;31m\]' # Add red if exit code non 0

      [ -n "$IN_NIX_SHELL" ] && NIX_SHELL_PROMPT='N\ '

      PS1=""
      __git_ps1 "''${KHAKI}''${PS1_PRE}''${NIX_SHELL_PROMPT}" "''${BOLD}\u@\W''${PS1_POST} ''${EXIT_CODE}⬥''${RESET} " "%s "

      [[ ''${__new_wd:=$PWD} != $PWD ]] && ls -AF; __new_wd=$PWD # Calls `l` when changing directory
    }

    PROMPT_COMMAND=__prompt_command

    __git_complete g _git_main
  '';
in
{
  programs.bash = {
    enable = true;
    historyFile = "${config.xdg.configHome}/bash/bash_history";
    historyControl = [ "ignoredups" ];
    historySize = 100000;
    historyFileSize = 10000000;
    shellOptions = [ "autocd" "cdspell" "checkwinsize" "histappend" ];
    shellAliases = {
      ll = "ls -alF";
      la = "ls -A";
      l = "ls -AF";
      v = "nvim";
      g = "git";
      grep = "grep --color=auto";
    };
    initExtra =
      source-git-compl +
      kitty-ssh-alias +
      bashrc-extra;
  };

  programs.fzf.enableBashIntegration = true;
  programs.dircolors.enableBashIntegration = true;
}

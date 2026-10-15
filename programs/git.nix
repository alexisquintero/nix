{ pkgs, lib, ... }:

let
  logFormat = "log --pretty=format:'%C(yellow)%h %Cred%ad %<(20[ltrunc]) %Cblue%an%Cgreen%d %Creset%s. %b' --date=short";
in
{
  programs.git = {
    enable = true;
    settings = {
      user.name  = "Alexis Quintero";
      alias = {
        co = "checkout";
        br = "branch";
        s = "status";
        c = "commit";
        l = "${logFormat} -30";
        l2 = logFormat;
        f = "fetch";
        gud = "commit --amend --no-edit";
        r = "rebase";
        d = "diff";
        dm = ''!git rev-list --left-right --count "$(git symbolic-ref --short refs/remotes/origin/HEAD)"...HEAD'';
        fixup = ''
        !sha=$( git -c color.ui=always log --oneline -n 1000 | ${lib.getExe pkgs.fzf} +s --ansi --no-multi --prompt 'Fixup> ' ) && git commit --fixup "$\{sha%% *}"
        '';
      };

      rebase = {
        autoStash  = true;
        autoSquash = true;
      };

      diff = {
        colorMoved = "plain";
        algorithm  = "histogram";
      };

      rerere = {
        enabled    = true;
        autoupdate = true;
      };

      core = {
        fsmonitor      = true;
        untrackedCache = true;
      };

      push.autoSetupRemote = true;
      merge.conflictStyle  = "zdiff3";
      fetch.prune          = true;
      init.defaultBranch   = "main";
    };
    ignores = [
      "*.bloop"
      "*.metals"
      "*metals.sbt"
      "*.mill-version"
      ".direnv"
    ];
  };
}

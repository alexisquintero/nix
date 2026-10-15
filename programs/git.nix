{ pkgs, lib, ... }:

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
        l = "log --pretty=format:'%C(yellow)%h %Cred%ad %<(20[ltrunc]) %Cblue%an%Cgreen%d %Creset%s. %b' --date=short -30";
        l2 = "log --pretty=format:'%C(yellow)%h %Cred%ad %<(20[ltrunc]) %Cblue%an%Cgreen%d %Creset%s. %b' --date=short";
        f = "fetch";
        gud = "commit --amend --no-edit";
        r = "rebase";
        d = "diff";
        dm = ''!git rev-list --left-right --count "$(git symbolic-ref --short refs/remotes/origin/HEAD)"...HEAD'';
        fixup = ''
        !sha=$( git -c color.ui=always log --oneline -n 1000 | ${lib.getExe pkgs.fzf} +s --ansi --no-multi --prompt 'Fixup> ' ) && git commit --fixup "$\{sha%% *}"
        '';
      };
      rebase.autoStash    = true;
      rebase.autoSquash   = true;
      push.autoSetupRemote = true;
      diff.colorMoved     = "plain";
      diff.algorithm      = "histogram";
      merge.conflictStyle = "zdiff3";
      fetch.prune         = true;
      init.defaultBranch  = "main";
      rerere.enabled      = true;
      rerere.autoupdate   = true;
      core.fsmonitor      = true;
      core.untrackedCache = true;
    };
    ignores = [
      "*.bloop"
      "*.metals"
      "*.metals.sbt"
      "*metals.sbt"
      "*.mill-version"
      ".direnv"
    ];
  };
}

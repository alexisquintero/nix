{ ... }:

{
  programs.git = {
    enable = true;
    userName = "Alexis Quintero";
    aliases = {
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
      dm = "rev-list --left-right --count origin/master...HEAD";
      fixup = ''
        !sha=$( git -c color.ui=always log --oneline -n 1000 | fzf +s --ansi --no-multi --prompt 'Fixup> ' ) && git commit --fixup "$\{sha%% *}"
      '';
    };
    ignores = [
      "*.bloop"
      "*.metals"
      "*.metals.sbt"
      "*metals.sbt"
      "*.mill-version"
    ];
  };
}

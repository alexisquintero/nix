{ pkgs, ... }:

let

    st = pkgs.st.override {
      conf = builtins.readFile ./dotfiles/st/config.h;
    };

    tmux-conf = builtins.readFile ./dotfiles/.tmux.conf;

    dunstrc = builtins.readFile ./dotfiles/.config/dunst/dunstrc; # TODO: use

    i3config = builtins.readFile ./dotfiles/.config/i3/config;
    i3statusconfig = builtins.readFile ./dotfiles/.config/i3/i3status; # TODO: use

    readlinerc = builtins.readFile ./dotfiles/.config/readline/inputrc;

    bashrc = builtins.readFile ./dotfiles/.bashrc;
    profile = builtins.readFile ./dotfiles/.profile;

in
{

  home = {
    sessionVariables = {
      EDITOR = "vim";
      VISUAL = "vim";
      LESSHISTFILE="-";
      LIBGL_ALWAYS_INDIRECT="1";
    };

    packages = with pkgs; [
      st
      i3status
    ];
  };

  programs = {

    home-manager = {
      enable = true;
    };

    git = {
      enable = true;
      userName = "Alexis Quinntero";
      userEmail = "alexis_quintero@hotmail.com.ar";

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
        dd = "rev-list --left-right --count origin/develop...HEAD";
        fixup = "!sha=\$( git -c color.ui=always log --oneline -n 1000 | fzf +s --ansi --no-multi --prompt 'Fixup> ' ) && git commit --fixup \"\${sha%% *}\"";
      };
    };

    bash = {
      enable = true;
      historyFile = "\$HOME/.config/bash/bash_history"; # TODO: ues XDG_CONFIG_HOME or similar
      initExtra = bashrc;
      profileExtra = profile;
    };

    neovim = {
      enable = true;
      vimAlias = true;
      vimdiffAlias = true;
      withNodeJs = true;
    };

    fzf = {
      enable = true;
      enableBashIntegration = true;
    };

    tmux = {
      enable = true;
      extraConfig = tmux-conf;
    };

    # i3status = {
    #   enable = true;
    # };

    readline = {
      enable = true;
      extraConfig = readlinerc;
    };

    gpg = {
      enable = true;
    };

  };

  services = {

    gpg-agent = {
      enable = true;
      defaultCacheTtl = 1800;
      enableSshSupport = true;
    };

    dunst = {
      enable = true;
    };

  };

  xsession = {

    windowManager = {

      i3 = {
        enable = true;
        extraConfig = i3config;
      };

    };

  };

}

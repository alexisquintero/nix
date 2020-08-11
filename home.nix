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

in
{

  home = {

    keyboard = {
      layout = "us";
      variant = "altgr-intl";
    };

    sessionVariables =
    let
      is-wsl = "" != builtins.getEnv "WSL_DISTRO_NAME";
      wsl-env-vars = {
        LIBGL_ALWAYS_INDIRECT = "1";
        DISPLAY = "\$(awk '/nameserver / {print $2; exit}' /etc/resolv.conf 2>/dev/null):0";
      };
      extra-env-vars = if is-wsl then wsl-env-vars else {};
    in
    {
      EDITOR = "vim";
      VISUAL = "vim";
      LESSHISTFILE="-";
      XDG_DATA_DIRS="\$HOME/.nix-profile/share:\$XDG_DATA_DIRS";
    }
    //
    extra-env-vars;

    packages = with pkgs; [
      st
      dmenu
      dejavu_fonts
      keepass
      clojure-lsp
      rnix-lsp
      haskellPackages.xmobar
      # ripgrep # TODO: Vim fzf
    ];
  };

  xdg.enable = true;

  imports = [
    ./vim.nix
  ];

  programs = {

    home-manager = {
      enable = true;
    };

    git = {
      enable = true;
      userName = "Alexis Quinntero";
      userEmail = "alexis_quintero@hotmail.com.ar";
      ignores = [
        "*.bloop"
        "*.metals"
        "*.metals.sbt"
        "*metals.sbt"
        "*.mill-version"
      ];

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
      profileExtra = ''
        . $HOME/.nix-profile/etc/profile.d/nix.sh
      '';
    };

    fzf = {
      enable = true;
      enableBashIntegration = true;
    };

    tmux = {
      enable = true;
      extraConfig = tmux-conf;
    };

    readline = {
      enable = true;
      extraConfig = readlinerc;
    };

    gpg = {
      enable = true;
    };

    chromium = {
      enable = true;
      extensions = [
        "pkehgijcmpdhfbdbbnkijodmdjhbjlgp" # Privacy badger
        "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark reader
        "gcbommkclmclpchllfjekcdonpmejbdp" # HTTPS everywhere
        "immpkjjlgappgfkkfieppnmlhakdmaab" # Imagus
        "kbmfpngjjgdllneeigpgjifpgocmfgmb" # Res
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock origin
        "dgogifpkoilgiofhhhodbodcfgomelhe" # wasavi
        "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium
      ];
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

  xsession =
    let

      wmi3 = {
        enable = true;
        config = null;
        extraConfig = i3config;
      };

      wmxmonad = {
        enable = true;
        config = ./dotfiles/.xmonad/xmonad.hs;
        extraPackages = haskellPackages: [
          haskellPackages.xmonad-contrib
          haskellPackages.xmonad-extras
          haskellPackages.xmonad
        ];
      };

    in
    {

      windowManager = {
        # command = "exec xmonad"; # "${pkgs.xmonad}/bin/xmonad";
        # i3 = wmi3;
        xmonad = wmxmonad;
      };

  };

}

{ pkgs, ... }:

let

  st = pkgs.st.override {
    conf = builtins.readFile ./dotfiles/st/config.h;
  };

  comma = import ( pkgs.fetchFromGitHub {
    owner = "Shopify";
    repo = "comma";
    rev = "4a62ec17e20ce0e738a8e5126b4298a73903b468";
    sha256 = "0n5a3rnv9qnnsrl76kpi6dmaxmwj1mpdd2g0b4n1wfimqfaz6gi1";
  }) {};

  tmux-conf = builtins.readFile ./dotfiles/.tmux.conf;
  i3config = builtins.readFile ./dotfiles/.config/i3/config;
  readlinerc = builtins.readFile ./dotfiles/.config/readline/inputrc;
  bashrc = builtins.readFile ./dotfiles/.bashrc;

  is-wsl = "" != builtins.getEnv "WSL_DISTRO_NAME";

in
{

  targets.genericLinux.enable = is-wsl;

  fonts.fontconfig.enable = true;

  home = {

    username = "alexis";
    homeDirectory = "/home/alexis";
    stateVersion = "21.03";

    keyboard = {
      layout = "us";
      variant = "altgr-intl";
    };

    sessionVariables =
    let
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
      # XDG_DATA_DIRS="\$HOME/.nix-profile/share:\$XDG_DATA_DIRS";
    }
    //
    extra-env-vars;

    packages = (with pkgs; [
      dmenu
      dejavu_fonts
      keepass
      haskellPackages.xmobar
      rnix-lsp
      scala
      sbt
      clojure
      clojure-lsp
      leiningen
      ripgrep
      scrot
      mpv
      openjdk
      xsel
      ghc
      libnotify
      docker-compose
      haskellPackages.haskell-language-server
      pulsemixer
    ]) ++
    [
      st
      comma
    ];
  };

  xdg = {
    enable = true;
    configFile."dunst/dunstrc".source = ./dotfiles/.config/dunst/dunstrc;
    configFile."i3/i3status".source = ./dotfiles/.config/i3/i3status;
    configFile."xmobar/xmobarrc".source = ./dotfiles/.config/xmobar/xmobarrc;
  };

  imports = [
    ./vim.nix
  ];

  programs = {

    home-manager = {
      enable = true;
    };

    git = {
      enable = true;
      userName = "Alexis Quintero";
      userEmail = "alexis_quintero@hotmail.com.ar";
      ignores = [
        "*.bloop"
        "*.metals"
        "*.metals.sbt"
        "*metals.sbt"
        "*.mill-version"
      ];

      aliases =
        let
          formatLog = "log --pretty=format:'%C(yellow)%h %Cred%ad %<(20[ltrunc]) %Cblue%an%Cgreen%d %Creset%s. %b' --date=short";
          statusCompare = branch: "rev-list --left-right --count origin/${branch}...HEAD";
        in
        {
        co = "checkout";
        br = "branch";
        s = "status";
        c = "commit";
        l = "${formatLog} -30";
        l2 = "${formatLog}";
        f = "fetch";
        gud = "commit --amend --no-edit";
        r = "rebase";
        d = "diff";
        dm = statusCompare "master";
        dd = statusCompare "develop";
        fixup = "!sha=\$( git -c color.ui=always log --oneline -n 1000 | fzf +s --ansi --no-multi --prompt 'Fixup> ' ) && git commit --fixup \"\${sha%% *}\"";
      };
    };

    bash = {
      enable = true;
      historyFile = "\$HOME/.config/bash/bash_history"; # TODO: ues XDG_CONFIG_HOME or similar
      initExtra = bashrc;
      profileExtra = if is-wsl then ''
        . $HOME/.nix-profile/etc/profile.d/nix.sh
      '' else "";
    };

    fzf = {
      enable = true;
      enableBashIntegration = true;
    };

    tmux = {
      enable = true;
      secureSocket = false;
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

    firefox = {
      enable = true;
    };

    dircolors = {
      enable = true;
      enableBashIntegration = true;
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

    xscreensaver = {
      enable = true;
    };

    redshift = {
      enable = true;
      brightness = {
        day = "0.7";
        night = "0.5";
      };
      latitude = "-32";
      longitude = "-60";
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

{ config, pkgs, lib, dotfiles, ... }:

let
  is-wsl = "" != builtins.getEnv "WSL_DISTRO_NAME";
in
{
  fonts.fontconfig.enable = true;

  home = {
    keyboard = {
      layout = "us";
      variant = "altgr-intl";
      options = [ "ctrl:nocaps" ];
    };

    sessionVariables = lib.mkIf is-wsl {
      LIBGL_ALWAYS_INDIRECT = "1";
      DISPLAY = "\$(awk '/nameserver / {print $2; exit}' /etc/resolv.conf 2>/dev/null):0";
    };

    packages = with pkgs; [
      ipafont
      keepass
      mpv
      xsel
      libnotify
      pulsemixer
      google-chrome
      bluetuith
      brightnessctl
    ];
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [ fcitx5-mozc ];
  };

  xdg.configFile = {
    "fcitx5/config".source = "${dotfiles}/.config/fcitx5/config";
    "fcitx5/profile".source = "${dotfiles}/.config/fcitx5/profile";
    "fcitx5/conf/xcb.conf".source = "${dotfiles}/.config/fcitx5/conf/xcb.conf";
  };

  imports = [
    ../services/screen-locker.nix
    ../private.nix
  ];

  programs = {
    firefox.enable = true;

    bash.profileExtra = lib.mkIf is-wsl ''
      . ${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.sh
    '';
  };

  services = {
    dunst = {
      enable = true;
      configFile = "${dotfiles}/.config/dunst/dunstrc";
    };

    redshift = {
      enable = true;
      settings.brightness = {
        day = "0.7";
        night = "0.5";
      };
      latitude = "36";
      longitude = "140";
    };

    xsuspender.enable = true;
    playerctld.enable = true;
    poweralertd.enable = true;
    cbatticon.enable = true;
    flameshot.enable = true;

    sxhkd = {
      enable = true;
      keybindings = {
        "XF86Audio{Raise,Lower}Volume" = "${lib.getExe pkgs.pulsemixer} --change-volume {+,-}5";
        "XF86AudioMute" = "${lib.getExe pkgs.pulsemixer} --toggle-mute";
        "XF86Audio{Play,Prev,Next}" = "${lib.getExe config.services.playerctld.package} {play-pause,previous,next}";
        "XF86TouchpadToggle" = "toggle-touchpad";
        "XF86MonBrightness{Up,Down}" = "brightnessctl set 10%{+,-}";
        "Print" = "${lib.getExe config.services.flameshot.package} screen";
        "Control_L + Print" = "${lib.getExe config.services.flameshot.package} gui";
        "super + {f,c}" = "{firefox,google-chrome-stable}";
        "super + y" = "i3lock -c 000000 ;xset dpms force off";
      };
    };
  };
}

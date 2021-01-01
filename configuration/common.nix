{ pkgs ? import <nixpkgs> {}, ... }:


{

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    grub.useOSProber = true;
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
  };

  networking = {
    networkmanager.enable = true;
    useDHCP = false;
    interfaces.wlp2s0.useDHCP = true;
  };

  time.timeZone = "America/Argentina/Buenos_Aires";

  environment.systemPackages = with pkgs; [
    wget vim
  ];

  sound = {
    enable = true;
  };

  hardware.pulseaudio.enable = true;

  i18n.defaultLocale = "en_US.UTF-8";

  services = {

    xserver = {
      layout = "us";
      xkbVariant = "altgr-intl";
      windowManager.xmonad = {
        enable = true;
        enableContribAndExtras = true;
        extraPackages = haskellPackages: [
          haskellPackages.xmonad-contrib
          haskellPackages.xmonad-extras
          haskellPackages.xmonad
        ];
      };
      displayManager.defaultSession = "none+xmonad";
    };

  };

  users.users.alexis = {
    isNormalUser = true;
    createHome = true;
    home = "/home/alexis";
    extraGroups = [ "wheel" "docker" "video" "audio" ];
  };

  virtualisation.docker.enable = true;

}

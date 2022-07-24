{ pkgs, ... }:

{

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    grub.useOSProber = true;
  };

  powerManagement = {
    enable = true;
  };

  networking = {
    networkmanager.enable = true;
    useDHCP = false;
    firewall.enable = true;
  };

  time = {
    timeZone = "America/Argentina/Buenos_Aires";
    hardwareClockInLocalTime = true;
  };

  environment = {
    systemPackages = with pkgs; [
      wget
      vim
    ];

    etc.hosts.mode = "0644";

  };

  sound = {
    enable = true;
  };

  hardware = {
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
      extraConfig = "load-module module-switch-on-connect";
    };
  };

  i18n.defaultLocale = "en_US.UTF-8";

  services = {
    xserver = {
      desktopManager.xterm.enable = true;
      enable = true;
    };
    thermald.enable = true;
  };

  users.users.alexis = {
    isNormalUser = true;
    createHome = true;
    home = "/home/alexis";
    extraGroups = [ "wheel" "docker" "video" "audio" ];
  };

  virtualisation.docker.enable = true;

}

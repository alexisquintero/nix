{ pkgs, ... }:

{

  nix = {
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
    firewall = {
      enable = true;
    };
  };

  time = {
    timeZone = "Asia/Tokyo";
    hardwareClockInLocalTime = true;
  };

  environment = {
    systemPackages = with pkgs; [
      wget
      vim
    ];

    etc.hosts.mode = "0644";

    pathsToLink = [ "/share/applications" "/share/xdg-desktop-portal" ];
  };

  hardware = {
    # pulseaudio = {
    #   enable = true;
    #   package = pkgs.pulseaudioFull;
    #   extraConfig = "load-module module-switch-on-connect";
    # };
  };

  i18n.defaultLocale = "en_US.UTF-8";

  services = {
    xserver = {
      # Keep xserver enabled for XWayland and hardware/driver setup
      enable = true;
    };
    thermald.enable = true;
  };

  # programs.niri sets up xdg.portal, display-manager session, gnome-keyring,
  # and systemd units automatically — see nixpkgs nixos/modules/programs/wayland/niri.nix
  programs.niri.enable = true;

  users.users.alexis = {
    isNormalUser = true;
    createHome = true;
    home = "/home/alexis";
    extraGroups = [ "wheel" "docker" "video" "audio" ];
  };

  virtualisation.docker.enable = true;

}

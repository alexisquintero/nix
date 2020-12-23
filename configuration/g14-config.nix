{ config, pkgs, ... }:

let
  nvidia = false;
  kernelPackages = pkgs.linuxPackages_latest;
  kernel = kernelPackages.kernel;

  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec -a "$0" "$@"
  '';

  toggle-touchpad = pkgs.writeShellScriptBin "toggle-touchpad" ''
    #!/run/current-system/sw/bin/bash
    #!${pkgs.bash}/bin/bash

    device=$(xinput list | grep -oP ".*Touchpad.*id=\K\d+")
    state=$(xinput list-props "$device" | grep "Device Enabled.*1$")

    [ -z "$state" ] && xinput --enable "$device" || xinput --disable "$device"
  '';

  buildAsusDkms = name: src: pkgs.stdenv.mkDerivation {
    inherit name src;
    nativeBuildInputs = [
      kernel.moduleBuildDependencies
    ];
    buildPhase = ''
      make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build M=$(pwd) modules
    '';
    installPhase = ''
      make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build M=$(pwd) INSTALL_MOD_PATH=$out modules_install
    '';
  };

  hid_asus_rog = buildAsusDkms "hid-asus-rog" (builtins.fetchGit {
    url = "https://gitlab.com/asus-linux/hid-asus-rog.git";
    ref = "main";
    rev = "c7af42151619cbd88d5eec718bd109f7a4d2636f";
  });

  asus_rog_nb_wmi = buildAsusDkms "asus-rog-nb-wmi" (builtins.fetchGit {
    url = "https://gitlab.com/asus-linux/asus-rog-nb-wmi.git";
    ref = "main";
    rev = "d57f78521a4a1cc974b4a1e01560e3b556cab174";
  });

in

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      ../asus-nb-ctrl/default.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      grub.useOSProber = true;
    };

    kernelPackages = kernelPackages;
    blacklistedKernelModules = [ "nouveau" "hid-asus" ];
    extraModulePackages = [ hid_asus_rog asus_rog_nb_wmi ];
    kernelModules = [ "hid-asus-rog" "asus-rog-nb-wmi" ];
  };

  powerManagement = {
    cpuFreqGovernor = "powersave";
  };

  # services.thermald.enable = true;

  networking = {
    hostName = "nixos-g14";
    networkmanager.enable = true;
    useDHCP = false;
    interfaces.wlp2s0.useDHCP = true;
  };

  time.timeZone = "America/Argentina/Buenos_Aires";

  environment.systemPackages = with pkgs; [
    wget vim
  ] ++ [
    nvidia-offload toggle-touchpad
  ];

  sound = {
    enable = true;
  };

  hardware = {

    pulseaudio.enable = true;

    nvidia = pkgs.lib.mkIf nvidia {
      modesetting.enable = true;
      powerManagement.enable = true;
      # powerManagement.finegrained = true;
      prime = {
        # amdgpuBusId = "PCI:4:0:0";
        nvidiaBusId = "PCI:1:0:0";
        offload.enable = true;
        # sync.enable = true;  # Do all rendering on the dGPU
      };
    };

    opengl = {
      enable = true;
      driSupport32Bit = true;
    };

  };

  services = {
    udev.extraRules = pkgs.lib.mkIf (!nvidia) ''
      # Remove nVidia devices, when present.
      ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{remove}="1"
    '';

    xserver = {
      videoDrivers = [ (if nvidia then "nvidia" else "amdgpu") ];
      enable = true;
      layout = "us";
      xkbVariant = "altgr-intl";
      libinput = {
        enable = true;
        disableWhileTyping = true;
      };
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

  i18n.defaultLocale = "en_US.UTF-8";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  users.users.alexis = {
    isNormalUser = true;
    createHome = true;
    home = "/home/alexis";
    extraGroups = [ "wheel" "docker" "video" "audio" ];
  };

  nix.allowedUsers = [ "alexis" ];

  virtualisation.docker.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  programs = {
    light.enable = true;
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}

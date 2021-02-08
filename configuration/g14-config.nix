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
    rev = "65a41f7eeba94c17db4e20ffb9815f07e475688a";
  });

  asus_rog_nb_wmi = buildAsusDkms "asus-rog-nb-wmi" (builtins.fetchGit {
    url = "https://gitlab.com/asus-linux/asus-rog-nb-wmi.git";
    ref = "main";
    rev = "976a28349443eb700f80a322f619ebb8f741894b";
  });

in

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      ./common.nix
      ../asus-nb-ctrl/default.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    kernelPackages = kernelPackages;
    blacklistedKernelModules = [ "nouveau" "hid-asus" ];
    extraModulePackages = [ hid_asus_rog asus_rog_nb_wmi ];
    kernelModules = [ "hid-asus-rog" "asus-rog-nb-wmi" ];
  };

  networking.hostName = "nixos-g14";

  environment.systemPackages = [
    nvidia-offload
    toggle-touchpad
  ];

  hardware = {

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

    tlp.enable = true;

    udev.extraRules = pkgs.lib.mkIf (!nvidia) ''
      # Remove nVidia devices, when present.
      ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{remove}="1"
    '';

    xserver = {
      videoDrivers = [ (if nvidia then "nvidia" else "amdgpu") ];
      enable = true;
      libinput = {
        enable = true;
        disableWhileTyping = true;
      };
    };

  };

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

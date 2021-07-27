{ config, pkgs, ... }:

let
  nvidia = false;
  kernelPackages = pkgs.linuxPackages_latest;
#  kernel = kernelPackages.kernel;

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

in

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      ./common.nix
      ../asusctl/default.nix
    ];

  nixpkgs.config.allowUnfree = true; # nvidia driver

  # Use the systemd-boot EFI boot loader.
  boot = {
    kernelPackages = kernelPackages;
    blacklistedKernelModules = [ "nouveau" ];
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

    bluetooth.enable = true;

  };

  services = {

    tlp.enable = true;

    udev = {
      extraRules = pkgs.lib.mkIf (!nvidia) ''
        # Remove nVidia devices, when present.
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{remove}="1"
      '';

      extraHwdb = ''
        evdev:input:b0003v0B05p1866*
          KEYBOARD_KEY_ff3100b2=home # Fn+Left
          KEYBOARD_KEY_ff3100b3=end  # Fn+Right
      '';
    };

    xserver = {
      # videoDrivers = [ "amdgpu" "nvidia" ];
      videoDrivers = [ "amdgpu" ];
      enable = true;
      libinput = {
        enable = true;
        touchpad.disableWhileTyping = true;
      };
    };

  };

  boot.initrd.luks.devices = {
    crypted = {
      device = "/dev/disk/by-uuid/b59aa862-7216-4682-862e-7b112c10df30";
      preLVM = true;
    };
  };

  programs = {
    light.enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}

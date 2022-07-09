{ config, pkgs, ... }:

let

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
      ./hardware-configuration.nix
      ../common.nix
    ];

  nixpkgs.config.allowUnfree = true; # nvidia driver

  boot = {
    blacklistedKernelModules = [ "nouveau" ];
  };

  networking = {
    hostName = "nixos-g14";
    interfaces.wlp2s0.useDHCP = true;
  };

  environment.systemPackages = [
    toggle-touchpad
  ];

  hardware = {

    opengl = {
      enable = true;
      driSupport32Bit = true;
    };

    bluetooth.enable = true;

    nvidia.powerManagement.finegrained = true;
  };

  services = {

    udev = {

      extraHwdb = ''
        evdev:input:b0003v0B05p1866*
          KEYBOARD_KEY_ff3100b2=home # Fn+Left
          KEYBOARD_KEY_ff3100b3=end  # Fn+Right
      '';
    };

    xserver = {
      libinput = {
        enable = true;
        touchpad.disableWhileTyping = true;
      };
    };

    power-profiles-daemon.enable = true;

    asusd.enable = true;

  };

  boot.initrd.luks.devices = {
    crypted = {
      device = "/dev/disk/by-uuid/b59aa862-7216-4682-862e-7b112c10df30";
      preLVM = true;
    };
  };

  programs = {
    light.enable = true;
    adb.enable = true;
    droidcam.enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}

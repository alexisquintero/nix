{ pkgs ? import <nixpkgs> {}, ...}:

let

  asus-nb-ctrl = import ../asus-nb-ctrl.nix { inherit pkgs; };

in {
  systemd.services.asusd = {
    serviceConfig = {
      Type = "dbus";
      BusName = "org.asuslinux.Daemon";
      ExecStart = "${asus-nb-ctrl}/bin/asusd";
    };

  };

  systemd.services.asusd = {
    enable = true;
  };

  systemd.services.asus-notify = {
    serviceConfig = {
      Type = "simple";
      # ExecStartPre = "${pkgs.sleep}/bin/sleep 2";
      ExecStart = "${asus-nb-ctrl}/bin/asus-notify";
      Restart = "on-failure";
      RestartSec = 1;
    };
  };

  systemd.services.asus-notify = {
    enable = true;
  };

}


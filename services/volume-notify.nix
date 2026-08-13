{ pkgs, lib, ... }:

let
  pactl       = lib.getExe' pkgs.pulseaudio "pactl";
  pulsemixer  = lib.getExe pkgs.pulsemixer;
  notify-send = lib.getExe pkgs.libnotify;

  volume-notify = pkgs.writeShellScriptBin "volume-notify" ''
    ${pactl} subscribe | while read -r line; do
      case "$line" in
        *"Event 'change' on sink"*)
          muted=$(${pulsemixer} --get-mute)
          if [ "$muted" = "1" ]; then
            ${notify-send} -u normal \
              -h string:x-dunst-stack-tag:volume \
              "Volume" "Muted"
          else
            vol=$(${pulsemixer} --get-volume | awk '{print $1}')
            ${notify-send} -u low \
              -h string:x-dunst-stack-tag:volume \
              "Volume" "''${vol}%"
          fi
          ;;
        *"Event 'change' on source"*)
          source=$(${pactl} get-default-source)
          if ! echo "$source" | grep -q "\.monitor"; then
            muted=$(${pactl} get-source-mute "$source" | awk '{print $2}')
            if [ "$muted" = "yes" ]; then
              ${notify-send} -u normal \
                -h string:x-dunst-stack-tag:mic \
                "Microphone" "Muted"
            else
              ${notify-send} -u critical \
                -h string:x-dunst-stack-tag:mic \
                "Microphone" "Unmuted"
            fi
          fi
          ;;
        *"Event 'change' on server"*)
          sink=$(${pactl} get-default-sink)
          name=$(${pactl} list sinks \
            | grep -A 30 "Name: $sink" \
            | grep "device.description" \
            | cut -d'"' -f2)
          [ -z "$name" ] && name="$sink"
          ${notify-send} -u critical \
            -h string:x-dunst-stack-tag:sink \
            "Audio Output" "$name"
          ;;
      esac
    done
  '';
in
{
  home.packages = [ volume-notify ];

  systemd.user.services.volume-notify = {
    Unit = {
      Description = "Volume change notification daemon";
      After       = [ "graphical-session.target" ];
      PartOf      = [ "graphical-session.target" ];
    };
    Service = {
      Type      = "simple";
      ExecStart = "${volume-notify}/bin/volume-notify";
      Restart   = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}

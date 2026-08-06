#!/bin/sh

# The volume_change event supplies a $INFO variable with the current volume
# percentage; on other triggers (e.g. --update at startup) query it directly.

if [ "$SENDER" = "volume_change" ]; then
  VOLUME="$INFO"
else
  VOLUME="$(osascript -e 'output volume of (get volume settings)')"
fi

sketchybar --set "$NAME" icon.drawing=off label="♪ ${VOLUME}%"

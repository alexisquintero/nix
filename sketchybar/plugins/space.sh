#!/bin/sh

# The space component always passes $SELECTED (true/false) and $SID, regardless
# of $SENDER. Occupancy ("does this space have any real windows") only arrives
# via the space_windows_change event ($INFO.space / $INFO.apps), so we persist
# it to a small state file and re-read it on every invocation (e.g. on plain
# selection changes, where we don't get fresh occupancy info).

STATE_DIR="/tmp/sketchybar_state"
mkdir -p "$STATE_DIR"
STATE_FILE="$STATE_DIR/space.$SID.occupied"

if [ "$SENDER" = "space_windows_change" ]; then
  space="$(echo "$INFO" | jq -r '.space')"
  if [ "$space" = "$SID" ]; then
    if [ "$(echo "$INFO" | jq -r '.apps | length > 0')" = "true" ]; then
      echo 1 > "$STATE_FILE"
    else
      echo 0 > "$STATE_FILE"
    fi
  fi
fi

occupied="$(cat "$STATE_FILE" 2>/dev/null || echo 0)"
# Note: this persists in /tmp across --reload, so a space keeps showing its
# last known occupancy until its next space_windows_change event fires. This
# is intentional (better a stale-but-likely-correct state than none).

# i3/xmonad palette: focused #4e495f/#c3a38a, inactive bg #0f2a3f/#816271.
if [ "$SELECTED" = "true" ]; then
  sketchybar --set "$NAME" background.drawing=on \
                           background.color=0xff4e495f \
                           icon.color=0xffc3a38a
elif [ "$occupied" = "1" ]; then
  sketchybar --set "$NAME" background.drawing=on \
                           background.color=0x300f2a3f \
                           icon.color=0xffe8dccf
else
  sketchybar --set "$NAME" background.drawing=off \
                           icon.color=0xff816271
fi

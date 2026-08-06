#!/bin/sh

PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"

if [ "$PERCENTAGE" = "" ]; then
  exit 0
fi

ICON="🔋"
if [ "$CHARGING" != "" ]; then
  ICON="🔌"
fi

sketchybar --set "$NAME" icon.drawing=off label="${ICON} ${PERCENTAGE}%"

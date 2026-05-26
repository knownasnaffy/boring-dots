#!/usr/bin/env bash

set -euo pipefail

ID_FILE="/tmp/battery_notify_id"

for bat in /sys/class/power_supply/*; do
  if [ "$(cat "$bat/type" 2>/dev/null)" = "Battery" ]; then
    BAT=$(cat "$bat/capacity")
    STATUS=$(cat "$bat/status")
    break
  fi
done

: "${BAT:?No battery found}"

if [ -f "$ID_FILE" ]; then
    ID=$(cat "$ID_FILE")
else
    ID=0
fi

if [ "$BAT" -le 15 ] && [ "$STATUS" = "Discharging" ]; then
  NEW_ID=$(
    notify-send \
      -u critical \
      -r "$ID" \
      -p \
      "Battery Critical" \
      "Battery at ${BAT}%"
  )

  paplay /usr/share/sounds/freedesktop/stereo/suspend-error.oga

  echo "$NEW_ID" > "$ID_FILE"

else
  if [ -f "$ID_FILE" ]; then
    notify-send \
      -u normal \
      -r "$ID" \
      -t 3000 \
      "Battery Stable" \
      "Battery at ${BAT}%"
    rm "$ID_FILE"
  fi
fi

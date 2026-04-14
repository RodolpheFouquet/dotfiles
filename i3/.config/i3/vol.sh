#!/bin/sh
if [ "$(uname)" = "FreeBSD" ]; then
    mixer vol | grep volume | cut -d= -f2 | cut -d: -f1 | xargs -I{} sh -c 'echo "{} * 100 / 1" | bc'
else
    wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%d", $2*100}'
fi

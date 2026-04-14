#!/bin/sh
if [ "$(uname)" = "FreeBSD" ]; then
    ifconfig wlan0 | grep 'inet ' | awk '{print $2}'
else
    ip -4 addr show wlp11s0 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1
fi

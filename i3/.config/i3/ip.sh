#!/bin/sh
if [ "$(uname)" = "FreeBSD" ]; then
    ifconfig | grep 'inet ' | awk '{print $2}' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' | grep -v '^127\.' | grep -v '^10\.'
else
    ip -4 addr show wlp11s0 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1
fi

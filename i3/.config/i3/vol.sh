#!/bin/sh
mixer vol | grep volume | cut -d= -f2 | cut -d: -f1 | xargs -I{} sh -c 'echo "{} * 100 / 1" | bc'

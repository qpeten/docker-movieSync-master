#!/bin/bash

transmission-daemon -f -g /transmission-config -e /dev/null &

/usr/bin/lua5.3 /movieSync.lua

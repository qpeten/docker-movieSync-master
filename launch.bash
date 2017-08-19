#!/bin/bash

/usr/bin/lua5.3 /movieSync.lua &
transmission-daemon -f -g /transmission-config

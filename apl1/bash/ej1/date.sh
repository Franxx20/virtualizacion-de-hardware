#!/bin/bash

echo "$1"
if [ -n "$1" ] && [ "$(date -d "$1" +%H:%M 2> /dev/null)" = "$1" ]; then
     echo 'This time is valid'
fi

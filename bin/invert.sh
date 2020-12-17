#!/bin/bash

sleep 4

if [ "$(pidof compton)" ];
    then
            pkill compton
    else
set -x
        ID=$(xdotool getactivewindow)
        CLASS=$(xprop -id "$ID"  | grep "WM_CLASS" | awk '{print $4}')
        COND="class_g=${CLASS}"
        echo compton --invert-color-include "$COND"
        compton --invert-color-include "$COND" &
fi
exit

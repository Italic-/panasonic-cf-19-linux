#!/bin/bash
# This script rotates the screen and touchscreen input 90 degrees each time it is called,
# also enables the virtual keyboard accordingly

# originally by Ruben Barkow: https://gist.github.com/rubo77/daa262e0229f6e398766
# adapted for Panasonic Toughbook CF-19 by nagyrobi

#### configuration
# find your Touchscreen  device with `xinput`

if [ "$1" = "--help"  ] || [ "$1" = "-h"  ] ; then
echo 'Usage: rotate-screen.sh [OPTION]'
echo
echo 'This script rotates the screen and touchscreen input 90 degrees each time it is called,'
echo 'also disables the touchpad, and enables the virtual keyboard accordingly'
echo
echo Available Flags:
echo ' -h --help display this help'
echo ' -n always rotates the screen back to normal'
echo ' -f (just horizontal) rotates the screen and touchscreen input only 180 degrees'
echo ' -l rotates the screen and touchscreen input 90 degrees counter-clockwise'
echo ' -r rotates the screen and touchscreen input 90 degrees clockwise'
exit 0
fi

TouchscreenDevice='Virtual core pointer'
DeviceList=(
    'Virtual core pointer'
    'Wacom ISDv4 93 Pad'
    'Wacom ISDv4 93 Pen stylus'
    'Wacom ISDv4 93 Pen eraser'
    'PS/2 Generic Mouse'
)

screenMatrix=$(xinput --list-props "$TouchscreenDevice" | awk '/Coordinate Transformation Matrix/{print $5$6$7$8$9$10$11$12$NF}')

# Matrix for rotation
# ⎡ 1 0 0 ⎤
# ⎜ 0 1 0 ⎥
# ⎣ 0 0 1 ⎦
normal='1 0 0 0 1 0 0 0 1'
normal_float='1.000000,0.000000,0.000000,0.000000,1.000000,0.000000,0.000000,0.000000,1.000000'

# Inverted (180°)
# ⎡ -1  0 1 ⎤
# ⎜  0 -1 1 ⎥
# ⎣  0  0 1 ⎦
inverted='-1 0 1 0 -1 1 0 0 1'
inverted_float='-1.000000,0.000000,1.000000,0.000000,-1.000000,1.000000,0.000000,0.000000,1.000000'

# 90° counter-clockwise
# ⎡ 0 -1 1 ⎤
# ⎜ 1  0 0 ⎥
# ⎣ 0  0 1 ⎦
left='0 -1 1 1 0 0 0 0 1'
left_float='0.000000,-1.000000,1.000000,1.000000,0.000000,0.000000,0.000000,0.000000,1.000000'

# 90° clockwise
# ⎡  0 1 0 ⎤
# ⎜ -1 0 1 ⎥
# ⎣  0 0 1 ⎦
right='0 1 0 -1 0 1 0 0 1'

function rot {
    for device in "${DeviceList[@]}"; do
        xinput set-prop "$device" 'Coordinate Transformation Matrix' $1
    done
}

if [[ "$1" == "-r" || \
   ( $screenMatrix == $normal_float && \
   "$1" != "-f" && \
   "$1" != "-l" && \
   "$1" != "-n" ) ]]; then
    echo "90° to the right"
    xrandr -o right
    rot "$right"
    killall xvkbd
    xvkbd &
# elif [ $screenMatrix == $right_float ] && \
#      [ "$1" != "-n" ] || \
#      [ "$1" == "-f" ]; then
#     # This is not desired on Panasonic CF-19, code left in if somebody still wants it
#     echo "Upside down"
#     xrandr -o inverted
#     rot "$inverted"
elif [[ "$1" == "-n" || \
     ( $screenMatrix == $left_float && \
     "$1" != "-f" && \
     "$1" != "-l" && \
     "$1" != "-r" ) ]]; then
    echo "Back to normal"
    killall xvkbd
    xrandr -o normal
    rot "$normal"
elif [[ "$1" == "-l" || \
     ( $screenMatrix == $right_float && \
     "$1" != "-f" && \
     "$1" != "-r" && \
     "$1" != "-n" ) || \
     ! "$1" ]]; then
    echo "90° to the left"
    xrandr -o left
    rot "$left"
    killall xvkbd
    xvkbd &
fi
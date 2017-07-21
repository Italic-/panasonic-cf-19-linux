#!/bin/bash
# This script toggles the appearance of the 'xvkbd' on-screen keyboard utility.
# Please make sure the filename of this script does not contain the 'xvkbd' string.
# For Panasonic Toughbook CF-19, to use with tablet buttons, provided by the modified panasonic-hbtn driver

if pgrep "xvkbd" > /dev/null 2>&1
then
    killall xvkbd
else
    xvkbd &
fi
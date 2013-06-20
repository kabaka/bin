#!/bin/bash

# Upload
sleep 0.1
scrot -s -e '~/projects/s3-file-bucket/s3up "$f" | xclip && rm "$f"' && firefox -new-tab "`xclip -o`"

# Local
#scrot -s '%s_$wx$h.png' -e 'mv $f ~/images/ss/ 2>/dev/null'
#notify-send 'Screen Shot' 'File to ~/images/ss/'
#firefox `xclip -o`
#feh `xclip -o`

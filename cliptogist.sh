#!/bin/zsh

RESULT=`xclip -o | gist --private -`
notify-send 'Clipboard to Gist' "Posted at $RESULT"
firefox $RESULT


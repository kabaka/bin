#!/bin/sh

#mencoder "$1" -o "$2" -of lavf -lavfopts format=asf -ovc lavc -lavcopts vcodec=wmv2:vbitrate=20000 -oac lavc -lavcopts acodec=wmav2
#mencoder "$1" -ffourcc XVID -ovc lavc -lavcopts vcodec=mpeg4:threads=8:vbitrate=20000:cmp=2:subcmp=2:trell=yes:v4mv=yes:mbd=2 -oac lavc -lavcopts acodec=ac3:abitrate=384 -channels 6 -o "$2"
mencoder "$1" -nosub -noautosub -ovc xvid -oac mp3lame -xvidencopts fixed_quant=2:threads=4 -alang en -o "$2"

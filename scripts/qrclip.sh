#!/bin/bash

out=/tmp/lastqr.png
out_info=/tmp/lastqr.ascii.info
out_clip=/tmp/lastqr.ascii.txt
last_clip="$(anamnesis -l 2 | sed -n 3p | awk -F, '{print $3}')" 
len=$(( ${#last_clip} - 2))
clip=${last_clip:3:$len}
clip=${clip::-2}

qrencode -s 4 -m 0 "$clip" -o $out

_to_ascii() {
    echo -e "QR: ${clip}\n" > $out_info
    exiv2 $out > /tmp/lastqr.info
    width=$(awk 'NR == 4' /tmp/lastqr.info | awk -F: '{print $2}' | awk -F' x ' '{print $2}')
    new_width=$(( width / 2 ))
    convert $out jpg:- | jp2a --chars=M. --width=${new_width} - > $out_clip
    sed -i 's/M/█/g' $out_clip 
    sed -i 's/\./ /g' $out_clip
}


case $1 in
  "kitty") 
    kitty +kitten icat $out
    ;;
  *)
    _to_ascii
    
    notify-send "$(cat $out_info)" "$(cat $out_clip)"
    ;;
esac

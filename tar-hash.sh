#!/bin/sh
IFS=''
if [ -d "$1" ]; then
        DIR="${1%/}"
        SIZE=`tar c "$DIR" | pv -c -S -s 4G -N "($DIR/)" | wc -c`
        #SIZE='4294967297'
        #echo $SIZE
        if [ "$SIZE" -ge "4294967296" ]; then
                # recursion
                ENTRYS=`ls -A -1 "$DIR"`
                echo "$ENTRYS" | while read ENTRY; do
                        $0 "$DIR/$ENTRY"
                done
        else
                # hash
                echo `tar c "$DIR" | pv -c -N "$DIR/" -s $SIZE | md5sum -b | awk '{ print $1 }'` $DIR/
        fi
else
        echo `pv -c -N "$1" "$1" | md5sum -b | awk '{ print $1 }'` $1
fi

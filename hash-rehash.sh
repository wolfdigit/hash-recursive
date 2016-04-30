#!/bin/bash
IFS=''
if [ -d "$1" ]; then
        DIR="${1%/}"
        if [ "x$2" = "x" ]; then
                SIZE=`tar c "$DIR" | pv -c -S -s 4G -N "($DIR/)" | wc -c`
        else
                if [ "x$2" = "xsm" ]; then
                        SIZE=0
                fi
                if [ "x$2" = "xbg" ]; then
                        SIZE=4294967296
                fi
        fi
        if [ "$SIZE" -ge "4294967296" ]; then
                # recursion
                ENTRYS=`ls -1 "$DIR"`
                echo "$ENTRYS" | while read ENTRY; do
                        $0 "$DIR/$ENTRY"
                done
        else
                # recursion-hash
                SUBS=""
                ENTRYS=`ls -1 "$DIR"`
                while read ENTRY; do
                if [ ! -z "$ENTRY" ]; then
                        SUB1=`$0 "$DIR/$ENTRY" sm`
                        if [ ! -z "$SUBS" ]; then
                                SUBS=`echo -e "$SUBS""\n""$SUB1"`
                        else
                                SUBS="$SUB1"
                        fi
                fi
                done <<< "$ENTRYS"
                #echo -e "VVV $DIR\n""$SUBS""\n^^^" 1>&2

                SIZE=0
                while read REC; do
                if [ ! -z "$REC" ]; then
                        #echo "$REC" 1>&2
                        SIZE1=`echo "$REC" | awk '{ print $2 }'`
                        SIZE=`echo $SIZE+$SIZE1 | bc`
                fi
                done <<< "$SUBS"
                echo -e `echo "$SUBS" | md5sum -b | awk '{ print $1 }'`"\t"$SIZE"\t"$DIR/
        fi
else
        # hash
        SIZE=`wc -c "$1" | awk '{ print $1 }'`
        if [ "$SIZE" -ge "10485760" ]; then
                echo -e `pv -c -N "$1" "$1" | md5sum -b | awk '{ print $1 }'`"\t"$SIZE"\t"$1
        else
                echo -e `md5sum -b "$1" | awk '{ print $1 }'`"\t"$SIZE"\t"$1
        fi
fi

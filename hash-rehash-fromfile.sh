#!/bin/bash
cat $1 | while read T; do
        ./hash-rehash.sh "$T"
done

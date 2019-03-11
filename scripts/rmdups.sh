#!/bin/bash
while IFS='' read -r line || [[ -n "$line" ]]; do
   echo -ne "$line" | cut -f1 | tr -d $'\n'; echo -ne "	";echo "$line" | cut -f2 | tr ',' '\n' | sort | uniq | xargs | sed 's/ /,/g' 
done < "$1"
